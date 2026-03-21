// import 'package:flutter_riverpod/flutter_riverpod.dart';
// import 'package:flutter_riverpod/legacy.dart';
// import '../model/message.dart';
// import '../services/chat_service.dart';
// import '../Constants.dart';

// class ChatState {
//   final List<Message> messages;
//   final bool isLoading;
//   final String? error;

//   const ChatState({
//     this.messages = const [],
//     this.isLoading = false,
//     this.error,
//   });

//   ChatState copyWith({
//     List<Message>? messages,
//     bool? isLoading,
//     String? error,
//   }) {
//     return ChatState(
//       messages: messages ?? this.messages,
//       isLoading: isLoading ?? this.isLoading,
//       error: error ?? this.error,
//     );
//   }
// }

// class ChatNotifier extends StateNotifier<ChatState> {
//   final ChatService _service;
//   IO.Socket? _socket;

//   ChatNotifier(this._service) : super(const ChatState());

//   // Load messages when chat screen opens
//   Future<void> fetchMessages(String conversationId) async {
//     state = state.copyWith(isLoading: true, error: null);
//     try {
//       final messages = await _service.getMessages(conversationId);
//       state = state.copyWith(messages: messages, isLoading: false);
//     } catch (e) {
//       state = state.copyWith(error: e.toString(), isLoading: false);
//     }
//   }

//   // Send message
//   Future<void> sendMessage({
//     required String conversationId,
//     required String text,
//     required String currentUserId,
//   }) async {
//     try {
//       // Save to DB
//       final message = await _service.sendMessage(
//         conversationId: conversationId,
//         text: text,
//       );

//       // Add to local state immediately
//       state = state.copyWith(messages: [...state.messages, message]);

//       // Emit via socket
//       _socket?.emit('sendMessage', {
//         'conversationId': conversationId,
//         'senderId': currentUserId,
//         'text': text,
//       });
//     } catch (e) {
//       state = state.copyWith(error: e.toString());
//     }
//   }

//   // Connect socket when chat screen opens
//   void connectSocket(String userId, String conversationId) {
//     _socket = IO.io(Constants.baseUrl, {
//       'transports': ['websocket'],
//       'autoConnect': true,
//     });

//     _socket!.onConnect((_) {
//       _socket!.emit('join', userId);
//       _socket!.emit('joinConversation', conversationId);
//     });

//     // New message arrives in real time
//     _socket!.on('newMessage', (data) {
//       final message = Message.fromJson(data);
//       // avoid duplicates
//       final exists = state.messages.any((m) => m.id == message.id);
//       if (!exists) {
//         state = state.copyWith(messages: [...state.messages, message]);
//       }
//     });
//   }

//   // Disconnect when leaving chat screen 
//   void disconnectSocket() {
//     _socket?.disconnect();
//     _socket = null;
//     state = const ChatState(); // reset state
//   }
// }

// final chatServiceProvider = Provider((ref) => ChatService());

// final chatProvider = StateNotifierProvider<ChatNotifier, ChatState>((ref) {
//   return ChatNotifier(ref.watch(chatServiceProvider));
// });
