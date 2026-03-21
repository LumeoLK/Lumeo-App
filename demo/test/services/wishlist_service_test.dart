import 'dart:convert';

import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';
import 'package:lumeo_v2/services/wishlist_service.dart';

void main() {
  const token = 'token-1234567890';

  group('WishlistService.getWishlist', () {
    test('returns products when API returns 200', () async {
      final mockClient = MockClient((request) async {
        expect(request.method, 'GET');
        expect(request.headers['Authorization'], 'Bearer $token');

        return http.Response(
          jsonEncode({
            'products': [
              {'_id': 'p1', 'title': 'Chair'},
              {'_id': 'p2', 'title': 'Table'},
            ],
          }),
          200,
          headers: {'content-type': 'application/json'},
        );
      });

      final items = await http.runWithClient(
        () => WishlistService.getWishlist(token),
        () => mockClient,
      );

      expect(items, hasLength(2));
      expect(items.first['_id'], 'p1');
    });

    test('throws when API returns non-200', () async {
      final mockClient = MockClient((request) async {
        return http.Response('server error', 500);
      });

      await expectLater(
        http.runWithClient(
          () => WishlistService.getWishlist(token),
          () => mockClient,
        ),
        throwsA(isA<Exception>()),
      );
    });
  });

  group('WishlistService.addToWishlist', () {
    test('accepts 201 response status', () async {
      final mockClient = MockClient((request) async {
        expect(request.method, 'POST');
        expect(request.headers['Authorization'], 'Bearer $token');

        final body = jsonDecode(request.body) as Map<String, dynamic>;
        expect(body['productId'], 'prod-1');

        return http.Response('created', 201);
      });

      await http.runWithClient(
        () => WishlistService.addToWishlist(token, 'prod-1'),
        () => mockClient,
      );
    });

    test('throws when status is not 200 or 201', () async {
      final mockClient = MockClient((request) async {
        return http.Response('bad request', 400);
      });

      await expectLater(
        http.runWithClient(
          () => WishlistService.addToWishlist(token, 'prod-1'),
          () => mockClient,
        ),
        throwsA(isA<Exception>()),
      );
    });
  });

  group('WishlistService.removeFromWishlist', () {
    test('throws when API returns non-200', () async {
      final mockClient = MockClient((request) async {
        expect(request.method, 'DELETE');
        return http.Response('not found', 404);
      });

      await expectLater(
        http.runWithClient(
          () => WishlistService.removeFromWishlist(token, 'prod-1'),
          () => mockClient,
        ),
        throwsA(isA<Exception>()),
      );
    });
  });
}
