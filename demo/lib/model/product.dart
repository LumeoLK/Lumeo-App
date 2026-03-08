class Product {
  final String id;
  final String name;
  final double price;
  final String description;
  final List<String> images;
  final String shopName;
  Product({
    required this.id,
    required this.name,
    required this.price,
    required this.description,
    this.images = const [],
    this.shopName = 'Unknown Seller',
  });

  factory Product.fromJson(Map<String, dynamic> json) {
    String shopName = 'Unknown Seller';
    final sellerId = json['sellerId'];
    if (sellerId is Map) {
      // extract shopName
      shopName = sellerId['shopName'] ?? 'Unknown Seller';
    }
    return Product(
      id: json['_id'] ?? '',
      name: json['title'] ?? '',
      price: (json['price'] as num).toDouble(),
      description: json['description'] ?? '',
      images: List<String>.from(json['images'] ?? []),
      shopName: shopName,
    );
  }
}
