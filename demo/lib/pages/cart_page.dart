import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../providers/cart_provider.dart';
import '../providers/auth_provider.dart';
import '../model/cart_item.dart';
import 'package:lumeo_v2/widgets/search_bar.dart';
import 'add_shipping_address.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../widgets/login_required_dialog.dart';

class CartPage extends ConsumerStatefulWidget {
  const CartPage({Key? key}) : super(key: key);

  @override
  ConsumerState<CartPage> createState() => _CartPageState();
}

class _CartPageState extends ConsumerState<CartPage> {
  String _searchQuery = '';
  bool _isLoggedIn = false;

  List<CartItem> _filterCartItems(List<CartItem> items) {
    final query = _searchQuery.trim().toLowerCase();
    if (query.isEmpty) return items;

    return items.where((item) {
      final name = (item.productName ?? '').toLowerCase();
      return name.contains(query);
    }).toList();
  }

  @override
  void initState() {
    super.initState();
    Future.microtask(() async {
      await _checkLoginStatus();
      if (_isLoggedIn) {
        ref.read(cartProvider.notifier).fetchCart();
      }
    });
  }

  Future<void> _checkLoginStatus() async {
    final user = ref.read(currentUserProvider);
    if (user != null && user.id.isNotEmpty) {
      if (mounted) setState(() => _isLoggedIn = true);
      return;
    }

    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('x-auth-token') ?? '';
    if (token.isNotEmpty) {
      if (mounted) setState(() => _isLoggedIn = true);
      return;
    }

    if (mounted) setState(() => _isLoggedIn = false);
  }

  @override
  Widget build(BuildContext context) {
    if (!_isLoggedIn) {
      return Scaffold(
        backgroundColor: const Color(0xFF1a1a1a),
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.shopping_cart_outlined, color: Colors.grey, size: 64),
              const SizedBox(height: 16),
              const Text(
                'Login to access your Cart',
                style: TextStyle(color: Colors.grey, fontSize: 18),
              ),
              const SizedBox(height: 16),
              ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFFFBB040),
                  foregroundColor: Colors.black,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(20),
                  ),
                ),
                onPressed: () => LoginRequiredDialog.show(context),
                child: const Text('Login'),
              ),
            ],
          ),
        ),
      );
    }

    final cartState = ref.watch(cartProvider);
    final filteredItems = _filterCartItems(cartState.items);

    return Scaffold(
      backgroundColor: const Color(0xFF1a1a1a),
      appBar: AppBar(
        backgroundColor: const Color(0xFF1a1a1a),
        elevation: 0,
        toolbarHeight: 70,
        title: SearchBarWidget(
          hintText: 'Search cart',
          onChanged: (value) {
            setState(() {
              _searchQuery = value;
            });
          },
        ),
      ),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Padding(
            padding: EdgeInsets.all(16.0),
            child: Text(
              'Cart',
              style: TextStyle(
                color: Colors.white,
                fontSize: 32,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),

         
          Expanded(
            child: cartState.isLoading
                ? const Center(child: CircularProgressIndicator(color: Color(0xFFFBB040)))
                : cartState.error != null
                    ? Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text(
                              'Something went wrong',
                              style: TextStyle(color: Colors.white70),
                            ),
                            if (cartState.error != null) ...[
                              const SizedBox(height: 8),
                              Padding(
                                padding: const EdgeInsets.symmetric(horizontal: 24),
                                child: Text(
                                  cartState.error!,
                                  textAlign: TextAlign.center,
                                  style: const TextStyle(
                                    color: Colors.redAccent,
                                    fontSize: 12,
                                  ),
                                ),
                              ),
                            ],
                            const SizedBox(height: 12),
                            ElevatedButton(
                              onPressed: () =>
                                  ref.read(cartProvider.notifier).fetchCart(),
                              style: ElevatedButton.styleFrom(
                                  backgroundColor: const Color(0xFFFBB040)),
                              child: const Text('Retry',
                                  style: TextStyle(color: Colors.black)),
                            ),
                          ],
                        ),
                      )
                    : filteredItems.isEmpty
                        ? const Center(
                            child: Text(
                              'No cart items found',
                              style: TextStyle(color: Colors.white70, fontSize: 16),
                            ),
                          )
                        : ListView.builder(
                            padding: const EdgeInsets.symmetric(horizontal: 16),
                            itemCount: filteredItems.length,
                            itemBuilder: (context, index) {
                              return buildCartItem(filteredItems[index]);
                            },
                          ),
          ),

          // Promo code section
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Row(
              children: [
                Expanded(
                  child: Container(
                    height: 50,
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    decoration: BoxDecoration(
                      color: const Color(0xFF2a2a2a),
                      borderRadius: BorderRadius.circular(25),
                    ),
                    child: const Center(
                      child: TextField(
                        style: TextStyle(color: Colors.white),
                        decoration: InputDecoration(
                          hintText: 'Enter your promo code',
                          hintStyle: TextStyle(color: Colors.grey),
                          border: InputBorder.none,
                        ),
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                Container(
                  width: 50,
                  height: 50,
                  decoration: const BoxDecoration(
                    color: Color(0xFF3a3a3a),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(Icons.arrow_forward, color: Colors.white),
                ),
              ],
            ),
          ),

          // Total amount
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'Total amount:',
                  style: TextStyle(color: Colors.grey, fontSize: 16),
                ),
                Text(
                  '\$${cartState.totalPrice.toStringAsFixed(2)}',
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: 16),

          // Reserve button
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: SizedBox(
              width: double.infinity,
              height: 55,
              child: ElevatedButton(
                onPressed: cartState.items.isEmpty ? null : () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => AddShippingAddressPage(),
                    ),
                  );
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFFFBB040),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(30),
                  ),
                ),
                child: const Text(
                  'RESERVE',
                  style: TextStyle(
                    color: Colors.black,
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget buildCartItem(CartItem item) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: const Color(0xFF2a2a2a),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
         
          Container(
            width: 100,
            height: 100,
            decoration: BoxDecoration(
              color: const Color(0xFF3a3a3a),
              borderRadius: BorderRadius.circular(8),
            ),
            clipBehavior: Clip.antiAlias,
            child: (item.productImage != null && item.productImage!.isNotEmpty)
                ? Image.network(
                    item.productImage!,
                    fit: BoxFit.cover,
                    errorBuilder: (context, error, stackTrace) {
                      return const Icon(
                        Icons.image_not_supported,
                        color: Colors.white54,
                        size: 36,
                      );
                    },
                  )
                : const Icon(Icons.chair, color: Colors.white54, size: 40),
          ),

          const SizedBox(width: 12),

          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Expanded(
                      child: Text(
                        item.productName?.isNotEmpty == true
                            ? item.productName!
                            : 'Item ${item.productId}',
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                        ),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    IconButton(
                      icon: const Icon(Icons.delete_outline, color: Colors.redAccent, size: 20),
                      onPressed: () async {
                        final notifier = ref.read(cartProvider.notifier);
                        await notifier.removeFromCart(item.productId);
                        final latest = ref.read(cartProvider);
                        if (!mounted) return;
                        if (latest.error != null) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(content: Text(latest.error!)),
                          );
                        } else {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(content: Text('Item removed from cart')),
                          );
                        }
                      },
                    ),
                  ],
                ),

                const SizedBox(height: 12),

                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Qty: ${item.quantity}',
                      style: const TextStyle(color: Colors.white70, fontSize: 14),
                    ),
                    Text(
                      '\$${item.price.toStringAsFixed(2)}',
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}