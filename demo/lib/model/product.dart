class Product {

  final String id;
  final String name;
  final double price;
  final String description;
  final List<String> images;
  final String shopName;
  final String sellerId;
  final String modelUrl; 

  Product({
    required this.id,
    required this.name,
    required this.price,
    required this.description,
    required this.modelUrl,
    this.images = const [],
    this.shopName = 'Unknown Seller',
    this.sellerId = '',
  });

  factory Product.fromJson(Map<String, dynamic> json) {
    String shopName = 'Unknown Seller';
    String sellerId = '';
    final sellerData = json['sellerId'];
    if (sellerData is Map) {
      shopName = sellerData['shopName'] ?? 'Unknown Seller';
      sellerId = sellerData['_id'] ?? '';
    } else if (sellerData is String) {
      sellerId = sellerData;
    }
    return Product(
      id: json['_id'] ?? '',
      name: json['title'] ?? '',
      price: (json['price'] as num).toDouble(),
      description: json['description'] ?? '',
      images: List<String>.from(json['images'] ?? []),
      shopName: shopName,
      sellerId: sellerId,
    );
  }
}
