import 'package:flutter/material.dart';

//color constants
const kBg = Color(0xFF000000);       // background color
const kCard = Color(0xFF1a1a1a);     // boxes color
const kOrange = Color(0xFFE8A020);
const kText = Colors.white;       // input texts color
const kHint = Color(0xFF888888);  //color for hints in the boxes

void main() => runApp(const MaterialApp(home: ListingsPage(), debugShowCheckedModeBanner: false));

class ListingsPage extends StatefulWidget {
  const ListingsPage({super.key});
  @override
  State<ListingsPage> createState() => _ListingsPageState();
}

class _ListingsPageState extends State<ListingsPage> {
  int _tab = 0;       // 0-Add Product, 1-Products List
  int _navIndex = 1;  // listings's index is 1st in navbar

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
      backgroundColor: kBg,
      appBar: _buildAppBar(),
      body: _tab == 0
          ? const AddProductForm()
          : const Center(child: Text('Products List', style: TextStyle(color: kText))),
      bottomNavigationBar: BottomNavigationBar(
        backgroundColor: kCard,
        selectedItemColor: kOrange,
        unselectedItemColor: kHint,
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
        backgroundColor: kBg,
        leading: const BackButton(color: kText),
        title: const Text('Listings', style: TextStyle(color: kText, fontSize: 28, fontWeight: FontWeight.bold)),
        centerTitle: true,
        actions: const [
          Padding(padding: EdgeInsets.only(right: 16), child: Icon(Icons.notifications_none, color: kText)),
        ],
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(52),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: Row(
              children: [
                _tabBtn('Add Product', 0),
                const SizedBox(width: 8),
                _tabBtn('Products List', 1),
              ],
            ),
          ),
        ),
      );

  Widget _tabBtn(String label, int index) {
    final selected = _tab == index;
    return GestureDetector(
      onTap: () => setState(() => _tab = index),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 8),
        decoration: BoxDecoration(
          color: selected ? kOrange : Colors.transparent,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: selected ? kOrange : kHint),
        ),
        child: Text(
          label,
          style: TextStyle(
            color: selected ? Colors.black : kText,
            fontWeight: FontWeight.w600,
            fontSize: 13,
          ),
        ),
      ),
    );
  }
}

// add product form
class AddProductForm extends StatelessWidget {
  const AddProductForm({super.key});

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [

          // title
          const Text(
            'Add Product — Details',
            style: TextStyle(color: kText, fontSize: 22, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 28),

          // image upload boxes
          Row(
            children: List.generate(3, (i) => Expanded(
              child: Container(
                margin: EdgeInsets.only(right: i < 2 ? 10 : 0),
                height: 120,
                decoration: BoxDecoration(color: kCard, borderRadius: BorderRadius.circular(10)),
                child: const Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.image_outlined, color: kHint, size: 32),
                    SizedBox(height: 6),
                    Text('Images', style: TextStyle(color: kHint, fontSize: 13)),
                  ],
                ),
              ),
            )),
          ),
          const SizedBox(height: 10),

          // camera icon
          Align(
            alignment: Alignment.centerRight,
            child: Container(
              padding: const EdgeInsets.all(10),
              decoration: const BoxDecoration(color: kOrange, shape: BoxShape.circle),
              child: const Icon(Icons.camera_alt, color: Colors.black, size: 22),
            ),
          ),
          const SizedBox(height: 28),

          // product name
          _field('Product name'),
          const SizedBox(height: 16),

          // price & discount
          Row(children: [
            Expanded(child: _field('Price (LKR)')),
            const SizedBox(width: 12),
            Expanded(child: _field('Discount (%)')),
          ]),
          const SizedBox(height: 32),

          // variants/options
          const Text(
            'Variants / Options',
            style: TextStyle(color: kOrange, fontWeight: FontWeight.bold, fontSize: 20),
          ),
          const SizedBox(height: 16),

          // variand input/ADD button
          Row(children: [
            Expanded(child: _field('Add size / color variant')),
            const SizedBox(width: 12),
            ElevatedButton(
              onPressed: () {},
              style: ElevatedButton.styleFrom(
                backgroundColor: kOrange,
                padding: const EdgeInsets.symmetric(horizontal: 22, vertical: 16),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
              ),
              child: const Text('ADD', style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold, fontSize: 15)),
            ),
          ]),
          const SizedBox(height: 16),

          // dimensions form
          Row(children: [
            Expanded(child: _field('Length (cm)')),
            const SizedBox(width: 10),
            Expanded(child: _field('Width (cm)')),
            const SizedBox(width: 10),
            Expanded(child: _field('Height (cm)')),
          ]),
          const SizedBox(height: 16),

          // stock
          Row(children: [
            Expanded(child: _field('Stack quantity')),
            const SizedBox(width: 10),
            TextButton(
              onPressed: () {},
              child: const Text(
                'Manage stack',
                style: TextStyle(color: kOrange, fontWeight: FontWeight.w600, fontSize: 14),
              ),
            ),
          ]),
          const SizedBox(height: 40),

          // save button
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: () {},
              style: ElevatedButton.styleFrom(
                backgroundColor: kOrange,
                padding: const EdgeInsets.symmetric(vertical: 16),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
              ),
              child: const Text(
                'Save Product',
                style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold, fontSize: 16),
              ),
            ),
          ),

          const SizedBox(height: 24),
        ],
      ),
    );
  }

  //resuable dark text field for boxes
  Widget _field(String hint) => TextField(
        style: const TextStyle(color: kText),
        decoration: InputDecoration(
          hintText: hint,
          hintStyle: const TextStyle(color: kHint, fontSize: 13),
          filled: true,
          fillColor: kCard,
          contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 16),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(8),
            borderSide: BorderSide.none,
          ),
        ),
      );
}