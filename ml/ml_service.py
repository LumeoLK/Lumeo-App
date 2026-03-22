import io
import os
import torch
import clip
import httpx
import numpy as np
import traceback
from PIL import Image
from fastapi import FastAPI, UploadFile, File, HTTPException
from fastapi.middleware.cors import CORSMiddleware
from sklearn.metrics.pairwise import cosine_similarity
from sklearn.cluster import KMeans
from contextlib import asynccontextmanager

#Configuration & Setup 
NODE_BACKEND_URL = os.getenv("NODE_BACKEND_URL", "https://lumeo-app.onrender.com")
device = "cuda" if torch.cuda.is_available() else "cpu"
model, preprocess = clip.load("ViT-B/32", device=device)

@asynccontextmanager
async def lifespan(app: FastAPI):
    # Initialize the HTTP client once for the app's lifetime
    app.requests_client = httpx.AsyncClient(timeout=30.0)
    yield
    await app.requests_client.aclose()

app = FastAPI(title="Lumeo ML Service", lifespan=lifespan)

app.add_middleware(
    CORSMiddleware,
    allow_origins=["*"],
    allow_methods=["*"],
    allow_headers=["*"],
)

# Helper Functions 

def analyze_image_features(image: Image.Image, remove_bg: bool = False):
    """
    Extracts CLIP embedding and dominant color.
    If remove_bg=True, it attempts to ignore corner colors (best for products).
    If remove_bg=False, it uses the whole image (best for room scans).
    """
    # CLIP Embedding
    img_input = preprocess(image).unsqueeze(0).to(device)
    with torch.no_grad():
        vector = model.encode_image(img_input)
        vector /= vector.norm(dim=-1, keepdim=True)
        embedding = vector.cpu().numpy().flatten().tolist()

    # Dominant Color (K-Means)
    img_small = image.resize((100, 100))
    pixels = np.array(img_small).reshape(-1, 3).astype(np.float32)
    
    target_pixels = pixels
    if remove_bg:
        # Detect background based on corners
        corners = pixels[[0, 99, 9900, 9999]]
        bg_color = corners.mean(axis=0)
        diff = np.linalg.norm(pixels - bg_color, axis=1)
        object_mask = diff > 40
        if object_mask.sum() > 50: # Only filter if we didn't remove everything
            target_pixels = pixels[object_mask]

    kmeans = KMeans(n_clusters=3, n_init=5, random_state=42)
    kmeans.fit(target_pixels)
    counts = np.bincount(kmeans.labels_)
    dominant_rgb = kmeans.cluster_centers_[np.argmax(counts)].astype(int).tolist()

    return embedding, dominant_rgb

def is_room_image(image: Image.Image) -> bool:
    """Basic heuristic to check if the image is a complex room vs a plain product."""
    img_small = image.resize((100, 100))
    pixels = np.array(img_small).astype(np.float32)
    
    color_std = pixels.reshape(-1, 3).std(axis=0).mean()
    gray = pixels.mean(axis=2)
    spatial_std = gray.std()
    unique_colors = len(np.unique(pixels.reshape(-1, 3) // 32, axis=0))

    # Rooms usually have high variance and many colors
    return color_std > 20 and spatial_std > 25 and unique_colors > 40

def compute_color_score(u_color, p_color) -> float:
    if not u_color or not p_color: return 0.0
    # Euclidean distance normalized (max distance is ~441)
    dist = np.linalg.norm(np.array(u_color) - np.array(p_color))
    return float(max(0, 1 - (dist / 441.67)))

# API Endpoints

@app.get("/")
def greet():
    return {"message": "Lumeo ML Service is Online"}

@app.post("/api/v1/product-metadata")
async def process_product(file: UploadFile = File(...)):
    """Used when adding products to the DB. Removes BG to get item color."""
    try:
        contents = await file.read()
        img = Image.open(io.BytesIO(contents)).convert('RGB')
        
        vector, rgb = analyze_image_features(img, remove_bg=True)
        return {"success": True, "data": {"rgb": rgb, "vector": vector}}
    except Exception as e:
        raise HTTPException(status_code=500, detail=str(e))

@app.post("/api/v1/search")
async def search_furniture(file: UploadFile = File(...)):
    """Finds products matching the user's room image."""
    if file.content_type not in ["image/jpeg", "image/png"]:
        raise HTTPException(status_code=400, detail="Invalid image type")

    try:
        # Load and Validate Image
        img_bytes = await file.read()
        img = Image.open(io.BytesIO(img_bytes)).convert('RGB')
        
        if not is_room_image(img):
            raise HTTPException(status_code=422, detail="Please scan a room with furniture.")

        # Extract features (remove_bg=False because we WANT the room colors)
        user_emb, user_rgb = analyze_image_features(img, remove_bg=False)

        # Fetch catalog from Node
        response = await app.requests_client.get(f"{NODE_BACKEND_URL}/api/products/mlproducts")
        response.raise_for_status()
        products = response.json()
        if not isinstance(products, list):
            products = products.get("products", [])

        if not products:
            return {"success": True, "results": [], "total": 0}

        # Calculate Scores
        scored = []
        user_vec = np.array(user_emb).reshape(1, -1)

        for product in products:
            product_emb = product.get("imageEmbedding")
            if not product_emb: continue
            
            product_vec = np.array(product_emb).reshape(1, -1)
            vis_score = float(cosine_similarity(user_vec, product_vec)[0][0])
            col_score = compute_color_score(user_rgb, product.get("dominantColor"))

            # Store temporary scores for normalization
            product_data = {**product, "_vis": vis_score, "_col": col_score}
            # Clean sensitive/heavy fields if necessary
            product_data.pop("imageEmbedding", None) 
            scored.append(product_data)

        if not scored: return {"success": True, "results": []}

        # Normalize and Finalize Ranking
        vis_vals = [s["_vis"] for s in scored]
        v_min, v_max = min(vis_vals), max(vis_vals)
        v_range = (v_max - v_min) if v_max != v_min else 1.0

        for s in scored:
            norm_vis = (s["_vis"] - v_min) / v_range
            # Weight: 60% Visual Similarity, 40% Color Match
            s["score"] = round((norm_vis * 0.6) + (s["_col"] * 0.4), 4)
            # Cleanup internal keys
            for key in ["_vis", "_col", "imageEmbedding"]: s.pop(key, None)

        scored.sort(key=lambda x: x["score"], reverse=True)
        
        return {
            "success": True,
            "total": len(scored[:10]),
            "results": scored[:10]
        }

    except Exception as e:
        print(traceback.format_exc())
        raise HTTPException(status_code=500, detail="Search failed")