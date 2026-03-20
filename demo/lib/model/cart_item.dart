class CartItem {
  final String productId;
  final double price;
  final int quantity;

  CartItem({
    required this.productId,
    required this.price,
    required this.quantity,
  });

  factory CartItem.fromJson(Map<String, dynamic> json) {
    return CartItem(
      productId: json["productId"],
      price: (json["price"] as num).toDouble(),
      quantity: json["quantity"],
    );
  }
}