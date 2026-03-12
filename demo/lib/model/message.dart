class Message {
  final String id;
  final String conversationId;
  final String text;
  final String senderId;
  final String senderName;
  final DateTime createdAt;

  Message({
    required this.id,
    required this.conversationId,
    required this.text,
    required this.senderId,
    required this.senderName,
    required this.createdAt,
  });

  factory Message.fromJson(Map<String, dynamic> json) {
    final sender = json['sender'];
    final senderId = sender is Map ? sender['_id'] ?? '' : '';
    final senderName = sender is Map ? sender['name'] ?? '' : '';

    return Message(
      id: json['_id'] ?? '',
      conversationId: json['conversation'] ?? '',
      text: json['text'] ?? '',
      senderId: senderId,
      senderName: senderName,
      createdAt: DateTime.parse(
        json['createdAt'] ?? DateTime.now().toIso8601String(),
      ),
    );
  }
}