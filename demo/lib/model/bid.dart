class Bid {
  final String id;
  final String requestId;
  final String sellerId;
  final String sellerName;
  final String sellerLogo;
  final double price;
  final String message;
  final int estimatedDays;
  final List<String> images;
  final String status;
  final DateTime createdAt;

  Bid({
    required this.id,
    required this.requestId,
    required this.sellerId,
    required this.sellerName,
    required this.sellerLogo,
    required this.price,
    required this.message,
    required this.estimatedDays,
    required this.images,
    required this.status,
    required this.createdAt,
  });

  factory Bid.fromJson(Map<String, dynamic> json) {
    // Determine seller name and logo from populated sellerId Map or raw String
    String name = 'Seller';
    String logo = '';
    String sId = '';

    if (json['sellerId'] is Map) {
      final sellerMap = json['sellerId'] as Map<String, dynamic>;
      sId = sellerMap['_id'] ?? '';
      name = sellerMap['shopName'] ?? sellerMap['displayName'] ?? 'Seller';
      logo = sellerMap['logo'] ?? '';
    } else {
      sId = json['sellerId'] ?? '';
    }

    return Bid(
      id: json['_id'] ?? '',
      requestId: json['requestId'] ?? '',
      sellerId: sId,
      sellerName: name,
      sellerLogo: logo,
      price: (json['price'] ?? 0).toDouble(),
      message: json['message'] ?? '',
      estimatedDays: json['estimatedDays'] ?? 0,
      images: List<String>.from(json['images'] ?? []),
      status: json['status'] ?? 'pending',
      createdAt: DateTime.parse(json['createdAt'] ?? DateTime.now().toIso8601String()),
    );
  }
}
