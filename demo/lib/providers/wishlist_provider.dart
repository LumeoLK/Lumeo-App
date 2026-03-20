import 'package:flutter_riverpod/legacy.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../model/product.dart';
import '../services/wishlist_service.dart';

class WishlistState {
  final List<Product> items;
  final bool isLoading;
  final String? error;

  const WishlistState({
    this.items = const [],
    this.isLoading = false,
    this.error,
  });

  WishlistState copyWith({
    List<Product>? items,
    bool? isLoading,
    String? error,
  }) {
    return WishlistState(
      items: items ?? this.items,
      isLoading: isLoading ?? this.isLoading,
      error: error,
    );
  }
}

class WishlistNotifier extends StateNotifier<WishlistState> {
  WishlistNotifier() : super(const WishlistState());

  Future<String> _getToken() async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('x-auth-token') ?? '';
    print('[WishlistProvider] Token: ${token.isNotEmpty ? token.substring(0, 10) : "EMPTY"}...');
    return token;
  }

  // Fetch Wishlist
  Future<void> fetchWishlist() async {
    print('[WishlistProvider] fetchWishlist called');
    state = state.copyWith(isLoading: true, error: null);

    try {
      final token = await _getToken();
      if (token.isEmpty) {
        print('[WishlistProvider] No token, skipping fetch');
        state = state.copyWith(items: [], isLoading: false);
        return;
      }
      final rawItems = await WishlistService.getWishlist(token);
      print('[WishlistProvider] Got ${rawItems.length} raw items');

      final items = rawItems.map((e) => Product.fromJson(e)).toList();
      print('[WishlistProvider] Parsed ${items.length} products');

      state = state.copyWith(items: items, isLoading: false);
    } catch (e) {
      print('[WishlistProvider] fetchWishlist ERROR: $e');
      state = state.copyWith(error: e.toString(), isLoading: false);
    }
  }

  // Add Product to Wishlist
  Future<void> addToWishlist(String productId) async {
    print('[WishlistProvider] addToWishlist called with productId=$productId');
    try {
      final token = await _getToken();
      await WishlistService.addToWishlist(token, productId);

      await fetchWishlist(); // refresh wishlist
    } catch (e) {
      print('[WishlistProvider] addToWishlist ERROR: $e');
      state = state.copyWith(error: e.toString());
    }
  }

  // Remove Product
  Future<void> removeFromWishlist(String productId) async {
    print('[WishlistProvider] removeFromWishlist called with productId=$productId');
    try {
      final token = await _getToken();
      await WishlistService.removeFromWishlist(token, productId);

      await fetchWishlist(); // refresh wishlist
    } catch (e) {
      print('[WishlistProvider] removeFromWishlist ERROR: $e');
      state = state.copyWith(error: e.toString());
    }
  }
}

final wishlistProvider = StateNotifierProvider<WishlistNotifier, WishlistState>((ref) {
  return WishlistNotifier();
});
