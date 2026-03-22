import 'package:flutter/material.dart';
import '../widgets/app_top_bar.dart';
import '../widgets/bottom_navagiationbar.dart';
import 'home_content.dart';

import 'wishlist_page.dart';
import 'ar_screen.dart';
import 'cart_page.dart';
import 'customFurniture.dart';
import 'emptyspace.dart';
import 'custom_request_review.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  int _selectedNavIndex = 0;

  final List<Widget> pages = const [
    HomeContent(),
    WishListPage(),
    ARSearchPage(),
    CartPage(),
  ];

  late final List<Widget> _pagesWithCustom = [
    ...pages,
    const CustomRequestReviewPage(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: const AppTopBar(),

      body: _pagesWithCustom[_selectedNavIndex],
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
