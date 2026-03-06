import { v2 as cloudinary } from "cloudinary";
import multer from "multer";

cloudinary.config({
  cloud_name: process.env.CLOUDINARY_CLOUD_NAME,
  api_key: process.env.CLOUDINARY_API_KEY,
  api_secret: process.env.CLOUDINARY_API_SECRET,
});

// Create a single, reusable helper function
// lib/cloudinary.js

export const uploadToCloudinary = (
  fileBuffer,
  folder,
  resourceType = "auto",
  customFilename = null,
) => {
  return new Promise((resolve, reject) => {
    // Set up the base options
    const options = {
      folder: folder,
      resource_type: resourceType,
    };

    // If we pass a custom filename (like "model.glb"), add it to options
    if (customFilename) {
      options.public_id = customFilename;
    }

    const stream = cloudinary.uploader.upload_stream(
      options,
      (error, result) => {
        if (error) {
          console.error("Cloudinary Upload Error:", error);
          return reject(error);
        }
        resolve(result);
      },
    );

    stream.end(fileBuffer);
  });
};

const upload = multer({
  storage: multer.memoryStorage(),
  limits: { fileSize: 10 * 1024 * 1024 },
  fileFilter: (req, file, cb) => {
    if (file.mimetype.startsWith("image/")) {
      cb(null, true);
    } else {
      cb(new Error("Only image files are allowed"), false);
    }
  },
});

export { cloudinary };
export default upload;
