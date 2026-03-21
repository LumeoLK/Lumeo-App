import './productdimensions.dart';

class Product {
  final String id;
  final String name;
  final double price;
  final List<String> images;
  final String shopName;
  final String sellerId;
  final String category;
  final int views;
  final DateTime? createdAt;
  final String description;
  final String modelUrl;
  final double averageRating;
  final ProductDimensions? dimensions;

  Product({
    required this.id,
    required this.name,
    required this.price,
    required this.images,
    required this.description,
    this.shopName = 'Unknown Seller',
    this.sellerId = '',
    this.category = '',
    this.views = 0,
    this.createdAt,
    required this.modelUrl,
    required this.averageRating,
    this.dimensions,
  });

  // Converts raw JSON from your backend into a Product object
  factory Product.fromJson(Map<String, dynamic> json) {
    return Product(
      id: json['_id'] ?? '',

      // FIXED: The backend sends 'title', not 'name'
      name: json['title'] ?? '',

      // Added a tiny safety net here in case price comes back as null
      price: (json['price'] as num?)?.toDouble() ?? 0.0,

      images:
          (json['images'] as List<dynamic>?)
              ?.map((item) => item.toString())
              .toList() ??
          [],

      description: json['description'] ?? '',

      // 👇 THE FIX: Read these values directly from the json map!
      shopName: json['shopName'] ?? 'Unknown Seller',

      // Note: Depending on your backend, sellerId might be an object.
      // If it is, this safely defaults to an empty string instead of crashing.
      sellerId: json['sellerId'] is String
          ? json['sellerId']
          : (json['sellerId']?['_id'] ?? ''),

      category: json['category'] ?? '',
      views: json['views'] ?? 0,
      createdAt: json['createdAt'] != null
          ? DateTime.tryParse(json['createdAt'])
          : null,

      // FIXED: Safely access the nested model3D -> url
      modelUrl: json['model3D']?['url'] ?? '',
      averageRating: (json['averageRating'] as num?)?.toDouble() ?? 0.0,

      dimensions: json['dimensions'] != null
          ? ProductDimensions.fromJson(json['dimensions'])
          : null,
    );
  }
}
