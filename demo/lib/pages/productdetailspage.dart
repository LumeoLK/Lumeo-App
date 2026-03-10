import 'package:flutter/material.dart';
import 'package:lumeo_v2/pages/chat_application.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../model/product.dart';
import 'ar_screen.dart';

class ProductDetailsPage extends StatefulWidget {
  const ProductDetailsPage({super.key, required this.product});

  final Product product;

  @override
  State<ProductDetailsPage> createState() => _ProductDetailsPageState();
}

class _ProductDetailsPageState extends State<ProductDetailsPage> {
  final Color backgroundColor = const Color(0xFF1E1E1E);
  final Color cardColor = const Color(0xFF2A2A2A);
  final Color accentColor = const Color(0xFFFDB04B);
  final Color secondaryTextColor = Colors.white70;
  int _selectedImageIndex = 0;
  @override
  Widget build(BuildContext context) {
    final images = widget.product.images;
    // 👇 widget.product gives you access to the product passed in
    final product = widget.product;

    return Scaffold(
      backgroundColor: backgroundColor,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(product.name, style: const TextStyle(color: Colors.white)),
        centerTitle: true,
        actions: [
          IconButton(
            icon: const Icon(Icons.share, color: Colors.white),
            onPressed: () {},
          ),
        ],
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            //Image Placeholder Section
            Container(
              height: 350,
              width: double.infinity,
              color: Colors.grey[800], // Placeholder from
              child: images.isNotEmpty
                  // Has images → show from Cloudinary
                  ? Image.network(
                      images[_selectedImageIndex],
                      fit: BoxFit.cover,
                      // Spinner while image loads
                      loadingBuilder: (context, child, loadingProgress) {
                        if (loadingProgress == null) return child;
                        return const Center(child: CircularProgressIndicator());
                      },
                      // Placeholder if image fails
                      errorBuilder: (context, error, stackTrace) {
                        return const Center(
                          child: Icon(
                            Icons.image_not_supported,
                            size: 50,
                            color: Colors.white24,
                          ),
                        );
                      },
                    )
                  //  No images show placeholder
                  : const Center(
                      child: Icon(Icons.image, size: 50, color: Colors.white24),
                    ),
            Stack(
              children: [
                // Product Image
                Container(
                  height: 350,
                  width: double.infinity,
                  color: Colors.grey[800],
                  child: product.image.isNotEmpty
                      ? Image.network(product.image, fit: BoxFit.cover)
                      : const Center(
                          child: Icon(Icons.image, size: 50, color: Colors.white24),
                        ),
                ),

                // AR Button — bottom right corner
                Positioned(
                  bottom: 20,
                  right: 20,
                  child: GestureDetector(
                    onTap: () {
                      // ✅ FIXED: was "product.modelUrl", now "widget.product.modelUrl"
                      // Both work since we did `final product = widget.product` above
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => ARScreen(modelUrl: product.modelUrl),
                        ),
                      );
                    },
                    child: Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: Colors.black.withOpacity(0.5),
                        shape: BoxShape.circle,
                        border: Border.all(color: Colors.white24),
                      ),
                      child: Image.asset(
                        'assets/icons/ar.png',
                        width: 30,
                        height: 30,
                        color: Colors.white,
                      ),
                    ),
                  ),
                ),
              ],
            ),

            if (images.length > 1)
              SizedBox(
                height: 70,
                child: ListView.builder(
                  scrollDirection: Axis.horizontal,
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 8,
                  ),
                  itemCount: images.length,
                  itemBuilder: (context, index) {
                    final isSelected = index == _selectedImageIndex;
                    return GestureDetector(
                      // Tap thumbnail → update main image
                      onTap: () => setState(() {
                        _selectedImageIndex = index;
                      }),
                      child: Container(
                        width: 55,
                        margin: const EdgeInsets.only(right: 8),
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(8),
                          // Highlight selected thumbnail
                          border: Border.all(
                            color: isSelected
                                ? accentColor
                                : Colors.transparent,
                            width: 2,
                          ),
                        ),
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(6),
                          child: Image.network(
                            images[index],
                            fit: BoxFit.cover,
                          ),
                        ),
                      ),
                    );
                  },
                ),
              ),
            Padding(
              padding: const EdgeInsets.all(20.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      _buildDropdown("Size"),
                      const SizedBox(width: 10),
                      _buildDropdown("Mahogani"),
                      const Spacer(),
                      const Icon(Icons.favorite_border, color: Colors.white),
                    ],
                  ),
                  const SizedBox(height: 20),

                  // ✅ FIXED: now uses real product data
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        product.name,
                        style: const TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                      Text(
                        '\$${product.price.toStringAsFixed(2)}',
                        style: const TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                    ],
                  ),
                  Text(
                    widget.product.shopName,
                    style: TextStyle(color: secondaryTextColor),
                  ),
                  const SizedBox(height: 15),

                  // ✅ FIXED: now uses real description
                  Text(
                    widget.product.description,
                    style: TextStyle(color: secondaryTextColor, height: 1.5),
                  ),
                  const SizedBox(height: 25),

                  SizedBox(
                    width: double.infinity,
                    height: 55,
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: accentColor,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(30),
                        ),
                      ),
                      onPressed: () async {
                        // try {
                        //   SharedPreferences prefs = await SharedPreferences.getInstance();
                        //   String token = prefs.getString('x-auth-token') ?? '';
                        //   await CartService.addToCart(
                        //     token,
                        //     widget.product.id,
                        //     widget.product.price,
                        //   );

                        //   ScaffoldMessenger.of(context).showSnackBar(
                        //     const SnackBar(content: Text("Added to cart")),
                        //   );
                        // } catch (e) {
                        //   print(e);
                        // }
                      },
                      child: const Text(
                        "ADD TO CART",
                        style: TextStyle(
                          color: Colors.black,
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 30),

                  // 6. List tiles for Shop Info/Customization
                  const Divider(color: Colors.white24),

                  _buildListTile("Ask For Customizations", () {
                    // Navigation code to the chat application page
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => const ChatApplication(),
                      ),
                    );
                  }),
                  const SizedBox(height: 30),

                  const Text(
                    "You can also like this",
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                  const SizedBox(height: 15),

                  SizedBox(
                    height: 200,
                    child: ListView.builder(
                      scrollDirection: Axis.horizontal,
                      itemCount: 3,
                      itemBuilder: (context, index) => _buildRelatedItem(),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDropdown(String label) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        border: Border.all(color: Colors.white24),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        children: [
          Text(label, style: const TextStyle(color: Colors.white)),
          const Icon(Icons.arrow_drop_down, color: Colors.white),
        ],
      ),
    );
  }

  Widget _buildListTile(String title, VoidCallback onTap) {
    return ListTile(
      contentPadding: EdgeInsets.zero,
      title: Text(title, style: const TextStyle(color: Colors.white)),
      trailing: const Icon(Icons.chevron_right, color: Colors.white),
      onTap: onTap, // Triggers the navigation
    );
  }

  Widget _buildRelatedItem() {
    return Container(
      width: 150,
      margin: const EdgeInsets.only(right: 15),
      decoration: BoxDecoration(
        color: cardColor,
        borderRadius: BorderRadius.circular(15),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            child: Container(
              decoration: BoxDecoration(
                color: Colors.grey[700],
                borderRadius: const BorderRadius.vertical(top: Radius.circular(15)),
              ),
            ),
          ),
          const Padding(
            padding: EdgeInsets.all(8.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text("Dining Chair", style: TextStyle(color: Colors.white, fontSize: 12)),
                Text("\$12", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
