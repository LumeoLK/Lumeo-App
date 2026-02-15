// import 'package:flutter/material.dart';

// class Userprofile extends StatefulWidget {
//   const Userprofile({super.key});

//   @override
//   State<Userprofile> createState() => _UserprofileState();
// }

// class _UserprofileState extends State<Userprofile> {
//   @override
//   Widget build(BuildContext context) {
//     return const Placeholder();
//   }
// }

import 'package:flutter/material.dart';

//void main() => runApp(const MaterialApp(home: ProfilePage()));

class Userprofile extends StatefulWidget {
  const Userprofile({super.key});

  // StatefulWidgets create a 'State' object that persists
  @override
  State<Userprofile> createState() => _UserprofileState();
}

class _UserprofileState extends State<Userprofile> {
  // 1. Define the variables that will change (the "State")
  bool isSeller = false;

  void toggleSellerStatus() {
    // 2. Wrap the change in setState() to trigger a UI refresh
    setState(() {
      isSeller = !isSeller;
    });
  }

  @override
  Widget build(BuildContext context) {
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
            const Row(
              children: [
                CircleAvatar(
                  radius: 40,
                  backgroundImage: NetworkImage('https://placeholder.com/150'),
                ),
                SizedBox(width: 16),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Matilda Brown',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    Text(
                      'matildabrown@mail.com',
                      style: TextStyle(color: Colors.grey),
                    ),
                  ],
                ),
              ],
            ),
            const SizedBox(height: 30),
            _buildMenuTile('My orders', 'Already have 12 orders'),
            _buildMenuTile('Shipping addresses', '3 addresses'),
            _buildMenuTile('Payment methods', 'Visa **34'),

            const SizedBox(height: 30),

            // 3. The UI now reacts to the 'isSeller' variable
            SizedBox(
              width: double.infinity,
              height: 55,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: isSeller
                      ? Colors.green
                      : const Color(0xFFFFB347),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(30),
                  ),
                ),
                onPressed: toggleSellerStatus,
                child: Text(
                  isSeller ? 'You are a Seller!' : 'Become a Seller',
                  style: const TextStyle(
                    color: Colors.black,
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMenuTile(String title, String subtitle) {
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
        ),
        const Divider(color: Colors.white12, height: 1),
      ],
    );
  }
}
