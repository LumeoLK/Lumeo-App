import 'package:flutter/material.dart';

class SellerBottomNavigationBar extends StatelessWidget {
  const SellerBottomNavigationBar({
    super.key,
    required this.currentIndex,
    required this.onTap,
  });

  final int currentIndex;
  final ValueChanged<int> onTap;

  static const List<_SellerNavItem> _navItems = [
    _SellerNavItem(label: 'Overview', icon: Icons.grid_view_rounded),
    _SellerNavItem(
      label: 'Listings',
      icon: Icons.format_list_bulleted_rounded,
    ),
    _SellerNavItem(label: 'Orders', icon: Icons.shopping_bag_outlined),
    _SellerNavItem(label: 'BluePrint 3D', icon: Icons.view_in_ar_rounded),
    _SellerNavItem(label: 'Custom', icon: Icons.tune_rounded),
    _SellerNavItem(label: 'Profile', icon: Icons.person_outline_rounded),
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
        children: List.generate(_navItems.length, (index) {
          final item = _navItems[index];
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
                      Icon(
                        item.icon,
                        size: 20,
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

class _SellerNavItem {
  const _SellerNavItem({required this.label, required this.icon});

  final String label;
  final IconData icon;
}
