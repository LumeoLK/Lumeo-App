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
      productId = rawProduct["_id"]?.toString() ?? '';
      productName =
          (rawProduct["title"] ?? rawProduct["name"])?.toString();
      final images = rawProduct["images"];
      if (images is List && images.isNotEmpty) {
        final firstImage = images.first;
        if (firstImage is String) {
          productImage = firstImage;
        } else if (firstImage is Map<String, dynamic>) {
          productImage =
              (firstImage["url"] ?? firstImage["secure_url"])?.toString();
        }
      }
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