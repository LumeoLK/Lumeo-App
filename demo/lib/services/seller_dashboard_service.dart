import 'dart:convert';

import '../Constants.dart';
import 'package:http/http.dart' as http;

class SellerDashboardException implements Exception {
  final String message;

  const SellerDashboardException(this.message);

  @override
  String toString() => message;
}

class SellerDashboardService {
  const SellerDashboardService();

  Future<Map<String, dynamic>> fetchDashboard(
    String token, {
    int listingsLimit = 10,
    int ordersLimit = 10,
  }) async {
    final uri = Uri.parse(
      '${Constants.sellerUri}/dashboard'
      '?listingsLimit=$listingsLimit&ordersLimit=$ordersLimit',
    );

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
      if (data is Map<String, dynamic>) {
        return data;
      }
      return const {};
    }

    final message =
        body['msg']?.toString() ??
        body['message']?.toString() ??
        'Unable to load seller dashboard.';
    throw SellerDashboardException(message);
  }
}
