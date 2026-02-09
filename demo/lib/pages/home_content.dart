import 'package:flutter/material.dart';

import '../widgets/search_bar.dart';
import '../widgets/banner_carousel.dart';
import '../widgets/product_section.dart';
import '../data/dummy_products.dart';

class HomeContent extends StatelessWidget {
  const HomeContent({super.key});

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const BannerCarousel(images: ["assets/banner.png"]),

          const SearchBarWidget(hintText: "Search products"),
          const SizedBox(height: 25),
          ProductSection(title: "Sale", products: dummyProducts),
          ProductSection(title: "New Arrivals", products: dummyProducts),
          ProductSection(title: "For You", products: dummyProducts),
        ],
      ),
    );
  }
}
