import { v2 as cloudinary } from "cloudinary";

cloudinary.config({
  cloud_name: process.env.CLOUDINARY_CLOUD_NAME,
  api_key: process.env.CLOUDINARY_API_KEY,
  api_secret: process.env.CLOUDINARY_API_SECRET,
});

export const uploadToCloudinary = (
  fileBuffer,
  folder,
  resourceType = "auto",
  customFilename = null,
) => {
  return new Promise((resolve, reject) => {
    const options = {
      folder,
      resource_type: resourceType,
    };

    if (customFilename) {
      options.public_id = customFilename;
    }

    const stream = cloudinary.uploader.upload_stream(
      options,
      (error, result) => {
        if (error) {
          return reject(error);
        }
        resolve(result);
      },
    );

    stream.end(fileBuffer);
  });
};
