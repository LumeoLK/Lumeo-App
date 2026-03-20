import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../providers/order_provider.dart';
import '../providers/cart_provider.dart';
import 'reserve_success.dart';

class AddressSelectionPage extends ConsumerStatefulWidget {
  const AddressSelectionPage({super.key});

  @override
  ConsumerState<AddressSelectionPage> createState() =>
      _AddressSelectionPageState();
}

class _AddressSelectionPageState extends ConsumerState<AddressSelectionPage> {
  final _formKey = GlobalKey<FormState>();
  final _addressController = TextEditingController();
  final _cityController = TextEditingController();
  final _postalCodeController = TextEditingController();
  final _phoneController = TextEditingController();
  bool _isPlacing = false;

  @override
  void dispose() {
    _addressController.dispose();
    _cityController.dispose();
    _postalCodeController.dispose();
    _phoneController.dispose();
    super.dispose();
  }

  Future<void> _placeOrder() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isPlacing = true);

    final order = await ref.read(orderProvider.notifier).placeOrder(
      shippingAddress: {
        'address': _addressController.text.trim(),
        'city': _cityController.text.trim(),
        'postalCode': _postalCodeController.text.trim(),
        'phone': _phoneController.text.trim(),
      },
    );

    setState(() => _isPlacing = false);

    if (order != null && mounted) {
      // Refresh cart (backend already cleared it)
      ref.read(cartProvider.notifier).fetchCart();

      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (_) => const ReserveSuccessPage()),
      );
    } else {
      final error = ref.read(orderProvider).error;
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(error ?? 'Failed to place order'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF1a1a1a),
      appBar: AppBar(
        backgroundColor: const Color(0xFF1a1a1a),
        elevation: 0,
        title: const Text(
          'Shipping Address',
          style: TextStyle(color: Colors.white),
        ),
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Delivery Details',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 28,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 8),
              const Text(
                'Enter your shipping address to complete the order',
                style: TextStyle(color: Colors.white54, fontSize: 14),
              ),
              const SizedBox(height: 30),

              // Address field
              _buildTextField(
                controller: _addressController,
                label: 'Street Address',
                icon: Icons.home_outlined,
                validator: (v) =>
                    v == null || v.isEmpty ? 'Address is required' : null,
              ),
              const SizedBox(height: 16),

              // City field
              _buildTextField(
                controller: _cityController,
                label: 'City',
                icon: Icons.location_city_outlined,
                validator: (v) =>
                    v == null || v.isEmpty ? 'City is required' : null,
              ),
              const SizedBox(height: 16),

              // Postal Code field
              _buildTextField(
                controller: _postalCodeController,
                label: 'Postal Code',
                icon: Icons.markunread_mailbox_outlined,
                keyboardType: TextInputType.number,
                validator: (v) =>
                    v == null || v.isEmpty ? 'Postal code is required' : null,
              ),
              const SizedBox(height: 16),

              // Phone field
              _buildTextField(
                controller: _phoneController,
                label: 'Phone Number',
                icon: Icons.phone_outlined,
                keyboardType: TextInputType.phone,
                validator: (v) =>
                    v == null || v.isEmpty ? 'Phone number is required' : null,
              ),
              const SizedBox(height: 16),

              // Payment info note
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: const Color(0xFF2a2a2a),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: const Color(0xFF3a3a3a)),
                ),
                child: Row(
                  children: [
                    const Icon(Icons.payments_outlined,
                        color: Color(0xFFFBB040), size: 28),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: const [
                          Text(
                            'Cash on Delivery',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 16,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          SizedBox(height: 4),
                          Text(
                            'Pay when you receive your order',
                            style:
                                TextStyle(color: Colors.white54, fontSize: 13),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 40),

              // Place Order button
              SizedBox(
                width: double.infinity,
                height: 55,
                child: ElevatedButton(
                  onPressed: _isPlacing ? null : _placeOrder,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFFFBB040),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(30),
                    ),
                  ),
                  child: _isPlacing
                      ? const SizedBox(
                          width: 24,
                          height: 24,
                          child: CircularProgressIndicator(
                            color: Colors.black,
                            strokeWidth: 2.5,
                          ),
                        )
                      : const Text(
                          'PLACE ORDER',
                          style: TextStyle(
                            color: Colors.black,
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
    required IconData icon,
    TextInputType? keyboardType,
    String? Function(String?)? validator,
  }) {
    return TextFormField(
      controller: controller,
      keyboardType: keyboardType,
      validator: validator,
      style: const TextStyle(color: Colors.white),
      decoration: InputDecoration(
        labelText: label,
        labelStyle: const TextStyle(color: Colors.white54),
        prefixIcon: Icon(icon, color: Colors.white54),
        filled: true,
        fillColor: const Color(0xFF2a2a2a),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide.none,
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: Color(0xFFFBB040)),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: Colors.red),
        ),
        focusedErrorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: Colors.red),
        ),
      ),
    );
  }
}