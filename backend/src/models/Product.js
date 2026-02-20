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
  dominantColor: {
        type: [Number], // Stored as [R, G, B]
        default: [0, 0, 0]
    },
  
    imageEmbedding: {
        type: [Number], 
        select: false   
    },
  views: { type: Number, default: 0 },
  
  averageRating: {
    type: Number,
    default: 0,
    min: 0,
    max: 5,
    set: val => Math.round(val * 10) / 10 // Round to 1 decimal place (e.g., 4.6)
  },
  numReviews: {
    type: Number,
    default: 0
  },

}, { timestamps: true });

function arrayLimit(val) {
  return val.length <= 5;
}

// Text Index for fast keyword search
productSchema.index({ title: "text", description: "text" });

//Compound Index for filtering by category + price 
productSchema.index({ category: 1, price: 1 });

const Product = mongoose.model("Product", productSchema);
export default Product;