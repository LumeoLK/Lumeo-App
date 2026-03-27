import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import '../services/listing_service.dart';
import '../model/create_product_request.dart';
import '../Constants.dart';

class AddProductForm extends StatefulWidget {
  const AddProductForm({super.key});

  @override
  State<AddProductForm> createState() => _AddProductFormState();
}

class _AddProductFormState extends State<AddProductForm> {
  // ── Form key ──────────────────────────────────────────
  final _formKey = GlobalKey<FormState>();

  // ── Service ───────────────────────────────────────────
  final _listingService = const ListingService();

  // ── Loading state ─────────────────────────────────────
  bool _isLoading = false;

  // ── Controllers ───────────────────────────────────────
  final _titleController = TextEditingController();
  final _descController = TextEditingController();
  final _priceController = TextEditingController();
  final _stockController = TextEditingController();
  final _lengthController = TextEditingController();
  final _widthController = TextEditingController();
  final _heightController = TextEditingController();
  final _variantController = TextEditingController();

  // ── Category ──────────────────────────────────────────
  String? _selectedCategory;

  // ── Images ────────────────────────────────────────────
  final List<File?> _images = [null, null, null];

  @override
  void dispose() {
    _titleController.dispose();
    _descController.dispose();
    _priceController.dispose();
    _stockController.dispose();
    _lengthController.dispose();
    _widthController.dispose();
    _heightController.dispose();
    _variantController.dispose();
    super.dispose();
  }

  // ── Image picking ─────────────────────────────────────
  Future<void> _pickImage(int index) async {
    final picker = ImagePicker();
    final picked = await picker.pickImage(source: ImageSource.gallery);
    if (picked != null) {
      setState(() => _images[index] = File(picked.path));
    }
  }

  Future<void> _pickImageFromCamera() async {
    final picker = ImagePicker();
    final picked = await picker.pickImage(source: ImageSource.camera);
    if (picked != null) {
      setState(() {
        for (int i = 0; i < _images.length; i++) {
          if (_images[i] == null) {
            _images[i] = File(picked.path);
            break;
          }
        }
      });
    }
  }

