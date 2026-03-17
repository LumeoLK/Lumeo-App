import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:lumeo_v2/model/product.dart';
import 'package:lumeo_v2/providers/wishlist_provider.dart';

class WishListPage extends ConsumerStatefulWidget {
  const WishListPage({Key? key}) : super(key: key);

  @override
  ConsumerState<WishListPage> createState() => _WishListPageState();
}

class _WishListPageState extends ConsumerState<WishListPage> {
  String selectedCategory = '';
  String sortBy = 'low_to_high';
  @override
  void initState() {
    super.initState();

    Future.microtask(() {
      ref.read(wishlistProvider.notifier).fetchWishlist();
    });
  }

  @override
  Widget build(BuildContext context) {
    final wishlistState = ref.watch(wishlistProvider);
    final items = wishlistState.items;

    if (wishlistState.isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    return Scaffold(
      backgroundColor: const Color(0xFF1a1a1a),
      appBar: AppBar(
        backgroundColor: const Color(0xFF1a1a1a),
        elevation: 0,
        title: Container(
          height: 40,
          decoration: BoxDecoration(
            color: const Color(0xFF2a2a2a),
            borderRadius: BorderRadius.circular(8),
          ),
          child: const TextField(
            style: TextStyle(color: Colors.white, fontSize: 14),
            decoration: InputDecoration(
              hintText: 'Search store',
              hintStyle: TextStyle(color: Colors.grey, fontSize: 14),
              border: InputBorder.none,
              contentPadding: EdgeInsets.symmetric(
                horizontal: 16,
                vertical: 10,
              ),
            ),
          ),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.search, color: Colors.white),
            onPressed: () {
              // search functionality
            },
          ),
          IconButton(
            icon: const Icon(Icons.person, color: Color(0xFFFBB040)),
            onPressed: () {
              // profile page
            },
          ),
        ],
      ),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Padding(
            padding: EdgeInsets.all(16.0),
            child: Text(
              'Wish List',
              style: TextStyle(
                color: Colors.white,
                fontSize: 32,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),

          // category filter chips
          SizedBox(
            height: 50,
            child: ListView(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: 16),
              children: [
                _buildCategoryChip('Chairs'),
                _buildCategoryChip('Beds'),
                _buildCategoryChip('Tables'),
                _buildCategoryChip('Sofas'),
              ],
            ),
          ),

          const SizedBox(height: 16),

          // filters and sorting row
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Row(
              children: [
                InkWell(
                  onTap: () {
                    _showFilterDialog();
                  },
                  child: Row(
                    children: const [
                      Icon(Icons.tune, color: Colors.white, size: 20),
                      SizedBox(width: 8),
                      Text(
                        'Filters',
                        style: TextStyle(color: Colors.white, fontSize: 14),
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 24),
                Expanded(
                  child: Row(
                    children: [
                      Icon(Icons.swap_vert, color: Colors.white, size: 20),
                      SizedBox(width: 8),
                      Text(
                        _getSortText(),
                        style: TextStyle(color: Colors.grey, fontSize: 14),
                      ),
                    ],
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.view_list, color: Colors.white),
                  onPressed: () {
                    // toggle list/grid view
                  },
                ),
              ],
            ),
          ),

          const SizedBox(height: 16),

          // list of items
          Expanded(
            child: _getFilteredItems(items).isEmpty
                ? const Center(
                    child: Text(
                      'No items',
                      style: TextStyle(color: Colors.grey, fontSize: 16),
                    ),
                  )
                : ListView.builder(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    itemCount: _getFilteredItems(items).length,
                    itemBuilder: (context, index) {
                      return _buildWishListItem(_getFilteredItems(items)[index]);
                    },
                  ),
          ),
        ],
      ),
    );
  }

  List<Product> _getFilteredItems(List<Product> items) {
    List<Product> filtered;

    if (selectedCategory.isEmpty) {
      filtered = List.from(items);
    } else {
      filtered = items.where((item) {
        return item.description.toLowerCase().contains(selectedCategory.toLowerCase());
      }).toList();
    }

    if (sortBy == 'low_to_high') {
      filtered.sort((a, b) => a.price.compareTo(b.price));
    } else if (sortBy == 'high_to_low') {
      filtered.sort((a, b) => b.price.compareTo(a.price));
    }

    return filtered;
  }

