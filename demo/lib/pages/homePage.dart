import 'package:flutter/material.dart';
import '../product/product_card.dart';
import '../data/dummy_products.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomepageState();
}

class _HomepageState extends State<HomePage> {
  int _currentBannerIndex = 0;
  int _selectedNavIndex = 0;

  final List<String> bannerImages = [
    "assets/banner.png",
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.black,
        elevation: 0,
        title: Text("Lumeo", style: TextStyle(fontSize: 20)),
        actions: [
          Icon(Icons.person_outline),
          SizedBox(width: 16),
        ],
      ),

      body: SingleChildScrollView(
        padding: EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Banner Carousel
            Column(
              children: [
                SizedBox(
                  height: 180,
                  width: double.infinity,
                  child: PageView.builder(
                    onPageChanged: (index) {
                      setState(() {
                        _currentBannerIndex = index;
                      });
                    },
                    itemCount: bannerImages.length,
                    itemBuilder: (context, index) {
                      return ClipRRect(
                        borderRadius: BorderRadius.circular(12),
                        child: Image.asset(
                          bannerImages[index],
                          fit: BoxFit.cover,
                        ),
                      );
                    },
                  ),
                ),
                const SizedBox(height: 8),
                // Dot indicators
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: List.generate(
                    bannerImages.length,
                    (index) => Container(
                      margin: const EdgeInsets.symmetric(horizontal: 4),
                      width: _currentBannerIndex == index ? 8 : 6,
                      height: 6,
                      decoration: BoxDecoration(
                        color: _currentBannerIndex == index
                            ? Colors.white
                            : Colors.grey,
                        borderRadius: BorderRadius.circular(3),
                      ),
                    ),
                  ),
                ),
              ],
            ),
            SizedBox(height: 20),
            Container(
              padding: EdgeInsets.symmetric(horizontal: 12),
              decoration: BoxDecoration(
                color: Colors.grey[900],
                borderRadius: BorderRadius.circular(12),
              ),
              child: Row(
                children: [
                  Icon(Icons.search, color: Colors.white54),
                  SizedBox(width: 8),
                  Expanded(
                    child: TextField(
                      style: TextStyle(color: Colors.white),
                      decoration: InputDecoration(
                        hintText: "Search products",
                        hintStyle: TextStyle(color: Colors.white),
                        border: InputBorder.none,
                      ),
                    ),
                  )
                ],
              ),
            ),
            SizedBox(height: 25),
            Text("Sale",
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            SizedBox(height: 12),
            SizedBox(
              height: 180,
              child: ListView.builder(
                scrollDirection: Axis.horizontal,
                itemCount: dummyProducts.length,
                itemBuilder: (context, index) {
                  return ProductCard(product: dummyProducts[index]);
                },
              ),
            ),
            SizedBox(height: 25),
            Text("New Arrivals",
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            SizedBox(height: 12),
            SizedBox(
              height: 180,
              child: ListView.builder(
                scrollDirection: Axis.horizontal,
                itemCount: dummyProducts.length,
                itemBuilder: (context, index) {
                  return ProductCard(product: dummyProducts[index]);
                },
              ),
            ),
            SizedBox(height: 20),
          ],
        ),
      ),

      // Bottom navbar
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _selectedNavIndex,
        onTap: (index) {
          setState(() {
            _selectedNavIndex = index;
          });
        },
        backgroundColor: Colors.black,
        selectedItemColor: Colors.white,
        unselectedItemColor: const Color(0xFFE09D3B),
        showSelectedLabels: true,
        showUnselectedLabels: true,
        items: [
          BottomNavigationBarItem(
            icon: Image.asset(
              'assets/icons/menu.png',
              width: 24,
              height: 24,
              color: _selectedNavIndex == 0
                  ? Colors.white
                  : const Color(0xFFE09D3B),
            ),
            label: "Home",
          ),
          BottomNavigationBarItem(
            icon: Image.asset(
              'assets/icons/wishlist.png',
              width: 24,
              height: 24,
              color: _selectedNavIndex == 1
                  ? Colors.white
                  : const Color(0xFFE09D3B),
            ),
            label: "Wish List",
          ),
          BottomNavigationBarItem(
            icon: Image.asset(
              'assets/icons/ar.png',
              width: 24,
              height: 24,
              color: _selectedNavIndex == 2
                  ? Colors.white
                  : const Color(0xFFE09D3B),
            ),
            label: "AR View",
          ),
          BottomNavigationBarItem(
            icon: Image.asset(
              'assets/icons/cart.png',
              width: 24,
              height: 24,
              color: _selectedNavIndex == 3
                  ? Colors.white
                  : const Color(0xFFE09D3B),
            ),
            label: "Cart",
          ),
          BottomNavigationBarItem(
            icon: Image.asset(
              'assets/icons/custom.png',
              width: 24,
              height: 24,
              color: _selectedNavIndex == 4
                  ? Colors.white
                  : const Color(0xFFE09D3B),
            ),
            label: "Custom",
          ),
        ],
      ),
    );
  }
}
