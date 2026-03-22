import Order from "../models/order.js";
import Product from "../models/Product.js";
import Cart from "../models/cart.js";
import mongoose from "mongoose";

const toObjectIdString = (value) => {
  if (!value) return "";
  if (typeof value === "string") return value;
  if (typeof value === "object" && value._id) return String(value._id);
  return String(value);
};

const buildOrderProductSnapshot = (productDoc, item) => ({
  _id: productDoc?._id || item.productId,
  title: productDoc?.title || item.title || "Product",
  images: Array.isArray(productDoc?.images) ? productDoc.images : [],
  price: Number(productDoc?.price ?? item.priceAtPurchase ?? 0),
  sellerId: productDoc?.sellerId || item.sellerId || null,
});

const withProductSnapshots = async (orders) => {
  const productIds = [
    ...new Set(
      orders
        .flatMap((order) => order.items || [])
        .map((item) => toObjectIdString(item?.productId))
        .filter(Boolean),
    ),
  ];

  if (!productIds.length) {
    return orders;
  }

  const products = await Product.find({ _id: { $in: productIds } })
    .select("title images price sellerId")
    .lean();

  const productById = new Map(products.map((p) => [String(p._id), p]));

  return orders.map((order) => ({
    ...order,
    items: (order.items || []).map((item) => {
      const productId = toObjectIdString(item?.productId);
      const productDoc = productById.get(productId);

      return {
        ...item,
        productId: buildOrderProductSnapshot(productDoc, item),
      };
    }),
  }));
};

// A. CREATE ORDER (Checkout) - Deprecated: Use placeOrder instead
export const createOrder = async (req, res) => {
  try {
    const { shippingAddress, paymentMethod } = req.body;
    const cart = await Cart.findOne({ userId: req.user.id }).populate("items.productId");
    if (!cart || cart.items.length === 0) {
      return res.status(400).json({ msg: "Cart is empty" });
    }

    if (!shippingAddress || typeof shippingAddress !== "object") {
      return res.status(400).json({ msg: "shippingAddress is required" });
    }

    if (!["cod", "card"].includes(paymentMethod)) {
      return res.status(400).json({ msg: "Invalid payment method" });
    }

    const session = await mongoose.startSession();
    session.startTransaction();

    try {
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
          priceAtPurchase: product.price,
          quantity: item.quantity,
        });
      }

      const sellerIds = [
        ...new Set(orderItems.map((item) => toObjectIdString(item.sellerId)).filter(Boolean)),
      ];
      const primarySellerId = sellerIds.length > 0 ? sellerIds[0] : null;

      const [newOrder] = await Order.create(
        [{
          buyerId: req.user.id,
          sellerId: primarySellerId,
          items: orderItems,
          totalAmount,
          shippingAddress,
          paymentMethod,
          status: "pending",
        }],
        { session }
      );

      await Cart.deleteOne({ userId: req.user.id }).session(session);
      await session.commitTransaction();
      session.endSession();

      res.status(201).json({ success: true, order: newOrder });
    } catch (error) {
      await session.abortTransaction();
      session.endSession();
      throw error;
    }
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

    if (!shippingAddress || typeof shippingAddress !== "object") {
      return res.status(400).json({ msg: "shippingAddress is required" });
    }

    const normalizedShippingAddress = {
      address: shippingAddress.address,
      city: shippingAddress.city,
      postalCode: shippingAddress.postalCode,
      phone: shippingAddress.phone || shippingAddress.phoneNumber,
    };

    if (
      !normalizedShippingAddress.address ||
      !normalizedShippingAddress.city ||
      !normalizedShippingAddress.postalCode ||
      !normalizedShippingAddress.phone
    ) {
      return res.status(400).json({
        msg: "shippingAddress requires address, city, postalCode and phone",
      });
    }

    
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

    const sellerIds = [
      ...new Set(orderItems.map((item) => toObjectIdString(item.sellerId)).filter(Boolean)),
    ];

    // Use first seller ID or null if none found
    const primarySellerId = sellerIds.length > 0 ? sellerIds[0] : null;

    const [order] = await Order.create([{
      buyerId: userId,
      sellerId: primarySellerId,
      items: orderItems,
      totalAmount,
      shippingAddress: normalizedShippingAddress,
      paymentMethod,
      paymentStatus: "pending",
      status: paymentMethod === "cod" ? "confirmed" : "pending"
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

    console.error("Order creation error:", error.message);
    return res.status(500).json({
      success: false,
      msg: error.message || "Failed to create order"
    });
  }
};

export const getMyOrders = async (req, res) => {
  try {
    const orders = await Order.find({ buyerId: req.user.id })
      .sort({ createdAt: -1 })
      .setOptions({ strictPopulate: false });

    const safeOrders = await withProductSnapshots(orders);

    res.json(safeOrders);
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
      .sort({ createdAt: -1 })
      .setOptions({ strictPopulate: false });

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
      .lean()
      .sort({ createdAt: -1 }) // Newest orders first
      .setOptions({ strictPopulate: false });

    const safeOrders = await withProductSnapshots(orders);

    res.json(safeOrders);
  } catch (error) {
    res.status(500).json({ msg: error.message });
  }
};