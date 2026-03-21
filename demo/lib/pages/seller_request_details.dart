import 'package:flutter/material.dart';
import 'seller_send_proposal.dart';

const bgColor = Color(0xFF000000);
const cardColor = Color(0xFF1a1a1a);
const kOrange = Color(0xFFfbb040);
const textColor = Colors.white;
const hintText = Color(0xFF888888);

void main() => runApp(const MaterialApp(home: RequestDetailsPage(), debugShowCheckedModeBanner: false));

class RequestDetailsPage extends StatefulWidget {
  const RequestDetailsPage({super.key});
  @override
  State<RequestDetailsPage> createState() => _RequestDetailsPageState();
}

class _RequestDetailsPageState extends State<RequestDetailsPage> {
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
      appBar: _buildAppBar(),
      body: const RequestDetailsBody(),
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

  AppBar _buildAppBar() => AppBar(
        backgroundColor: bgColor,
        leading: const BackButton(color: textColor),
        title: const Column(
          children: [
            Text('Request Details',
                style: TextStyle(color: textColor, fontSize: 22, fontWeight: FontWeight.bold)),
            Text('Request ID • #COR-4821 • Posted 2 hrs ago',
                style: TextStyle(color: hintText, fontSize: 13)),
          ],
        ),
        centerTitle: true,
        actions: const [
          Padding(padding: EdgeInsets.only(right: 16), child: Icon(Icons.notifications_none, color: textColor)),
        ],
      );
}

class RequestDetailsBody extends StatelessWidget {
  const RequestDetailsBody({super.key});

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [

          const SizedBox(height: 8),

          // user info card
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: cardColor,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [

                // avatar + name + deadline row
                Row(
                  children: [
                    Container(
                      width: 44,
                      height: 44,
                      decoration: BoxDecoration(
                        color: kOrange.withOpacity(0.2),
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(Icons.person, color: kOrange, size: 24),
                    ),
                    const SizedBox(width: 12),
                    const Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('Namal P.',
                            style: TextStyle(color: textColor, fontWeight: FontWeight.bold, fontSize: 16)),
                        Text('Posted 2 hrs ago',
                            style: TextStyle(color: hintText, fontSize: 12)),
                      ],
                    ),
                    const Spacer(),
                    const Text('Deadline: 12 days',
                        style: TextStyle(color: textColor, fontSize: 13)),
                  ],
                ),
                const SizedBox(height: 14),

                // order title
                const Text('Need Custom Wooden Bed Frame',
                    style: TextStyle(color: kOrange, fontWeight: FontWeight.bold, fontSize: 16)),
                const SizedBox(height: 6),

                // location
                const Text('Location : Colombo',
                    style: TextStyle(color: textColor, fontSize: 13)),
                const SizedBox(height: 10),

                // budget + chat icon row
                Row(
                  children: [
                    const Text('Budget: Rs. 85,000',
                        style: TextStyle(color: kOrange, fontWeight: FontWeight.bold, fontSize: 18)),
                    const Spacer(),
                    Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: kOrange.withOpacity(0.15),
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(Icons.chat_bubble_outline, color: kOrange, size: 20),
                    ),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(height: 20),

          // description section
          const Text('Description',
              style: TextStyle(color: textColor, fontWeight: FontWeight.bold, fontSize: 16)),
          const SizedBox(height: 10),
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: cardColor,
              borderRadius: BorderRadius.circular(10),
            ),
            child: const Text(
              'I need a modern wardrobe with 3 sliding doors, internal lighting, mirror panel on one door. Dimensions: 6ft × 8ft. Prefer matte dark finish and soft-close hinges.',
              style: TextStyle(color: textColor, fontSize: 13, height: 1.6),
            ),
          ),
          const SizedBox(height: 20),

          // materials & dimensions section
          const Text('Materials & Dimensions',
              style: TextStyle(color: textColor, fontWeight: FontWeight.bold, fontSize: 16)),
          const SizedBox(height: 10),
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: cardColor,
              borderRadius: BorderRadius.circular(10),
            ),
            child: const Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _BulletRow(label: 'Preferred:', value: 'Teak / Light maple'),
                SizedBox(height: 8),
                _BulletRow(label: 'Finish:', value: 'matte'),
                SizedBox(height: 8),
                _BulletRow(label: 'Dimensions:', value: '6ft × 8ft'),
                SizedBox(height: 8),
                _BulletRow(label: 'Special:', value: 'internal lighting'),
              ],
            ),
          ),
          const SizedBox(height: 20),

          // attachments section
          const Text('Attachments',
              style: TextStyle(color: hintText, fontWeight: FontWeight.bold, fontSize: 16)),
          const SizedBox(height: 10),
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: cardColor,
              borderRadius: BorderRadius.circular(10),
            ),
            child: const Text('No attachments added.',
                style: TextStyle(color: hintText, fontSize: 13)),
          ),
          const SizedBox(height: 20),

          // other sellers bids section
          const Text("Other Sellers' Bids",
              style: TextStyle(color: textColor, fontWeight: FontWeight.bold, fontSize: 16)),
          const SizedBox(height: 4),
          const Text("For fairness, bids are anonymized — price & message hidden.",
              style: TextStyle(color: hintText, fontSize: 12)),
          const SizedBox(height: 10),
          _bidRow('1h ago'),
          const SizedBox(height: 8),
          _bidRow('3h ago'),
          const SizedBox(height: 32),

          // send proposal button
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: () {  //go to the send proposal page
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => const SendProposalPage()),
                );
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: kOrange,
                padding: const EdgeInsets.symmetric(vertical: 16),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
              ),
              child: const Text('SEND PROPOSAL',
                  style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold, fontSize: 15, letterSpacing: 1)),
            ),
          ),

          const SizedBox(height: 16),
        ],
      ),
    );
  }

  // bid row widget
  Widget _bidRow(String timeAgo) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      decoration: BoxDecoration(
        color: cardColor,
        borderRadius: BorderRadius.circular(10),
      ),
      child: Row(
        children: [
          Container(
            width: 32,
            height: 32,
            decoration: BoxDecoration(
              color: hintText.withOpacity(0.2),
              shape: BoxShape.circle,
            ),
            child: const Icon(Icons.person, color: hintText, size: 18),
          ),
          const SizedBox(width: 12),
          const Text('Bid submitted',
              style: TextStyle(color: textColor, fontSize: 13)),
          const Spacer(),
          Text(timeAgo, style: const TextStyle(color: hintText, fontSize: 12)),
        ],
      ),
    );
  }
}

// reusable bullet point row
class _BulletRow extends StatelessWidget {
  final String label;
  final String value;
  const _BulletRow({required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text('• ', style: TextStyle(color: textColor, fontSize: 13)),
        RichText(
          text: TextSpan(
            children: [
              TextSpan(
                  text: '$label ',
                  style: const TextStyle(color: textColor, fontWeight: FontWeight.bold, fontSize: 13)),
              TextSpan(
                  text: value,
                  style: const TextStyle(color: textColor, fontSize: 13)),
            ],
          ),
        ),
      ],
    );
  }
}