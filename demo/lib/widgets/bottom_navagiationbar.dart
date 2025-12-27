import 'package:flutter/material.dart';

class BottomNav extends StatelessWidget {
  final int currentIndex;
  final Function(int) onTap;

  const BottomNav({
    super.key,
    required this.currentIndex,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return BottomNavigationBar(
      currentIndex: currentIndex,
      onTap: onTap,
      backgroundColor: Colors.black,
      selectedItemColor: Colors.white,
      unselectedItemColor: const Color(0xFFE09D3B),
      items: [
        _item('assets/icons/menu.png', 'Home', 0),
        _item('assets/icons/wishlist.png', 'Wish List', 1),
        _item('assets/icons/ar.png', 'AR View', 2),
        _item('assets/icons/cart.png', 'Cart', 3),
        _item('assets/icons/custom.png', 'Custom', 4),
      ],
    );
  }

  BottomNavigationBarItem _item(String icon, String label, int index) {
    return BottomNavigationBarItem(
      icon: Image.asset(
        icon,
        width: 24,
        height: 24,
        color: currentIndex == index ? Colors.white : const Color(0xFFE09D3B),
      ),
      label: label,
    );
  }
}
