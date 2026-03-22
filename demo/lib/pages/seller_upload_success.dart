import 'package:flutter/material.dart';
import 'seller_custom_orders.dart';

const bgColor = Color(0xFF000000);
const cardColor = Color(0xFF1a1a1a);
const kOrange = Color(0xFFfbb040);
const textColor = Colors.white;
const hintText = Color(0xFF888888);

void main() => runApp(const MaterialApp(home: UploadSuccessPage(), debugShowCheckedModeBanner: false));

class UploadSuccessPage extends StatefulWidget {
  const UploadSuccessPage({super.key});
  @override
  State<UploadSuccessPage> createState() => _UploadSuccessPageState();
}

class _UploadSuccessPageState extends State<UploadSuccessPage> {
  int _navIndex = 4;

  final _navItems = const [
    BottomNavigationBarItem(icon: Icon(Icons.bar_chart), label: 'Overview'),
    BottomNavigationBarItem(icon: Icon(Icons.list_alt), label: 'Listings'),
    BottomNavigationBarItem(icon: Icon(Icons.receipt_long), label: 'Orders'),
    BottomNavigationBarItem(icon: Icon(Icons.view_in_ar), label: 'Blueprint 3D'),
    BottomNavigationBarItem(icon: Icon(Icons.tune), label: 'Custom'),
    BottomNavigationBarItem(icon: Icon(Icons.person), label: 'Profile'),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: bgColor,
      body: SafeArea(
        child: Stack(
          children: [
            // main content
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 32),
              child: Column(
                children: [
                  const Spacer(flex: 2),

                  // badge icon with dots
                  _buildBadge(),
                  const SizedBox(height: 24),

                  // upload successfully text
                  const Text(
                    'Upload Successfully',
                    style: TextStyle(
                      color: textColor,
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 40),

                  // view proposal button
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: () {
                        Navigator.pushAndRemoveUntil(
                          context,
                          MaterialPageRoute(
                            builder: (_) => const CustomOrdersFeedPage(initialTab: 1),
                          ),
                          (route) => false,
                        );
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: kOrange,
                        padding: const EdgeInsets.symmetric(vertical: 15),
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(30)),
                      ),
                      child: const Text(
                        'View Proposal',
                        style: TextStyle(
                            color: Colors.black,
                            fontWeight: FontWeight.bold,
                            fontSize: 15),
                      ),
                    ),
                  ),
                  const SizedBox(height: 12),

                  // remove proposal button 
                  SizedBox(
                    width: double.infinity,
                    child: OutlinedButton(
                      onPressed: () {},
                      style: OutlinedButton.styleFrom(
                        side: const BorderSide(color: Colors.redAccent, width: 1.5),
                        padding: const EdgeInsets.symmetric(vertical: 15),
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(30)),
                      ),
                      child: const Text(
                        'Remove Proposal',
                        style: TextStyle(
                            color: Colors.redAccent,
                            fontWeight: FontWeight.bold,
                            fontSize: 15),
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),

                  // note text
                  const Text(
                    'You can edit your proposal from the "My Proposals" panel. Buyer will be notified.',
                    textAlign: TextAlign.center,
                    style: TextStyle(color: hintText, fontSize: 12, height: 1.5),
                  ),

                  const Spacer(flex: 3),

                  // back to feed button
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: () {
                        // goes all the way back to the feed
                        Navigator.popUntil(context, (route) => route.isFirst);
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: kOrange,
                        padding: const EdgeInsets.symmetric(vertical: 15),
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(30)),
                      ),
                      child: const Text(
                        'BACK TO FEED',
                        style: TextStyle(
                            color: Colors.black,
                            fontWeight: FontWeight.bold,
                            fontSize: 14,
                            letterSpacing: 1),
                      ),
                    ),
                  ),
                  const SizedBox(height: 24),
                ],
              ),
            ),

            // chat icon positioned to the right
            /*Positioned(
              right: 24,
              top: MediaQuery.of(context).size.height * 0.38,
              child: Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: kOrange.withOpacity(0.15),
                  shape: BoxShape.circle,
                ),
                child: const Icon(Icons.chat_bubble_outline,
                    color: kOrange, size: 22),
              ),
            ),*/
          ],
        ),
      ),
      bottomNavigationBar: BottomNavigationBar(
        backgroundColor: cardColor,
        selectedItemColor: kOrange,
        unselectedItemColor: hintText,
        currentIndex: _navIndex,
        onTap: (i) => setState(() => _navIndex = i),
        type: BottomNavigationBarType.fixed,
        selectedFontSize: 10,
        unselectedFontSize: 10,
        items: _navItems,
      ),
    );
  }

  // badge with decorative dots around it
  Widget _buildBadge() {
    return SizedBox(
      width: 140,
      height: 140,
      child: Stack(
        alignment: Alignment.center,
        children: [
          // decorative dots
          Positioned(top: 8, left: 20,
              child: _dot(8)),
          Positioned(top: 4, right: 28,
              child: _dot(6)),
          Positioned(bottom: 10, left: 14,
              child: _dot(6)),
          Positioned(bottom: 6, right: 20,
              child: _dot(9)),
          Positioned(top: 30, right: 8,
              child: _dot(5)),
          Positioned(bottom: 30, left: 6,
              child: _dot(5)),

          // badge circle
          Container(
            width: 90,
            height: 90,
            decoration: const BoxDecoration(
              color: kOrange,
              shape: BoxShape.circle,
            ),
            child: const Icon(Icons.check, color: Colors.white, size: 44),
          ),
        ],
      ),
    );
  }

  // small decorative dot
  Widget _dot(double size) => Container(
        width: size,
        height: size,
        decoration: BoxDecoration(
          color: kOrange.withOpacity(0.5),
          shape: BoxShape.circle,
        ),
      );
}