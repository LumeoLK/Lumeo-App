import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../pages/userProfile.dart';
import '../pages/home_page.dart';
import 'login_required_dialog.dart';

class AppTopBar extends StatelessWidget implements PreferredSizeWidget {
  const AppTopBar({super.key});

  static const _backgroundColor = Color(0xFF0F0F0F);
  static const _borderColor = Color(0xFF242424);
  static const _surfaceColor = Color(0xFF171717);
  static const _accentColor = Color(0xFFFBB040);

  @override
  Widget build(BuildContext context) {
    return AppBar(
      backgroundColor: _backgroundColor,
      surfaceTintColor: Colors.transparent,
      elevation: 0,
      scrolledUnderElevation: 0,
      automaticallyImplyLeading: false,
      toolbarHeight: 86,
      titleSpacing: 0,
      shape: const Border(bottom: BorderSide(color: _borderColor, width: 1)),
      title: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20),
        child: SizedBox(
          height: 56,
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Expanded(
                child: Align(
                  alignment: Alignment.centerLeft,
                  child: Material(
                    color: Colors.transparent,
                    child: InkWell(
                      borderRadius: BorderRadius.circular(14),
                      onTap: () {
                        Navigator.pushReplacement(
                          context,
                          MaterialPageRoute(
                            builder: (context) => const HomePage(),
                          ),
                        );
                      },
                      child: Padding(
                        padding: const EdgeInsets.symmetric(vertical: 10),
                        child: Image.asset(
                          'assets/icons/logo.png',
                          height: 34,
                          fit: BoxFit.contain,
                          alignment: Alignment.centerLeft,
                        ),
                      ),
                    ),
                  ),
                ),
              ),
              _ProfileButton(
                onTap: () async {
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
                    MaterialPageRoute(
                      builder: (context) => const Userprofile(),
                    ),
                  );
                },
              ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  Size get preferredSize => const Size.fromHeight(86);
}

class _ProfileButton extends StatelessWidget {
  const _ProfileButton({required this.onTap});

  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        borderRadius: BorderRadius.circular(24),
        onTap: onTap,
        child: Container(
          width: 48,
          height: 48,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            gradient: const LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [Color(0xFF202020), Color(0xFF131313)],
            ),
            border: Border.all(color: AppTopBar._borderColor),
          ),
          child: const Center(
            child: Icon(
              Icons.person_rounded,
              color: AppTopBar._accentColor,
              size: 22, // slightly increased for better balance
            ),
          ),
        ),
      ),
    );
  }
}
