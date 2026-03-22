import { v2 as cloudinary } from 'cloudinary';

// 1. Configure Cloudinary 
// (It's best practice to load these from process.env in production)
cloudinary.config({
  cloud_name: 'YOUR_CLOUD_NAME', // e.g., 'drno34my4' from your logs
  api_key: 'YOUR_API_KEY',
  api_secret: 'YOUR_API_SECRET'
});

async function uploadAndNotify(jobId, localFilePath) {
  try {
    console.log(`Starting upload for job ${jobId}...`);

    // 2. Upload the file directly to Cloudinary
    const uploadResult = await cloudinary.uploader.upload(localFilePath, {
      folder: 'blueprints', // Keeps your dashboard organized
      resource_type: 'auto' // Automatically handles images, raw files, etc.
    });

    console.log('Upload successful! File securely hosted at:', uploadResult.secure_url);

    // 3. Create the lightweight JSON payload (No base64 strings!)
    const webhookPayload = {
      jobId: jobId,
      status: 'success',
      resultUrl: uploadResult.secure_url 
    };

    // 4. Send the tiny webhook to your Main Backend
    const mainBackendWebhookUrl = `${process.env.BACKEND_URL}/api/webhooks/blueprint-3d-update`; // Change to your actual route
    
    // Using native fetch (available in Node 18+). You can also use axios here.
    const response = await fetch(mainBackendWebhookUrl, {
      method: 'POST',
      headers: { 'Content-Type': 'application/json' },
      body: JSON.stringify(webhookPayload)
    });

    if (!response.ok) {
      throw new Error(`Webhook failed with status: ${response.status}`);
    }

    console.log('Webhook successfully sent to main backend!');

  } catch (error) {
    console.error('Worker Error:', error);
    // Here you might want to send a "failed" webhook payload instead
  }
}

// --- How you call it after your simulation finishes ---
// uploadAndNotify('69b12de14720df522dec7fa8', './temp/simulation-result.png');