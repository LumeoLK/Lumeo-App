import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../pages/seller_dashboard.dart';
import '../pages/seller_listings.dart';
import '../widgets/seller_bottom_navigation_bar.dart';

/// The root shell for the seller experience.
///
/// Owns all navigation state and decides which page is active.
/// Individual pages (e.g. [SellerDashboardPage]) are pure content —
/// they know nothing about the nav bar or routing.
///
/// Add a real page widget to [_pages] as each tab is built out.
/// The [IndexedStack] keeps every visited page alive in the tree,
/// preserving scroll position and loaded data when the user switches tabs.
class SellerShell extends StatefulWidget {
  const SellerShell({super.key});

  @override
  State<SellerShell> createState() => _SellerShellState();
}

class _SellerShellState extends State<SellerShell> {
  int _activeNav = 0;

  /// One entry per tab in [SellerBottomNavigationBar._navItems].
  /// Replace placeholder widgets with real pages as they are built.
  static const List<Widget> _pages = [
    SellerDashboardPage(), // 0 — Overview
    ListingsPage(), // 1 — Listings
    _PlaceholderPage(label: 'Orders'), // 2
    _PlaceholderPage(label: 'BluePrint 3D'), // 3
    _PlaceholderPage(label: 'Custom'), // 4
    _PlaceholderPage(label: 'Profile'), // 5
  ];

  void _onNavTap(int index) {
    setState(() => _activeNav = index);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF1a1a1a),
      // IndexedStack renders all pages but only shows the active one.
      // This preserves state (scroll position, loaded data) across tab switches.
      body: IndexedStack(index: _activeNav, children: _pages),
      bottomNavigationBar: SellerBottomNavigationBar(
        currentIndex: _activeNav,
        onTap: _onNavTap,
      ),
    );
  }
}

/// Temporary stand-in for tabs that haven't been built yet.
/// Remove once the real page is added to [_SellerShellState._pages].
class _PlaceholderPage extends StatelessWidget {
  const _PlaceholderPage({required this.label});

  final String label;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF1a1a1a),
      body: Center(
        child: Text(
          '$label\n(coming soon)',
          textAlign: TextAlign.center,
          style: const TextStyle(
            color: Colors.white38,
            fontSize: 16,
            height: 1.6,
          ),
        ),
      ),
    );
  }
}
