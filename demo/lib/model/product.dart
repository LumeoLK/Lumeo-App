import './productdimensions.dart';
class Product {
  final String id;
  final String name;
  final double price;
  final List<String> images;
  final String description;
  final String modelUrl;
  final double averageRating; // 👈 add this
  final ProductDimensions? dimensions;

  Product({
    required this.id,
    required this.name,
    required this.price,
    required this.images,
    required this.description,
    required this.modelUrl,
    required this.averageRating, 
    this.dimensions,
  });

  // Converts raw JSON from your backend into a Product object
  // Converts raw JSON from your backend into a Product object
  factory Product.fromJson(Map<String, dynamic> json) {
    return Product(
      id: json['_id'] ?? '',

      // 👇 FIXED: The backend sends 'title', not 'name'
      name: json['title'] ?? '',

      price: (json['price'] as num).toDouble(),

      // 👇 (From our previous step)
      images:
          (json['images']
                  as List<
                    dynamic
                  >?) // Note: your schema says 'images', not 'image'
              ?.map((item) => item.toString())
              .toList() ??
          [],

      description: json['description'] ?? '',

      // 👇 FIXED: Safely access the nested model3D -> url
      // The `?` ensures that if 'model3D' is null, it doesn't crash, it just falls back to ''
      modelUrl: json['model3D']?['url'] ?? '',
      averageRating: (json['averageRating'] as num?)?.toDouble() ?? 0,
      dimensions: json['dimensions'] != null
          ? ProductDimensions.fromJson(json['dimensions'])
          : null,
    );
  }
}
