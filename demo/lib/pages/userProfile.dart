import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:lumeo_v2/pages/seller-registration_info.dart';
import 'package:lumeo_v2/pages/seller_dashboard.dart';
import 'package:lumeo_v2/pages/seller_shell.dart';
import 'package:lumeo_v2/pages/seller_verification_page.dart';
import 'package:lumeo_v2/providers/auth_provider.dart';
import 'package:lumeo_v2/providers/order_provider.dart';
import 'package:lumeo_v2/widgets/secondary_app_bar.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:lumeo_v2/pages/customFurniture.dart';
import 'package:lumeo_v2/pages/login.dart';
import 'package:lumeo_v2/pages/my_orders.dart';
import 'package:lumeo_v2/widgets/login_required_dialog.dart';
import 'settings_page.dart';

import 'seller_onboarding1.dart';

class Userprofile extends ConsumerStatefulWidget {
  const Userprofile({super.key});

  @override
  ConsumerState<Userprofile> createState() => _UserprofileState();
}

class _UserprofileState extends ConsumerState<Userprofile> {
  bool _isLoggedIn = false;
  bool _isVerified = false;
  @override
  void initState() {
    super.initState();
    print('[UserProfile] Initializing UserProfile page');
    Future.microtask(() async {
      print('[UserProfile] Checking login status...');
      await _checkLoginStatus();

      await ref
          .read(authProvider.notifier)
          .checkSellerVerification(); // fetch fresh from API
      await _loadVerifiedStatus(); // read updated prefs

      print('[UserProfile] Fetching orders...');
      if (_isLoggedIn) {
        ref.read(orderProvider.notifier).fetchMyOrders();
      }
    });
  }

  Future<void> _loadVerifiedStatus() async {
    final prefs = await SharedPreferences.getInstance();
    final verified = prefs.getBool('seller_is_verified') ?? false;
    if (mounted) setState(() => _isVerified = verified);
  }

  Future<void> _checkLoginStatus() async {
    print('[UserProfile] Checking login status...');
    final user = ref.read(currentUserProvider);
    if (user != null && user.id.isNotEmpty) {
      print('[UserProfile] User authenticated via provider - ID: ${user.id}');
      if (mounted) setState(() => _isLoggedIn = true);
      return;
    }
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('x-auth-token') ?? '';
    if (token.isNotEmpty) {
      print('[UserProfile] User authenticated via token');
      if (mounted) setState(() => _isLoggedIn = true);
      return;
    }
    print('[UserProfile] User not authenticated');
    if (mounted) setState(() => _isLoggedIn = false);
  }

  void _logout() async {
    print('[UserProfile] Logout initiated');
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('x-auth-token', '');
    await prefs.setString('userId', '');
    print('[UserProfile] Cleared authentication tokens');
    await ref.read(authProvider.notifier).signout();
    print('[UserProfile] Signed out from auth provider');

    if (mounted) {
      print('[UserProfile] Navigating to login screen');
      Navigator.of(context).pushAndRemoveUntil(
        MaterialPageRoute(builder: (context) => const Login()),
        (route) => false,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    if (!_isLoggedIn) {
      print('[UserProfile] User not logged in - showing login prompt');
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
                onPressed: () {
                  print('[UserProfile] Login button tapped');
                  LoginRequiredDialog.show(context);
                },
                child: const Text('Login'),
              ),
            ],
          ),
        ),
      );
    }

    final user = ref.watch(currentUserProvider);
    final orderState = ref.watch(orderProvider);
    final bool isSeller = user?.role == 'seller';

    final bool isPending = isSeller && !_isVerified;
    final bool isVerifiedSeller = isSeller && _isVerified;

    final int orderCount = orderState.orders.length;

    print('[UserProfile] Building profile - Order count: $orderCount');
    print('[UserProfile] Orders loading: ${orderState.isLoading}');
    print('[UserProfile] Total orders fetched: ${orderState.orders.length}');
    if (orderState.error != null) {
      print('[UserProfile] Order fetch error: ${orderState.error}');
    }

    return Scaffold(
      backgroundColor: const Color(0xFF1E1E1E),
      appBar: SecondaryAppTopBar(searchHintText: 'Search profile'),
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
              orderState.isLoading
                  ? 'Loading orders...'
                  : 'Already have $orderCount order${orderCount != 1 ? 's' : ''}',
              onTap: () {
                print('[UserProfile] Navigating to My Orders page');
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => const MyOrders()),
                );
              },
            ),
            _buildMenuTile(
              'Shipping addresses (Not available for MVP)',
              '3 addresses',
              onTap: () {
                print(
                  '[UserProfile] Shipping addresses tapped (Not available for MVP)',
                );
                // Out of scope feature for MVP, but can implement in future iterations
              },
            ),
            _buildMenuTile(
              'Payment methods (Not available for MVP)',
              'COD',
              onTap: () {
                print(
                  '[UserProfile] Payment methods tapped (Not available for MVP)',
                );
                //Out of scope for MVP, but can implement in future iterations
              },
            ),
            _buildMenuTile(
              'Settings',
              'Account and privacy',
              onTap: () {
                print('[UserProfile] Navigating to Settings page');
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => const SettingsPage()),
                );
              },
            ),
            _buildMenuTile(
              'Custom Furniture',
              'Create your own design',
              onTap: () {
                print('[UserProfile] Navigating to Custom Furniture page');
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
                  backgroundColor: isPending
                      ? Colors
                            .grey
                            .shade800 // muted for pending
                      : const Color(0xFFFFB347), // orange for active
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(30),
                  ),
                ),
                onPressed: () {
                  if (isVerifiedSeller) {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => const SellerShell(),
                      ),
                    );
                  } else if (isPending) {
                    // Take them back to the pending screen to see status
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => const SellerVerificationPage(),
                      ),
                    );
                  } else {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => const SellerOnboardingPage(),
                      ),
                    );
                  }
                },
                child: Text(
                  isVerifiedSeller
                      ? 'Go to Seller Dashboard'
                      : isPending
                      ? '⏳ Verification Pending'
                      : 'Become a Seller',
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
