import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_riverpod/legacy.dart';
import '../model/product.dart';
import '../services/product_service.dart';

class ProductState {
  final List<Product> products;
  final bool isLoading;
  final String? error;

  const ProductState({
    this.products = const [],
    this.isLoading = false,
    this.error,
  });
  ProductState copyWith({
    List<Product>? products,
    bool? isLoading,
    String? error,
  }) {
    return ProductState(
      products: products ?? this.products,
      isLoading: isLoading ?? this.isLoading,
      error: error ?? this.error,
    );
  }
}

class ProductNotifier extends StateNotifier<ProductState> {
  final ProductService _service;

  ProductNotifier(this._service) : super(const ProductState());

  Future<void> fetchProducts() async {
    state = state.copyWith(isLoading: true, error: null);

    try {
      // Tell service to fetch
      final products = await _service.getAllProducts();

      state = state.copyWith(products: products, isLoading: false);
    } catch (e) {
      state = state.copyWith(error: e.toString(), isLoading: false);
    }
  }
}

final productServiceProvider = Provider((ref) => ProductService());

final productProvider = StateNotifierProvider<ProductNotifier, ProductState>((
  ref,
) {
  return ProductNotifier(ref.watch(productServiceProvider));
});
