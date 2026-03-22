import 'package:flutter_test/flutter_test.dart';
import 'package:lumeo_v2/model/cart_item.dart';
import 'package:lumeo_v2/model/product.dart';

void main() {
  group('Product.fromJson', () {
    test('maps full product json correctly', () {
      final json = <String, dynamic>{
        '_id': 'p1',
        'title': 'Modern Chair',
        'price': 149.99,
        'images': ['https://img/1.png', 'https://img/2.png'],
        'description': 'Ergonomic chair',
        'shopName': 'Lumeo Store',
        'sellerId': {'_id': 'seller-123'},
        'category': 'furniture',
        'views': 14,
        'createdAt': '2026-01-15T10:30:00.000Z',
        'model3D': {'url': 'https://cdn/model.glb'},
        'averageRating': 4.6,
      };

      final product = Product.fromJson(json);

      expect(product.id, 'p1');
      expect(product.name, 'Modern Chair');
      expect(product.price, 149.99);
      expect(product.images, hasLength(2));
      expect(product.shopName, 'Lumeo Store');
      expect(product.sellerId, 'seller-123');
      expect(product.modelUrl, 'https://cdn/model.glb');
      expect(product.averageRating, 4.6);
      expect(product.createdAt, isNotNull);
    });

    test('uses defaults when fields are missing', () {
      final json = <String, dynamic>{
        '_id': 'p2',
        'title': 'Side Table',
        'price': null,
        'description': 'Compact side table',
      };

      final product = Product.fromJson(json);

      expect(product.id, 'p2');
      expect(product.name, 'Side Table');
      expect(product.price, 0.0);
      expect(product.images, isEmpty);
      expect(product.shopName, 'Unknown Seller');
      expect(product.sellerId, '');
      expect(product.modelUrl, '');
      expect(product.averageRating, 0.0);
      expect(product.createdAt, isNull);
    });
  });

  group('CartItem.fromJson', () {
    test('reads nested product info', () {
      final json = <String, dynamic>{
        'productId': {
          '_id': 'prod-11',
          'title': 'Lamp',
          'images': [
            {'url': 'https://img/lamp.png'},
          ],
        },
        'price': 59.5,
        'quantity': 2,
      };

      final item = CartItem.fromJson(json);

      expect(item.productId, 'prod-11');
      expect(item.productName, 'Lamp');
      expect(item.productImage, 'https://img/lamp.png');
      expect(item.price, 59.5);
      expect(item.quantity, 2);
    });

    test('handles plain product id', () {
      final json = <String, dynamic>{
        'productId': 'prod-22',
        'price': 30,
        'quantity': 1,
      };

      final item = CartItem.fromJson(json);

      expect(item.productId, 'prod-22');
      expect(item.productName, isNull);
      expect(item.productImage, isNull);
      expect(item.price, 30.0);
      expect(item.quantity, 1);
    });
  });
}