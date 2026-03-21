import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:lumeo_v2/pages/seller-registration_info.dart';
import 'package:lumeo_v2/pages/seller_dashboard.dart';
import 'package:lumeo_v2/providers/auth_provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:lumeo_v2/pages/customFurniture.dart';
import 'package:lumeo_v2/pages/login.dart';
import 'package:lumeo_v2/pages/my_orders.dart';
import 'package:lumeo_v2/widgets/login_required_dialog.dart';
import 'seller_onboarding1.dart';
class Userprofile extends ConsumerStatefulWidget {
  const Userprofile({super.key});

  @override
  ConsumerState<Userprofile> createState() => _UserprofileState();
}

class _UserprofileState extends ConsumerState<Userprofile> {
  bool _isLoggedIn = false;

  @override
  void initState() {
    super.initState();
    Future.microtask(() async {
      await _checkLoginStatus();
    });
  }

  Future<void> _checkLoginStatus() async {
    final user = ref.read(currentUserProvider);
    if (user != null && user.id.isNotEmpty) {
      if (mounted) setState(() => _isLoggedIn = true);
      return;
    }
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('x-auth-token') ?? '';
    if (token.isNotEmpty) {
      if (mounted) setState(() => _isLoggedIn = true);
      return;
    }
    if (mounted) setState(() => _isLoggedIn = false);
  }

  void _logout() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('x-auth-token', '');
    await prefs.setString('userId', '');
    await ref.read(authProvider.notifier).signout();

    if (mounted) {
      Navigator.of(context).pushAndRemoveUntil(
        MaterialPageRoute(builder: (context) => const Login()),
        (route) => false,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    if (!_isLoggedIn) {
      return Scaffold(
        backgroundColor: const Color(0xFF1E1E1E),
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.person_outline, color: Colors.grey, size: 64),
              const SizedBox(height: 16),
              const Text(
                'Login to view your Profile',
                style: TextStyle(color: Colors.grey, fontSize: 18),
              ),
              const SizedBox(height: 16),
              ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFFFBB040),
                  foregroundColor: Colors.black,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(20),
                  ),
                ),
                onPressed: () => LoginRequiredDialog.show(context),
                child: const Text('Login'),
              ),
            ],
          ),
        ),
      );
    }

    final user = ref.watch(currentUserProvider);
    final bool isSeller = user?.role == 'seller';

    return Scaffold(
      backgroundColor: const Color(0xFF1E1E1E),
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        actions: [
          IconButton(
            onPressed: () {},
            icon: const Icon(Icons.search, color: Colors.white),
          ),
          const CircleAvatar(
            backgroundColor: Color(0xFF2E2E2E),
            child: Icon(Icons.person, color: Colors.orange),
          ),
          const SizedBox(width: 16),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'My profile',
              style: TextStyle(
                color: Colors.white,
                fontSize: 32,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 20),
            Row(
              children: [
                CircleAvatar(
                  radius: 40,
                  backgroundColor: const Color(0xFF2E2E2E),
                  backgroundImage:
                      (user?.profilePicture != null &&
                          user!.profilePicture.isNotEmpty)
                      ? NetworkImage(user.profilePicture)
                      : null,
                  child:
                      (user?.profilePicture == null ||
                          user!.profilePicture.isEmpty)
                      ? const Icon(
                          Icons.person,
                          color: Color(0xFF1a1a1a),
                          size: 40,
                        )
                      : null,
                ),
                const SizedBox(width: 16),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      user?.name ?? 'User',
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    Text(
                      user?.email ?? '',
                      style: const TextStyle(color: Colors.grey),
                    ),
                  ],
                ),
              ],
            ),
            const SizedBox(height: 30),

            _buildMenuTile(
              'My orders',
              'Already have 12 orders',
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => const MyOrders()),
                );
              },
            ),
            _buildMenuTile(
              'Shipping addresses',
              '3 addresses',
              onTap: () {
                // TODO: Implement Shipping addresses page
              },
            ),
            _buildMenuTile(
              'Payment methods',
              'Visa **34',
              onTap: () {
                // TODO: Implement Payment methods page
              },
            ),
            _buildMenuTile(
              'Settings',
              'Account and privacy',
              onTap: () {
                // TODO: Implement Settings page
              },
            ),
            _buildMenuTile(
              'Custom Furniture',
              'Create your own design',
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const CustomFurniturePage(),
                  ),
                );
              },
            ),

            const SizedBox(height: 30),

            // from HEAD: role-aware button — shows dashboard for sellers,
            // registration flow for regular users
            SizedBox(
              width: double.infinity,
              height: 55,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFFFFB347),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(30),
                  ),
                ),
                onPressed: () {
                  if (isSeller) {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => const SellerDashboardPage(),
                      ),
                    );
                  } else {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) =>
                            const SellerOnboardingPage(),
                      ),
                    );
                  }
                },
                child: Text(
                  isSeller ? 'Go to Seller Dashboard' : 'Become a Seller',
                  style: const TextStyle(
                    color: Colors.black,
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),

            const SizedBox(height: 20),

            TextButton(
              onPressed: _logout,
              child: const Center(
                child: Text(
                  'Sign Out',
                  style: TextStyle(color: Colors.red, fontSize: 16),
                ),
              ),
            ),
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }

  // from HEAD: kept as instance method (not static) since it's used
  // inside build() and may need context/ref access in the future
  Widget _buildMenuTile(String title, String subtitle, {VoidCallback? onTap}) {
    return Column(
      children: [
        ListTile(
          contentPadding: EdgeInsets.zero,
          title: Text(
            title,
            style: const TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.bold,
            ),
          ),
          subtitle: Text(
            subtitle,
            style: const TextStyle(color: Colors.grey, fontSize: 12),
          ),
          trailing: const Icon(Icons.chevron_right, color: Colors.grey),
          onTap: onTap, // also fixed: was duplicated in original
        ),
        const Divider(color: Colors.white12, height: 1),
      ],
    );
  }
}
