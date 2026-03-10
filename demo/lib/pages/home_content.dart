import 'package:flutter/material.dart';
import '../widgets/search_bar.dart';
import '../widgets/banner_carousel.dart';
import '../widgets/product_section.dart';
import '../providers/product_provider.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../utils/utils.dart';


class HomeContent extends ConsumerStatefulWidget {
  const HomeContent({super.key});

  @override
  ConsumerState<HomeContent> createState() => _HomeContentState();
}

class _HomeContentState extends ConsumerState<HomeContent> {
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
        showSnackBar(context, next.error!);
      }
    });


    // User sees this while products are being fetched
    if (productState.isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    // Grab the products list from the whiteboard
    final products = productState.products;

    // Products are ready — show the actual page
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const BannerCarousel(images: ["assets/banner.png"]),
          const SearchBarWidget(hintText: "Search products"),
          const SizedBox(height: 25),
          ProductSection(title: "Sale", products: products),
          ProductSection(title: "New Arrivals", products: products),
          ProductSection(title: "For You", products: products),
        ],
      ),
    );
  }
}
