import Order from "../models/Order.js";
import Product from "../models/Product.js";

// A. CREATE ORDER (Checkout)
// This is called when User clicks "Place Order" in the App
export const createOrder = async (req, res) => {
  try {
    const { sellerId, items, totalAmount, shippingAddress, paymentMethod } = req.body;

    // Basic Validation
    if (!items || items.length === 0) {
      return res.status(400).json({ msg: "No items in order" });
    }

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

// B. GET MY ORDERS (User History)
export const getMyOrders = async (req, res) => {
  try {
    const orders = await Order.find({ buyerId: req.user.id })
      .populate("items.productId", "title images") // Show product name & image
      .populate("items.customRequestId", "title")  // Show custom request title
      .populate("sellerId", "shopName")            // Show Shop Name
      .sort({ createdAt: -1 });

    res.json(orders);
  } catch (error) {
    res.status(500).json({ msg: error.message });
  }
};

// C. GET SHOP ORDERS (Seller Dashboard)
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