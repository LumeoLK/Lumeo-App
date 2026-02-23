import Order from "../models/order.js";
import Product from "../models/Product.js";
import Cart from "../models/cart.js";
import mongoose from "mongoose";
import { populate } from "dotenv";

// A. CREATE ORDER (Checkout)
export const createOrder = async (req, res) => {
  try {
    const {shippingAddress, paymentMethod } = req.body;
    const cart = await Cart.findOne({ userId: req.user.id }).populate("items.productId");
    if (!cart || cart.items.length === 0) {
      return res.status(400).json({ msg: "Cart is empty" });
    }
    const session = await mongoose.startSession();
    session.startTransaction();
    
    const newOrder = new Order({
      buyerId: req.user.id,
      sellerId,
      items,
      totalAmount,
      shippingAddress,
      paymentMethod,
      status: "pending"
    });

    await newOrder.save();

    res.status(201).json({ success: true, order: newOrder });
  } catch (error) {
    res.status(500).json({ msg: error.message });
  }
};

export const placeOrder = async (req, res) => {
  const session = await mongoose.startSession();
  session.startTransaction();

  try {
    const userId = req.user.id;
    const { shippingAddress, paymentMethod } = req.body;

    
    if (!["cod", "card"].includes(paymentMethod)) {
      return res.status(400).json({ msg: "Invalid payment method" });
    }

   
    const cart = await Cart.findOne({ userId }).session(session);

    if (!cart || cart.items.length === 0) {
      return res.status(400).json({ msg: "Cart is empty" });
    }

    let orderItems = [];
    let totalAmount = 0;

    for (const item of cart.items) {
      if (item.quantity <= 0) {
        throw new Error("Invalid quantity");
      }

      const product = await Product.findOneAndUpdate(
        { _id: item.productId, stock: { $gte: item.quantity } },
        { $inc: { stock: -item.quantity } },
        { new: true, session }
      );

      if (!product) {
        throw new Error(`Insufficient stock for product ${item.productId}`);
      }

      const subtotal = product.price * item.quantity;
      totalAmount += subtotal;

      orderItems.push({
        productId: product._id,
        sellerId: product.sellerId,
        title: product.title,
        priceAtPurchase: product.price,
        quantity: item.quantity,
        subtotal
      });
    }

    const [order] = await Order.create([{
      buyerId: userId,
      items: orderItems,
      totalAmount,
      shippingAddress,
      paymentMethod,
      paymentStatus: "pending",
      orderStatus: paymentMethod === "COD" ? "confirmed" : "pending"
    }], { session });

   
    await Cart.deleteOne({ userId }).session(session);

    
    await session.commitTransaction();
    session.endSession();

    return res.status(201).json({
      success: true,
      message: "Order placed successfully",
      order
    });

  } catch (error) {
    await session.abortTransaction();
    session.endSession();

    return res.status(400).json({
      success: false,
      msg: error.message
    });
  }
};

export const getMyOrders = async (req, res) => {
  try {
    const orders = await Order.find({ buyerId: req.user.id })
      .populate({
        path: "items.productId", 
        select: "title price images sellerId", 
        populate: { 
          path: "sellerId", // 2. Inside that Product, go populate the Seller
          model: "Seller",    // (Optional) Explicitly state the model if generic
          select: "shopName phoneNumber" // Select fields from Seller
      }
  })
      .populate("items.customRequestId", "title")  // Show custom request title
                // Show Shop Name
      .sort({ createdAt: -1 });

    res.json(orders);
  } catch (error) {
    res.status(500).json({ msg: error.message });
  }
};

// GET SHOP ORDERS (Seller Dashboard)
export const getSellerOrders = async (req, res) => {
  try {
    // Note: req.user.sellerId comes from the updated verifySeller middleware
    const orders = await Order.find({ sellerId: req.user.sellerId })
      .populate("buyerId", "name email")
      .populate("items.productId", "title")
      .sort({ createdAt: -1 });

    res.json(orders);
  } catch (error) {
    res.status(500).json({ msg: error.message });
  }
};

// D. UPDATE ORDER STATUS (Seller Action)
export const updateOrderStatus = async (req, res) => {
  try {
    const { orderId, status } = req.body;

    const order = await Order.findById(orderId);
    if (!order) return res.status(404).json({ msg: "Order not found" });

    // Security: Check if this seller owns the order
    if (order.sellerId.toString() !== req.user.sellerId.toString()) {
      return res.status(403).json({ msg: "Not authorized to update this order" });
    }

    order.status = status;
    await order.save();

    res.json({ success: true, msg: "Order status updated", status: order.status });
  } catch (error) {
    res.status(500).json({ msg: error.message });
  }
};



export const getUserOrders = async (req, res) => {
  try {
    const orders = await Order.find({ buyerId: req.user.id })
      .populate({
        path: "items.productId",
        select: "title images price" // Only get necessary fields
      })
      .populate({
        path: "items.customRequestId",
        select: "title description" // Get details for custom jobs
      })
      .populate("sellerId", "shopName") // Show which shop they bought from
      .sort({ createdAt: -1 }); // Newest orders first

    res.json(orders);
  } catch (error) {
    res.status(500).json({ msg: error.message });
  }
};