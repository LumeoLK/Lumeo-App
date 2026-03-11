import 'dart:convert';
import 'package:http/http.dart' as http;
import '../Constants.dart';

class CartService {

  static Future<void> addToCart(
      String token,
      String productId,
      double price,
      ) async {

    final response = await http.post(
      Uri.parse("${Constants.cartUri}/add"),
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

    if (response.statusCode != 200 && response.statusCode != 201) {
      throw Exception("Failed to add to cart: ${response.statusCode} - ${response.body}");
    }
  }

  static Future<List<dynamic>> getCart(String token) async {

    final response = await http.get(
      Uri.parse(Constants.cartUri),
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
      Uri.parse("${Constants.cartUri}/remove"),
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