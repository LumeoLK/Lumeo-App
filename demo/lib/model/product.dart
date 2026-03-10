class Product {
  final String id; // MongoDB _id — needed to fetch from backend
  final String name;
  final double price;
  final String image;
  final String description;
  final String modelUrl; // 👈 the .glb file URL

  Product({
    required this.id,
    required this.name,
    required this.price,
    required this.image,
    required this.description,
    required this.modelUrl,
  });

  // Converts raw JSON from your backend into a Product object
  factory Product.fromJson(Map<String, dynamic> json) {
    return Product(
      id: json['_id'] ?? '',
      name: json['name'] ?? '',
      price: (json['price'] as num).toDouble(),
      image: json['image'] ?? '',
      description: json['description'] ?? '',
      modelUrl: json['modelUrl'] ?? '',
    );
  }
}
