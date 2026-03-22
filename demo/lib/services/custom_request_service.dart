import 'dart:convert';
import 'package:http/http.dart' as http;
import '../Constants.dart';
import '../model/custom_request.dart';
import '../model/bid.dart';

class CustomRequestService {
  final String token;

  CustomRequestService({required this.token});

  // Fetch all open custom requests (Bidding Marketplace)
  Future<List<CustomRequest>> getMarketplaceRequests() async {
    final response = await http.get(
      Uri.parse('${Constants.requestsUri}/browse'),
      headers: {
        'Authorization': 'Bearer $token',
      },
    );

    if (response.statusCode == 200) {
      final Map<String, dynamic> data = jsonDecode(response.body);
      final List<dynamic> requestsJson = data['requests'] ?? [];
      return requestsJson.map((json) => CustomRequest.fromJson(json)).toList();
    } else {
      throw Exception('Failed to load browseable requests');
    }
  }

  // Fetch my custom requests (Customer dashboard)
  Future<List<CustomRequest>> getMyRequests() async {
    final response = await http.get(
      Uri.parse('${Constants.requestsUri}/my-requests'), // Create this route in backend
      headers: {
        'Authorization': 'Bearer $token',
      },
    );

    if (response.statusCode == 200) {
      final Map<String, dynamic> data = jsonDecode(response.body);
      final List<dynamic> requestsJson = data['requests'] ?? [];
      return requestsJson.map((json) => CustomRequest.fromJson(json)).toList();
    } else {
      throw Exception('Failed to load my requests: ${response.statusCode} - ${response.body}');
    }
  }

  // Create a new custom request
  Future<CustomRequest> createCustomRequest({
    required String title,
    required String description,
    required double budget,
    DateTime? deadline,
    // Add image uploading logic if needed — for now JSON
  }) async {
    final response = await http.post(
      Uri.parse('${Constants.requestsUri}/create'),
      headers: {
        'Content-Type': 'application/json; charset=UTF-8',
        'Authorization': 'Bearer $token',
      },
      body: jsonEncode({
        'title': title,
        'description': description,
        'budget': budget,
        if (deadline != null) 'deadline': deadline.toIso8601String(),
      }),
    );

    if (response.statusCode == 201) {
      final Map<String, dynamic> data = jsonDecode(response.body);
      return CustomRequest.fromJson(data['request']);
    } else {
      final Map<String, dynamic> data = jsonDecode(response.body);
      throw Exception(data['msg'] ?? 'Failed to create request');
    }
  }

  // Fetch bids for a request
  Future<List<Bid>> getBidsForRequest(String requestId) async {
    final response = await http.post(
      Uri.parse('${Constants.requestsUri}/getbids'),
      headers: {
        'Content-Type': 'application/json; charset=UTF-8',
        'Authorization': 'Bearer $token',
      },
      body: jsonEncode({'requestId': requestId}),
    );

    if (response.statusCode == 200) {
      final Map<String, dynamic> data = jsonDecode(response.body);
      final List<dynamic> bidsJson = data['bids'] ?? [];
      return bidsJson.map((json) => Bid.fromJson(json)).toList();
    } else {
      throw Exception('Failed to load bids');
    }
  }
}
