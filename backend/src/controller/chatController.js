import Conversation from "../models/conversation.js";
import Message from "../models/message.js";
import Seller from "../models/seller.js";

// Called when customer taps "Chat with Seller" on product detail page
export const startConversation = async (req, res) => {
  try {
    const { sellerId, productId } = req.body;
    const customerId = req.user.id;

    // sellerId from frontend is Seller._id
    // Convert it to the linked User._id for chat participants
    const seller = await Seller.findById(sellerId);

    if (!seller) {
      return res.status(404).json({ message: "Seller not found" });
    }

    const sellerUserId = seller.userId.toString();

    // Check if a conversation already exists for this customer, seller user, and product
    let conversation = await Conversation.findOne({
      participants: { $all: [customerId, sellerUserId] },
      product: productId,
    });

    // Create a new chat if the conversation does not exist
    if (!conversation) {
      conversation = await Conversation.create({
        participants: [customerId, sellerUserId],
        product: productId,
      });
    }

    // Populate participant details before sending back
    await conversation.populate("participants", "name email profilePicture role");
    await conversation.populate("product", "title images");

    res.status(200).json(conversation);
  } catch (error) {
    res.status(500).json({ message: "Server error", error: error.message });
  }
};

// Retrieving all conversations (returns a list of chat rooms)
export const getConversations = async (req, res) => {
  try {
    const conversations = await Conversation.find({
      participants: req.user.id,
    })
      .populate("participants", "name profilePicture role")
      .populate("product", "title images")
      .sort({ updatedAt: -1 });

    res.json(conversations);
  } catch (error) {
    res.status(500).json({ message: "Server error", error: error.message });
  }
};

// Sending a message
export const sendMessage = async (req, res) => {
  try {
    const { conversationId, text } = req.body;

    const message = await Message.create({
      conversation: conversationId,
      sender: req.user.id,
      text,
    });

    // Update conversation preview and timestamp
    await Conversation.findByIdAndUpdate(conversationId, {
      lastMessage: text,
      updatedAt: new Date(),
    });

    // Populate sender info before returning
    await message.populate("sender", "name profilePicture");

    res.status(201).json(message);
  } catch (error) {
    res.status(500).json({ message: "Server error", error: error.message });
  }
};

// Open a particular chat
export const getMessages = async (req, res) => {
  try {
    const messages = await Message.find({
      conversation: req.params.conversationId,
    })
      .populate("sender", "name profilePicture")
      .sort({ createdAt: 1 });

    res.json(messages);
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
