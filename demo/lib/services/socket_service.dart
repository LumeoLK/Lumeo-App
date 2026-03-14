import 'package:socket_io_client/socket_io_client.dart' as IO;
import '../Constants.dart';

class SocketService {
  // Singleton — only one socket connection ever exists in the app
  static final SocketService _instance = SocketService._internal();
  factory SocketService() => _instance;
  SocketService._internal();

  // The actual socket connection object
  late IO.Socket socket;

  // Called once after login — opens the persistent connection to your server
  void connect(String userId) {
    socket = IO.io(
      Constants.baseUrl, // Android emulator → your machine
      IO.OptionBuilder()
          .setTransports(['websocket']) // use websocket not long-polling
          .disableAutoConnect() // we control when to connect manually
          .build(),
    );

    socket.connect(); // open the connection

    socket.onConnect((_) {
      print('Socket connected');
      socket.emit('join', userId); // tell server which user room we belong to
    });

    socket.onDisconnect((_) => print('Socket disconnected'));
  }

  // Called when user opens a specific chat screen
  // This tells the server "I'm in this conversation room now"
  void joinConversation(String conversationId) {
    socket.emit('joinConversation', conversationId);
  }

  // Called when user taps send — broadcasts message to everyone in the room
  void sendMessage(Map<String, dynamic> message) {
    socket.emit('sendMessage', message);
  }

  // Listen for incoming messages from the other person
  // The handler is a function that runs every time a new message arrives
  void onNewMessage(Function(dynamic) handler) {
    socket.on('newMessage', handler);
  }

  // Remove the listener — important when leaving the chat screen
  // Without this, old listeners stack up and you get duplicate messages
  void offNewMessage() => socket.off('newMessage');

  // Typing indicators
  void emitTyping(String conversationId, String userId) {
    socket.emit('typing', {'conversationId': conversationId, 'userId': userId});
  }

  void stopTyping(String conversationId) {
    socket.emit('stopTyping', {'conversationId': conversationId});
  }

  void onUserTyping(Function(dynamic) handler) {
    socket.on('userTyping', handler);
  }

  void onUserStoppedTyping(Function(dynamic) handler) {
    socket.on('userStoppedTyping', handler);
  }

  void offTyping() {
    socket.off('userTyping');
    socket.off('userStoppedTyping');
  }

  void disconnect() => socket.disconnect();
}
