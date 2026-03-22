class CustomRequest {
  final String id;
  final String userId;
  final String title;
  final String description;
  final double budget;
  final List<String> referenceImages;
  final String status;
  final DateTime createdAt;

  CustomRequest({
    required this.id,
    required this.userId,
    required this.title,
    required this.description,
    required this.budget,
    required this.referenceImages,
    required this.status,
    required this.createdAt,
  });

  factory CustomRequest.fromJson(Map<String, dynamic> json) {
    return CustomRequest(
      id: json['_id'] ?? '',
      userId: json['userId'] ?? '',
      title: json['title'] ?? '',
      description: json['description'] ?? '',
      budget: (json['budget'] ?? 0).toDouble(),
      referenceImages: List<String>.from(json['referenceImages'] ?? []),
      status: json['status'] ?? 'open',
      createdAt: DateTime.parse(json['createdAt'] ?? DateTime.now().toIso8601String()),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      '_id': id,
      'userId': userId,
      'title': title,
      'description': description,
      'budget': budget,
      'referenceImages': referenceImages,
      'status': status,
      'createdAt': createdAt.toIso8601String(),
    };
  }
}
