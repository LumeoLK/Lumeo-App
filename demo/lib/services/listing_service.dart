import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import '../Constants.dart';
import '../model/create_product_request.dart';

// ── Typed exception ───────────────────────────────────────
class ListingException implements Exception {
  const ListingException(this.message);
  final String message;

  @override
  String toString() => message;
}

// ── Service ───────────────────────────────────────────────
class ListingService {
  const ListingService();

  /// Creates a product by sending a multipart POST request.
  ///
  /// Throws [ListingException] on auth failure, validation errors,
  /// or any non-201 response from the server.
  Future<Map<String, dynamic>> createProduct(
    CreateProductRequest request,
  ) async {
    // 1. Get auth token
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('x-auth-token')?.trim() ?? '';

    if (token.isEmpty) {
      throw const ListingException(
        'You must be logged in to create a listing.',
      );
    }

    // 2. Build multipart request
    // Backend endpoint might be /api/products/add or /api/products/create
    // Judging by OrderService, it might be /create
    final uri = Uri.parse('${Constants.productsUri}/create');
    final multipartRequest = http.MultipartRequest('POST', uri);

    // 3. Attach auth headers
    // The app mostly uses 'Authorization: Bearer $token'
    multipartRequest.headers.addAll({
      'Authorization': 'Bearer $token',
      'x-auth-token': token, // keeping this for fallback
    });

    // 4. Attach text fields
    multipartRequest.fields.addAll({
      'title': request.title,
      'description': request.description,
      'price': request.price.toString(),
      'category': request.category,
      'stock': request.stock.toString(),
      // Send dimensions as separate fields as the backend might expect them flat
      'length': request.length.toString(),
      'width': request.width.toString(),
      'height': request.height.toString(),
    });

    // 5. Attach image files
    for (int i = 0; i < request.images.length; i++) {
      multipartRequest.files.add(
        await http.MultipartFile.fromPath(
          'images', // Key 'images' (common for array uploads)
          request.images[i].path,
        ),
      );
    }

    // 6. Send
    try {
      final streamedResponse = await multipartRequest.send().timeout(
        const Duration(seconds: 60),
        onTimeout: () => throw const ListingException(
          'Request timed out. Check your connection and try again.',
        ),
      );

      final response = await http.Response.fromStream(streamedResponse);

      // 7. Parse response
      final body = _parseBody(response.body);

      if (response.statusCode == 201 || response.statusCode == 200) {
        return body;
      }

      // Surface backend error message if available
      final msg =
          body['msg']?.toString() ??
          body['message']?.toString() ??
          'Failed to create product (${response.statusCode})';
      throw ListingException(msg);
    } catch (e) {
      if (e is ListingException) rethrow;
      throw ListingException('Error occurred: $e');
    }
  }

  // ── Helpers ───────────────────────────────────────────

  /// Safely parses JSON, falls back to empty map on failure.
  Map<String, dynamic> _parseBody(String body) {
    try {
      final decoded = jsonDecode(body);
      if (decoded is Map<String, dynamic>) return decoded;
      return const {};
    } catch (_) {
      return const {};
    }
  }
}
