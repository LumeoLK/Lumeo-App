from fastapi import FastAPI, UploadFile, File, HTTPException
import numpy as np
from PIL import Image
import io

app = FastAPI(title="ML Metadata")

def get_image_metadata(image_bytes):
    try:
        img = Image.open(io.BytesIO(image_bytes)).convert('RGB')
        
        # extract colours (RGB)
        extracted_rgb = [120, 45, 200] 
        
        #vector embeddings
        image_vector = np.random.rand(128).tolist() 
        
        return extracted_rgb, image_vector
    except Exception as e:
        raise Exception(f"ML Processing Error: {str(e)}")

#Api endpoint 
@app.post("/api/v1/product-metadata")
async def process_product(file: UploadFile = File(...)):
    if not file.content_type.startswith("image/"):
        raise HTTPException(status_code=400, detail="File must be an image")

    contents = await file.read()
    rgb, vector = get_image_metadata(contents)
    
    return {
        "status": "success",
        "data": {
            "rgb": rgb,
            "vector": vector,
        }
    }