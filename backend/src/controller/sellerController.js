import Seller from "../models/seller.js";
import User from "../models/User.js";
import Product from "../models/Product.js";
import jwt from "jsonwebtoken";
export const becomeSeller = async (req, res) => {
  try {
    const { shopName, displayName, businessAddress, phoneNumber,businessRegNumber,password } = req.body;
    if(!shopName || !displayName || !businessAddress || !phoneNumber || !businessRegNumber){
      return  res.status(400).json({success: false, msg: "Please provide all the required fields" });
    }

    const existingShop = await Seller.findOne({ userId: req.user.id });
    if (existingShop) {
      return res.status(400).json({ success: false, msg: "You have already applied to be a seller." });
    }
    const existingSeller = await Seller.findOne({ businessRegNumber });
    if (existingSeller) {
      return res
        .status(400)
        .json({success: false, msg: "Seller with same Business Registration Number already exist" });
    }

   const logoUrl = req.files['logo'] ? req.files['logo'][0].path : null;
    const nicFrontUrl = req.files['NICfront'] ? req.files['NICfront'][0].path : null;
    const nicBackUrl = req.files['NICback'] ? req.files['NICback'][0].path : null;
    if(!logoUrl || !nicFrontUrl || !nicBackUrl) {
       return res.status(400).json({ success: false, msg: "Please upload Logo, NIC Front, and NIC Back images." });
    }

    const user = await User.findOne({ _id: req.user.id }).select("+password");
    user.role = "seller";
    await user.save();


    const seller = new Seller({
      userId: req.user.id,
      shopName,
      displayName,
      logo: logoUrl,
      businessAddress,
      phoneNumber,
      NICfront: nicFrontUrl,
      NICback: nicBackUrl,
      businessRegNumber,
      isVerified: false
    });
    
    await seller.save();

    const token = jwt.sign(
          { id: user._id, role: user.role },
          process.env.JWT_SECRET,
          { expiresIn: "30d" }
        );
      
    res.json({success: true, token,seller});
  } catch (error) {
    res.status(500).json({ msg: error.message });
  }
}


export const createProduct = async (req, res) => {
  try {
    const { 
      title, 
      description, 
      price, 
      category, 
      stock, 
      length, width, height
    } = req.body;

   
    const seller = await Seller.findOne({ userId: req.user.id });
    if (!seller) {
      return res.status(404).json({ success: false, msg: "Seller profile not found." });
    }

    if (!req.files || req.files.length === 0) {
      return res.status(400).json({ success: false, msg: "Please upload at least one image." });
    }
    
    const imageUrls = req.files.map(file => file.path);

   
    const newProduct = new Product({
      sellerId: seller._id, 
      title,
      description,
      price,
      category,
      stock,
      images: imageUrls,
      dimensions: {
        length: length,
        width: width,
        height: height
      }
    });

    await newProduct.save();

    res.status(201).json({ 
      success: true, 
      msg: "Product created successfully!", 
      product: newProduct 
    });

  } catch (error) {
    res.status(500).json({ success: false, msg: error.message });
  }
};


export const getAllProducts = async (req, res) => {
  try {
    const products = await Product.find().sort({ createdAt: -1 }); // Newest first
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
      sortBy, // 'newest', 'price-low', 'price-high'
      page = 1, 
      limit = 10 
    } = req.query;

    // 2. Build the Database Query Object
    let query = {};

    // A. Text Search (Case insensitive regex)
    if (keyword) {
      query.title = { $regex: keyword, $options: "i" };
    }

    // B. Category Filter
    if (category) {
      query.category = category;
    }

    // C. Price Range Filter
    if (minPrice || maxPrice) {
      query.price = {};
      if (minPrice) query.price.$gte = Number(minPrice); // Greater than or equal
      if (maxPrice) query.price.$lte = Number(maxPrice); // Less than or equal
    }

    // 3. Handle Sorting
    let sortOptions = {};
    if (sortBy === "price-low") {
      sortOptions.price = 1; // Ascending
    } else if (sortBy === "price-high") {
      sortOptions.price = -1; // Descending
    } else {
      sortOptions.createdAt = -1; // Default: Newest first
    }

    // 4. Pagination (Skip & Limit)
    // Page 1 = skip 0. Page 2 = skip 10.
    const skip = (Number(page) - 1) * Number(limit);

    // 5. Execute Query
    const products = await Product.find(query)
      .sort(sortOptions)
      .skip(skip)
      .limit(Number(limit))
      .select("title price images category"); // Optimization: Don't fetch description for list view

    // 6. Get Total Count (For frontend pagination UI)
    const total = await Product.countDocuments(query);

    res.json({
      success: true,
      count: products.length,
      total,
      page: Number(page),
      pages: Math.ceil(total / Number(limit)),
      data: products
    });

  } catch (error) {
    res.status(500).json({ msg: error.message });
  }
};