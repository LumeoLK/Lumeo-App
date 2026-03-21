import 'dart:convert';
import 'dart:io';

import 'package:http/http.dart' as http;
import 'package:http_parser/http_parser.dart';

import '../Constants.dart';

class SellerListingsException implements Exception {
  final String message;

  const SellerListingsException(this.message);

  @override
  String toString() => message;
}

class SellerListingsService {
  const SellerListingsService();

  Future<List<Map<String, dynamic>>> fetchActiveListings(
    String token, {
    int limit = 20,
  }) async {
    final uri = Uri.parse('${Constants.sellersUri}/active-listings?limit=$limit');

    final response = await http.get(
      uri,
      headers: {
        'Content-Type': 'application/json; charset=UTF-8',
        'Authorization': 'Bearer $token',
      },
    );

    Map<String, dynamic> body = const {};
    if (response.body.isNotEmpty) {
      final decoded = jsonDecode(response.body);
      if (decoded is Map<String, dynamic>) {
        body = decoded;
      }
    }

    if (response.statusCode == 200 && body['success'] == true) {
      final data = body['data'];
      if (data is List) {
        return data
            .whereType<Map>()
            .map((item) => item.map((key, value) => MapEntry('$key', value)))
            .toList();
      }
      return const [];
    }

    final message =
        body['msg']?.toString() ??
        body['message']?.toString() ??
        'Unable to load seller listings.';
    throw SellerListingsException(message);
  }

  Future<Map<String, dynamic>> createProduct({
    required String token,
    required String title,
    required String description,
    required String category,
    required String price,
    required String stock,
    required String length,
    required String width,
    required String height,
    required List<File> images,
  }) async {
    final request = http.MultipartRequest(
      'POST',
      Uri.parse('${Constants.productsUri}/create'),
    );

    request.headers.addAll({'Authorization': 'Bearer $token'});
    request.fields.addAll({
      'title': title,
      'description': description,
      'category': category,
      'price': price,
      'stock': stock,
      'length': length,
      'width': width,
      'height': height,
    });

    for (final image in images) {
      request.files.add(
        await http.MultipartFile.fromPath(
          'images',
          image.path,
          contentType: _mediaTypeForPath(image.path),
        ),
      );
    }

    final streamedResponse = await request.send();
    final response = await http.Response.fromStream(streamedResponse);

    Map<String, dynamic> body = const {};
    if (response.body.isNotEmpty) {
      final decoded = jsonDecode(response.body);
      if (decoded is Map<String, dynamic>) {
        body = decoded;
      }
    }

    if ((response.statusCode == 200 || response.statusCode == 201) &&
        body['success'] == true) {
      return body;
    }

    final message =
        body['msg']?.toString() ??
        body['message']?.toString() ??
        'Unable to create product.';
    throw SellerListingsException(message);
  }

  MediaType _mediaTypeForPath(String path) {
    final normalized = path.toLowerCase();
    if (normalized.endsWith('.png')) {
      return MediaType('image', 'png');
    }
    if (normalized.endsWith('.webp')) {
      return MediaType('image', 'webp');
    }
    if (normalized.endsWith('.heic')) {
      return MediaType('image', 'heic');
    }
    return MediaType('image', 'jpeg');
  }
}
