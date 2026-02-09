import mongoose from "mongoose";

const bidSchema = mongoose.Schema({
  requestId: {
    type: mongoose.Schema.Types.ObjectId,
    ref: "CustomRequest",
    required: true,
  },
  sellerId: {
    type: mongoose.Schema.Types.ObjectId,
    ref: "Seller",
    required: true,
  },
  
 images: [{
    type: String, 
    validate: [arrayLimit, '{PATH} exceeds the limit of 3 im ages'],
  }],
  price: { type: Number, required: true },
  message: { type: String }, 
  estimatedDays: { type: Number, required: true }, 
  
  status: {
    type: String,
    enum: ["pending", "accepted", "rejected"],
    default: "pending"
  }
}, { timestamps: true });

const Bid = mongoose.model("Bid", bidSchema);
export default Bid;

function arrayLimit(val) {
  return val.length <= 3;
}