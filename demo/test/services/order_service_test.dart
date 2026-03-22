import 'dart:convert';

import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';
import 'package:lumeo_v2/model/order.dart';
import 'package:lumeo_v2/services/order_service.dart';

void main() {
  const token = 'token-1234567890';

  group('OrderService.placeOrder', () {
    test('creates order successfully', () async {
      const shippingAddress = {
        'street': '123 Main St',
        'city': 'Colombo',
        'postalCode': '00100',
      };

      final mockClient = MockClient((request) async {
        expect(request.method, 'POST');
        expect(request.headers['Authorization'], 'Bearer $token');

        final body = jsonDecode(request.body) as Map<String, dynamic>;
        expect(body['shippingAddress']['street'], '123 Main St');
        expect(body['paymentMethod'], 'cod');

        return http.Response(
          jsonEncode({
            'order': {
              '_id': 'order-1',
              'buyerId': 'buyer-1',
              'items': [],
              'totalAmount': 1500.0,
              'paymentMethod': 'cod',
              'paymentStatus': 'pending',
              'shippingAddress': shippingAddress,
              'status': 'pending',
              'createdAt': '2026-03-21T10:30:00.000Z',
            },
          }),
          201,
          headers: {'content-type': 'application/json'},
        );
      });

      final order = await http.runWithClient(
        () => OrderService.placeOrder(
          token,
          shippingAddress: shippingAddress,
        ),
        () => mockClient,
      );

      expect(order, isA<Order>());
      expect(order.id, 'order-1');
      expect(order.status, 'pending');
      expect(order.totalAmount, 1500.0);
    });

    test('throws when create order fails', () async {
      const shippingAddress = {'street': '123 Main St'};

      final mockClient = MockClient((request) async {
        return http.Response(
          jsonEncode({'msg': 'Invalid shipping address'}),
          400,
          headers: {'content-type': 'application/json'},
        );
      });

      await expectLater(
        http.runWithClient(
          () => OrderService.placeOrder(
            token,
            shippingAddress: shippingAddress,
          ),
          () => mockClient,
        ),
        throwsA(isA<Exception>()),
      );
    });
  });

  group('OrderService.getMyOrders', () {
    test('returns my orders list', () async {
      final mockClient = MockClient((request) async {
        expect(request.method, 'GET');
        expect(request.headers['Authorization'], 'Bearer $token');

        return http.Response(
          jsonEncode([
            {
              '_id': 'order-1',
              'buyerId': 'buyer-1',
              'items': [],
              'totalAmount': 800.0,
              'paymentMethod': 'cod',
              'paymentStatus': 'paid',
              'shippingAddress': {'city': 'Colombo'},
              'status': 'shipped',
              'createdAt': '2026-03-20T08:00:00.000Z',
            },
            {
              '_id': 'order-2',
              'buyerId': 'buyer-1',
              'items': [],
              'totalAmount': 1200.0,
              'paymentMethod': 'cod',
              'paymentStatus': 'pending',
              'shippingAddress': {'city': 'Kandy'},
              'status': 'processing',
              'createdAt': '2026-03-21T09:00:00.000Z',
            },
          ]),
          200,
          headers: {'content-type': 'application/json'},
        );
      });

      final orders = await http.runWithClient(
        () => OrderService.getMyOrders(token),
        () => mockClient,
      );

      expect(orders, hasLength(2));
      expect(orders[0].id, 'order-1');
      expect(orders[0].status, 'shipped');
      expect(orders[1].id, 'order-2');
      expect(orders[1].totalAmount, 1200.0);
    });

    test('returns empty list when no orders', () async {
      final mockClient = MockClient((request) async {
        return http.Response(
          jsonEncode([]),
          200,
          headers: {'content-type': 'application/json'},
        );
      });

      final orders = await http.runWithClient(
        () => OrderService.getMyOrders(token),
        () => mockClient,
      );

      expect(orders, isEmpty);
    });

    test('throws when loading orders fails', () async {
      final mockClient = MockClient((request) async {
        return http.Response(
          jsonEncode({'msg': 'Unauthorized'}),
          401,
          headers: {'content-type': 'application/json'},
        );
      });

      await expectLater(
        http.runWithClient(
          () => OrderService.getMyOrders(token),
          () => mockClient,
        ),
        throwsA(isA<Exception>()),
      );
    });
  });
}
