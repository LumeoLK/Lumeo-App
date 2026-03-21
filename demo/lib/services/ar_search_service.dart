import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_riverpod/legacy.dart';
import 'package:http/http.dart' as http;
import '../Constants.dart';
import '../utils/utils.dart';
import 'package:http_parser/http_parser.dart';

// Stores the list of search results
final searchResultsProvider = StateProvider<List<dynamic>>((ref) => []);

// Tracks loading state
final searchLoadingProvider = StateProvider<bool>((ref) => false);

// Main service provider
final arSearchProvider = Provider((ref) => ARSearchService(ref));

class ARSearchService {
  final Ref _ref;
  ARSearchService(this._ref);

  Future<void> searchFurniture({
    required BuildContext context,
    required File imageFile,
    int topK = 10,
  }) async {
    try {
      // Set loading state
      _ref.read(searchLoadingProvider.notifier).state = true;
      _ref.read(searchResultsProvider.notifier).state = [];

      // Build multipart request — same as Postman form-data
      final uri = Uri.parse('${Constants.mlUri}/api/v1/search');
      final request = http.MultipartRequest('POST', uri);

      request.files.add(
        http.MultipartFile.fromBytes(
          'file',
          await imageFile.readAsBytes(),
          filename: 'room.jpg',
          contentType: MediaType('image', 'jpeg'),
        ),
      );

      final streamedResponse = await request.send();
      final response = await http.Response.fromStream(streamedResponse);

      if (response.statusCode == 200) {
        final body = jsonDecode(response.body);

        if (body['success'] == true) {
          final results = body['results'] as List<dynamic>;

          // Update results provider
          _ref.read(searchResultsProvider.notifier).state = results;
        } else {
          showSnackBar(context, 'Search returned no results');
        }
      } else {
        final error = jsonDecode(response.body);
        showSnackBar(
          context,
          'Search failed: ${error['detail'] ?? 'Unknown error'}',
        );
      }
    } catch (e) {
      print('ARSearchService error: $e');
      showSnackBar(context, 'Could not connect to ML backend: $e');
    } finally {
      // Always stop loading
      _ref.read(searchLoadingProvider.notifier).state = false;
    }
  }
}
