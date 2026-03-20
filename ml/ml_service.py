from fastapi import FastAPI, UploadFile, File, HTTPException
from fastapi.middleware.cors import CORSMiddleware
from sklearn.metrics.pairwise import cosine_similarity
import torch
import clip
from PIL import Image
from sklearn.cluster import KMeans
import numpy as np
import io
import traceback
import httpx
import os

app = FastAPI(title="Lumeo ML Service")

app.add_middleware(
    CORSMiddleware,
    allow_origins=["*"],
    allow_methods=["*"],
    allow_headers=["*"],
)

device = "cuda" if torch.cuda.is_available() else "cpu"
model, preprocess = clip.load("ViT-B/32", device=device)

NODE_BACKEND_URL = os.getenv("NODE_BACKEND_URL", "https://lumeo-app.onrender.com")


@app.get("/")
def greet():
    return {"message": "Welcome to the Lumeo ML Services!"}


def is_room_image(image_bytes) -> bool:
    """Check if image looks like a room using basic image analysis."""
    try:
        img = Image.open(io.BytesIO(image_bytes)).convert('RGB')
        img_small = img.resize((100, 100))
        pixels = np.array(img_small).astype(np.float32)

        # Color variance — rooms have diverse colors
        color_std = pixels.reshape(-1, 3).std(axis=0).mean()

        # Spatial variance — rooms have complex patterns
        gray = pixels.mean(axis=2)
        spatial_std = gray.std()

        # Number of distinct color regions
        unique_colors = len(np.unique(pixels.reshape(-1, 3) // 32, axis=0))

        print(f"[DEBUG] color_std={color_std:.1f}, spatial_std={spatial_std:.1f}, unique_colors={unique_colors}")

        return color_std > 20 and spatial_std > 25 and unique_colors > 40
    except Exception as e:
        print(f"[DEBUG] is_room_image error: {e}")
        return True  # if check fails, allow through


def compute_color_score(user_color: list, product_color: list) -> float:
    if not user_color or not product_color:
        return 0.0
    u = np.array(user_color)
    p = np.array(product_color)
    distance = np.linalg.norm(u - p)
    return float(1 - (distance / 441.67))


@app.post("/api/v1/product-metadata")
async def process_product(file: UploadFile = File(...)):
    try:
        contents = await file.read()
        img = Image.open(io.BytesIO(contents)).convert('RGB')

        img_input = preprocess(img).unsqueeze(0).to(device)
        with torch.no_grad():
            vector = model.encode_image(img_input)
            vector /= vector.norm(dim=-1, keepdim=True)
            image_vector = vector.cpu().numpy().flatten().tolist()

        img_small = img.resize((100, 100))
        pixels = np.array(img_small).reshape(-1, 3).astype(np.float32)
        corner_indices = [0, 99, 9900, 9999]
        corners = pixels[corner_indices]
        bg_color = corners.mean(axis=0)
        diff = np.linalg.norm(pixels - bg_color, axis=1)
        object_pixels = pixels[diff > 40]

        if len(object_pixels) < 50:
            object_pixels = pixels

        kmeans = KMeans(n_clusters=3, n_init=10, random_state=42)
        kmeans.fit(object_pixels)
        centers = kmeans.cluster_centers_
        labels = kmeans.labels_
        counts = np.bincount(labels, minlength=3)
        dominant_rgb = centers[np.argmax(counts)].astype(int).tolist()
        print(f"Dominant RGB: {dominant_rgb}")

        return {"success": True, "data": {"rgb": dominant_rgb, "vector": image_vector}}

    except Exception as e:
        print(traceback.format_exc())
        raise HTTPException(status_code=500, detail=str(e))


@app.post("/api/v1/search")
async def search_furniture(file: UploadFile = File(...)):
    if file.content_type not in ["image/jpeg", "image/png", "image/jpg"]:
        raise HTTPException(status_code=400, detail="Only JPEG/PNG images accepted")

    image_bytes = await file.read()
    if not image_bytes:
        raise HTTPException(status_code=400, detail="Uploaded file is empty")

    print("[DEBUG] Image received — size:", len(image_bytes), "bytes")

    # Check if image looks like a room 
    if not is_room_image(image_bytes):
        raise HTTPException(
            status_code=422,
            detail="Please scan a room with furniture."
        )

    # Extract CLIP embedding + dominant color
    try:
        img = Image.open(io.BytesIO(image_bytes)).convert('RGB')

        img_input = preprocess(img).unsqueeze(0).to(device)
        with torch.no_grad():
            image_features = model.encode_image(img_input)
            image_features /= image_features.norm(dim=-1, keepdim=True)

        user_embedding = image_features.cpu().numpy().flatten().tolist()
        print("[DEBUG] Embedding extracted, length:", len(user_embedding))

        img_small = img.resize((100, 100))
        pixels = np.array(img_small).reshape(-1, 3).astype(np.float32)
        corner_indices = [0, 99, 9900, 9999]
        corners = pixels[corner_indices]
        bg_color = corners.mean(axis=0)
        diff = np.linalg.norm(pixels - bg_color, axis=1)
        object_pixels = pixels[diff > 40]

        if len(object_pixels) < 50:
            object_pixels = pixels

        kmeans = KMeans(n_clusters=3, n_init=10, random_state=42)
        kmeans.fit(object_pixels)
        centers = kmeans.cluster_centers_
        labels = kmeans.labels_
        counts = np.bincount(labels, minlength=3)
        user_color = centers[np.argmax(counts)].astype(int).tolist()
        print(f"[DEBUG] User dominant color: {user_color}")

    except Exception as e:
        print(traceback.format_exc())
        raise HTTPException(status_code=500, detail=f"Image processing failed: {str(e)}")

    #  Fetch products from Node 
    try:
        async with httpx.AsyncClient(timeout=30.0) as client:
            print(f"[DEBUG] Fetching products from Node")
            response = await client.get(f"{NODE_BACKEND_URL}/api/products/mlproducts")
            response.raise_for_status()
            data = response.json()
            if isinstance(data, list):
                products = data
            else:
                products = data.get("products", [])
            print(f"[DEBUG] Fetched {len(products)} products")

            if products:
                sample = products[0]
                has_emb = bool(sample.get("imageEmbedding") and len(sample.get("imageEmbedding")) > 0)
                has_col = bool(sample.get("dominantColor") and len(sample.get("dominantColor")) == 3)
                print(f"[DEBUG] Sample → has imageEmbedding: {has_emb}, has dominantColor: {has_col}")

    except httpx.ConnectError:
        raise HTTPException(status_code=503, detail="Cannot connect to Node backend")
    except httpx.TimeoutException:
        raise HTTPException(status_code=504, detail="Node backend timed out")
    except httpx.HTTPStatusError as e:
        raise HTTPException(status_code=502, detail=f"Node backend error: {e.response.status_code}")

    if not products:
        return {"success": True, "results": [], "total": 0}

    # Score every product 
    user_vec = np.array(user_embedding).reshape(1, -1)
    scored = []

    for product in products:
        embedding = product.get("imageEmbedding")
        if not embedding or len(embedding) == 0:
            continue

        product_vec = np.array(embedding).reshape(1, -1)
        visual_score = float(cosine_similarity(user_vec, product_vec)[0][0])
        color_score = compute_color_score(user_color, product.get("dominantColor", []))

        scored.append({
            "id": str(product.get("_id", "")),
            "title": product.get("title", ""),
            "description": product.get("description", ""),
            "price": product.get("price", 0),
            "category": product.get("category", ""),
            "images": product.get("images", []),
            "dimensions": product.get("dimensions", {}),
            "dominantColor": product.get("dominantColor", []),
            "averageRating": product.get("averageRating", 0),
            "model3D": product.get("model3D", {}),
            "_visual": visual_score,
            "_color": color_score,
        })

    if not scored:
        return {"success": True, "results": [], "total": 0}

    # Normalize visual scores 
    visual_scores = np.array([s['_visual'] for s in scored])
    min_v = visual_scores.min()
    max_v = visual_scores.max()
    range_v = max_v - min_v + 1e-8

    for s in scored:
        normalized_visual = (s['_visual'] - min_v) / range_v
        s['score'] = round((normalized_visual * 0.6) + (s['_color'] * 0.4), 4)
        del s['_visual']
        del s['_color']

    #Sort and return top 10 
    scored.sort(key=lambda x: x["score"], reverse=True)
    top_results = scored[:10]

    print(f"[DEBUG] Top scores: {[r['score'] for r in top_results]}")

    return {
        "success": True,
        "total": len(top_results),
        "results": top_results,
    }