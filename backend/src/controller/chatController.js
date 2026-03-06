import Conversation from "../models/conversation.js";
import Message from "../models/message.js";

//Called when customer taps "Chat with Seller" on product detail page
export const startConversation = async (req, res) => {
  try {
    const { sellerId, productId } = req.body;
    const customerId = req.user.id;

    //Check if a conversation already exists for this customer, seller, product
    let conversation = await Conversation.findOne({
      participants: { $all: [customerId, sellerId] },
      product: productId,
    });

    // Create a new chat if the conversation does not exists
    if (!conversation) {
      conversation = await Conversation.create({
        participants: [customerId, sellerId],
        product: productId,
      });
    }

    // Populate participant details before sending back
    await conversation.populate("participants", "name email avatar role");

    res.status(200).json(conversation);
  } catch (error) {
    res.status(500).json({ message: "Server error", error: error.message });
  }
};

//retreiving all the conversation (returns a list of Chat Rooms)
export const getConversations = async (req, res) => {
  try {
    const conversations = await Conversation.find({
      participants: req.user.id, // Find all chats this user is part of
    })
      .populate("participants", "name avatar role")
      .populate("product", "name image") // Show product info in chat list
      .sort({ updatedAt: -1 }); // Most recent first

    res.json(conversations);
  } catch (error) {
    res.status(500).json({ message: "Server error", error: error.message });
  }
};

//Sending a message
export const sendMessage = async (req, res) => {
  try {
    const { conversationId, text } = req.body;

    // Create the message
    const message = await Message.create({
      conversation: conversationId,
      sender: req.user.id,
      text,
    });

    //Update the conversation's lastMessage preview
    await Conversation.findByIdAndUpdate(conversationId, {
      lastMessage: text,
    });

    //Populate sender info before returning
    await message.populate("sender", "name avatar");

    res.status(201).json(message);
  } catch (error) {
    res.status(500).json({ message: "Server error", error: error.message });
  }
};

//open a particular chat
export const getMessages = async (req, res) => {
  try {
    const messages = await Message.find({
      conversation: req.params.conversationId,
    })
      .populate("sender", "name avatar")
      .sort({ createdAt: 1 }); // Oldest first

    res.json(messages);
  } catch (error) {
    res.status(500).json({ message: "Server error", error: error.message });
  }
};
