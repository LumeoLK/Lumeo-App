import 'package:flutter/material.dart';

class Constants {
  // The base address of the server
  static const String baseUrl = "https://lumeo-app.onrender.com";

  // Specific API routes
  static String authUri = '$baseUrl/api/auth';

  // ML backend
  static const String mlUri = 'https://lumeocs14-lumeo-ml.hf.space';

  static String cartUri = '$baseUrl/api/cart';
  static String productsUri = '$baseUrl/api/products';
  static String requestsUri = '$baseUrl/api/requests';
  static String chatUri = '$baseUrl/api/chat';
  static String wishlistUri = '$baseUrl/api/wishlist';
  static String ordersUri = '$baseUrl/api/orders';
  static String sellersUri = '$baseUrl/api/seller';

  // UI colors
  static const Color bgColor = Color(0xFF000000);
  static const Color cardColor = Color(0xFF1a1a1a);
  static const Color kOrange = Color(0xFFfbb040);
  static const Color textColor = Colors.white;
  static const Color hintText = Color(0xFF888888);

  // Categories
  static const List<String> kCategories = [
    'Sofa',
    'Chair',
    'Table',
    'Bed',
    'Wardrobe',
    'Shelf',
    'Desk',
    'Cabinet',
    'Lighting',
    'Decor',
    'Other',
  ];
}
