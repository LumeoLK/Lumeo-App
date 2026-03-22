import 'dart:convert';
import 'package:http/http.dart' as http;
import '../Constants.dart';
import '../model/order.dart';

class OrderService {

  // POST /api/orders/create
  // Backend reads the cart from DB, so we only send address + payment method
  static Future<Order> placeOrder(
    String token, {
    required Map<String, dynamic> shippingAddress,
  }) async {
    final response = await http.post(
      Uri.parse("${Constants.ordersUri}/create"),
      headers: {
        "Content-Type": "application/json",
        "Authorization": "Bearer $token",
      },
      body: jsonEncode({
        "shippingAddress": shippingAddress,
        "paymentMethod": "cod", // hardcoded for now — no payment feature yet
      }),
    );

    if (response.statusCode == 201) {
      final data = jsonDecode(response.body);
      return Order.fromJson(data['order']);
    } else {
      final data = jsonDecode(response.body);
      throw Exception(data['msg'] ?? 'Failed to place order');
    }
  }

  // GET /api/orders/my-orders
  static Future<List<Order>> getMyOrders(String token) async {
    final response = await http.get(
      Uri.parse("${Constants.ordersUri}/my-orders"),
      headers: {
        "Authorization": "Bearer $token",
      },
    );

    if (response.statusCode == 200) {
      final List<dynamic> data = jsonDecode(response.body);
      return data.map((e) => Order.fromJson(e)).toList();
    } else {
      try {
        final data = jsonDecode(response.body);
        final msg = (data['msg'] ?? '').toString();

        throw Exception(
          msg.isNotEmpty
              ? msg
              :
              'Failed to load orders: ${response.statusCode} - ${response.body}',
        );
      } catch (_) {
        throw Exception(
          'Failed to load orders: ${response.statusCode} - ${response.body}',
        );
      }
    }
  }
}
