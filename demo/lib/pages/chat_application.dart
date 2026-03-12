import 'package:flutter/material.dart';

class ChatApplication extends StatefulWidget {
  const ChatApplication({super.key});

  @override
  State<ChatApplication> createState() => _ChatApplicationState();
}

class _ChatApplicationState extends State<ChatApplication> {
  final Color accentColor = const Color(0xFFFDB04B); // Your yellow/orange
  final Color darkBg = const Color(0xFF1E1E1E);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: darkBg,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text(
          "Nathon James",
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        ),
      ),
      body: Column(
        children: [
          // 1. The White Chat Container
          Expanded(
            child: Container(
              margin: const EdgeInsets.symmetric(horizontal: 15, vertical: 10),
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.95),
                borderRadius: BorderRadius.circular(15),
              ),
              child: ListView(
                padding: const EdgeInsets.all(15),
                children: [
                  _buildMessage("M", "Hello!", isMe: false),
                  _buildMessage(
                    "J",
                    "Hello sir! How can I help you?",
                    isMe: true,
                  ),
                  _buildMessage(
                    "M",
                    "Can I customize this color into white?",
                    isMe: false,
                  ),
                  _buildMessage("J", "Of course sir.", isMe: true),
                  _buildMessage("M", "Typing...", isMe: false),
                ],
              ),
            ),
          ),

          // 2. The Input Area
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
                    child: const Center(
                      child: TextField(
                        style: TextStyle(color: Colors.white70),
                        decoration: InputDecoration(
                          hintText: "Thank You! I'll place my order now",
                          hintStyle: TextStyle(
                            color: Colors.white38,
                            fontSize: 14,
                          ),
                          border: InputBorder.none,
                        ),
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 15),
                Icon(Icons.send, color: Colors.white, size: 28),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // 3. Message Bubble Helper
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
