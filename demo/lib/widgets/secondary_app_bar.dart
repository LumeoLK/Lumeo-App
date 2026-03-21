import 'package:flutter/material.dart';
import '../pages/userProfile.dart';
import '../widgets/search_bar.dart';

class SecondaryAppTopBar extends StatelessWidget implements PreferredSizeWidget {
  final ValueChanged<String>? onSearchChanged;
  final VoidCallback? onSearchTap;
  final String searchHintText;

  const SecondaryAppTopBar({
    super.key,
    this.onSearchChanged,
    this.onSearchTap,
    this.searchHintText = 'Search...',
  });

  @override
  Widget build(BuildContext context) {
    return AppBar(
      backgroundColor: Colors.black,
      elevation: 0,
      title: SearchBarWidget(
        hintText: searchHintText,
        readOnly: onSearchChanged == null && onSearchTap == null,
        onTap: onSearchTap,
        onChanged: onSearchChanged,
      ),

      actions: [
        IconButton(
          icon: const Icon(Icons.person, color: Color(0xFFFBB040)),
          onPressed: () {
            Navigator.push(context, MaterialPageRoute(builder: (context) => Userprofile()));
          },
        ),
        const SizedBox(width: 16),
      ],
    );
  }

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);
}
