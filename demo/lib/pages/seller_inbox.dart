import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../model/conversation.dart';
import '../services/chat_service.dart';
import '../pages/chat_application.dart';

class SellerInboxPage extends StatefulWidget {
  const SellerInboxPage({super.key});

  @override
  State<SellerInboxPage> createState() => _SellerInboxPageState();
}

class _SellerInboxPageState extends State<SellerInboxPage> {
  final ChatService _chatService = ChatService();

  List<Conversation> _conversations = [];
  bool _isLoading = true;
  String? _error;
  String _sellerUserId = '';
  String _sellerName = 'Seller';

  @override
  void initState() {
    super.initState();
    _loadInbox();
  }

  Future<void> _loadInbox() async {
    setState(() {
      _isLoading = true;
      _error = null;
    });

    try {
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString('x-auth-token')?.trim() ?? '';

      if (token.isEmpty) {
        throw Exception('Please log in first');
      }

      final conversations = await _chatService.getConversations();

      if (!mounted) return;

      setState(() {
        _conversations = conversations;
        _sellerUserId =
            prefs.getString('userId') ?? prefs.getString('id') ?? '';
        _sellerName =
            prefs.getString('userName') ?? prefs.getString('name') ?? 'Seller';
        _isLoading = false;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _error = e.toString().replaceFirst('Exception: ', '');
        _isLoading = false;
      });
    }
  }

  // ── Build ─────────────────────────────────────────────────

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF1a1a1a),
      appBar: AppBar(
        backgroundColor: const Color(0xFF1a1a1a),
        automaticallyImplyLeading: false,
        title: const Text(
          'Messages',
          style: TextStyle(
            color: Colors.white,
            fontSize: 24,
            fontWeight: FontWeight.bold,
          ),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh_rounded, color: Colors.white),
            onPressed: _loadInbox,
          ),
        ],
        bottom: const PreferredSize(
          preferredSize: Size.fromHeight(1),
          child: Divider(color: Color(0xFF2a2a2a), height: 1),
        ),
      ),
      body: _buildBody(),
    );
  }

  Widget _buildBody() {
    if (_isLoading) {
      return const Center(
        child: CircularProgressIndicator(color: Color(0xFFFBB040)),
      );
    }

    if (_error != null) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(
                Icons.error_outline,
                color: Colors.redAccent,
                size: 44,
              ),
              const SizedBox(height: 14),
              Text(
                _error!,
                style: const TextStyle(color: Colors.white70, fontSize: 13),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 20),
              ElevatedButton(
                onPressed: _loadInbox,
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFFFBB040),
                ),
                child: const Text(
                  'Retry',
                  style: TextStyle(
                    color: Colors.black,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          ),
        ),
      );
    }

    if (_conversations.isEmpty) {
      return const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.chat_bubble_outline_rounded,
              color: Color(0xFF555555),
              size: 52,
            ),
            SizedBox(height: 14),
            Text(
              'No messages yet',
              style: TextStyle(
                color: Colors.white,
                fontSize: 16,
                fontWeight: FontWeight.w600,
              ),
            ),
            SizedBox(height: 6),
            Text(
              'Conversations with buyers will appear here',
              style: TextStyle(color: Colors.grey, fontSize: 12),
            ),
          ],
        ),
      );
    }

    return RefreshIndicator(
      color: const Color(0xFFFBB040),
      backgroundColor: const Color(0xFF2a2a2a),
      onRefresh: _loadInbox,
      child: ListView.separated(
        padding: const EdgeInsets.symmetric(vertical: 8),
        itemCount: _conversations.length,
        separatorBuilder: (_, __) =>
            const Divider(color: Color(0xFF2a2a2a), height: 1),
        itemBuilder: (context, index) {
          return _ConversationTile(
            conversation: _conversations[index],
            sellerUserId: _sellerUserId,
            sellerName: _sellerName,
          );
        },
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────
//  CONVERSATION TILE
// ─────────────────────────────────────────────────────────

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
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
      leading: const CircleAvatar(
        radius: 24,
        backgroundColor: Color(0xFF2a2a2a),
        child: Icon(Icons.person, color: Color(0xFFFBB040)),
      ),
      title: Text(
        conversation.shopName,
        style: const TextStyle(
          color: Colors.white,
          fontSize: 14,
          fontWeight: FontWeight.w600,
        ),
      ),
      subtitle: Padding(
        padding: const EdgeInsets.only(top: 3),
        child: Text(
          conversation.lastMessage.isEmpty
              ? conversation.productName
              : conversation.lastMessage,
          style: const TextStyle(color: Colors.white60, fontSize: 12),
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
        ),
      ),
      onTap: () {
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
