import 'package:flutter/material.dart';
import 'package:lumeo_v2/model/conversation.dart';
import 'package:lumeo_v2/pages/chat_application.dart';
import 'package:shared_preferences/shared_preferences.dart';

class SellerInboxSheet extends StatelessWidget {
  final List<Conversation> conversations;

  const SellerInboxSheet({super.key, required this.conversations});

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Container(
        padding: const EdgeInsets.all(16),
        child: ListView.builder(
          itemCount: conversations.length,
          itemBuilder: (context, index) {
            final conv = conversations[index];
            return ListTile(
              title: Text(conv.shopName),
              subtitle: Text(conv.lastMessage),
              onTap: () async {
                Navigator.pop(context);

                final prefs = await SharedPreferences.getInstance();
                final currentUserId = prefs.getString('userId') ?? '';
                final currentUserName = prefs.getString('userName') ?? 'Seller';

                if (!context.mounted) return;

                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => ChatApplication(
                      conversation: conv,
                      currentUserId: currentUserId,
                      currentUserName: currentUserName,
                    ),
                  ),
                );
              },
            );
          },
        ),
      ),
    );
  }
}