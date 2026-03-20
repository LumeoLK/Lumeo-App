import 'dart:convert';
import 'package:http/http.dart' as http;
import '../model/product.dart';
import "../Constants.dart";

class ProductService {
  
  Future<List<Product>> getAllProducts() async {
    try {
      final response = await http.get(
        Uri.parse('${Constants.productsUri}/'), 
        headers: {'Content-Type': 'application/json'},
      );

      if (response.statusCode == 200) {
        final List<dynamic> jsonData = json.decode(response.body);
        return jsonData.map((item) => Product.fromJson(item)).toList();
      } else {
        throw Exception('Failed to load products: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Error connecting to server: $e');
    }
  }
  // Fetch single product by ID (for detail page)
  static Future<Product> getProductById(String id) async {
    final response = await http.get(Uri.parse('${Constants.productsUri}/$id'));

    if (response.statusCode == 200) {
      return Product.fromJson(jsonDecode(response.body));
    } else {
      throw Exception('Failed to load product');
    }
  }
}
