import Seller from "../models/seller.js";
import User from "../models/User.js";
import Product from "../models/Product.js";
import jwt from "jsonwebtoken";
import { cloudinary } from "../lib/cloudinary.js"; // ← NEW

// Helper to upload buffer to Cloudinary
const uploadToCloudinary = (buffer, folder) => {
  return new Promise((resolve, reject) => {
    const stream = cloudinary.uploader.upload_stream(
      { folder },
      (error, result) => (error ? reject(error) : resolve(result))
    );
    stream.end(buffer);
  });
};

export const becomeSeller = async (req, res) => {
  try {
    const { shopName, displayName, businessAddress, phoneNumber, businessRegNumber } = req.body;

    if (!shopName || !displayName || !businessAddress || !phoneNumber || !businessRegNumber) {
      return res.status(400).json({ success: false, msg: "Please provide all the required fields" });
    }

    const existingShop = await Seller.findOne({ userId: req.user.id });
    if (existingShop) {
      return res.status(400).json({ success: false, msg: "You have already applied to be a seller." });
    }

    const existingSeller = await Seller.findOne({ businessRegNumber });
    if (existingSeller) {
      return res.status(400).json({ success: false, msg: "Seller with same Business Registration Number already exist" });
    }

    // ← Check file existence using buffers, not .path
    if (!req.files?.logo || !req.files?.NICfront || !req.files?.NICback) {
      return res.status(400).json({ success: false, msg: "Please upload Logo, NIC Front, and NIC Back images." });
    }

    // ← Upload all 3 to Cloudinary in parallel
    const [logoResult, nicFrontResult, nicBackResult] = await Promise.all([
      uploadToCloudinary(req.files["logo"][0].buffer, "lumeo_sellers"),
      uploadToCloudinary(req.files["NICfront"][0].buffer, "lumeo_sellers"),
      uploadToCloudinary(req.files["NICback"][0].buffer, "lumeo_sellers"),
    ]);

    const user = await User.findOne({ _id: req.user.id }).select("+password");
    user.role = "seller";
    await user.save();

    const seller = new Seller({
      userId: req.user.id,
      shopName,
      displayName,
      logo: logoResult.secure_url,        // ← secure_url not .path
      businessAddress,
      phoneNumber,
      NICfront: nicFrontResult.secure_url,
      NICback: nicBackResult.secure_url,
      businessRegNumber,
      isVerified: false,
    });

    await seller.save();

    const token = jwt.sign(
      { id: user._id, role: user.role },
      process.env.JWT_SECRET,
      { expiresIn: "30d" }
    );

    res.json({ success: true, token, seller });
  } catch (error) {
    res.status(500).json({ msg: error.message });
  }
};

export const createProduct = async (req, res) => {
  try {
    const { title, description, price, category, stock, length, width, height } = req.body;

    const seller = await Seller.findOne({ userId: req.user.id });
    if (!seller) {
      return res.status(404).json({ success: false, msg: "Seller profile not found." });
    }

    if (!req.files || req.files.length === 0) {
      return res.status(400).json({ success: false, msg: "Please upload at least one image." });
    }

    const imageUrls = req.files.map((file) => file.path);

    const newProduct = new Product({
      sellerId: seller._id,
      title, description, price, category, stock,
      images: imageUrls,
      dimensions: { length, width, height },
    });

    await newProduct.save();

    res.status(201).json({ success: true, msg: "Product created successfully!", product: newProduct });
  } catch (error) {
    res.status(500).json({ success: false, msg: error.message });
  }
};

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
    const { keyword, category, minPrice, maxPrice, sortBy, page = 1, limit = 10 } = req.query;

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

    res.json({ success: true, count: products.length, total, page: Number(page), pages: Math.ceil(total / Number(limit)), data: products });
  } catch (error) {
    res.status(500).json({ msg: error.message });
  }
};