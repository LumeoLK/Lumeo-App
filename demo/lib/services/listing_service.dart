import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import '../Constants.dart';
// ── Typed exception ───────────────────────────────────────
class ListingException implements Exception {
  const ListingException(this.message);
  final String message;

  @override
  String toString() => message;
}

// ── Request model ─────────────────────────────────────────
/// Everything the form collects, passed as one clean object
/// to [ListingService.createProduct].
class CreateProductRequest {
  const CreateProductRequest({
    required this.title,
    required this.description,
    required this.price,
    required this.category,
    required this.stock,
    required this.length,
    required this.width,
    required this.height,
    required this.images, // only non-null files
  });

  final String title;
  final String description;
  final double price;
  final String category;
  final int stock;
  final double length;
  final double width;
  final double height;
  final List<File> images;
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
    final uri = Uri.parse('${Constants.productsUri}/create');
    final multipartRequest = http.MultipartRequest('POST', uri);

    // 3. Attach auth header
    multipartRequest.headers['x-auth-token'] = token;

    // 4. Attach text fields
    multipartRequest.fields.addAll({
      'title': request.title,
      'description': request.description,
      'price': request.price.toString(),
      'category': request.category,
      'stock': request.stock.toString(),
      'length': request.length.toString(),
      'width': request.width.toString(),
      'height': request.height.toString(),
    });

    // 5. Attach image files
    for (int i = 0; i < request.images.length; i++) {
      final file = request.images[i];
      final stream = http.ByteStream(file.openRead());
      final length = await file.length();
      final filename = 'image_$i${_extension(file.path)}';

      multipartRequest.files.add(
        http.MultipartFile(
          'images', // must match multer field name on backend
          stream,
          length,
          filename: filename,
        ),
      );
    }

    // 6. Send
    final streamedResponse = await multipartRequest.send().timeout(
      const Duration(seconds: 60), // images can be large
      onTimeout: () => throw const ListingException(
        'Request timed out. Check your connection and try again.',
      ),
    );

    final response = await http.Response.fromStream(streamedResponse);

    // 7. Parse response
    final body = _parseBody(response.body);

    if (response.statusCode == 201) {
      return body;
    }

    // Surface backend error message if available
    final msg =
        body['msg']?.toString() ??
        'Failed to create product (${response.statusCode})';
    throw ListingException(msg);
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

  /// Extracts file extension from path, defaults to .jpg.
  String _extension(String path) {
    final dot = path.lastIndexOf('.');
    return dot != -1 ? path.substring(dot) : '.jpg';
  }
}
