from fastapi import FastAPI, UploadFile, File, HTTPException
import torch
import clip
from PIL import Image
from sklearn.cluster import KMeans
import numpy as np
import io

app = FastAPI(title="Lumeo ML Service")

# Load CLIP Model once when server starts
device = "cuda" if torch.cuda.is_available() else "cpu"
model, preprocess = clip.load("ViT-B/32", device=device)

def extract_ml_features(image_bytes):
    try:
        img = Image.open(io.BytesIO(image_bytes)).convert('RGB')
        
        # Extract Vector (CLIP)
        img_input = preprocess(img).unsqueeze(0).to(device)
        with torch.no_grad():
            vector = model.encode_image(img_input)
            vector /= vector.norm(dim=-1, keepdim=True)
            image_vector = vector.cpu().numpy().flatten().tolist()
        
        # Extract Colors (K-Means)
        img_small = img.resize((100, 100))
        pixels = np.array(img_small).reshape(-1, 3)
        kmeans = KMeans(n_clusters=3, n_init=10)
        kmeans.fit(pixels)
        centers = kmeans.cluster_centers_
        distances = np.linalg.norm(centers - np.array([255, 255, 255]), axis=1)
        dominant_rgb = centers[np.argmax(distances)].astype(int).tolist()

        return dominant_rgb, image_vector
    except Exception as e:
        raise Exception(f"Processing Error: {str(e)}")

@app.post("/api/v1/product-metadata")
async def process_product(file: UploadFile = File(...)):
    contents = await file.read()
    rgb, vector = extract_ml_features(contents)
    
    return {
        "status": "success",
        "data": {
            "rgb": rgb,    
            "vector": vector
        }
    }