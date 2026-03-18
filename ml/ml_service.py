from fastapi import FastAPI, UploadFile, File, HTTPException,Query
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
    CORSMiddleware, # security handshake between the browser and the server
    allow_origins=["*"],
    allow_methods=["*"], 
    allow_headers=["*"], 
)

# Load CLIP Model once when server starts
device = "cuda" if torch.cuda.is_available() else "cpu"
model, preprocess = clip.load("ViT-B/32", device=device)

NODE_BACKEND_URL = os.getenv("NODE_BACKEND_URL","https://lumeo-app.onrender.com")

@app.get("/")
def greet():
    return {"message": "Welcome to the Lumeo ML Services!"}

def extract_ml_features(image_bytes):
    try:
        img = Image.open(io.BytesIO(image_bytes)).convert('RGB')

        # Extract Vector (CLIP)
        img_input = preprocess(img).unsqueeze(0).to(device)
        with torch.no_grad():
            vector = model.encode_image(img_input)
            vector /= vector.norm(dim=-1, keepdim=True)  #it scales the vector to a lenght of 1
            image_vector = vector.cpu().numpy().flatten().tolist()

        # Extract Dominant Color
        img_small = img.resize((100, 100))
        pixels = np.array(img_small).reshape(-1, 3).astype(np.float32)

        # Detect background color from corners
        corner_indices = [0, 99, 9900, 9999]
        corners = pixels[corner_indices]
        bg_color = corners.mean(axis=0)
       
        # Filter out background pixels
        # Any pixel within 40 RGB distance of background = background
        diff = np.linalg.norm(pixels - bg_color, axis=1)
        object_pixels = pixels[diff > 40]

        # Fallback if too few object pixels found
        if len(object_pixels) < 50:
            print("Too few object pixels — using all pixels")
            object_pixels = pixels

        # KMeans on object pixels only
        kmeans = KMeans(n_clusters=3, n_init=10, random_state=42)
        kmeans.fit(object_pixels)
        centers = kmeans.cluster_centers_

        # Pick most frequent cluster
        labels = kmeans.labels_
        counts = np.bincount(labels, minlength=3)
        dominant_rgb = centers[np.argmax(counts)].astype(int).tolist()
        print(f"  Dominant RGB: {dominant_rgb}")

        return dominant_rgb, image_vector
    except Exception as e:
        raise Exception(f"Processing Error: {str(e)}")

def compute_color_score(user_color: list, product_color: list) -> float:
    if not user_color or not product_color:
        return 0.0
    u = np.array(user_color)
    p = np.array(product_color)
    distance = np.linalg.norm(u - p)
    max_distance = 441.67
    return float(1 - (distance / max_distance))

@app.post("/api/v1/product-metadata")
async def process_product(file: UploadFile = File(...)): # Name MUST be 'file' to match Node
    try:
        # Read the file contents
        contents = await file.read()

        # Pass contents to the feature extractor
        rgb, vector = extract_ml_features(contents)
        
        return {"success": True, "data": {"rgb": rgb, "vector": vector}}
    except Exception as e:
        # Print the full error trace in the Python terminal for easier debugging
        print(traceback.format_exc())
        
        # Send 500 status code so Node.js Axios catches the error
        raise HTTPException(status_code=500, detail=str(e))


@app.post("/api/v1/search")
async def search_furniture(
    file: UploadFile = File(...),
):
    # Validate file type
    if file.content_type not in ["image/jpeg", "image/png", "image/jpg"]:
        raise HTTPException(status_code=400, detail="Only JPEG/PNG images accepted")

    # Read image bytes
    image_bytes = await file.read()
    if not image_bytes:
        raise HTTPException(status_code=400, detail="Uploaded file is empty")

    # Extract embedding + color from uploaded image
    try:
        user_color, user_embedding = extract_ml_features(image_bytes)
        print(f"User image dominant color: {user_color}")
    except Exception as e:
        print(traceback.format_exc())
        raise HTTPException(status_code=500, detail=f"Image processing failed: {str(e)}")
    

    # Fetch ALL products from Node
    try:
        async with httpx.AsyncClient(timeout=30.0) as client:
            response = await client.get(
                f"{NODE_BACKEND_URL}/api/products/"
            )
            response.raise_for_status()
            data = response.json()
            products = data.get("products", [])
            print(f"Fetched {len(products)} products from Node")

    except httpx.ConnectError:
        raise HTTPException(
            status_code=503,
            detail=f"Cannot connect to Node backend at {NODE_BACKEND_URL} — is it running?",
        )
    except httpx.TimeoutException:
        raise HTTPException(status_code=504, detail="Node backend timed out")
    except httpx.HTTPStatusError as e:
        raise HTTPException(
            status_code=502,
            detail=f"Node backend returned error: {e.response.status_code}",
        )

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

        # Visual similarity 80% + color 20%
        visual_score = float(cosine_similarity(user_vec, product_vec)[0][0])
        color_score = compute_color_score(user_color, product.get("dominantColor", []))
        final_score = (visual_score * 0.8) + (color_score * 0.2)

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
            "score": round(final_score, 4),
        })
   # Sort by score and return top results
    scored.sort(key=lambda x: x["score"], reverse=True)
    top_results = scored[:10]

    print(f"Top {len(top_results)} results — scores: {[r['score'] for r in top_results]}")

    return {
        "success": True,
        "total": len(top_results),
        "results": top_results,
    }