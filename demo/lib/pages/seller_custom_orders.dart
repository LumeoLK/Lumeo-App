import 'package:flutter/material.dart';
import 'seller_request_details.dart';

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
  final int initialTab;
  const CustomOrdersFeedPage({super.key, this.initialTab = 0});

  @override
  State<CustomOrdersFeedPage> createState() => _CustomOrdersFeedPageState();
}

class _CustomOrdersFeedPageState extends State<CustomOrdersFeedPage> {
  late int _tab;        // 0-Orders Feed, 1-My Proposals
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
    void initState() {
      super.initState();
      _tab = widget.initialTab;
    }
    
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: bgColor,
      appBar: _buildAppBar(),
      body: _tab == 0
          ? const OrdersFeedBody()
          : const MyProposalsBody(),
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
class OrdersFeedBody extends StatefulWidget {
  const OrdersFeedBody({super.key});
  @override
  State<OrdersFeedBody> createState() => _OrdersFeedBodyState();
}

class _OrdersFeedBodyState extends State<OrdersFeedBody> {
  String sortBy = 'budget_low_to_high';  // current sort option
  bool isGridView = false; //current grid view is false

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
                  GestureDetector(
                    onTap: _showFilterDialog,
                    child: Row(children: const [
                      Icon(Icons.filter_list, color: textColor, size: 16),
                      SizedBox(width: 4),
                      Text('Filters', style: TextStyle(color: textColor, fontSize: 13)),
                    ]),
                  ),
                  const SizedBox(width: 16),

                  // price sort
                  Row(children: [
                  const Icon(Icons.swap_vert, color: textColor, size: 16),
                  const SizedBox(width: 4),
                  Text(
                    sortBy == 'budget_high_to_low'
                        ? 'Budget: highest to low'
                        : sortBy == 'deadline'
                            ? 'Deadline'
                            : 'Budget: lowest to high',
                    style: const TextStyle(color: textColor, fontSize: 13),
                  ),
                ]),

                  const Spacer(),

                  // grid view
                  GestureDetector(
                    onTap: () => setState(() => isGridView = !isGridView),
                    child: Icon(
                      isGridView ? Icons.view_list : Icons.grid_view,
                      color: textColor,
                      size: 20,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),

        //orders list
        Expanded(
          child: isGridView ? _buildGridView() : ListView.builder(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            itemCount: _getFilteredOrders().length,
            itemBuilder: (context, index) => OrderCard(order: _getFilteredOrders()[index]),
          ),
        ),
      ],
    );
  }

  Widget _buildGridView() {
  return GridView.builder(
    padding: const EdgeInsets.symmetric(horizontal: 16),
    gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
      crossAxisCount: 2,
      crossAxisSpacing: 12,
      mainAxisSpacing: 12,
      childAspectRatio: 0.75,
    ),
    itemCount: _getFilteredOrders().length,
    itemBuilder: (context, index) {
      final order = _getFilteredOrders()[index];
      return Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: cardColor,
          borderRadius: BorderRadius.circular(12),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(order.name,
                style: const TextStyle(color: textColor, fontWeight: FontWeight.bold, fontSize: 13)),
            Text(order.timeAgo,
                style: const TextStyle(color: hintText, fontSize: 10)),
            const SizedBox(height: 8),
            Text(order.title,
                style: const TextStyle(color: kOrange, fontWeight: FontWeight.bold, fontSize: 12),
                maxLines: 2,
                overflow: TextOverflow.ellipsis),
            const SizedBox(height: 6),
            Text(order.description,
                style: const TextStyle(color: hintText, fontSize: 11),
                maxLines: 2,
                overflow: TextOverflow.ellipsis),
            const Spacer(),
            Text('Budget: ${order.budget}',
                style: const TextStyle(color: textColor, fontSize: 11, fontWeight: FontWeight.w600)),
            Text('Deadline: ${order.deadline}',
                style: const TextStyle(color: textColor, fontSize: 11)),
            const SizedBox(height: 8),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (_) => const RequestDetailsPage()),
                  );
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: kOrange,
                  padding: const EdgeInsets.symmetric(vertical: 8),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                ),
                child: const Text('View Details',
                    style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold, fontSize: 11)),
              ),
            ),
          ],
        ),
      );
    },
  );
  }

  List<OrderRequest> _getFilteredOrders() {
  List<OrderRequest> filtered = List.from(sampleOrders);

  if (sortBy == 'budget_low_to_high') {
  filtered.sort((a, b) => a.budget.compareTo(b.budget));
} else if (sortBy == 'budget_high_to_low') {
  filtered.sort((a, b) => b.budget.compareTo(a.budget));
} else if (sortBy == 'deadline') {
  filtered.sort((a, b) => a.deadline.compareTo(b.deadline));
}

  return filtered; 
}

void _showFilterDialog() {
  showDialog(
    context: context,
    builder: (context) {
      return AlertDialog(
        backgroundColor: cardColor,
        title: const Text('Sort & Filter', style: TextStyle(color: textColor)),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              title: const Text('Budget: Low to High', style: TextStyle(color: textColor)),
              leading: Radio<String>(
                value: 'budget_low_to_high',
                groupValue: sortBy,
                activeColor: kOrange,
                onChanged: (value) {
                  setState(() => sortBy = value!);
                  Navigator.pop(context);
                },
              ),
            ),
            ListTile(
              title: const Text('Budget: High to Low', style: TextStyle(color: textColor)),
              leading: Radio<String>(
                value: 'budget_high_to_low',
                groupValue: sortBy,
                activeColor: kOrange,
                onChanged: (value) {
                  setState(() => sortBy = value!);
                  Navigator.pop(context);
                },
              ),
            ),
            ListTile(
              title: const Text('Deadline', style: TextStyle(color: textColor)),
              leading: Radio<String>(
                value: 'deadline',
                groupValue: sortBy,
                activeColor: kOrange,
                onChanged: (value) {
                  setState(() => sortBy = value!);
                  Navigator.pop(context);
                },
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Close', style: TextStyle(color: kOrange)),
          ),
        ],
      );
    },
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
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => const RequestDetailsPage()),
                );
              },
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

