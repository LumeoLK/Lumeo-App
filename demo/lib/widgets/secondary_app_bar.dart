import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../pages/userProfile.dart';
import '../widgets/search_bar.dart';
import 'login_required_dialog.dart';

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
          onPressed: () async {
            final prefs = await SharedPreferences.getInstance();
            final token = prefs.getString('x-auth-token') ?? '';
            if (token.isEmpty) {
              if (!context.mounted) return;
              await LoginRequiredDialog.show(context);
              return;
            }

            if (!context.mounted) return;
            Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => const Userprofile()),
            );
          },
        ),
        const SizedBox(width: 16),
      ],
    );
  }

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);
}