  String _getSortText() {
    if (sortBy == 'low_to_high') {
      return 'Price: lowest to high';
    } else if (sortBy == 'high_to_low') {
      return 'Price: highest to low';
    } else if (sortBy == 'available') {
      return 'Available only';
    }
    return 'Price: lowest to high';
  }

  Widget _buildCategoryChip(String category) {
    bool isSelected = selectedCategory == category;
    return Padding(
      padding: const EdgeInsets.only(right: 8),
      child: ChoiceChip(
        label: Text(category),
        selected: isSelected,
        onSelected: (selected) {
          setState(() {
            if (selectedCategory == category) {
              selectedCategory = ''; // deselect if clicking same category
            } else {
              selectedCategory = category; // select new category
            }
          });
        },
        backgroundColor: const Color(0xFF2a2a2a),
        selectedColor: Colors.white,
        labelStyle: TextStyle(
          color: isSelected ? Colors.black : Colors.white,
          fontSize: 14,
        ),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      ),
    );
  }

  Widget _buildWishListItem(Product product) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: const Color(0xFF2a2a2a),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          // product image with badges
          Stack(
            children: [
              Container(
                width: 100,
                height: 100,
                decoration: BoxDecoration(
                  color: const Color(0xFF3a3a3a),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(8),
                  child: product.images.isNotEmpty
                      ? Image.network(product.images[0], fit: BoxFit.cover)
                      : Container(color: Colors.grey),
                ),
              ),
            ],
          ),

          const SizedBox(width: 12),

          // product info
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  product.shopName,
                  style: const TextStyle(color: Colors.grey, fontSize: 12),
                ),
                const SizedBox(height: 4),
                Text(
                  product.name,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                Text(
                  '',
                  style: const TextStyle(color: Colors.grey, fontSize: 12),
                ),
                const SizedBox(height: 8),
                Text(
                  '\$${product.price}',
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ),

          // action buttons
          Column(
            children: [
              IconButton(
                icon: const Icon(Icons.close, color: Colors.white, size: 20),
                onPressed: () {
                  // remove from wishlist
                  ref
                      .read(wishlistProvider.notifier)
                      .removeFromWishlist(product.id);
                },
              ),
              const SizedBox(height: 20),
              Container(
                decoration: const BoxDecoration(
                  color: Color(0xFFFBB040),
                  shape: BoxShape.circle,
                ),
                child: IconButton(
                  icon: const Icon(
                    Icons.shopping_cart,
                    color: Colors.white,
                    size: 20,
                  ),
                  onPressed: () {
                          // navigate to AR view or add to cart
                          print('View in AR: ${product.name}');
                        },
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  //filtering options
  void _showFilterDialog() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          backgroundColor: const Color(0xFF2a2a2a),
          title: const Text(
            'Sort & Filter',
            style: TextStyle(color: Colors.white),
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              ListTile(
                title: const Text(
                  'Price: Low to High',
                  style: TextStyle(color: Colors.white),
                ),
                leading: Radio<String>(
                  value: 'low_to_high',
                  groupValue: sortBy,
                  activeColor: const Color(0xFFFBB040),
                  onChanged: (value) {
                    setState(() {
                      sortBy = value!;
                    });
                    Navigator.pop(context);
                  },
                ),
              ),
              ListTile(
                title: const Text(
                  'Price: High to Low',
                  style: TextStyle(color: Colors.white),
                ),
                leading: Radio<String>(
                  value: 'high_to_low',
                  groupValue: sortBy,
                  activeColor: const Color(0xFFFBB040),
                  onChanged: (value) {
                    setState(() {
                      sortBy = value!;
                    });
                    Navigator.pop(context);
                  },
                ),
              ),
              ListTile(
                title: const Text(
                  'Available Only',
                  style: TextStyle(color: Colors.white),
                ),
                leading: Radio<String>(
                  value: 'available',
                  groupValue: sortBy,
                  activeColor: const Color(0xFFFBB040),
                  onChanged: (value) {
                    setState(() {
                      sortBy = value!;
                    });
                    Navigator.pop(context);
                  },
                ),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(context);
              },
              child: const Text(
                'Close',
                style: TextStyle(color: Color(0xFFFBB040)),
              ),
            ),
          ],
        );
      },
    );
  }
}
