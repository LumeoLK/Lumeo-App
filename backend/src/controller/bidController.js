import CustomRequest from "../models/customRequest.js";
import Bid from "../models/bid.js";
import Seller from "../models/seller.js";


export const createRequest = async (req, res) => {
  try {
    const { title, description, budget, deadline } = req.body;
    
    
    const images = req.files ? req.files.map(file => file.path) : [];

    const newRequest = new CustomRequest({
      userId: req.user.id,
      title,
      description,
      budget,
      deadline,
      referenceImages: images
    });

    await newRequest.save();
    res.status(201).json({ success: true, request: newRequest });
  } catch (error) {
    res.status(500).json({ success: false, msg: error.message });
  }
};

export const getOpenRequests = async (req, res) => {
  try {
   
    const requests = await CustomRequest.find({ status: "open" }).sort({ createdAt: -1 });
    res.json({ success: true, requests });
  } catch (error) {
    res.status(500).json({ success: false, msg: error.message });
  }
};

export const placeBid = async (req, res) => {
  try {
    const { requestId, price, message, estimatedDays } = req.body;
    
    const seller = await Seller.findOne({ userId: req.user.id });
    if (!seller) return res.status(403).json({ success: false, msg: "Only sellers can bid" });

    const request = await CustomRequest.findById(requestId);
    if (!request || request.status !== "open") {
      return res.status(400).json({ success: false, msg: "Request is closed or not found" });
    }
    if (!req.files || req.files.length === 0) {
      return res.status(400).json({ success: false, msg: "Please upload at least one image." });
    }
    
    const imageUrls = req.files.map(file => file.path);
    const newBid = new Bid({
      requestId,
      sellerId: seller._id,
      price,
      message,
      estimatedDays,
      images:imageUrls
    });

    await newBid.save();
    res.status(201).json({ success: true, msg: "Bid placed successfully!", bid: newBid });
  } catch (error) {
    res.status(500).json({ success: false, msg: error.message });
  }
};