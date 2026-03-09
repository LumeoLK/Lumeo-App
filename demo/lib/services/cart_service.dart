import 'dart:convert';
import 'package:http/http.dart' as http;

class CartService {

  static const String baseUrl = "https://lumeo-app.onrender.com/api/cart";

  static Future<void> addToCart(
      String token,
      String productId,
      double price,
      ) async {

    final response = await http.post(
      Uri.parse("$baseUrl/add"),
      headers: {
        "Content-Type": "application/json",
        "Authorization": "Bearer $token"
      },
      body: jsonEncode({
        "productId": productId,
        "quantity": 1,
        "price": price
      }),
    );

    if (response.statusCode != 200) {
      throw Exception("Failed to add to cart");
    }
  }

  static Future<List<dynamic>> getCart(String token) async {

    final response = await http.get(
      Uri.parse(baseUrl),
      headers: {
        "Authorization": "Bearer $token"
      },
    );

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      return data["items"];
    } else {
      throw Exception("Failed to load cart");
    }
  }

  static Future<void> removeFromCart(
      String token,
      String productId,
      ) async {

    final response = await http.delete(
      Uri.parse("$baseUrl/remove"),
      headers: {
        "Content-Type": "application/json",
        "Authorization": "Bearer $token"
      },
      body: jsonEncode({
        "productId": productId
      }),
    );

    if (response.statusCode != 200) {
      throw Exception("Failed to remove item");
    }
  }
}