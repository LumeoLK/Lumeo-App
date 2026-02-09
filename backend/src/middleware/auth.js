import jwt from "jsonwebtoken";
import User from "../models/User.js";

/* 1. VERIFY TOKEN 
  Checks if the user is logged in. 
  Decodes the token and attaches the user info to 'req.user'
*/
export const verifyToken = async (req, res, next) => {
  try {
    let token = req.header("Authorization");

    if (!token) {
      return res.status(403).json({ msg: "Access Denied: No token provided" });
    }

    if (token.startsWith("Bearer ")) {
      token = token.slice(7, token.length).trimLeft();
    }

    const verified = jwt.verify(token, process.env.JWT_SECRET);
    req.user = verified; 
    next(); 
  } catch (error) {
    res.status(401).json({ msg: "Invalid or Expired Token" });
  }
};

/* 1. VERIFY ADMIN 
  Checks admin using the cookie
*/
export const verifyAdmin = async (req, res, next) => {
  try {
    const {admin_token}= req.cookies;
    if (!admin_token) {
      return res.status(403).json({ msg: "Access Denied: No token provided" });
    }
    if (admin_token.startsWith("Bearer ")) {
      admin_token = admin_token.slice(7, admin_token.length).trimLeft();
    }

    const verified = jwt.verify(admin_token, process.env.JWT_SECRET);
    const user = await User.findById(verified.id);
    
    if (user.role !== "admin") {
      return res.status(403).json({ msg: "Access Denied: Admins only" });
    }
    
    next();
  } catch (error) {
    res.status(500).json({ error: error.message });
  }
};

/* 1. VERIFY SELLER
  Checks the role is seller or admin . should run after VERIFYTOKEN function.
*/
export const verifySeller = async (req, res, next) => {
  try {
    const user = await User.findById(req.user.id);
    if (user.role !== "seller" && user.role !== "admin") {
       return res.status(403).json({ msg: "Access Denied" });
    }

    // NEW: Find the shop and attach it
    const shop = await Seller.findOne({ userId: req.user.id });
    if(shop) {
        req.user.sellerId = shop._id; // <--- This fixes the Order Controller
    }else{
      res.status(403).json({ success:false, msg: "Access Denied: No shop found for this user" });
    }

    next();
  } catch (error) {
    res.status(500).json({ error: error.message });
  }
};