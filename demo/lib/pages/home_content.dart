import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../widgets/search_bar.dart';
import '../widgets/banner_carousel.dart';
import '../widgets/product_section.dart';
import '../services/product_service.dart';
import '../model/product.dart';

// Provider to fetch products from MongoDB
final productsProvider = FutureProvider<List<Product>>((ref) async {
  return await ProductService.getAllProducts();
});

class HomeContent extends ConsumerWidget {
  const HomeContent({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final productsAsyncValue = ref.watch(productsProvider);

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const BannerCarousel(images: ["assets/banner.png"]),
          const SearchBarWidget(hintText: "Search products"),
          const SizedBox(height: 25),
          // Display products based on async state
          productsAsyncValue.when(
            loading: () => const Padding(
              padding: EdgeInsets.all(24.0),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  CircularProgressIndicator(),
                  SizedBox(height: 16),
                  Text('Loading products...'),
                ],
              ),
            ),
            error: (error, stackTrace) => Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                children: [
                  const SizedBox(height: 20),
                  const Icon(Icons.error_outline, color: Colors.red, size: 48),
                  const SizedBox(height: 16),
                  Text(
                    'Failed to load products',
                    style: Theme.of(context).textTheme.titleMedium,
                  ),
                  const SizedBox(height: 8),
                  Text(
                    error.toString(),
                    style: const TextStyle(color: Colors.white70, fontSize: 12),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 16),
                  ElevatedButton.icon(
                    onPressed: () {
                      ref.refresh(productsProvider);
                    },
                    icon: const Icon(Icons.refresh),
                    label: const Text('Retry'),
                  ),
                ],
              ),
            ),
            data: (products) {
              if (products.isEmpty) {
                return Center(
                  child: Padding(
                    padding: const EdgeInsets.all(24.0),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Icon(Icons.shopping_bag_outlined,
                            size: 48, color: Colors.white54),
                        const SizedBox(height: 16),
                        const Text('No products available'),
                      ],
                    ),
                  ),
                );
              }
              return Column(
                children: [
                  ProductSection(title: "All Products", products: products),
                  ProductSection(title: "New Arrivals", products: products),
                  ProductSection(title: "For You", products: products),
                ],
              );
            },
          ),
        ],
      ),
    );
  }
}
