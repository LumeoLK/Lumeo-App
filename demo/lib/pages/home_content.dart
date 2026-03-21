
import 'package:flutter/material.dart';
import '../widgets/search_bar.dart';
import '../widgets/banner_carousel.dart';
import '../widgets/product_section.dart';
import '../providers/product_provider.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class HomeContent extends ConsumerStatefulWidget {
  const HomeContent({super.key});

  @override
  ConsumerState<HomeContent> createState() => _HomeContentState();
}

class _HomeContentState extends ConsumerState<HomeContent> {
  String _searchQuery = '';

  bool _matchesSearch(dynamic product, String query) {
    if (query.isEmpty) return true;
    final normalized = query.toLowerCase();
    final name = (product.name ?? '').toString().toLowerCase();
    final category = (product.category ?? '').toString().toLowerCase();
    final description = (product.description ?? '').toString().toLowerCase();
    final shopName = (product.shopName ?? '').toString().toLowerCase();

    return name.contains(normalized) ||
        category.contains(normalized) ||
        description.contains(normalized) ||
        shopName.contains(normalized);
  }

  List<dynamic> _filterProducts(List<dynamic> products) {
    if (_searchQuery.trim().isEmpty) return products;
    return products.where((product) => _matchesSearch(product, _searchQuery.trim())).toList();
  }

  @override
  void initState() {
    super.initState();

    // Runs once when the page first opens
    // waits for the page to fully build then fetches
    Future.microtask(() => ref.read(productProvider.notifier).fetchProducts());
  }

  @override
  Widget build(BuildContext context) {
    // Every time state changes this widget rebuilds automatically
    final productState = ref.watch(productProvider);

    // ref.listen — listens for changes without rebuilding the page
    ref.listen(productProvider, (previous, next) {
      // Only show snackbar when a new error appears
      if (next.error != null && next.error != previous?.error) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text(next.error!)));
      }
    });

    // User sees this while products are being fetched
    if (productState.isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    // Products are ready — show the actual page
    final filteredProducts = _filterProducts(productState.products);

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const BannerCarousel(images: ["assets/banner.png"]),
          SearchBarWidget(
            hintText: "Search products",
            onChanged: (value) {
              setState(() {
                _searchQuery = value;
              });
            },
          ),
          const SizedBox(height: 25),
          if (_searchQuery.trim().isEmpty) ...[
            ProductSection(title: "Sale", products: productState.saleProducts),
            ProductSection(
              title: "New Arrivals",
              products: productState.newArrivals,
            ),
            ProductSection(title: "For You", products: productState.forYou),
          ] else if (filteredProducts.isEmpty) ...[
            const Padding(
              padding: EdgeInsets.symmetric(vertical: 24),
              child: Text(
                "No products found",
                style: TextStyle(color: Colors.white70, fontSize: 16),
              ),
            ),
          ] else ...[
            ProductSection(title: "Search Results", products: filteredProducts),
          ],
        ],
      ),
    );
  }
}
