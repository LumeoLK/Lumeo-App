import mongoose from "mongoose";

const conversationSchema = new mongoose.Schema(
  {
    // The two people in this conversation
    participants: [
      {
        type: mongoose.Schema.Types.ObjectId,
        ref: "User", // References the User model
      },
    ],
    // Which product this chat is about
    product: {
      type: mongoose.Schema.Types.ObjectId,
      ref: "Product",
      required: true,
    },
    // The very last message
    lastMessage: {
      type: String,
      default: "",
    },
  },
  {
    timestamps: true,
  },
);

const conversation = mongoose.model("Conversation", conversationSchema);
export default conversation;
