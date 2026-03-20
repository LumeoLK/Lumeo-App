import 'dart:convert';
import 'package:http/http.dart' as http;
import '../Constants.dart';

class WishlistService {

  static Future<void> addToWishlist(
      String token,
      String productId,
      ) async {
    print('[WishlistService] addToWishlist called with productId=$productId, token=${token.substring(0, 10)}...');

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

    print('[WishlistService] addToWishlist response: ${response.statusCode} - ${response.body}');

    if (response.statusCode != 200 && response.statusCode != 201) {
      throw Exception("Failed to add to wishlist: ${response.statusCode} - ${response.body}");
    }
  }

  static Future<List<dynamic>> getWishlist(String token) async {
    print('[WishlistService] getWishlist called with token=${token.isNotEmpty ? token.substring(0, 10) : "EMPTY"}...');

    final response = await http.get(
      Uri.parse(Constants.wishlistUri),
      headers: {
        "Authorization": "Bearer $token"
      },
    );

    print('[WishlistService] getWishlist response: ${response.statusCode} - ${response.body}');

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      return data["products"] ?? [];
    } else {
      throw Exception("Failed to load wishlist: ${response.statusCode} - ${response.body}");
    }
  }

  static Future<void> removeFromWishlist(
      String token,
      String productId,
      ) async {
    print('[WishlistService] removeFromWishlist called with productId=$productId');

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

    print('[WishlistService] removeFromWishlist response: ${response.statusCode} - ${response.body}');

    if (response.statusCode != 200) {
      throw Exception("Failed to remove item: ${response.statusCode} - ${response.body}");
    }
  }
}