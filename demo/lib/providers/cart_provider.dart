import 'package:flutter_riverpod/legacy.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../model/cart_item.dart';
import '../services/cart_service.dart';

class CartState {
  final List<CartItem> items;
  final bool isLoading;
  final String? error;

  const CartState({
    this.items = const [],
    this.isLoading = false,
    this.error,
  });

  CartState copyWith({
    List<CartItem>? items,
    bool? isLoading,
    String? error,
  }) {
    return CartState(
      items: items ?? this.items,
      isLoading: isLoading ?? this.isLoading,
      error: error ?? this.error,
    );
  }

  double get totalPrice =>
      items.fold(0, (sum, item) => sum + item.price * item.quantity);

  int get itemCount => items.fold(0, (sum, item) => sum + item.quantity);
}

class CartNotifier extends StateNotifier<CartState> {
  CartNotifier() : super(const CartState());

  Future<String> _getToken() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString('x-auth-token') ?? '';
  }

  Future<void> fetchCart() async {
    state = state.copyWith(isLoading: true, error: null);
    try {
      final token = await _getToken();
      final rawItems = await CartService.getCart(token);
      final items = rawItems.map((e) => CartItem.fromJson(e)).toList();
      state = state.copyWith(items: items, isLoading: false);
    } catch (e) {
      state = state.copyWith(error: e.toString(), isLoading: false);
    }
  }

  Future<void> addToCart(String productId, double price) async {
    try {
      final token = await _getToken();
      print('[CartProvider] Token: ${token.isNotEmpty ? "${token.substring(0, 20)}..." : "EMPTY"}');
      print('[CartProvider] Adding product: $productId, price: $price');
      await CartService.addToCart(token, productId, price);
      print('[CartProvider] Add to cart succeeded!');
      await fetchCart(); // Refresh cart after adding
    } catch (e) {
      print('[CartProvider] Add to cart FAILED: $e');
      state = state.copyWith(error: e.toString());
    }
  }

  Future<void> removeFromCart(String productId) async {
    try {
      final token = await _getToken();
      await CartService.removeFromCart(token, productId);
      await fetchCart(); // Refresh cart after removing
    } catch (e) {
      state = state.copyWith(error: e.toString());
    }
  }
}

final cartProvider = StateNotifierProvider<CartNotifier, CartState>((ref) {
  return CartNotifier();
});
