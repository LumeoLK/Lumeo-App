export const setupSocket = (io) => {
  io.on("connection", (socket) => {
    console.log("User connected:", socket.id);

    //User joins their personal room (to receive messages)
    socket.on("join", (userId) => {
      socket.join(userId);
      console.log(`User ${userId} joined their room`);
    });

    //User opens a specific conversation
    socket.on("joinConversation", (conversationId) => {
      socket.join(conversationId);
      console.log(`Socket joined conversation: ${conversationId}`);
    });

    //Someone sends a message
    socket.on("sendMessage", (message) => {
      // Emit to everyone in that conversation room (including sender)
      io.to(message.conversationId).emit("newMessage", message);
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
