import axios from "axios";
import FormData from "form-data";
import Product from "../models/Product.js";
import Seller from "../models/seller.js";
import { generate3DModel } from "../services/meshyservices.js";
import { uploadToCloudinary } from "../lib/cloudinary.js";
export const createProduct = async (req, res) => {
  try {
    const {
      title,
      description,
      price,
      category,
      stock,
      length,
      width,
      height,
    } = req.body;

    // 1. Authenticate Seller
    const seller = await Seller.findOne({ userId: req.user.id });
    if (!seller) {
      return res
        .status(404)
        .json({ success: false, msg: "Seller profile not found." });
    }

    // File Validation
    if (!req.files || req.files.length === 0) {
      return res
        .status(400)
        .json({ success: false, msg: "Please upload at least one image." });
    }

    // takes the first image to feed the ML model
    const mainImage = req.files[0];

    // 3. Process Upload & ML in Parallel
    const [mlResponse, cloudinaryResults] = await Promise.all([
      // ML Service (Using only the main image)
      (async () => {
        try {
          const form = new FormData();
          form.append("file", mainImage.buffer, {
            filename: mainImage.originalname,
            contentType: mainImage.mimetype,
          });
          const mlUrl = process.env.ML_SERVICE_URL || "http://127.0.0.1:8000";
          const res = await axios.post(
            `${mlUrl}/api/v1/product-metadata`,
            form,
            {
              headers: { ...form.getHeaders() },
            },
          );
          return res.data;
        } catch (err) {
          console.error("ML Service unreachable, using defaults.");
          return null;
        }
      })(),

      // Upload ALL images to Cloudinary
      Promise.all(
        req.files.map((file) =>
          uploadToCloudinary(file.buffer, "lumeo_products"),
        ),
      ),
    ]);

    // 4. Extract Data from both successful tasks
    const { rgb, vector } = mlResponse.data;
    const imageUrls = cloudinaryResults.map((result) => result.secure_url);

    // 5. Create Product
    const newProduct = new Product({
      sellerId: seller._id,
      title,
      description,
      price,
      category,
      stock,
      images: imageUrls, 
      dimensions: { length, width, height },
      dominantColor: rgb, 
      imageEmbedding: vector,
      model3D: { status: "pending" },
    });
    
    await newProduct.save();
    console.log("data saved")
    const result = await generate3DModel(newProduct._id, imageUrls); 
    
    res.status(201).json({
      success: true,
      msg: "Product created successfully!",
      product: newProduct,
      jobid: result.jobId,
    });
  } catch (error) {
    console.error("Product Creation Error:", error);
    res.status(500).json({ success: false, msg: error.message });
  }
};


export const approve3DModel = async (req, res) => {
  try {
    const { productId } = req.params;
    const product = await Product.findById(productId);

    if (!product) {
      return res.status(404).json({ msg: "Product not found." });
    }

    if (product.model3D.status !== "success") {
      return res.status(400).json({ msg: "3D model is not ready for approval." });
    }

    await Product.findByIdAndUpdate(productId, {
      "model3D.status": "approved",
    });

    res.status(200).json({success:true, msg: "3D model approved successfully." });
  } catch (error) {
    console.error("Error approving 3D model:", error);
    res.status(500).json({ msg: "Failed to approve 3D model." });
  }
}

export const getAllProducts = async (req, res) => {
  try {
    const products = await Product.find().sort({ createdAt: -1 });
    res.json(products);
  } catch (error) {
    res.status(500).json({ msg: error.message });

  }
};

export const searchProducts = async (req, res) => {
  try {
    const {
      keyword,
      category,
      minPrice,
      maxPrice,
      sortBy,
      page = 1,
      limit = 10,
    } = req.query;

    let query = {};
    if (keyword) query.title = { $regex: keyword, $options: "i" };
    if (category) query.category = category;
    if (minPrice || maxPrice) {
      query.price = {};
      if (minPrice) query.price.$gte = Number(minPrice);
      if (maxPrice) query.price.$lte = Number(maxPrice);
    }

    let sortOptions = {};
    if (sortBy === "price-low") sortOptions.price = 1;
    else if (sortBy === "price-high") sortOptions.price = -1;
    else sortOptions.createdAt = -1;

    const skip = (Number(page) - 1) * Number(limit);

    const products = await Product.find(query)
      .sort(sortOptions)
      .skip(skip)
      .limit(Number(limit))
      .select("title price images category");

    const total = await Product.countDocuments(query);

    res.json({
      success: true,
      count: products.length,
      total,
      page: Number(page),
      pages: Math.ceil(total / Number(limit)),
      data: products,
    });
  } catch (error) {
    res.status(500).json({ msg: error.message });
  }
};

export const getProductById = async (req, res) => {
  try {
    const product = await Product.findById(req.params.id);
    if (!product) {
      return res.status(404).json({ msg: "Product not found." });
    }
    res.json(product);
  } catch (error) {
    console.log(error.message);
    return res.status(500).json({ msg: error.message });
  }
}
