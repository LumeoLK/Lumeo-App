import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../model/conversation.dart';
import '../services/chat_service.dart';
import '../pages/chat_application.dart';

/// Opens the seller inbox as a modal bottom sheet.
///
/// Call this from anywhere in the seller flow — e.g. the Messages tab
/// in [SellerShell] — by awaiting [showSellerInbox].
///
/// Example:
/// ```dart
/// case 2: // Messages tab
///   await showSellerInbox(context);
///   break;
/// ```
Future<void> showSellerInbox(BuildContext context) async {
  final chatService = ChatService();

  try {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('x-auth-token')?.trim() ?? '';

    if (token.isEmpty) {
      if (!context.mounted) return;
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Please log in first')));
      return;
    }

    final conversations = await chatService.getConversations();

    if (!context.mounted) return;

    final sellerUserId =
        prefs.getString('userId') ?? prefs.getString('id') ?? '';
    final sellerName =
        prefs.getString('userName') ?? prefs.getString('name') ?? 'Seller';

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: const Color(0xFF1a1a1a),
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (_) => SellerInboxSheet(
        conversations: conversations,
        sellerUserId: sellerUserId,
        sellerName: sellerName,
      ),
    );
  } catch (e) {
    if (!context.mounted) return;
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(SnackBar(content: Text('Failed to load conversations: $e')));
  }
}

/// The bottom sheet UI that lists all seller conversations.
///
/// Tapping a conversation navigates to [ChatApplication].
/// This widget is intentionally stateless — all data is passed in
/// by [showSellerInbox] after being fetched.
class SellerInboxSheet extends StatelessWidget {
  const SellerInboxSheet({
    super.key,
    required this.conversations,
    required this.sellerUserId,
    required this.sellerName,
  });

  final List<Conversation> conversations;
  final String sellerUserId;
  final String sellerName;

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: SizedBox(
        height: MediaQuery.of(context).size.height * 0.75,
        child: Column(
          children: [
            _buildHandle(),
            _buildHeader(),
            const SizedBox(height: 4),
            Expanded(
              child: conversations.isEmpty
                  ? _buildEmpty()
                  : _buildConversationList(context),
            ),
          ],
        ),
      ),
    );
  }

  // ── Sub-widgets ───────────────────────────────────────────

  Widget _buildHandle() {
    return Padding(
      padding: const EdgeInsets.only(top: 14, bottom: 10),
      child: Container(
        width: 40,
        height: 4,
        decoration: BoxDecoration(
          color: Colors.white24,
          borderRadius: BorderRadius.circular(999),
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return const Padding(
      padding: EdgeInsets.only(bottom: 8),
      child: Text(
        'Messages',
        style: TextStyle(
          color: Colors.white,
          fontSize: 18,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }

  Widget _buildEmpty() {
    return const Center(
      child: Text('No messages yet', style: TextStyle(color: Colors.white70)),
    );
  }

  Widget _buildConversationList(BuildContext context) {
    return ListView.separated(
      itemCount: conversations.length,
      separatorBuilder: (_, __) =>
          const Divider(color: Colors.white10, height: 1),
      itemBuilder: (context, index) {
        final conv = conversations[index];
        return _ConversationTile(
          conversation: conv,
          sellerUserId: sellerUserId,
          sellerName: sellerName,
        );
      },
    );
  }
}

/// A single conversation row inside [SellerInboxSheet].
///
/// Extracted as its own widget to keep [SellerInboxSheet] clean
/// and to give this tile a natural place to grow (unread badges,
/// timestamps, online indicators, etc.).
class _ConversationTile extends StatelessWidget {
  const _ConversationTile({
    required this.conversation,
    required this.sellerUserId,
    required this.sellerName,
  });

  final Conversation conversation;
  final String sellerUserId;
  final String sellerName;

  @override
  Widget build(BuildContext context) {
    return ListTile(
      leading: const CircleAvatar(
        backgroundColor: Color(0xFFFBB040),
        child: Icon(Icons.person, color: Colors.black),
      ),
      title: Text(
        conversation.shopName,
        style: const TextStyle(color: Colors.white),
      ),
      subtitle: Text(
        conversation.lastMessage.isEmpty
            ? conversation.productName
            : conversation.lastMessage,
        style: const TextStyle(color: Colors.white60),
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
      ),
      onTap: () {
        Navigator.pop(context);
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (_) => ChatApplication(
              conversation: conversation,
              currentUserId: sellerUserId,
              currentUserName: sellerName,
            ),
          ),
        );
      },
    );
  }
}
