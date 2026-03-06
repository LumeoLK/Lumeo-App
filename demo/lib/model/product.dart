class Product {
  final String id;
  final String title;
  final String description;
  final double price;
  final String category;
  final int stock;
  final List<String> images;
  final double averageRating;
  final int numReviews;

  Product({
    required this.id,
    required this.title,
    required this.description,
    required this.price,
    required this.category,
    required this.stock,
    required this.images,
    this.averageRating = 0,
    this.numReviews = 0,
  });

  // Factory constructor to create Product from JSON
  factory Product.fromJson(Map<String, dynamic> json) {
    return Product(
      id: json['_id'] ?? '',
      title: json['title'] ?? '',
      description: json['description'] ?? '',
      price: (json['price'] ?? 0).toDouble(),
      category: json['category'] ?? '',
      stock: json['stock'] ?? 0,
      images: List<String>.from(json['images'] ?? []),
      averageRating: (json['averageRating'] ?? 0).toDouble(),
      numReviews: json['numReviews'] ?? 0,
    );
  }

  // Convert Product to JSON
  Map<String, dynamic> toJson() {
    return {
      '_id': id,
      'title': title,
      'description': description,
      'price': price,
      'category': category,
      'stock': stock,
      'images': images,
      'averageRating': averageRating,
      'numReviews': numReviews,
    };
  }
}
