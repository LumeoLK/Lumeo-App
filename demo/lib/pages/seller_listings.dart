import 'dart:io';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';
import 'package:flutter/widget_previews.dart';
import '../services/listing_service.dart';
import '../services/product_service.dart';
import '../model/product.dart';
import '../pages/productpage.dart';

// ── Color constants ───────────────────────────────────────
const bgColor = Color(0xFF000000);
const cardColor = Color(0xFF1a1a1a);
const kOrange = Color(0xFFfbb040);
const textColor = Colors.white;
const hintText = Color(0xFF888888);

// ── Category options ──────────────────────────────────────
const List<String> kCategories = [
  'Sofa',
  'Chair',
  'Table',
  'Bed',
  'Wardrobe',
  'Shelf',
  'Desk',
  'Cabinet',
  'Lighting',
  'Decor',
  'Other',
];

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
      backgroundColor: bgColor,
      appBar: _buildAppBar(),
      body: _tab == 0 ? const AddProductForm() : const ProductsListTab(),
    );
  }

  AppBar _buildAppBar() => AppBar(
    backgroundColor: bgColor,
    leading: const BackButton(color: textColor),
    title: const Text(
      'Listings',
      style: TextStyle(
        color: textColor,
        fontSize: 28,
        fontWeight: FontWeight.bold,
      ),
    ),
    centerTitle: true,
    actions: const [
      Padding(
        padding: EdgeInsets.only(right: 16),
        child: Icon(Icons.notifications_none, color: textColor),
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

  @Preview()
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

// ─────────────────────────────────────────────────────────
//  ADD PRODUCT FORM
// ─────────────────────────────────────────────────────────
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
                color: textColor,
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
                        color: cardColor,
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
                                  color: hintText,
                                  size: 32,
                                ),
                                SizedBox(height: 6),
                                Text(
                                  'Images',
                                  style: TextStyle(
                                    color: hintText,
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
                    color: kOrange,
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
                color: kOrange,
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
                    backgroundColor: kOrange,
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
                      color: kOrange,
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
                  backgroundColor: kOrange,
                  disabledBackgroundColor: kOrange.withOpacity(0.5),
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
    style: const TextStyle(color: textColor),
    validator: validator,
    decoration: InputDecoration(
      hintText: hint,
      hintStyle: const TextStyle(color: hintText, fontSize: 13),
      filled: true,
      fillColor: cardColor,
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
    initialValue: _selectedCategory,
    dropdownColor: cardColor,
    style: const TextStyle(color: textColor, fontSize: 14),
    hint: const Text(
      'Select category',
      style: TextStyle(color: hintText, fontSize: 13),
    ),
    icon: const Icon(Icons.keyboard_arrow_down, color: hintText),
    decoration: InputDecoration(
      filled: true,
      fillColor: cardColor,
      contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 16),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(8),
        borderSide: BorderSide.none,
      ),
    ),
    items: kCategories
        .map((cat) => DropdownMenuItem(value: cat, child: Text(cat)))
        .toList(),
    onChanged: (val) => setState(() => _selectedCategory = val),
  );
}

// ─────────────────────────────────────────────────────────
//  PRODUCTS LIST TAB
// ─────────────────────────────────────────────────────────
class ProductsListTab extends StatefulWidget {
  const ProductsListTab({super.key});

  @override
  State<ProductsListTab> createState() => _ProductsListTabState();
}

class _ProductsListTabState extends State<ProductsListTab> {
  final ProductService _productService = ProductService();

  List<Product> _products = [];
  bool _isLoading = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    _loadProducts();
  }

  Future<void> _loadProducts() async {
    setState(() {
      _isLoading = true;
      _error = null;
    });

    try {
      final products = await _productService.getAllProducts();
      if (!mounted) return;
      setState(() {
        _products = products;
        _isLoading = false;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _error = e.toString().replaceFirst('Exception: ', '');
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Center(child: CircularProgressIndicator(color: kOrange));
    }

    if (_error != null) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(
                Icons.error_outline,
                color: Colors.redAccent,
                size: 44,
              ),
              const SizedBox(height: 14),
              Text(
                _error!,
                style: const TextStyle(color: Colors.white70, fontSize: 13),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 20),
              ElevatedButton(
                onPressed: _loadProducts,
                style: ElevatedButton.styleFrom(backgroundColor: kOrange),
                child: const Text(
                  'Retry',
                  style: TextStyle(
                    color: Colors.black,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          ),
        ),
      );
    }

    if (_products.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.inventory_2_outlined, color: hintText, size: 52),
            const SizedBox(height: 14),
            const Text(
              'No products yet',
              style: TextStyle(
                color: textColor,
                fontSize: 16,
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 6),
            const Text(
              'Switch to Add Product to create your first listing',
              style: TextStyle(color: hintText, fontSize: 12),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      );
    }

    return RefreshIndicator(
      color: kOrange,
      backgroundColor: cardColor,
      onRefresh: _loadProducts,
      child: GridView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: _products.length,
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 2,
          crossAxisSpacing: 12,
          mainAxisSpacing: 12,
          childAspectRatio: 0.72,
        ),
        itemBuilder: (context, index) {
          return _ProductCard(product: _products[index]);
        },
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────
//  PRODUCT CARD
// ─────────────────────────────────────────────────────────
class _ProductCard extends StatelessWidget {
  const _ProductCard({required this.product});

  final Product product;

  @override
  Widget build(BuildContext context) {
    final imageUrl = product.images.isNotEmpty ? product.images.first : '';
    final inStock = (product.stock);

    return GestureDetector(
      onTap: () => Get.to(() => ProductDetailPage(productId: product.id)),
      child: Container(
        decoration: BoxDecoration(
          color: cardColor,
          borderRadius: BorderRadius.circular(12),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // ── Image ─────────────────────────────────
            Expanded(
              child: Stack(
                fit: StackFit.expand,
                children: [
                  ClipRRect(
                    borderRadius: const BorderRadius.vertical(
                      top: Radius.circular(12),
                    ),
                    child: imageUrl.isNotEmpty
                        ? Image.network(
                            imageUrl,
                            fit: BoxFit.cover,
                            errorBuilder: (_, __, ___) => _placeholder(),
                          )
                        : _placeholder(),
                  ),
                  // Stock badge top-right
                  Positioned(
                    top: 8,
                    right: 8,
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 7,
                        vertical: 3,
                      ),
                      decoration: BoxDecoration(
                        color: product.stock > 0
                            ? const Color(0xFF1C3D27)
                            : const Color(0xFF3D1C1C),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Text(
                        product.stock > 0 ? 'In Stock' : 'Out of Stock',
                        style: TextStyle(
                          color: product.stock > 0
                              ? const Color(0xFF4BC87A)
                              : Colors.redAccent,
                          fontSize: 8,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),

            // ── Info ──────────────────────────────────
            Padding(
              padding: const EdgeInsets.all(10),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Category chip
                  if ((product.category ?? '').isNotEmpty)
                    Container(
                      margin: const EdgeInsets.only(bottom: 4),
                      padding: const EdgeInsets.symmetric(
                        horizontal: 6,
                        vertical: 2,
                      ),
                      decoration: BoxDecoration(
                        color: kOrange.withOpacity(0.15),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Text(
                        product.category ?? '',
                        style: const TextStyle(
                          color: kOrange,
                          fontSize: 8,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),

                  // Title
                  Text(
                    product.title,
                    style: const TextStyle(
                      color: textColor,
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                      height: 1.3,
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 5),

                  // Price
                  Text(
                    '₦${product.price.toStringAsFixed(0)}',
                    style: const TextStyle(
                      color: kOrange,
                      fontSize: 13,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 6),

                  // Stats row
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _stat(IconData icon, String value, Color color) {
    return Row(
      children: [
        Icon(icon, size: 11, color: color),
        const SizedBox(width: 2),
        Text(value, style: const TextStyle(fontSize: 10, color: hintText)),
      ],
    );
  }

  Widget _placeholder() {
    return Container(
      color: const Color(0xFF2a2a2a),
      child: const Center(
        child: Icon(Icons.chair_rounded, color: Color(0xFF8A5C2A), size: 40),
      ),
    );
  }
}
