import 'package:flutter_riverpod/flutter_riverpod.dart';
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

  // lowest priced products
  List<Product> get saleProducts {
    final sorted = [...products];
    sorted.sort((a, b) => a.price.compareTo(b.price));
    return sorted.take(10).toList();
  }

  //  most recently added
  List<Product> get newArrivals {
    final sorted = [...products];
    sorted.sort((a, b) {
      if (a.createdAt == null || b.createdAt == null) return 0;
      return b.createdAt!.compareTo(a.createdAt!);
    });
    return sorted.take(10).toList();
  }

  // most viewed / popular
  List<Product> get forYou {
    final sorted = [...products];
    sorted.sort((a, b) => b.views.compareTo(a.views));
    return sorted.take(10).toList();
  }

  // similar products by category
  List<Product> similarProducts(String category, String excludeId) {
    final filtered = products
        .where((p) => p.category == category && p.id != excludeId)
        .toList();
    // fallback to popular if no similar products found
    if (filtered.isEmpty) {
      return forYou;
    }
    return filtered.take(10).toList();
  }

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

class ProductNotifier extends Notifier<ProductState> {
  late final ProductService _service;

  @override
  ProductState build() {
    _service = ref.read(productServiceProvider);
    return const ProductState();
  }

  Future<void> fetchProducts() async {
    state = state.copyWith(isLoading: true, error: null);
    try {
      final products = await _service.getAllProducts();
      state = state.copyWith(products: products, isLoading: false);
    } catch (e) {
      state = state.copyWith(error: e.toString(), isLoading: false);
    }
  }
}

final productServiceProvider = Provider((ref) => ProductService());

final productProvider = NotifierProvider<ProductNotifier, ProductState>(
  () => ProductNotifier(),
);
