import 'package:flutter/material.dart';

//color constrants
const bgColor = Color(0xFF000000);  //background color
const cardColor = Color(0xFF1a1a1a); //boxes color
const kOrange = Color(0xFFfbb040);
const textColor = Colors.white;
const hintText = Color(0xFF888888); //hint text color

void main() => runApp(const MaterialApp(home: CustomOrdersFeedPage(), debugShowCheckedModeBanner: false));

//sample data model
class OrderRequest {
  final String name;
  final String timeAgo;
  final String title;
  final String description;
  final String budget;
  final String deadline;

  const OrderRequest({
    required this.name,
    required this.timeAgo,
    required this.title,
    required this.description,
    required this.budget,
    required this.deadline,
  });
}

// sample orders list
final List<OrderRequest> sampleOrders = [
  const OrderRequest(
    name: 'Namal P.',
    timeAgo: 'Posted 2 hrs ago',
    title: 'Need Custom Wooden Bed Frame',
    description: 'Looking for a minimal king-size wooden bed ...',
    budget: 'Rs. 85,000',
    deadline: '12 days',
  ),
  const OrderRequest(
    name: 'Namal P.',
    timeAgo: 'Posted 2 hrs ago',
    title: 'Need Custom Wooden Bed Frame',
    description: 'Looking for a minimal king-size wooden bed ...',
    budget: 'Rs. 85,000',
    deadline: '12 days',
  ),
  const OrderRequest(
    name: 'Namal P.',
    timeAgo: 'Posted 4 hrs ago',
    title: 'Need Custom Wooden Bed Frame',
    description: 'Looking for a minimal king-size wooden bed ...',
    budget: 'Rs. 85,000',
    deadline: '12 days',
  ),
];

// MAIN PAGE

class CustomOrdersFeedPage extends StatefulWidget {
  const CustomOrdersFeedPage({super.key});
  @override
  State<CustomOrdersFeedPage> createState() => _CustomOrdersFeedPageState();
}

class _CustomOrdersFeedPageState extends State<CustomOrdersFeedPage> {
  int _tab = 0;        // 0-Orders Feed, 1-My Proposals
  int _navIndex = 4;   // custom tab selected

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
      body: _tab == 0
          ? const OrdersFeedBody()
          : const Center(child: Text('My Proposals', style: TextStyle(color: textColor))),
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

  //app bar
  AppBar _buildAppBar() => AppBar(
        backgroundColor: bgColor,
        leading: const BackButton(color: textColor),
        title: const Column(
          children: [
            Text('Custom Orders Feed', style: TextStyle(color: textColor, fontSize: 26, fontWeight: FontWeight.bold)),
            Text('Explore buyer requests and send proposals.', style: TextStyle(color: hintText, fontSize: 14)),
          ],
        ),
        centerTitle: true,
        actions: const [
          Padding(padding: EdgeInsets.only(right: 16), child: Icon(Icons.notifications_none, color: textColor)),
        ],
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(75),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 18),
            child: Row(
              children: [
                _tabBtn('Orders Feed', 0),
                const SizedBox(width: 8),
                _tabBtn('My Proposals', 1),
              ],
            ),
          ),
        ),
      );

  // tab button
  Widget _tabBtn(String label, int index) {
    final selected = _tab == index;
    return GestureDetector(
      onTap: () => setState(() => _tab = index),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 8),
        decoration: BoxDecoration(
          color: selected ? kOrange : Colors.transparent,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: selected ? kOrange : hintText),
        ),
        child: Text(
          label,
          style: TextStyle(
            color: selected ? Colors.black : textColor,
            fontWeight: FontWeight.w600,
            fontSize: 13,
          ),
        ),
      ),
    );
  }
}

//ORDERS FEED body
class OrdersFeedBody extends StatelessWidget {
  const OrdersFeedBody({super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        // search/filter bar
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          child: Column(
            children: [
              // search field
              TextField(
                style: const TextStyle(color: textColor),
                decoration: InputDecoration(
                  hintText: 'Search',
                  hintStyle: const TextStyle(color: hintText),
                  prefixIcon: const Icon(Icons.search, color: hintText),
                  filled: true,
                  fillColor: cardColor,
                  contentPadding: const EdgeInsets.symmetric(vertical: 12),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10),
                    borderSide: BorderSide.none,
                  ),
                ),
              ),
              const SizedBox(height: 10),

              // filters row
              Row(
                children: [
                  // filters button
                  Row(children: const [
                    Icon(Icons.filter_list, color: textColor, size: 16),
                    SizedBox(width: 4),
                    Text('Filters', style: TextStyle(color: textColor, fontSize: 13)),
                  ]),
                  const SizedBox(width: 16),

                  // price sort
                  Row(children: const [
                    Icon(Icons.swap_vert, color: textColor, size: 16),
                    SizedBox(width: 4),
                    Text('Price: lowest to high', style: TextStyle(color: textColor, fontSize: 13)),
                  ]),

                  const Spacer(),

                  // grid view
                  const Icon(Icons.grid_view, color: textColor, size: 20),
                ],
              ),
            ],
          ),
        ),

        //orders list
        Expanded(
          child: ListView.builder(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            itemCount: sampleOrders.length,
            itemBuilder: (context, index) => OrderCard(order: sampleOrders[index]),
          ),
        ),
      ],
    );
  }
}

// ORDER CARD
class OrderCard extends StatelessWidget {
  final OrderRequest order;
  const OrderCard({super.key, required this.order});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: cardColor,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [

          // user info row
          Row(
            children: [
              // avatar circle
              Container(
                width: 36,
                height: 36,
                decoration: BoxDecoration(
                  color: hintText.withOpacity(0.3),
                  shape: BoxShape.circle,
                ),
                child: const Icon(Icons.person, color:hintText, size: 20),
              ),
              const SizedBox(width: 10),

              // name and time
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(order.name,
                      style: const TextStyle(color: textColor, fontWeight: FontWeight.bold, fontSize: 14)),
                  Text(order.timeAgo,
                      style: const TextStyle(color: hintText, fontSize: 11)),
                ],
              ),

              const Spacer(),

              // chat icon
              Container(
                padding: const EdgeInsets.all(6),
                decoration: BoxDecoration(
                  color: kOrange.withOpacity(0.15),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Icon(Icons.chat_bubble_outline, color: kOrange, size: 18),
              ),
            ],
          ),
          const SizedBox(height: 12),

          //order title
          Text(order.title,
              style: const TextStyle(color: kOrange, fontWeight: FontWeight.bold, fontSize: 15)),
          const SizedBox(height: 6),

          //description
          Text(order.description,
              style: const TextStyle(color: hintText, fontSize: 13)),
          const SizedBox(height: 12),

          //budget and deadline
          Row(
            children: [
              Text('Budget: ${order.budget}',
                  style: const TextStyle(color: textColor, fontWeight: FontWeight.w600, fontSize: 13)),
              const SizedBox(width: 16),
              Text('Deadline: ${order.deadline}',
                  style: const TextStyle(color: textColor, fontSize: 13)),
            ],
          ),
          const SizedBox(height: 14),

          //view request details button
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: () {},
              style: ElevatedButton.styleFrom(
                backgroundColor: kOrange,
                padding: const EdgeInsets.symmetric(vertical: 12),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
              ),
              child: const Text(
                'View Request Details',
                style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold, fontSize: 14),
              ),
            ),
          ),
        ],
      ),
    );
  }
}