import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:flutter/foundation.dart';
import '../Constants.dart';
import '../model/product.dart';

class ProductService {
  /// Fetch all products from MongoDB
  static Future<List<Product>> getAllProducts() async {
    try {
      final url = '${Constants.uri}/api/products/';
      if (kDebugMode) {
        print('Fetching products from: $url');
      }

      final response = await http.get(
        Uri.parse(url),
        headers: <String, String>{
          'Content-Type': 'application/json; charset=UTF-8',
        },
      ).timeout(const Duration(seconds: 60));

      if (kDebugMode) {
        print('Response Status: ${response.statusCode}');
        print('Response Body: ${response.body}');
      }

      if (response.statusCode == 200) {
        final List<dynamic> data = jsonDecode(response.body);
        if (kDebugMode) {
          print('Fetched ${data.length} products');
        }
        List<Product> products = data
            .map((product) => Product.fromJson(product as Map<String, dynamic>))
            .toList();
        return products;
      } else {
        throw Exception('Failed to load products: ${response.statusCode}');
      }
    } catch (e) {
      if (kDebugMode) {
        print('Error fetching products: $e');
      }
      throw Exception('Error fetching products: $e');
    }
  }

  /// Search products with filters
  static Future<Map<String, dynamic>> searchProducts({
    String? keyword,
    String? category,
    double? minPrice,
    double? maxPrice,
    String sortBy = 'newest',
    int page = 1,
    int limit = 10,
  }) async {
    try {
      Map<String, String> queryParams = {
        'page': page.toString(),
        'limit': limit.toString(),
        'sortBy': sortBy,
      };

      if (keyword != null && keyword.isNotEmpty) {
        queryParams['keyword'] = keyword;
      }
      if (category != null && category.isNotEmpty) {
        queryParams['category'] = category;
      }
      if (minPrice != null) {
        queryParams['minPrice'] = minPrice.toString();
      }
      if (maxPrice != null) {
        queryParams['maxPrice'] = maxPrice.toString();
      }

      final Uri uri = Uri.parse('${Constants.uri}/api/products/search')
          .replace(queryParameters: queryParams);

      final response = await http.get(uri).timeout(const Duration(seconds: 60));

      if (response.statusCode == 200) {
        final Map<String, dynamic> data = jsonDecode(response.body);
        List<Product> products = (data['data'] as List)
            .map((product) => Product.fromJson(product as Map<String, dynamic>))
            .toList();

        return {
          'success': true,
          'products': products,
          'total': data['total'] ?? 0,
          'page': data['page'] ?? 1,
          'pages': data['pages'] ?? 1,
        };
      } else {
        return {
          'success': false,
          'error': 'Failed to search products: ${response.statusCode}',
        };
      }
    } catch (e) {
      return {
        'success': false,
        'error': 'Error searching products: $e',
      };
    }
  }

  /// Get single product by ID
  static Future<Product> getProductById(String productId) async {
    try {
      final response = await http.get(
        Uri.parse('${Constants.uri}/api/products/$productId'),
        headers: <String, String>{
          'Content-Type': 'application/json; charset=UTF-8',
        },
      ).timeout(const Duration(seconds: 60));

      if (response.statusCode == 200) {
        final Map<String, dynamic> data = jsonDecode(response.body);
        return Product.fromJson(data);
      } else {
        throw Exception('Failed to load product: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Error fetching product: $e');
    }
  }
}
