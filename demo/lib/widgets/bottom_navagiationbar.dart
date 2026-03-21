import 'package:flutter/material.dart';

class BottomNav extends StatelessWidget {
  const BottomNav({super.key, required this.currentIndex, required this.onTap});

  final int currentIndex;
  final ValueChanged<int> onTap;

  static const List<_BottomNavItem> _items = [
    _BottomNavItem(label: 'Home', iconPath: 'assets/icons/menu.png'),
    _BottomNavItem(label: 'Wish List', iconPath: 'assets/icons/wishlist.png'),
    _BottomNavItem(label: 'AR View', iconPath: 'assets/icons/ar.png'),
    _BottomNavItem(label: 'Cart', iconPath: 'assets/icons/cart.png'),
    _BottomNavItem(label: 'Custom', iconPath: 'assets/icons/custom.png'),
  ];

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 68,
      decoration: const BoxDecoration(
        color: Color(0xFF111111),
        border: Border(top: BorderSide(color: Color(0xFF2a2a2a))),
      ),
      child: Row(
        children: List.generate(_items.length, (index) {
          final item = _items[index];
          final isActive = index == currentIndex;

          return Expanded(
            child: GestureDetector(
              onTap: () => onTap(index),
              behavior: HitTestBehavior.opaque,
              child: Stack(
                alignment: Alignment.topCenter,
                children: [
                  if (isActive)
                    Container(
                      height: 2.5,
                      width: 22,
                      decoration: const BoxDecoration(
                        color: Color(0xFFFBB040),
                        borderRadius: BorderRadius.vertical(
                          bottom: Radius.circular(3),
                        ),
                      ),
                    ),
                  Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Image.asset(
                        item.iconPath,
                        width: 20,
                        height: 20,
                        color: isActive
                            ? const Color(0xFFFBB040)
                            : const Color(0xFF555555),
                      ),
                      const SizedBox(height: 3),
                      Text(
                        item.label,
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontSize: 8,
                          fontWeight: isActive
                              ? FontWeight.w600
                              : FontWeight.w400,
                          color: isActive
                              ? const Color(0xFFFBB040)
                              : const Color(0xFF555555),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          );
        }),
      ),
    );
  }
}

class _BottomNavItem {
  const _BottomNavItem({required this.label, required this.iconPath});

  final String label;
  final String iconPath;
}
