import mongoose from "mongoose";

const customRequestSchema = mongoose.Schema({
  userId: {
    type: mongoose.Schema.Types.ObjectId,
    ref: "User",
    required: true,
  },
  
  title: { type: String, required: true },
  description: { type: String, required: true },
  referenceImages: [{ type: String }],
  
 
  budget: { type: Number, required: true }, 
  deadline: { type: Date }, 
  
  
  status: {
    type: String,
    enum: ["open", "closed", "completed"],
    default: "open"
  },
  winningBidId: {
    type: mongoose.Schema.Types.ObjectId,
    ref: "Bid",
    default: null
  }
}, { timestamps: true });

const CustomRequest = mongoose.model("CustomRequest", customRequestSchema);
export default CustomRequest;