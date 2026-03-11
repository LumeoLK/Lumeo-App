class CartItem {
  final String productId;
  final double price;
  final int quantity;
  final String? productName;
  final String? productImage;

  CartItem({
    required this.productId,
    required this.price,
    required this.quantity,
    this.productName,
    this.productImage,
  });

  factory CartItem.fromJson(Map<String, dynamic> json) {
    
    final rawProduct = json["productId"];
    String productId;
    String? productName;
    String? productImage;

    if (rawProduct is Map<String, dynamic>) {
      productId = rawProduct["_id"] ?? '';
      productName = rawProduct["title"];
      final images = rawProduct["images"];
      productImage = (images is List && images.isNotEmpty) ? images[0] : null;
    } else {
      productId = rawProduct?.toString() ?? '';
    }

    return CartItem(
      productId: productId,
      price: (json["price"] as num).toDouble(),
      quantity: json["quantity"],
      productName: productName,
      productImage: productImage,
    );
  }
}