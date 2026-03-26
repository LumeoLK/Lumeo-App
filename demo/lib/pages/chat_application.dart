import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../model/conversation.dart';
import '../providers/chat_provider.dart';

class ChatApplication extends ConsumerStatefulWidget {
  final Conversation conversation;
  final String currentUserId;
  final String currentUserName;
  final String currentUserAvatar;
  final String otherUserAvatar;

  const ChatApplication({
    super.key,
    required this.conversation,
    required this.currentUserId,
    required this.currentUserName,
    this.currentUserAvatar = '',
    this.otherUserAvatar = '',
  });

  @override
  ConsumerState<ChatApplication> createState() => _ChatApplicationState();
}

class _ChatApplicationState extends ConsumerState<ChatApplication> {
  final Color accentColor = const Color(0xFFFDB04B);
  final Color darkBg = const Color(0xFF1E1E1E);
  final TextEditingController _messageController = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  late ChatNotifier _chatNotifier;

  @override
  void initState() {
    super.initState();
    _chatNotifier = ref.read(chatProvider.notifier);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _chatNotifier.loadMessages(widget.conversation.id);
    });
  }

  @override
  void dispose() {
    _chatNotifier.leaveChat();
    _messageController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

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
    if (text.isEmpty) return;
    _messageController.clear();
    _chatNotifier.sendMessage(
      conversationId: widget.conversation.id,
      text: text,
    );
    _scrollToBottom();
  }

  @override
  Widget build(BuildContext context) {
    final chatState = ref.watch(chatProvider);

    if (chatState.messages.isNotEmpty) {
      _scrollToBottom();
    }

    return Scaffold(
      backgroundColor: darkBg,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () async => await Navigator.maybePop(context),
        ),
        title: Row(
          children: [
            _buildAvatar(
              imageUrl: widget.otherUserAvatar,
              fallbackInitial: widget.conversation.shopName.isNotEmpty
                  ? widget.conversation.shopName[0].toUpperCase()
                  : '?',
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    widget.conversation.shopName,
                    style: const TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                    ),
                    overflow: TextOverflow.ellipsis,
                  ),
                  Text(
                    widget.conversation.productName,
                    style: const TextStyle(color: Colors.white60, fontSize: 12),
                    overflow: TextOverflow.ellipsis,
                  ),
                  if (chatState.isTyping)
                    const Text(
                      'typing...',
                      style: TextStyle(color: Colors.white60, fontSize: 12),
                    ),
                ],
              ),
            ),
          ],
        ),
      ),
      body: Column(
        children: [
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
          Expanded(
            child: chatState.isLoading
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

                              // Use String comparison to avoid ID type mismatches
                              final isMe =
                                  message.senderId.toString() ==
                                  widget.currentUserId.toString();

                              return _buildMessage(
                                text: message.text,
                                isMe: isMe,
                                imageUrl: isMe
                                    ? widget.currentUserAvatar
                                    : widget.otherUserAvatar,
                                fallbackInitial: message.senderName.isNotEmpty
                                    ? message.senderName[0].toUpperCase()
                                    : '?',
                              );
                            },
                          ),
                  ),
          ),
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

  Widget _buildMessage({
    required String text,
    required bool isMe,
    required String imageUrl,
    required String fallbackInitial,
  }) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(vertical: 10),
      child: Row(
        mainAxisAlignment: isMe
            ? MainAxisAlignment.end
            : MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          if (!isMe) ...[
            _buildAvatar(imageUrl: imageUrl, fallbackInitial: fallbackInitial),
            const SizedBox(width: 8),
          ],
          Flexible(
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
              decoration: BoxDecoration(
                color: isMe
                    ? accentColor.withOpacity(0.85)
                    : Colors.grey.shade200,
                borderRadius: BorderRadius.only(
                  topLeft: const Radius.circular(16),
                  topRight: const Radius.circular(16),
                  bottomLeft: Radius.circular(isMe ? 16 : 4),
                  bottomRight: Radius.circular(isMe ? 4 : 16),
                ),
              ),
              child: Text(
                text,
                style: TextStyle(
                  color: isMe ? Colors.black87 : Colors.black54,
                  fontWeight: isMe ? FontWeight.w500 : FontWeight.normal,
                  fontSize: 15,
                ),
              ),
            ),
          ),
          if (isMe) ...[
            const SizedBox(width: 8),
            _buildAvatar(imageUrl: imageUrl, fallbackInitial: fallbackInitial),
          ],
        ],
      ),
    );
  }

  Widget _buildAvatar({
    required String imageUrl,
    required String fallbackInitial,
  }) {
    return CircleAvatar(
      radius: 18,
      backgroundColor: accentColor,
      backgroundImage: imageUrl.isNotEmpty ? NetworkImage(imageUrl) : null,
      onBackgroundImageError: imageUrl.isNotEmpty ? (_, __) {} : null,
      child: imageUrl.isEmpty
          ? Text(
              fallbackInitial,
              style: const TextStyle(
                color: Colors.black,
                fontWeight: FontWeight.bold,
                fontSize: 14,
              ),
            )
          : null,
    );
  }
}
