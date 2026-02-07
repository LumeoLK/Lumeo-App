import mongoose from "mongoose";

const sellerSchema = mongoose.Schema({
  userId: {
    type: mongoose.Schema.Types.ObjectId,
    ref: "User", // Links to the User model
    required: true,
    unique: true // One user can only have one shop (for now)
  },
  shopName: {
    type: String,
    required: true,
    unique: true, // Shop names must be unique
    trim: true
  },
  displayName: {
    type: String,
    required: true
  },
  phoneNumber: {
    type: String,
    required: true
  },
  businessAddress: {
    type: String,
    required: true
  },
  businessRegNumber: {
    type: String
  },
  logo: {
    type: String,
    default: ""
  },
  NICfront: {
    type: String,
    default: ""
  },
  NICback: {
    type: String,
    default: ""
  },
  isVerified: {
    type: Boolean,
    default: false 
  },
 
  rating: { type: Number, default: 0 },
  totalSales: { type: Number, default: 0 },
}, { timestamps: true });

const Seller = mongoose.model("Seller", sellerSchema);
export default Seller;