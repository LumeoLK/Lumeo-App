import mongoose from "mongoose";

const orderSchema = mongoose.Schema({
  // 1. The Buyer
  buyerId: {
    type: mongoose.Schema.Types.ObjectId,
    ref: "User",
    required: true,
  },

  // 2. The Shop (Seller)
  // Note: If a user buys from 2 different shops, you should create 2 separate Order documents.
  sellerId: {
    type: mongoose.Schema.Types.ObjectId,
    ref: "Seller",
    required: true,
  },

  // 3. The Products
  items: [
    {
      productId: { type: mongoose.Schema.Types.ObjectId, ref: "Product" }, // For standard items
      customRequestId: { type: mongoose.Schema.Types.ObjectId, ref: "CustomRequest" }, // For custom jobs
      quantity: { type: Number, default: 1 },
      priceAtPurchase: { type: Number, required: true } // Store price here in case it changes later
    }
  ],

  // 4. Financials
  totalAmount: { type: Number, required: true },
  paymentMethod: { type: String, enum: ["cod", "card"], default: "cod" },
  paymentStatus: { type: String, enum: ["pending", "paid", "failed"], default: "pending" },

  // 5. Shipping Information
  shippingAddress: {
    address: { type: String, required: true },
    city: { type: String, required: true },
    postalCode: { type: String, required: true },
    phone: { type: String, required: true }
  },

  // 6. Order Status
  status: {
    type: String,
    enum: ["pending", "processing", "shipped", "delivered", "cancelled"],
    default: "pending"
  }
}, { timestamps: true });

const Order = mongoose.model("Order", orderSchema);
export default Order;