class Conversation {
  final String id;
  final String productId;
  final String productName;
  final String shopName;
  final String lastMessage;

  Conversation({
    required this.id,
    required this.productId,
    required this.productName,
    required this.shopName,
    required this.lastMessage,
  });

  factory Conversation.fromJson(Map<String, dynamic> json) {
    final product = json['product'];
    final participants = json['participants'] as List<dynamic>? ?? [];

    String productId = '';
    String productName = '';
    String shopName = 'Unknown Shop';

    if (product is Map<String, dynamic>) {
      productId = product['_id']?.toString() ?? '';
      productName =
          product['title']?.toString() ??
          product['name']?.toString() ??
          '';
    }

    if (participants.isNotEmpty) {
      final firstParticipant = participants.first;
      if (firstParticipant is Map<String, dynamic>) {
        shopName = firstParticipant['name']?.toString() ?? 'Unknown Shop';
      }
    }

    return Conversation(
      id: json['_id']?.toString() ?? '',
      productId: productId,
      productName: productName,
      shopName: shopName,
      lastMessage: json['lastMessage']?.toString() ?? '',
    );
  }
}