class Conversation {
  final String id;
  final String productId;
  final String productName;
  final String lastMessage;

  Conversation({
    required this.id,
    required this.productId,
    required this.productName,
    required this.lastMessage,
  });

  factory Conversation.fromJson(Map<String, dynamic> json) {
    final product = json['product'];
    final productName = product is Map ? product['name'] ?? '' : '';
    final productId = product is Map ? product['_id'] ?? '' : '';

    return Conversation(
      id: json['_id'] ?? '',
      productId: productId,
      productName: productName,
      lastMessage: json['lastMessage'] ?? '',
    );
  }
}