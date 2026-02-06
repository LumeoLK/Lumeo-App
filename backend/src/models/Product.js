import mongoose from "mongoose";

const productSchema = mongoose.Schema({
 
  sellerId: {
    type: mongoose.Schema.Types.ObjectId,
    ref: "Seller",
    required: true,
  },


  title: {
    type: String,
    required: true,
    trim: true,
  },
  description: {
    type: String,
    required: true,
  },
  price: {
    type: Number,
    required: true,
    min: 0,
  },
  category: {
    type: String, 
    required: true,
    enum: ["Living Room", "Bedroom", "Office", "Kitchen", "Decor"], 
    index: true, 
  },
  stock: {
    type: Number,
    default: 1, 
    min: 0,
  },

 
  images: [{
    type: String, 
    validate: [arrayLimit, '{PATH} exceeds the limit of 5 images'],
  }],

 
  dimensions: {
    length: { type: Number, required: true }, 
    width:  { type: Number, required: true }, 
    height: { type: Number, required: true }, 
    unit: { type: String, default: "cm" }
  },

 
  views: { type: Number, default: 0 },

}, { timestamps: true });

function arrayLimit(val) {
  return val.length <= 5;
}

const Product = mongoose.model("Product", productSchema);
export default Product;