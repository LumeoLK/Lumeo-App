class Message {
  final String id;
  final String conversationId;
  final String senderId;
  final String senderName;
  final String senderProfilePicture;
  final String text;
  final DateTime createdAt;

  Message({
    required this.id,
    required this.conversationId,
    required this.senderId,
    required this.senderName,
    this.senderProfilePicture = '',
    required this.text,
    required this.createdAt,
  });

  factory Message.fromJson(Map<String, dynamic> json) {
    final sender = json['sender'];

    return Message(
      id: json['_id']?.toString() ?? '',
      conversationId: json['conversation']?.toString() ?? '',
      senderId: sender is Map<String, dynamic>
          ? sender['_id']?.toString() ?? ''
          : json['sender']?.toString() ?? '',
      senderName: sender is Map<String, dynamic>
          ? sender['name']?.toString() ?? ''
          : '',
      senderProfilePicture: sender is Map<String, dynamic>
          ? sender['profilePicture']?.toString() ?? ''
          : '',
      text: json['text']?.toString() ?? '',
      createdAt: json['createdAt'] != null
          ? DateTime.tryParse(json['createdAt']) ?? DateTime.now()
          : DateTime.now(),
    );
  }
}