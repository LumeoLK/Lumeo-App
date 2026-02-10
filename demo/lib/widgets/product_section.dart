import 'package:flutter/material.dart';
import '../product/product_card.dart';

class ProductSection extends StatelessWidget {
  final String title;
  final String subTitle;
  final List products;
  final String viewAll = "View All";

  const ProductSection({
    super.key,
    required this.title,
    required this.subTitle,
    required this.products,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: const TextStyle(
            fontSize: 32,
            fontWeight: FontWeight.bold,
          ),
        ),
        // subtitle and view more on same row
        Row(
          children: [
            Expanded(
              child: Text(
                subTitle,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(
                  fontSize: 18,
                  color: Color.fromARGB(255, 171, 180, 189),
                ),
              ),
            ),
            Text(
              viewAll,
              style: const TextStyle(
                fontSize: 18,
                color: Color.fromARGB(255, 171, 180, 189),
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        SizedBox(
          height: 220,
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            itemCount: products.length,
            itemBuilder: (context, index) {
              return ProductCard(product: products[index]);
            },
          ),
        ),
        const SizedBox(height: 25),
      ],
    );
  }
}
