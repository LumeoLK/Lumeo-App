import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../model/conversation.dart';
import '../providers/chat_provider.dart';

class ChatApplication extends ConsumerStatefulWidget {
  final Conversation conversation; // the chat room we're in
  final String currentUserId; // logged in user's id
  final String currentUserName; // logged in user's name

  const ChatApplication({
    super.key,
    required this.conversation,
    required this.currentUserId,
    required this.currentUserName,
  });

  @override
  ConsumerState<ChatApplication> createState() => _ChatApplicationState();
}

class _ChatApplicationState extends ConsumerState<ChatApplication> {
  final Color accentColor = const Color(0xFFFDB04B);
  final Color darkBg = const Color(0xFF1E1E1E);
  final TextEditingController _messageController = TextEditingController();
  final ScrollController _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    // Load message history + set up socket listeners
    // Future.microtask ensures this runs after the widget is built
    Future.microtask(
      () =>
          ref.read(chatProvider.notifier).loadMessages(widget.conversation.id),
    );
  }

  @override
  void dispose() {
    // Clean up when user leaves the chat screen
    // This removes socket listeners so we don't get duplicate messages
    ref.read(chatProvider.notifier).leaveChat();
    _messageController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  // Scrolls to the bottom of the message list
  // Called every time a new message arrives
  void _scrollToBottom() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_scrollController.hasClients) {
        _scrollController.animateTo(
          _scrollController.position.maxScrollExtent,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOut,
        );
      }
    });
  }

  void _sendMessage() {
    final text = _messageController.text.trim();
    if (text.isEmpty) return; // don't send empty messages

    _messageController.clear();

    // Tell the provider to send the message
    // Provider handles optimistic UI + HTTP save + socket broadcast
    ref
        .read(chatProvider.notifier)
        .sendMessage(
          conversationId: widget.conversation.id,
          text: text,
          currentUserId: widget.currentUserId,
          currentUserName: widget.currentUserName,
        );

    _scrollToBottom();
  }

  @override
  Widget build(BuildContext context) {
    // Watch the provider — UI rebuilds whenever state changes
    // e.g. new message arrives, loading state changes, error occurs
    final chatState = ref.watch(chatProvider);

    // Auto scroll when new messages arrive
    if (chatState.messages.isNotEmpty) {
      _scrollToBottom();
    }

    return Scaffold(
      backgroundColor: darkBg,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Show product name in the app bar
            Text(
              widget.conversation.productName,
              style: const TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold,
                fontSize: 16,
              ),
            ),
            // Show typing indicator under the name
            if (chatState.isTyping)
              const Text(
                'typing...',
                style: TextStyle(color: Colors.white60, fontSize: 12),
              ),
          ],
        ),
      ),
      body: Column(
        children: [
          // Error banner — shows if something went wrong
          if (chatState.error != null)
            Container(
              width: double.infinity,
              color: Colors.red.withOpacity(0.8),
              padding: const EdgeInsets.all(8),
              child: Text(
                chatState.error!,
                style: const TextStyle(color: Colors.white),
                textAlign: TextAlign.center,
              ),
            ),

          // Message list
          Expanded(
            child: chatState.isLoading
                // Show spinner while loading history
                ? const Center(child: CircularProgressIndicator())
                : Container(
                    margin: const EdgeInsets.symmetric(
                      horizontal: 15,
                      vertical: 10,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.95),
                      borderRadius: BorderRadius.circular(15),
                    ),
                    child: chatState.messages.isEmpty
                        // Show empty state if no messages yet
                        ? const Center(
                            child: Text(
                              'No messages yet.\nSay hello!',
                              textAlign: TextAlign.center,
                              style: TextStyle(color: Colors.black38),
                            ),
                          )
                        : ListView.builder(
                            controller: _scrollController,
                            padding: const EdgeInsets.all(15),
                            itemCount: chatState.messages.length,
                            itemBuilder: (context, index) {
                              final message = chatState.messages[index];

                              // Compare senderId to know which side to show
                              // your messages on the right, theirs on the left
                              final isMe =
                                  message.senderId == widget.currentUserId;

                              return _buildMessage(
                                // First letter of sender's name for avatar
                                message.senderName.isNotEmpty
                                    ? message.senderName[0].toUpperCase()
                                    : '?',
                                message.text,
                                isMe: isMe,
                              );
                            },
                          ),
                  ),
          ),

          // Input area
          Padding(
            padding: const EdgeInsets.all(20.0),
            child: Row(
              children: [
                Expanded(
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 20),
                    height: 50,
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(5),
                    ),
                    child: Center(
                      child: TextField(
                        controller: _messageController,
                        style: const TextStyle(color: Colors.white70),
                        decoration: const InputDecoration(
                          hintText: 'Type a message...',
                          hintStyle: TextStyle(
                            color: Colors.white38,
                            fontSize: 14,
                          ),
                          border: InputBorder.none,
                        ),
                        // Allow sending with keyboard done button
                        onSubmitted: (_) => _sendMessage(),
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 15),
                GestureDetector(
                  onTap: _sendMessage,
                  child: const Icon(Icons.send, color: Colors.white, size: 28),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMessage(String initial, String text, {required bool isMe}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 10),
      child: Row(
        mainAxisAlignment: isMe
            ? MainAxisAlignment.end
            : MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          if (!isMe) _buildAvatar(initial),
          const SizedBox(width: 10),
          Flexible(
            child: Text(
              text,
              style: TextStyle(
                color: isMe ? Colors.black87 : Colors.black54,
                fontWeight: isMe ? FontWeight.bold : FontWeight.normal,
                fontSize: 15,
              ),
            ),
          ),
          const SizedBox(width: 10),
          if (isMe) _buildAvatar(initial),
        ],
      ),
    );
  }

  Widget _buildAvatar(String initial) {
    return CircleAvatar(
      radius: 18,
      backgroundColor: accentColor,
      child: Text(
        initial,
        style: const TextStyle(
          color: Colors.black,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }
}
