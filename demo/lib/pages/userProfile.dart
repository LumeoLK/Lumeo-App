import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../services/auth_service.dart';
import '../widgets/login_required_dialog.dart';
import '../pages/login.dart';
import '../pages/my_orders.dart';


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
      setState(() => _isLoggedIn = true);
      return;
    }
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('x-auth-token') ?? '';
    if (token.isNotEmpty) {
      setState(() => _isLoggedIn = true);
      return;
    }
    setState(() => _isLoggedIn = false);
  }

  void _logout() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('x-auth-token', '');
    await prefs.setString('userId', '');
    ref.read(currentUserProvider.notifier).state = null;

    if (mounted) {
      Navigator.of(context).pushAndRemoveUntil(
        MaterialPageRoute(builder: (context) => Login()),
        (route) => false,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    // If not logged in, show login prompt
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
                onPressed: () {
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
          CircleAvatar(
            backgroundColor: const Color(0xFF2E2E2E),
            backgroundImage: (user?.profilePicture != null && user!.profilePicture.isNotEmpty)
                ? NetworkImage(user.profilePicture)
                : null,
            child: (user?.profilePicture == null || user!.profilePicture.isEmpty)
                ? const Icon(Icons.person, color: Color(0xFF1a1a1a))
                : null,
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
                  backgroundImage: (user?.profilePicture != null && user!.profilePicture.isNotEmpty)
                      ? NetworkImage(user.profilePicture)
                      : null,
                  child: (user?.profilePicture == null || user!.profilePicture.isEmpty)
                      ? const Icon(Icons.person, color: Color(0xFF1a1a1a), size: 40)
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
            _buildMenuTile('My orders', 'View your order history', onTap: () {
             Navigator.push(context, MaterialPageRoute(builder: (context) => MyOrders()));
            }),
            _buildMenuTile('Shipping addresses', 'Manage your addresses', onTap: () {
              // TODO: Navigate to addresses page
            }),
            _buildMenuTile('Payment methods', 'Manage your payment methods', onTap: () {
              // TODO: Navigate to payment methods page
            }),

            const SizedBox(height: 30),

            // Logout Button
            SizedBox(
              width: double.infinity,
              height: 55,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: Color(0xFFFBB040),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(30),
                  ),
                ),
                onPressed: _logout,
                child: const Text(
                  'Sign Out',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }

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
          onTap: onTap,
        ),
        const Divider(color: Colors.white12, height: 1),
      ],
    );
  }
}
