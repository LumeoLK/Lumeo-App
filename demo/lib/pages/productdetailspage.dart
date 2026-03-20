import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:lumeo_v2/pages/chat_application.dart';
import 'package:lumeo_v2/providers/cart_provider.dart';
import 'package:lumeo_v2/providers/chat_provider.dart';
import 'package:lumeo_v2/providers/auth_provider.dart';
import '../model/product.dart';
import '../utils/auth_guard.dart';
import '../pages/cart_page.dart';
import '../providers/wishlist_provider.dart';

// Step 1: ConsumerStatefulWidget instead of StatefulWidget
class ProductDetailsPage extends ConsumerStatefulWidget {
  const ProductDetailsPage({super.key, required this.product});

  final Product product;

  @override
  ConsumerState<ProductDetailsPage> createState() => _ProductDetailsPageState();
}

// Step 2: ConsumerState instead of State — this is what gives us access to "ref"
class _ProductDetailsPageState extends ConsumerState<ProductDetailsPage> {
  final Color backgroundColor = const Color(0xFF1E1E1E);
  final Color cardColor = const Color(0xFF2A2A2A);
  final Color accentColor = const Color(0xFFFDB04B);
  final Color secondaryTextColor = Colors.white70;
  int _selectedImageIndex = 0;

  @override
  Widget build(BuildContext context) {
    final images = widget.product.images;

    // Step 3: ref.watch — reads cartState and rebuilds button when isLoading changes
    final cartState = ref.watch(cartProvider);
    final wishlistState = ref.watch(wishlistProvider);
    final isFavorite = wishlistState.items.any((item) => item.id == widget.product.id);

    return Scaffold(
      backgroundColor: backgroundColor,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () async {
            await Navigator.maybePop(context);
          },
        ),
        title: Text(
          widget.product.name,
          style: const TextStyle(color: Colors.white),
        ),
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
            Container(
              height: 350,
              width: double.infinity,
              color: Colors.grey[800],
              child: images.isNotEmpty
                  ? Image.network(
                      images[_selectedImageIndex],
                      fit: BoxFit.cover,
                      loadingBuilder: (context, child, loadingProgress) {
                        if (loadingProgress == null) return child;
                        return const Center(child: CircularProgressIndicator());
                      },
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
                  : const Center(
                      child: Icon(Icons.image, size: 50, color: Colors.white24),
                    ),
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
                      onTap: () => setState(() => _selectedImageIndex = index),
                      child: Container(
                        width: 55,
                        margin: const EdgeInsets.only(right: 8),
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(8),
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
                      IconButton(
                        icon: Icon(
                          isFavorite ? Icons.favorite : Icons.favorite_border,
                          color: isFavorite ? Colors.red : Colors.white,
                        ),
                        onPressed: () async {
                          print('Heart tapped! isFavorite=$isFavorite, productId=${widget.product.id}');
                          
                          if (!await requireAuth(context, ref)) {
                            print('Auth check failed - user not logged in');
                            return;
                          }
                          print('Auth check passed');
                          
                          try {
                            if (isFavorite) {
                              print('Removing from wishlist...');
                              await ref.read(wishlistProvider.notifier).removeFromWishlist(widget.product.id);
                            } else {
                              print('Adding to wishlist...');
                              await ref.read(wishlistProvider.notifier).addToWishlist(widget.product.id);
                            }
                            print('Wishlist operation completed');
                          } catch (e) {
                            print('Wishlist error: $e');
                            if (context.mounted) {
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(
                                  content: Text('Wishlist error: $e'),
                                  backgroundColor: Colors.red,
                                ),
                              );
                            }
                          }
                        },
                      ),
                    ],
                  ),
                  const SizedBox(height: 20),

                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Expanded(
                        child: Text(
                          widget.product.name,
                          style: TextStyle(
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Text(
                        widget.product.price.toString(),
                        style: TextStyle(
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

                  Text(
                    widget.product.description,
                    style: TextStyle(color: secondaryTextColor, height: 1.5),
                  ),
                  const SizedBox(height: 25),

                  // Add to Cart Button
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
                      // Disabled while loading so user can't double-tap
                      onPressed: cartState.isLoading
                          ? null
                          : () async {
                              // Check if user is logged in first
                              if (!await requireAuth(context, ref)) return;

                              // User is authenticated — proceed with adding to cart
                              await ref
                                  .read(cartProvider.notifier)
                                  .addToCart(
                                    widget.product.id,
                                    widget.product.price,
                                  );

                              final error = ref.read(cartProvider).error;
                              if (context.mounted) {
                                if (error == null) {
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (_) => const CartPage(),
                                    ),
                                  );
                                } else {
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    SnackBar(
                                      content: Text('Failed: $error'),
                                      backgroundColor: Colors.red,
                                    ),
                                  );
                                }
                              }
                            },
                      child: cartState.isLoading
                          ? const SizedBox(
                              width: 20,
                              height: 20,
                              child: CircularProgressIndicator(
                                strokeWidth: 2,
                                color: Colors.black,
                              ),
                            )
                          : const Text(
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

                  const Divider(color: Colors.white24),

                  _buildListTile("Ask For Customizations", () async {
                    // Check user is logged in
                    if (!await requireAuth(context, ref)) return;

                    // Get logged in user from Riverpod
                    final currentUser = ref.read(currentUserProvider);
                    if (currentUser == null) return;

                    // Show loading spinner while fetching/creating conversation
                    showDialog(
                      context: context,
                      barrierDismissible: false,
                      builder: (_) =>
                          const Center(child: CircularProgressIndicator()),
                    );

                    try {
                      // Hit POST /api/chat/conversations on your backend
                      final conversation = await ref
                          .read(chatServiceProvider)
                          .startConversation(
                            sellerId: widget.product.sellerId,
                            productId: widget.product.id,
                          );
                      print('=== conversationId: ${conversation.id} ===');
                      print('=== productId: ${conversation.productId} ===');
                      print('=== sellerId: ${widget.product.sellerId} ===');
                      if (context.mounted) {
                        Navigator.pop(context); // dismiss spinner
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => ChatApplication(
                              conversation: conversation,
                              currentUserId: currentUser.id,
                              currentUserName: currentUser.name,
                            ),
                          ),
                        );
                      }
                    } catch (e) {
                      if (context.mounted) {
                        Navigator.pop(context); // dismiss spinner
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text('Could not start chat: $e'),
                            backgroundColor: Colors.red,
                          ),
                        );
                      }
                    }
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
      onTap: onTap,
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
                borderRadius: const BorderRadius.vertical(
                  top: Radius.circular(15),
                ),
              ),
            ),
          ),
          const Padding(
            padding: EdgeInsets.all(8.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  "Dining Chair",
                  style: TextStyle(color: Colors.white, fontSize: 12),
                ),
                Text(
                  "\$12",
                  style: TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
