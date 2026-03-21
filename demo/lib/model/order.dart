import 'shipping_adress.dart';
import 'order_item.dart';

class Order {
  final String id;
  final String buyerId;
  final List<OrderItem> items;
  final double totalAmount;
  final String paymentMethod; // "cod" or "card"
  final String paymentStatus; // "pending", "paid", "failed"
  final ShippingAddress shippingAddress;
  final String status; // "pending", "processing", "shipped", "delivered", "cancelled"
  final DateTime createdAt;

  Order({
    required this.id,
    required this.buyerId,
    required this.items,
    required this.totalAmount,
    required this.paymentMethod,
    required this.paymentStatus,
    required this.shippingAddress,
    required this.status,
    required this.createdAt,
  });

  factory Order.fromJson(Map<String, dynamic> json) {
    return Order(
      id: json['_id'] ?? '',
      buyerId: json['buyerId'] ?? '',
      items: (json['items'] as List<dynamic>?)
              ?.map((e) => OrderItem.fromJson(e as Map<String, dynamic>))
              .toList() ??
          [],
      totalAmount: (json['totalAmount'] as num?)?.toDouble() ?? 0.0,
      paymentMethod: json['paymentMethod'] ?? 'cod',
      paymentStatus: json['paymentStatus'] ?? 'pending',
      shippingAddress: ShippingAddress.fromJson(
        json['shippingAddress'] as Map<String, dynamic>? ?? {},
      ),
      status: json['status'] ?? 'pending',
      // Parse ISO date string → DateTime
      createdAt: DateTime.tryParse(json['createdAt'] ?? '') ?? DateTime.now(),
    );
  }

  /// Total quantity of all items in this order
  int get totalQuantity => items.fold(0, (sum, item) => sum + item.quantity);
}