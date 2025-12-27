import 'package:flutter/material.dart';
import '../widgets/app_top_bar.dart';
import '../widgets/bottom_navagiationbar.dart';
import 'home_content.dart';

import 'wishlist_page.dart';
import 'ar_view_page.dart';
import 'cart_page.dart';
import 'custom_page.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  int _selectedNavIndex = 0;

  final List<Widget> pages = const [
    HomeContent(),
    WishlistPage(),
    ARViewPage(),
    CartPage(),
    CustomPage(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: const AppTopBar(),

      body: pages[_selectedNavIndex],
      bottomNavigationBar: BottomNav(
        currentIndex: _selectedNavIndex,
        onTap: (index) {
          setState(() {
            _selectedNavIndex = index;
          });
        },
      ),
    );
  }
}