  // ── Build ─────────────────────────────────────────────
  @override
  Widget build(BuildContext context) {
    return Form(
      key: _formKey,
      child: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Title
            const Text(
              'Add Product — Details',
              style: TextStyle(
                color: Constants.textColor,
                fontSize: 22,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 28),

            // ── Image upload boxes ──────────────────────
            Row(
              children: List.generate(
                3,
                (i) => Expanded(
                  child: GestureDetector(
                    onTap: () => _pickImage(i),
                    child: Container(
                      margin: EdgeInsets.only(right: i < 2 ? 10 : 0),
                      height: 120,
                      decoration: BoxDecoration(
                        color: Constants.cardColor,
                        borderRadius: BorderRadius.circular(10),
                        border: Border.all(color: Colors.white, width: 1.5),
                      ),
                      child: _images[i] != null
                          ? ClipRRect(
                              borderRadius: BorderRadius.circular(10),
                              child: Image.file(_images[i]!, fit: BoxFit.cover),
                            )
                          : const Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(
                                  Icons.image_outlined,
                                  color: Constants.hintText,
                                  size: 32,
                                ),
                                SizedBox(height: 6),
                                Text(
                                  'Images',
                                  style: TextStyle(
                                    color: Constants.hintText,
                                    fontSize: 13,
                                  ),
                                ),
                              ],
                            ),
                    ),
                  ),
                ),
              ),
            ),
            const SizedBox(height: 10),

            // Camera button
            Align(
              alignment: Alignment.centerRight,
              child: GestureDetector(
                onTap: _pickImageFromCamera,
                child: Container(
                  padding: const EdgeInsets.all(10),
                  decoration: const BoxDecoration(
                    color: Constants.kOrange,
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(
                    Icons.camera_alt,
                    color: Colors.black,
                    size: 22,
                  ),
                ),
              ),
            ),
            const SizedBox(height: 28),

            // ── Product name ────────────────────────────
            _field(
              'Product name',
              controller: _titleController,
              validator: (v) => v == null || v.trim().isEmpty
                  ? 'Product name is required'
                  : null,
            ),
            const SizedBox(height: 16),

            // ── Description ─────────────────────────────
            _field(
              'Description',
              controller: _descController,
              maxLines: 4,
              validator: (v) => v == null || v.trim().isEmpty
                  ? 'Description is required'
                  : null,
            ),
            const SizedBox(height: 16),

            // ── Category dropdown ───────────────────────
            _categoryDropdown(),
            const SizedBox(height: 16),

            // ── Price ───────────────────────────────────
            _field(
              'Price (₦)',
              controller: _priceController,
              keyboardType: TextInputType.number,
              validator: (v) {
                if (v == null || v.trim().isEmpty) return 'Price is required';
                if (double.tryParse(v.trim()) == null) {
                  return 'Enter a valid number';
                }
                return null;
              },
            ),
            const SizedBox(height: 32),

            // ── Variants / Options ──────────────────────
            const Text(
              'Variants / Options',
              style: TextStyle(
                color: Constants.kOrange,
                fontWeight: FontWeight.bold,
                fontSize: 20,
              ),
            ),
            const SizedBox(height: 16),

            Row(
              children: [
                Expanded(
                  child: _field(
                    'Add size / color variant',
                    controller: _variantController,
                  ),
                ),
                const SizedBox(width: 12),
                ElevatedButton(
                  onPressed: () {
                    // variant logic comes in Step 3
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Constants.kOrange,
                    padding: const EdgeInsets.symmetric(
                      horizontal: 22,
                      vertical: 16,
                    ),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                  child: const Text(
                    'ADD',
                    style: TextStyle(
                      color: Colors.black,
                      fontWeight: FontWeight.bold,
                      fontSize: 15,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),

            // ── Dimensions ──────────────────────────────
            Row(
              children: [
                Expanded(
                  child: _field(
                    'Length (cm)',
                    controller: _lengthController,
                    keyboardType: TextInputType.number,
                    validator: (v) =>
                        v == null || v.trim().isEmpty ? 'Required' : null,
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: _field(
                    'Width (cm)',
                    controller: _widthController,
                    keyboardType: TextInputType.number,
                    validator: (v) =>
                        v == null || v.trim().isEmpty ? 'Required' : null,
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: _field(
                    'Height (cm)',
                    controller: _heightController,
                    keyboardType: TextInputType.number,
                    validator: (v) =>
                        v == null || v.trim().isEmpty ? 'Required' : null,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),

            // ── Stock ───────────────────────────────────
            Row(
              children: [
                Expanded(
                  child: _field(
                    'Stock quantity',
                    controller: _stockController,
                    keyboardType: TextInputType.number,
                    validator: (v) {
                      if (v == null || v.trim().isEmpty) {
                        return 'Stock is required';
                      }
                      if (int.tryParse(v.trim()) == null) {
                        return 'Enter a whole number';
                      }
                      return null;
                    },
                  ),
                ),
                const SizedBox(width: 10),
                TextButton(
                  onPressed: () {},
                  child: const Text(
                    'Manage stock',
                    style: TextStyle(
                      color: Constants.kOrange,
                      fontWeight: FontWeight.w600,
                      fontSize: 14,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 40),

            // ── Save button ─────────────────────────────
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: _isLoading ? null : _onSave,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Constants.kOrange,
                  disabledBackgroundColor: Constants.kOrange.withOpacity(0.5),
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
                child: _isLoading
                    ? const SizedBox(
                        height: 20,
                        width: 20,
                        child: CircularProgressIndicator(
                          color: Colors.black,
                          strokeWidth: 2.5,
                        ),
                      )
                    : const Text(
                        'Save Product',
                        style: TextStyle(
                          color: Colors.black,
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                        ),
                      ),
              ),
            ),

            const SizedBox(height: 24),
          ],
        ),
      ),
    );
  }

  // ── Save handler ──────────────────────────────────────
  Future<void> _onSave() async {
    // 1. Validate at least one image
    final selectedImages = _images.whereType<File>().toList();
    if (selectedImages.isEmpty) {
      _showError('Please add at least one product image');
      return;
    }

    // 2. Validate category
    if (_selectedCategory == null) {
      _showError('Please select a category');
      return;
    }

    // 3. Validate all text fields
    if (!_formKey.currentState!.validate()) return;

    // 4. Build request object
    final request = CreateProductRequest(
      title: _titleController.text.trim(),
      description: _descController.text.trim(),
      price: double.parse(_priceController.text.trim()),
      category: _selectedCategory!,
      stock: int.parse(_stockController.text.trim()),
      length: double.parse(_lengthController.text.trim()),
      width: double.parse(_widthController.text.trim()),
      height: double.parse(_heightController.text.trim()),
      images: selectedImages,
    );

    // 5. Call service
    setState(() => _isLoading = true);

    try {
      await _listingService.createProduct(request);

      if (!mounted) return;

      // 6. Success — clear form and show confirmation
      _resetForm();
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Product created successfully!'),
          backgroundColor: Color(0xFF4BC87A),
          duration: Duration(seconds: 3),
        ),
      );
    } on ListingException catch (e) {
      if (!mounted) return;
      _showError(e.message);
    } catch (e) {
      if (!mounted) return;
      _showError('Something went wrong. Please try again.');
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  // ── Helpers ───────────────────────────────────────────

  void _showError(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.redAccent,
        duration: const Duration(seconds: 3),
      ),
    );
  }

  void _resetForm() {
    _formKey.currentState?.reset();
    _titleController.clear();
    _descController.clear();
    _priceController.clear();
    _stockController.clear();
    _lengthController.clear();
    _widthController.clear();
    _heightController.clear();
    _variantController.clear();
    setState(() {
      _selectedCategory = null;
      _images[0] = null;
      _images[1] = null;
      _images[2] = null;
    });
  }

  // ── Reusable text field ───────────────────────────────
  Widget _field(
    String hint, {
    TextEditingController? controller,
    TextInputType keyboardType = TextInputType.text,
    int maxLines = 1,
    String? Function(String?)? validator,
  }) => TextFormField(
    controller: controller,
    keyboardType: keyboardType,
    maxLines: maxLines,
    style: const TextStyle(color: Constants.textColor),
    validator: validator,
    decoration: InputDecoration(
      hintText: hint,
      hintStyle: const TextStyle(color: Constants.hintText, fontSize: 13),
      filled: true,
      fillColor: Constants.cardColor,
      contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 16),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(8),
        borderSide: BorderSide.none,
      ),
      errorStyle: const TextStyle(color: Colors.redAccent, fontSize: 11),
      errorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(8),
        borderSide: const BorderSide(color: Colors.redAccent),
      ),
      focusedErrorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(8),
        borderSide: const BorderSide(color: Colors.redAccent),
      ),
    ),
  );

  // ── Category dropdown ─────────────────────────────────
  Widget _categoryDropdown() => DropdownButtonFormField<String>(
    value: _selectedCategory,
    dropdownColor: Constants.cardColor,
    style: const TextStyle(color: Constants.textColor, fontSize: 14),
    hint: const Text(
      'Select category',
      style: TextStyle(color: Constants.hintText, fontSize: 13),
    ),
    icon: const Icon(Icons.keyboard_arrow_down, color: Constants.hintText),
    decoration: InputDecoration(
      filled: true,
      fillColor: Constants.cardColor,
      contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 16),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(8),
        borderSide: BorderSide.none,
      ),
    ),
    items: Constants.kCategories
        .map((cat) => DropdownMenuItem(value: cat, child: Text(cat)))
        .toList(),
    onChanged: (val) => setState(() => _selectedCategory = val),
  );
}