// sample proposal model
class ProposalItem {
  final String name;
  final String title;
  final String timeAgo;
  final String price;
  final String status; // 'active' or 'closed'

  const ProposalItem({
    required this.name,
    required this.title,
    required this.timeAgo,
    required this.price,
    required this.status,
  });
}

// sample proposals list
final List<ProposalItem> sampleProposals = [
  const ProposalItem(name: 'Namal P.', title: 'Custom Modern Bed', timeAgo: 'Submitted 1 Hour ago', price: 'LKR 4500', status: 'active'),
  const ProposalItem(name: 'Namal P.', title: 'Custom Modern Bed', timeAgo: 'Submitted 1 Hour ago', price: 'LKR 4500', status: 'active'),
  const ProposalItem(name: 'Namal P.', title: 'Custom Modern Bed', timeAgo: 'Submitted 1 Hour ago', price: 'LKR 4500', status: 'closed'),
];

class MyProposalsBody extends StatefulWidget {
  const MyProposalsBody({super.key});
  @override
  State<MyProposalsBody> createState() => _MyProposalsBodyState();
}

class _MyProposalsBodyState extends State<MyProposalsBody> {
  bool isGridView = false;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          child: Column(
            children: [
              // search field
              TextField(
                style: const TextStyle(color: textColor),
                decoration: InputDecoration(
                  hintText: 'Office Chairs...',
                  hintStyle: const TextStyle(color: hintText),
                  suffixIcon: const Icon(Icons.search, color: hintText),
                  filled: true,
                  fillColor: cardColor,
                  contentPadding: const EdgeInsets.symmetric(vertical: 12, horizontal: 14),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10),
                    borderSide: const BorderSide(color: Colors.blueAccent, width: 1.5),
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10),
                    borderSide: const BorderSide(color: Colors.blueAccent, width: 1.5),
                  ),
                ),
              ),
              const SizedBox(height: 10),

              // filter row
              Row(
                children: [
                  const Row(children: [
                    Icon(Icons.filter_list, color: textColor, size: 16),
                    SizedBox(width: 4),
                    Text('Filters', style: TextStyle(color: textColor, fontSize: 13)),
                  ]),
                  const SizedBox(width: 16),
                  const Row(children: [
                    Icon(Icons.swap_vert, color: textColor, size: 16),
                    SizedBox(width: 4),
                    Text('Price: lowest to high', style: TextStyle(color: textColor, fontSize: 13)),
                  ]),
                  const Spacer(),
                  GestureDetector(
                    onTap: () => setState(() => isGridView = !isGridView),
                    child: Icon(isGridView ? Icons.view_list : Icons.grid_view, color: textColor, size: 20),
                  ),
                ],
              ),
            ],
          ),
        ),

        // proposals list
        Expanded(
          child: ListView.builder(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            itemCount: sampleProposals.length,
            itemBuilder: (context, index) => _ProposalCard(proposal: sampleProposals[index]),
          ),
        ),
      ],
    );
  }
}

// proposal card
class _ProposalCard extends StatelessWidget {
  final ProposalItem proposal;
  const _ProposalCard({required this.proposal});

  @override
  Widget build(BuildContext context) {
    final isClosed = proposal.status == 'closed';
    final contentColor = isClosed ? hintText : textColor;
    final priceColor = isClosed ? hintText : kOrange;

    return Opacity(
      opacity: isClosed ? 0.6 : 1.0,
      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: cardColor,
          borderRadius: BorderRadius.circular(12),
        ),
        child: Row(
          children: [
            // image thumbnail
            Container(
              width: 80,
              height: 80,
              decoration: BoxDecoration(
                color: Colors.black,
                borderRadius: BorderRadius.circular(8),
              ),
            ),
            const SizedBox(width: 12),

            // details
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // status badge row
                  Row(
                    children: [
                      const Spacer(),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 3),
                        decoration: BoxDecoration(
                          color: isClosed ? Colors.grey : Colors.green,
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Text(
                          isClosed ? 'Closed' : 'Active',
                          style: const TextStyle(color: Colors.white, fontSize: 11, fontWeight: FontWeight.bold),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 2),

                  Text(proposal.name, style: TextStyle(color: contentColor, fontSize: 13)),
                  Text(proposal.title,
                      style: TextStyle(color: contentColor, fontWeight: FontWeight.bold, fontSize: 15)),
                  Text(proposal.timeAgo, style: TextStyle(color: isClosed ? hintText : hintText, fontSize: 11)),
                  const SizedBox(height: 6),
                  Text(proposal.price,
                      style: TextStyle(color: priceColor, fontWeight: FontWeight.bold, fontSize: 16)),
                  const SizedBox(height: 6),

                  // icons row
                  Row(
                    children: [
                      const Spacer(),
                      if (!isClosed)
                        Container(
                          padding: const EdgeInsets.all(6),
                          decoration: BoxDecoration(
                            color: kOrange.withOpacity(0.15),
                            shape: BoxShape.circle,
                          ),
                          child: const Icon(Icons.chat_bubble_outline, color: kOrange, size: 16),
                        ),
                      const SizedBox(width: 8),
                      Icon(Icons.remove_red_eye_outlined, color: isClosed ? hintText : hintText, size: 18),
                      const SizedBox(width: 8),
                      Icon(Icons.more_horiz, color: isClosed ? hintText : textColor, size: 18),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}