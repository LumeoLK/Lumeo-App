import 'dart:convert';
import 'package:http/http.dart' as http;
import '../Constants.dart';

class ProductServiceException implements Exception {
  final String message;
  const ProductServiceException(this.message);

  @override
  String toString() => message;
}

class ProductService {
  const ProductService();

  Future<Map<String, dynamic>> fetchProduct(
    String productId,
    String token,
  ) async {
    final uri = Uri.parse('${Constants.productsUri}/$productId');

    final response = await http.get(
      uri,
      headers: {
        'Content-Type': 'application/json; charset=UTF-8',
        'Authorization': 'Bearer $token',
      },
    );

    Map<String, dynamic> body = const {};
    print("product fetched");
    if (response.body.isNotEmpty) {
      final decoded = jsonDecode(response.body);
      if (decoded is Map<String, dynamic>) {
        body = decoded;
        return body;
      }
    }
    final data = body['data'];
    if (data is Map<String, dynamic>) return data;
    return {};

    // final message =
    //     body['msg']?.toString() ??
    //     body['message']?.toString() ??
    //     'Unable to load product.';
    // throw ProductServiceException(message);
  }

  Future<void> retryModel3D(String productId, String token) async {
    final uri = Uri.parse('${Constants.baseUrl}/api/product/retry-3d');

    final response = await http.post(
      uri,
      headers: {
        'Content-Type': 'application/json; charset=UTF-8',
        'Authorization': 'Bearer $token',
      },
      body: jsonEncode({'productId': productId}),
    );

    Map<String, dynamic> body = const {};

    if (response.body.isNotEmpty) {
      final decoded = jsonDecode(response.body);
      if (decoded is Map<String, dynamic>) {
        body = decoded;
      }
    }

    if (response.statusCode == 200 && body['success'] == true) return;

    final message =
        body['msg']?.toString() ??
        body['message']?.toString() ??
        'Retry failed.';
    throw ProductServiceException(message);
  }
}
