class OrderItemProduct {
  final String id;
  final String title;
  final double price;
  final List<String> images;

  OrderItemProduct({
    required this.id,
    required this.title,
    required this.price,
    required this.images,
  });

  factory OrderItemProduct.fromJson(Map<String, dynamic> json) {
    return OrderItemProduct(
      id: json['_id'] ?? '',
      title: json['title'] ?? 'Unknown Product',
      price: (json['price'] as num?)?.toDouble() ?? 0.0,
      images: (json['images'] as List<dynamic>?)
              ?.map((e) => e.toString())
              .toList() ??
          [],
    );
  }

  String? get firstImage => images.isNotEmpty ? images[0] : null;
}