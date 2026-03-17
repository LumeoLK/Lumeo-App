import 'dart:convert';
import 'package:http/http.dart' as http;
import '../Constants.dart';

class WishlistService {

  static Future<void> addToWishlist(
      String token,
      String productId,
      ) async {

    final response = await http.post(
      Uri.parse("${Constants.wishlistUri}/add"),
      headers: {
        "Content-Type": "application/json",
        "Authorization": "Bearer $token"
      },
      body: jsonEncode({
        "productId": productId,
      }),
    );

    if (response.statusCode != 200 && response.statusCode != 201) {
      throw Exception("Failed to add to wishlist: ${response.statusCode} - ${response.body}");
    }
  }

  static Future<List<dynamic>> getWishlist(String token) async {

    final response = await http.get(
      Uri.parse(Constants.wishlistUri),
      headers: {
        "Authorization": "Bearer $token"
      },
    );

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      return data["products"];
    } else {
      throw Exception("Failed to load wishlist");
    }
  }

  static Future<void> removeFromWishlist(
      String token,
      String productId,
      ) async {

    final response = await http.delete(
      Uri.parse("${Constants.wishlistUri}/remove"),
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