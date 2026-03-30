import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:lumeo_v2/providers/custom_request_provider.dart';
import 'package:lumeo_v2/model/custom_request.dart';
import 'package:lumeo_v2/model/bid.dart';
import 'package:intl/intl.dart';
import 'seller_send_proposal.dart';

const bgColor = Color(0xFF000000);
const cardColor = Color(0xFF1a1a1a);
const kOrange = Color(0xFFfbb040);
const textColor = Colors.white;
const hintText = Color(0xFF888888);

class RequestDetailsPage extends StatefulWidget {
  final CustomRequest request;
  const RequestDetailsPage({super.key, required this.request});
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
      body: RequestDetailsBody(request: widget.request),
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
        title: Column(
          children: [
            const Text('Request Details',
                style: TextStyle(color: textColor, fontSize: 22, fontWeight: FontWeight.bold)),
            Text('Request ID • #${widget.request.id.substring(0, 8).toUpperCase()} • ${DateFormat('MMM d, y').format(widget.request.createdAt)}',
                style: const TextStyle(color: hintText, fontSize: 13)),
          ],
        ),
        centerTitle: true,
        actions: const [
          Padding(padding: EdgeInsets.only(right: 16), child: Icon(Icons.notifications_none, color: textColor)),
        ],
      );
}

class RequestDetailsBody extends ConsumerStatefulWidget {
  final CustomRequest request;
  const RequestDetailsBody({super.key, required this.request});
  @override
  ConsumerState<RequestDetailsBody> createState() => _RequestDetailsBodyState();
}

class _RequestDetailsBodyState extends ConsumerState<RequestDetailsBody> {
  @override
  void initState() {
    super.initState();
    Future.microtask(() =>
      ref.read(customRequestProvider.notifier).fetchBidsForRequest(widget.request.id)
    );
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(customRequestProvider);
    final bids = state.bidsByRequest[widget.request.id] ?? [];
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
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text('Custom Request',
                            style: TextStyle(color: textColor, fontWeight: FontWeight.bold, fontSize: 16)),
                        Text(DateFormat('MMM d, y').format(widget.request.createdAt),
                            style: const TextStyle(color: hintText, fontSize: 12)),
                      ],
                    ),
                    const Spacer(),
                    Text('Status: ${widget.request.status}',
                      style: const TextStyle(color: textColor, fontSize: 13)),
                  ],
                ),
                const SizedBox(height: 14),

                // order title
                Text(widget.request.title,
                  style: const TextStyle(color: kOrange, fontWeight: FontWeight.bold, fontSize: 16)),
                const SizedBox(height: 6),

                // location
                const Text('Location : Colombo',
                    style: TextStyle(color: textColor, fontSize: 13)),
                const SizedBox(height: 10),

                // budget + chat icon row
                Row(
                  children: [
                    Text('Budget: Rs. ${widget.request.budget.toStringAsFixed(0)}',
                      style: const TextStyle(color: kOrange, fontWeight: FontWeight.bold, fontSize: 18)),
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
            child: Text(
              widget.request.description,
              style: const TextStyle(color: textColor, fontSize: 13, height: 1.6),
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
            child: widget.request.referenceImages.isEmpty
                ? const Text('No attachments added.',
                    style: TextStyle(color: hintText, fontSize: 13))
                : Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: widget.request.referenceImages.map((url) =>
                      ClipRRect(
                        borderRadius: BorderRadius.circular(8),
                        child: Image.network(url, width: 80, height: 80, fit: BoxFit.cover),
                      )
                    ).toList(),
                  ),
          ),
          const SizedBox(height: 20),

          // other sellers bids section
          const Text("Other Sellers' Bids",
              style: TextStyle(color: textColor, fontWeight: FontWeight.bold, fontSize: 16)),
          const SizedBox(height: 4),
          const Text("For fairness, bids are anonymized — price & message hidden.",
              style: TextStyle(color: hintText, fontSize: 12)),
          const SizedBox(height: 10),
          if (bids.isEmpty)
            const Text('No bids yet.', style: TextStyle(color: hintText, fontSize: 13))
          else
            ...bids.map((bid) => Column(
              children: [
                _bidRow(DateFormat('MMM d, h:mm a').format(bid.createdAt)),
                const SizedBox(height: 8),
              ],
            )).toList(),
            
          const SizedBox(height: 32),

          // send proposal button
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: () {  //go to the send proposal page
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => SendProposalPage(requestId: widget.request.id)),
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