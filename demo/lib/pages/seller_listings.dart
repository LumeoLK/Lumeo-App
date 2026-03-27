import 'package:flutter/material.dart';
import '../widgets/add_product_form.dart';
import '../widgets/products_list_tab.dart';
import '../Constants.dart';

class ListingsPage extends StatefulWidget {
  const ListingsPage({super.key});

  @override
  State<ListingsPage> createState() => _ListingsPageState();
}

class _ListingsPageState extends State<ListingsPage> {
  int _tab = 0; // 0 — Add Product, 1 — Products List

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Constants.bgColor,
      appBar: _buildAppBar(),
      body: _tab == 0 ? const AddProductForm() : const ProductsListTab(),
    );
  }

  AppBar _buildAppBar() => AppBar(
    backgroundColor: Constants.bgColor,
    leading: const BackButton(color: Constants.textColor),
    title: const Text(
      'Listings',
      style: TextStyle(
        color: Constants.textColor,
        fontSize: 28,
        fontWeight: FontWeight.bold,
      ),
    ),
    centerTitle: true,
    actions: const [
      Padding(
        padding: EdgeInsets.only(right: 16),
        child: Icon(Icons.notifications_none, color: Constants.textColor),
      ),
    ],
    bottom: PreferredSize(
      preferredSize: const Size.fromHeight(75),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 18),
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
          color: selected ? Constants.kOrange : Colors.transparent,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: selected ? Constants.kOrange : Constants.hintText),
        ),
        child: Text(
          label,
          style: TextStyle(
            color: selected ? Colors.black : Constants.textColor,
            fontWeight: FontWeight.w600,
            fontSize: 13,
          ),
        ),
      ),
    );
  }
}
