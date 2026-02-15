import 'package:flutter/material.dart';

class WishListPage extends StatefulWidget {
  const WishListPage({Key? key}) : super(key: key);

  @override
  State<WishListPage> createState() => _WishListPageState();
}

class _WishListPageState extends State<WishListPage> {
  String selectedCategory = '';
  String sortBy = 'low_to_high';

  // sample data for testing
  final List<Map<String, dynamic>> wishListItems = [
    {
      'id': 1,
      'name': 'Tufted Wingback Accent Chair',
      'seller': 'Nathan James',
      'material': 'Mahogany',
      'price': 32,
      'image': 'assets/images/chair1.avif',
      'isNew': false,
      'discount': null,
      'soldOut': false,
      'category': 'Chairs',
    },
    {
      'id': 2,
      'name': 'Modern Wood-Frame Armchair',
      'seller': 'Nathan James',
      'material': 'Teak',
      'price': 46,
      'image': 'assets/images/chair2.avif',
      'isNew': true,
      'discount': null,
      'soldOut': false,
      'category': 'Chairs',
    },
    {
      'id': 3,
      'name': 'Modern Ergonomic Scoop Chair',
      'seller': 'John Doe',
      'material': 'Walnut',
      'price': 52,
      'image': 'assets/images/chair3.jpg',
      'isNew': false,
      'discount': null,
      'soldOut': true,
      'category': 'Chairs',
    },
    {
      'id': 4,
      'name': '6-Seater Pedestal Dining Table',
      'seller': 'John Doe',
      'material': 'Mahogany',
      'price': 100,
      'image': 'assets/images/table.png',
      'isNew': false,
      'discount': 30,
      'soldOut': false,
      'category': 'Tables',
    },
  ];

  @override
  Widget build(BuildContext context) {
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
              contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 10),
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
                      child: _getFilteredItems().isEmpty
                          ? const Center(
                              child: Text(
                                'No items',
                                style: TextStyle(color: Colors.grey, fontSize: 16),
                              ),
                            )
                          : ListView.builder(
                              padding: const EdgeInsets.symmetric(horizontal: 16),
                              itemCount: _getFilteredItems().length,
                              itemBuilder: (context, index) {
                                return _buildWishListItem(_getFilteredItems()[index]);
                              },
                            ),  
                        ),
                  ],
                ),
                bottomNavigationBar: _buildBottomNav(),
              );
            }

            List<Map<String, dynamic>> _getFilteredItems() {
              List<Map<String, dynamic>> filtered;
              
              // filter by category
              if (selectedCategory.isEmpty) {
                filtered = List.from(wishListItems);
              } else {
                filtered = wishListItems.where((item) {
                  return item['category'] == selectedCategory;
                }).toList();
              }
              
              // apply sorting
              if (sortBy == 'low_to_high') {
                filtered.sort((a, b) => a['price'].compareTo(b['price']));
              } else if (sortBy == 'high_to_low') {
                filtered.sort((a, b) => b['price'].compareTo(a['price']));
              } else if (sortBy == 'available') {
                filtered = filtered.where((item) => !item['soldOut']).toList();
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
              selectedCategory = '';  // deselect if clicking same category
            } else {
              selectedCategory = category;  // select new category
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

  Widget _buildWishListItem(Map<String, dynamic> item) {
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
                  child: item['soldOut']
                      ? ColorFiltered(
                          colorFilter: const ColorFilter.mode(
                            Colors.grey,
                            BlendMode.saturation,
                          ),
                          child: Image.asset(
                            item['image'],
                            fit: BoxFit.cover,
                          ),
                        )
                      : Image.asset(
                          item['image'],
                          fit: BoxFit.cover,
                        ),
                ),
              ),
              if (item['isNew'])
                Positioned(
                  top: 8,
                  left: 8,
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(4),
                    ),
                    child: const Text(
                      'NEW',
                      style: TextStyle(
                        color: Colors.black,
                        fontSize: 10,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
              if (item['discount'] != null)
                Positioned(
                  top: 8,
                  left: 8,
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: Colors.red,
                      borderRadius: BorderRadius.circular(4),
                    ),
                    child: Text(
                      '-${item['discount']}%',
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 10,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
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
                  item['seller'],
                  style: const TextStyle(
                    color: Colors.grey,
                    fontSize: 12,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  item['name'],
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                Text(
                  item['material'],
                  style: const TextStyle(
                    color: Colors.grey,
                    fontSize: 12,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  '${item['price']}\$',
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                if (item['soldOut'])
                  const Padding(
                    padding: EdgeInsets.only(top: 4),
                    child: Text(
                      'Sorry, this item is currently sold out',
                      style: TextStyle(
                        color: Colors.grey,
                        fontSize: 11,
                      ),
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
                  print('Remove item ${item['id']}');
                },
              ),
              const SizedBox(height: 20),
              Container(
                decoration: const BoxDecoration(
                  color: Color(0xFFFBB040),
                  shape: BoxShape.circle,
                ),
                child: IconButton(
                  icon: const Icon(Icons.shopping_cart, color: Colors.white, size: 20),
                  onPressed: item['soldOut']
                      ? null
                      : () {
                          // navigate to AR view or add to cart
                          print('View in AR: ${item['name']}');
                        },
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildBottomNav() {
    return Container(
      height: 70,
      decoration: const BoxDecoration(
        color: Color(0xFF2a2a2a),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          _buildNavItem(Icons.home, 'Home', false),
          _buildNavItem(Icons.favorite_border, 'Wish List', true),
          _buildNavItem(Icons.view_in_ar, 'AR View', false),
          _buildNavItem(Icons.shopping_cart, 'Cart', false),
          _buildNavItem(Icons.settings, 'Custom', false),
        ],
      ),
    );
  }

  Widget _buildNavItem(IconData icon, String label, bool isActive) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Icon(
          icon,
          color: isActive ? Colors.white : const Color(0xFFFBB040),
          size: 28,
        ),
        const SizedBox(height: 4),
        Text(
          label,
          style: TextStyle(
            color: isActive ? Colors.white : const Color(0xFFFBB040),
            fontSize: 10,
          ),
        ),
      ],
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
