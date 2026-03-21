import 'package:flutter/material.dart';

class ShippingAddressesPage extends StatefulWidget {
  const ShippingAddressesPage({super.key});

  @override
  State<ShippingAddressesPage> createState() =>
      _ShippingAddressesPageState();
}

class _ShippingAddressesPageState extends State<ShippingAddressesPage> {
  int selectedIndex = 0;

  final List<Map<String, String>> addresses = [
    {
      "name": "Jane Doe",
      "address": "3 Newbridge Court",
      "city": "Chino Hills, CA 91709, United States",
    },
    {
      "name": "John Doe",
      "address": "3 Newbridge Court",
      "city": "Chino Hills, CA 91709, United States",
    },
    {
      "name": "John Doe",
      "address": "51 Riverside",
      "city": "Chino Hills, CA 91709, United States",
    },
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF121212),

      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: const Icon(Icons.arrow_back),
        centerTitle: true,
        title: const Text(
          "Shipping Addresses",
          style: TextStyle(fontWeight: FontWeight.w600),
        ),
      ),

      body: ListView.builder(
        padding: const EdgeInsets.all(20),
        itemCount: addresses.length,
        itemBuilder: (context, index) {
          final item = addresses[index];
          return _buildAddressCard(item, index);
        },
      ),

      floatingActionButton: FloatingActionButton(
        backgroundColor: Colors.white,
        onPressed: () {
          // Navigate to Add Address Page
        },
        child: const Icon(Icons.add, color: Colors.black),
      ),
    );
  }

  Widget _buildAddressCard(Map<String, String> data, int index) {
    final isSelected = selectedIndex == index;

    return Container(
      margin: const EdgeInsets.only(bottom: 24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          /// Name + Edit
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                data["name"]!,
                style: const TextStyle(
                  color: Colors.white70,
                  fontSize: 16,
                ),
              ),
              GestureDetector(
                onTap: () {
                  // TODO: Navigate to edit page
                },
                child: const Text(
                  "Edit",
                  style: TextStyle(
                    color: Color(0xFFFBB040),
                    fontSize: 16,
                  ),
                ),
              ),
            ],
          ),

          const SizedBox(height: 8),

          /// Address
          Text(
            data["address"]!,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 20,
              fontWeight: FontWeight.bold,
            ),
          ),

          const SizedBox(height: 4),

          Text(
            data["city"]!,
            style: const TextStyle(
              color: Colors.white70,
              fontSize: 16,
            ),
          ),

          const SizedBox(height: 12),

          /// Checkbox Row
          Row(
            children: [
              GestureDetector(
                onTap: () {
                  setState(() {
                    selectedIndex = index;
                  });
                },
                child: Container(
                  width: 28,
                  height: 28,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(6),
                    border: Border.all(
                      color: isSelected ? Colors.white : Colors.grey,
                      width: 2,
                    ),
                    color: isSelected ? Colors.white : Colors.transparent,
                  ),
                  child: isSelected
                      ? const Icon(Icons.check,
                          size: 20, color: Colors.black)
                      : null,
                ),
              ),
              const SizedBox(width: 12),
              const Text(
                "Use as the shipping address",
                style: TextStyle(
                  color: Colors.white70,
                  fontSize: 16,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}