class Product {
  final String id;
  final String name;
  final double price;
  final String description;
  final List<String> images;

  Product({
    required this.id,
    required this.name,
    required this.price,
    required this.description,
    this.images = const [],
  });

  factory Product.fromJson(Map<String, dynamic> json) {
    return Product(
      id: json['_id'] ?? '',
      name: json['title'] ?? '',
      price: (json['price'] as num).toDouble(),
      description: json['description'] ?? '',
      images: List<String>.from(json['images'] ?? []),
    );
  }
}
