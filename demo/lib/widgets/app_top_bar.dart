import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../pages/userProfile.dart';
import '../pages/home_page.dart';
import 'login_required_dialog.dart';

class AppTopBar extends StatelessWidget implements PreferredSizeWidget {
  const AppTopBar({super.key});

  @override
  Widget build(BuildContext context) {
    return AppBar(
      backgroundColor: Colors.black,
      elevation: 0,
      title: GestureDetector(
        onTap: () {
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(
              builder: (context) => HomePage(),
            ),
          );
        },
        child: Image.asset(
          'assets/icons/logo.png',
          height: 40,
        ),
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
