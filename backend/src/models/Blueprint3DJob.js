import mongoose from "mongoose";

const blueprint3DJobSchema = new mongoose.Schema(
  {
    blueprintImageUrl: {
      type: String,
      required: true,
    },

    model3DUrl: {
      type: String,
      default: null,
    },

    queueJobId: {
      type: String,
    },

    status: {
      type: String,
      enum: ["pending", "processing", "completed", "failed"],
      default: "pending",
    },

    errorMessage: {
      type: String,
      default: null,
    },
  },
  { timestamps: true }
);

export default mongoose.model("Blueprint3DJob", blueprint3DJobSchema);