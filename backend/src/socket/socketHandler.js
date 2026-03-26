export const setupSocket = (io) => {
  // Verify JWT before allowing any connection
  io.use((socket, next) => {
    const token = socket.handshake.auth?.token;
    if (!token) return next(new Error("Authentication required"));
    try {
      const decoded = jwt.verify(token, process.env.JWT_SECRET);
      socket.data.userId = decoded.id;
      next();
    } catch {
      next(new Error("Invalid token"));
    }
  });

  io.on("connection", (socket) => {
    console.log("User connected:", socket.id);

    //User joins their personal room (to receive messages)
    socket.join(socket.data.userId);

    //User opens a specific conversation
    socket.on("joinConversation", (conversationId) => {
      socket.join(conversationId);
      console.log(`Socket joined conversation: ${conversationId}`);
    });

    //Someone sends a message
    socket.on("sendMessage", (message) => {
      const trustedMessage = {
        ...message,
        sender: {
          _id: socket.data.userId,
          name: message.sender?.name ?? "",
        },
      };
      // Emit to everyone in that conversation room (including sender)
      io.to(message.conversationId).emit("newMessage", trustedMessage);
    });

    //Typing indicator
    socket.on("typing", ({ conversationId, userId }) => {
      socket.to(conversationId).emit("userTyping", { userId });
    });

    socket.on("stopTyping", ({ conversationId }) => {
      socket.to(conversationId).emit("userStoppedTyping");
    });

    socket.on("disconnect", () => {
      console.log("User disconnected:", socket.id);
    });
  });
};

export default setupSocket;
