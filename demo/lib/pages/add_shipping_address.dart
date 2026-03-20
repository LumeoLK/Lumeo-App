import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../providers/cart_provider.dart';
import '../providers/order_provider.dart';
import 'reserve_success.dart';

class AddShippingAddressPage extends ConsumerStatefulWidget {
  const AddShippingAddressPage({super.key});

  @override
  ConsumerState<AddShippingAddressPage> createState() =>
      _AddShippingAddressPageState();
}

class _AddShippingAddressPageState
    extends ConsumerState<AddShippingAddressPage> {
  bool _isSubmitting = false;

  Future<void> _submitOrder() async {
    if (_isSubmitting) return;

    setState(() => _isSubmitting = true);

    final order = await ref.read(orderProvider.notifier).placeOrder(
      shippingAddress: {
        'fullName': 'Guest User',
        'address': '3 Newbridge Court',
        'city': 'Chino Hills',
        'state': 'California',
        'postalCode': '91709',
        'country': 'United States',
      },
    );

    if (!mounted) return;

    setState(() => _isSubmitting = false);

    if (order != null) {
      await ref.read(cartProvider.notifier).fetchCart();

      if (!mounted) return;

      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => const ReserveSuccessPage(),
        ),
      );
      return;
    }

    final error = ref.read(orderProvider).error ?? 'Failed to place order';

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(error),
        backgroundColor: Colors.red,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF121212),
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: const Icon(Icons.arrow_back),
        title: const Text(
          "Adding Shipping Address",
          style: TextStyle(fontWeight: FontWeight.w600),
        ),
        centerTitle: true,
      ),
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20),
        child: Column(
          children: [
            const SizedBox(height: 20),

            _buildField("Full name", ""),
            _buildField("Address", "3 Newbridge Court"),
            _buildField("City", "Chino Hills"),
            _buildField("State/Province/Region", "California"),
            _buildField("Zip Code (Postal Code)", "91709"),
            _buildField("Country", "United States", isArrow: true),

            const Spacer(),

            Padding(
              padding: const EdgeInsets.all(16.0),
              child: SizedBox(
                width: double.infinity,
                height: 55,
                child: ElevatedButton(
                  onPressed: _isSubmitting ? null : _submitOrder,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFFFBB040),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(30),
                    ),
                  ),
                  child: _isSubmitting
                      ? const SizedBox(
                          height: 22,
                          width: 22,
                          child: CircularProgressIndicator(
                            strokeWidth: 2.5,
                            valueColor:
                                AlwaysStoppedAnimation<Color>(Colors.black),
                          ),
                        )
                      : const Text(
                          'SAVE ADDRESS',
                          style: TextStyle(
                            color: Colors.black,
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
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

  Widget _buildField(String label, String value, {bool isArrow = false}) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 25),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: const TextStyle(
              color: Colors.grey,
              fontSize: 14,
            ),
          ),
          const SizedBox(height: 8),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                value,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 18,
                  fontWeight: FontWeight.w600,
                ),
              ),
              if (isArrow)
                const Icon(Icons.chevron_right, color: Colors.grey),
            ],
          ),
        ],
      ),
    );
  }
}