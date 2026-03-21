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
    final productName = product is Map ? product['name'] ?? '' : '';
    final productId = product is Map ? product['_id'] ?? '' : '';
    final shopName = product is Map ? product['shopName'] ?? 'Unknown Shop' : 'Unknown Shop';
    return Conversation(
      id: json['_id'] ?? '',
      productId: productId,
      productName: productName,
      shopName: shopName,
      lastMessage: json['lastMessage'] ?? '',
    );
  }
}
