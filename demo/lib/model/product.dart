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
  final int stock;
  final String title;

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
    required this.stock,
    required this.title,
  });

  factory Product.fromJson(Map<String, dynamic> json) {
    return Product(
      id: json['_id'] ?? '',
      name: json['title'] ?? '',
      price: (json['price'] as num?)?.toDouble() ?? 0.0,
      images:
          (json['images'] as List<dynamic>?)
              ?.map((item) => item.toString())
              .toList() ??
          [],
      description: json['description'] ?? '',
      shopName: json['shopName'] ?? 'Unknown Seller',
      sellerId: json['sellerId'] is String
          ? json['sellerId']
          : (json['sellerId']?['_id'] ?? ''),
      category: json['category'] ?? '',
      views: json['views'] ?? 0,
      createdAt: json['createdAt'] != null
          ? DateTime.tryParse(json['createdAt'])
          : null,
      modelUrl: json['model3D']?['url'] ?? '',
      averageRating: (json['averageRating'] as num?)?.toDouble() ?? 0.0,
      dimensions: json['dimensions'] != null
          ? ProductDimensions.fromJson(json['dimensions'])
          : null,
          stock: json['stock'] ?? 0,
          title: json['title'] ?? '',
    );
  }
}
