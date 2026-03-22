import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter/services.dart';
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
  final _formKey = GlobalKey<FormState>();

  late final TextEditingController _fullNameController;
  late final TextEditingController _addressController;
  late final TextEditingController _cityController;
  late final TextEditingController _stateController;
  late final TextEditingController _postalCodeController;
  late final TextEditingController _countryController;
  late final TextEditingController _phoneController;

  String? _validatePersonName(String? value) {
    final input = value?.trim() ?? '';
    if (input.isEmpty) return 'Full name is required';
    if (input.length < 3) return 'Name is too short';
    if (!RegExp(r"^[A-Za-z ]+$").hasMatch(input)) {
      return 'Name can contain letters and spaces only';
    }
    return null;
  }

  String? _validateAddress(String? value) {
    final input = value?.trim() ?? '';
    if (input.isEmpty) return 'Address is required';
    if (input.length < 6) return 'Address looks too short';
    return null;
  }

  String? _validateTextLocation(String label, String? value) {
    final input = value?.trim() ?? '';
    if (input.isEmpty) return '$label is required';
    if (!RegExp(r"^[A-Za-z .'-]+$").hasMatch(input)) {
      return '$label has invalid characters';
    }
    return null;
  }

  String? _validatePostalCode(String? value) {
    final input = value?.trim() ?? '';
    if (input.isEmpty) return 'Postal code is required';
    if (!RegExp(r'^[0-9A-Za-z -]{4,10}$').hasMatch(input)) {
      return 'Enter a valid postal code';
    }
    return null;
  }

  String? _validatePhone(String? value) {
    final input = value?.trim() ?? '';
    if (input.isEmpty) {
      return 'Phone number is required';
    }
    final digits = input.replaceAll(RegExp(r'\D'), '');
    if (digits.length != 10) {
      return 'Phone number must be exactly 10 digits';
    }
    return null;
  }

  @override
  void initState() {
    super.initState();
    _fullNameController = TextEditingController(text: '');
    _addressController = TextEditingController(text: '');
    _cityController = TextEditingController(text: '');
    _stateController = TextEditingController(text: '');
    _postalCodeController = TextEditingController(text: '');
    _countryController = TextEditingController(text: '');
    _phoneController = TextEditingController(text: '');
  }

  @override
  void dispose() {
    _fullNameController.dispose();
    _addressController.dispose();
    _cityController.dispose();
    _stateController.dispose();
    _postalCodeController.dispose();
    _countryController.dispose();
    _phoneController.dispose();
    super.dispose();
  }

  Future<void> _submitOrder() async {
    if (_isSubmitting) return;
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isSubmitting = true);

    final order = await ref.read(orderProvider.notifier).placeOrder(
      shippingAddress: {
        'fullName': _fullNameController.text.trim(),
        'address': _addressController.text.trim(),
        'city': _cityController.text.trim(),
        'state': _stateController.text.trim(),
        'postalCode': _postalCodeController.text.trim(),
        'country': _countryController.text.trim(),
        'phone': _phoneController.text.trim(),
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
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () async {
            await Navigator.maybePop(context);
          },
        ),
        title: const Text("Adding Shipping Address"),
        centerTitle: true,
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
          child: Form(
            key: _formKey,
            autovalidateMode: AutovalidateMode.disabled,
            child: Column(
              children: [
                _buildField(
                  "Full name",
                  _fullNameController,
                  hintText: 'Enter your full name',
                  validator: _validatePersonName,
                ),
                _buildField(
                  "Address",
                  _addressController,
                  hintText: 'House no, street, area',
                  validator: _validateAddress,
                ),
                _buildField(
                  "City",
                  _cityController,
                  hintText: 'Enter city',
                  validator: (value) => _validateTextLocation('City', value),
                ),
                _buildField(
                  "State/Province/Region",
                  _stateController,
                  hintText: 'Enter state or province',
                  validator: (value) =>
                      _validateTextLocation('State/Province/Region', value),
                ),
                _buildField(
                  "Zip Code (Postal Code)",
                  _postalCodeController,
                  hintText: 'e.g. 91709 or 00100',
                  keyboardType: TextInputType.text,
                  validator: _validatePostalCode,
                ),
                _buildField(
                  "Country",
                  _countryController,
                  hintText: 'Enter country',
                  validator: (value) => _validateTextLocation('Country', value),
                ),
                _buildField(
                  "Phone Number",
                  _phoneController,
                  hintText: '10-digit phone number',
                  keyboardType: TextInputType.phone,
                  inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                  validator: _validatePhone,
                ),
                const SizedBox(height: 12),
                SizedBox(
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
                const SizedBox(height: 20),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildField(
    String label,
    TextEditingController controller, {
    required String hintText,
    TextInputType keyboardType = TextInputType.text,
    List<TextInputFormatter>? inputFormatters,
    String? Function(String?)? validator,
  }) {
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
          TextFormField(
            controller: controller,
            keyboardType: keyboardType,
            inputFormatters: inputFormatters,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 16,
              fontWeight: FontWeight.w500,
            ),
            decoration: InputDecoration(
              hintText: hintText,
              hintStyle: const TextStyle(color: Colors.grey),
              filled: true,
              fillColor: const Color(0xFF1F1F1F),
              contentPadding: const EdgeInsets.symmetric(
                horizontal: 14,
                vertical: 14,
              ),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(10),
                borderSide: const BorderSide(color: Color(0xFF2E2E2E)),
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(10),
                borderSide: const BorderSide(color: Color(0xFF2E2E2E)),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(10),
                borderSide: const BorderSide(color: Color(0xFFFBB040)),
              ),
              errorBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(10),
                borderSide: const BorderSide(color: Colors.redAccent),
              ),
              focusedErrorBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(10),
                borderSide: const BorderSide(color: Colors.redAccent),
              ),
            ),
            validator: validator ??
                (value) {
                  if (value == null || value.trim().isEmpty) {
                    return 'This field is required';
                  }
                  return null;
                },
          ),
        ],
      ),
    );
  }
}