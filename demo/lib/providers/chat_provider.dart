import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_riverpod/legacy.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../model/message.dart';
import '../services/chat_service.dart';
import '../services/socket_service.dart';

// The details displayed in the UI
class ChatState {
  final List<Message> messages; // all the chat bubbles
  final bool isLoading; // show spinner while fetching history
  final bool isTyping; // show "typing..." when other person types
  final String? error; // show error banner if something goes wrong

  const ChatState({
    this.messages = const [],
    this.isLoading = false,
    this.isTyping = false,
    this.error,
  });

  // Creates a new ChatState with only the fields that was specify changed
  ChatState copyWith({
    List<Message>? messages,
    bool? isLoading,
    bool? isTyping,
    String? error,
  }) {
    return ChatState(
      messages: messages ?? this.messages,
      isLoading: isLoading ?? this.isLoading,
      isTyping: isTyping ?? this.isTyping,
      error: error, // clears the error
    );
  }
}

// The UI calls methods on this, and it updates the state
class ChatNotifier extends StateNotifier<ChatState> {
  final ChatService _chatService;
  final SocketService _socketService = SocketService(); // singleton instance

  ChatNotifier(this._chatService) : super(const ChatState());

  // Called when the chat screen opens
  // Fetches message history via HTTP
  // Joins the socket room for this conversation
  // Sets up listeners for real-time events
  Future<void> loadMessages(String conversationId) async {
    state = state.copyWith(isLoading: true);

    try {
      // load history from backend via HTTP
      final messages = await _chatService.getMessages(conversationId);
      state = state.copyWith(messages: messages, isLoading: false);

      // join the socket room
      // Now the server knows to send us messages for this conversation
      _socketService.joinConversation(conversationId);

      // clear any old listeners first
      // This prevents duplicate messages if the user left and came back
      _socketService.offNewMessage();
      _socketService.offTyping();

      // listen for new messages arriving in real time
      // When the other person sends a message, this fires automatically
      _socketService.onNewMessage((data) {
        final newMsg = Message.fromJson(Map<String, dynamic>.from(data));

        // Check if we already have this message
        // This prevents duplicates of our own sent messages come back
        // through the socket too since we're in the same room
        final alreadyExists = state.messages.any((m) => m.id == newMsg.id);
        if (!alreadyExists) {
          state = state.copyWith(messages: [...state.messages, newMsg]);
        }
      });

      // listen for typing indicators
      _socketService.onUserTyping((_) {
        state = state.copyWith(isTyping: true);
      });

      _socketService.onUserStoppedTyping((_) {
        state = state.copyWith(isTyping: false);
      });
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        error: 'Could not load messages: $e',
      );
    }
  }

  // Called when user taps the send button
  Future<void> sendMessage({
    required String conversationId,
    required String text,
  }) async {
    final prefs = await SharedPreferences.getInstance();
    final currentUserId = prefs.getString('userId') ?? '';
    // Optimistic UI
    // Add a temporary message immediately so the UI feels instant
    // The user sees their message right away without waiting for the server
    final tempMessage = Message(
      id: 'temp_${DateTime.now().millisecondsSinceEpoch}',
      conversationId: conversationId,
      text: text,
      senderId: currentUserId,
      senderName: "",
      createdAt: DateTime.now(),
    );
    state = state.copyWith(messages: [...state.messages, tempMessage]);

    try {
      // Save to backend via HTTP
      // This persists the message to MongoDB
      final savedMessage = await _chatService.sendMessage(
        conversationId: conversationId,
        text: text,
      );

      // Replace the temporary message with the real saved one
      // The real one has a proper MongoDB _id instead of our fake temp id
      final updatedMessages = state.messages
          .map((m) => m.id == tempMessage.id ? savedMessage : m)
          .toList();
      state = state.copyWith(messages: updatedMessages);

      // Broadcast via socket so the other person sees it instantly
      _socketService.sendMessage({
        'conversationId': conversationId,
        '_id': savedMessage.id,
        'text': savedMessage.text,
        'conversation': conversationId,
        'createdAt': savedMessage.createdAt.toIso8601String(),
      });
    } catch (e) {
      // If saving failed, remove the optimistic message
      // and show an error so the user knows to try again
      final rolledBack = state.messages
          .where((m) => m.id != tempMessage.id)
          .toList();
      state = state.copyWith(
        messages: rolledBack,
        error: 'Failed to send message. Try again.',
      );
    }
  }

  void leaveChat() {
    _socketService.offNewMessage();
    _socketService.offTyping();
  }

  @override
  void dispose() {
    _socketService.offNewMessage();
    _socketService.offTyping();
    super.dispose();
  }
}

final chatServiceProvider = Provider((ref) => ChatService());

final chatProvider = StateNotifierProvider.autoDispose<ChatNotifier, ChatState>(
  (ref) {
    return ChatNotifier(ref.read(chatServiceProvider));
  },
);
