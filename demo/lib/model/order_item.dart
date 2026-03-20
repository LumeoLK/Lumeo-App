import 'order_item_product.dart';

class OrderItem {
  final OrderItemProduct? product; 
  final String? productId; 
  final int quantity;
  final double priceAtPurchase;

  OrderItem({
    this.product,
    this.productId,
    required this.quantity,
    required this.priceAtPurchase,
  });

  factory OrderItem.fromJson(Map<String, dynamic> json) {
   
    final rawProduct = json['productId'];
    OrderItemProduct? product;
    String? productId;

    if (rawProduct is Map<String, dynamic>) {
     
      product = OrderItemProduct.fromJson(rawProduct);
      productId = product.id;
    } else if (rawProduct != null) {
      productId = rawProduct.toString();
    }

    return OrderItem(
      product: product,
      productId: productId,
      quantity: json['quantity'] ?? 1,
      priceAtPurchase: (json['priceAtPurchase'] as num?)?.toDouble() ?? 0.0,
    );
  }
}