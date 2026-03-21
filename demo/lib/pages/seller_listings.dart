import 'dart:io';

import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../services/seller_listings_service.dart';
import '../widgets/seller_bottom_navigation_bar.dart';

const bgColor = Color(0xFF000000);
const cardColor = Color(0xFF1A1A1A);
const kOrange = Color(0xFFFBB040);
const textColor = Colors.white;
const hintText = Color(0xFF888888);

const List<String> _productCategories = [
  'Living Room',
  'Bedroom',
  'Office',
  'Kitchen',
  'Decor',
];

void main() => runApp(
  const MaterialApp(
    home: ListingsPage(),
    debugShowCheckedModeBanner: false,
  ),
);

class ListingsPage extends StatefulWidget {
  const ListingsPage({super.key});

  @override
  State<ListingsPage> createState() => _ListingsPageState();
}

class _ListingsPageState extends State<ListingsPage> {
  final SellerListingsService _service = const SellerListingsService();

  int _tab = 0;
  int _navIndex = 1;
  bool _isLoadingListings = true;
  String? _listingsError;
  List<Map<String, dynamic>> _listings = const [];

  @override
  void initState() {
    super.initState();
    _loadListings();
  }

  Future<void> _loadListings() async {
    setState(() {
      _isLoadingListings = true;
      _listingsError = null;
    });

    try {
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString('x-auth-token')?.trim() ?? '';

      if (token.isEmpty) {
        throw const SellerListingsException(
          'Please log in with a seller account first.',
        );
      }

      final listings = await _service.fetchActiveListings(token);
      if (!mounted) return;

      setState(() {
        _listings = listings;
        _isLoadingListings = false;
      });
    } catch (error) {
      if (!mounted) return;
      setState(() {
        _listingsError = error.toString().replaceFirst('Exception: ', '');
        _isLoadingListings = false;
      });
    }
  }

  Future<void> _handleProductSaved() async {
    setState(() => _tab = 1);
    await _loadListings();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: bgColor,
      appBar: _buildAppBar(),
      body: AnimatedSwitcher(
        duration: const Duration(milliseconds: 200),
        child: _tab == 0
            ? AddProductForm(
                key: const ValueKey('add-product'),
                onProductSaved: _handleProductSaved,
              )
            : SellerProductsList(
                key: const ValueKey('products-list'),
                isLoading: _isLoadingListings,
                error: _listingsError,
                listings: _listings,
                onRefresh: _loadListings,
              ),
      ),
      bottomNavigationBar: SellerBottomNavigationBar(
        currentIndex: _navIndex,
        onTap: (index) => setState(() => _navIndex = index),
      ),
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

class AddProductForm extends StatefulWidget {
  const AddProductForm({super.key, this.onProductSaved});

  final Future<void> Function()? onProductSaved;

  @override
  State<AddProductForm> createState() => _AddProductFormState();
}

class _AddProductFormState extends State<AddProductForm> {
  final SellerListingsService _service = const SellerListingsService();
  final ImagePicker _picker = ImagePicker();
  final TextEditingController _titleController = TextEditingController();
  final TextEditingController _descriptionController = TextEditingController();
  final TextEditingController _priceController = TextEditingController();
  final TextEditingController _stockController = TextEditingController();
  final TextEditingController _lengthController = TextEditingController();
  final TextEditingController _widthController = TextEditingController();
  final TextEditingController _heightController = TextEditingController();
  final List<File?> _images = List<File?>.filled(4, null);

  String _selectedCategory = _productCategories.first;
  bool _isSubmitting = false;

  @override
  void dispose() {
    _titleController.dispose();
    _descriptionController.dispose();
    _priceController.dispose();
    _stockController.dispose();
    _lengthController.dispose();
    _widthController.dispose();
    _heightController.dispose();
    super.dispose();
  }

  Future<void> _pickImage(int index) async {
    final picked = await _picker.pickImage(source: ImageSource.gallery);
    if (picked == null || !mounted) return;

    setState(() => _images[index] = File(picked.path));
  }

  List<File> get _selectedImages => _images.whereType<File>().toList();

  Future<void> _submitProduct() async {
    FocusScope.of(context).unfocus();

    final title = _titleController.text.trim();
    final description = _descriptionController.text.trim();
    final price = _priceController.text.trim();
    final stock = _stockController.text.trim();
    final length = _lengthController.text.trim();
    final width = _widthController.text.trim();
    final height = _heightController.text.trim();

    if (title.isEmpty ||
        description.isEmpty ||
        price.isEmpty ||
        stock.isEmpty ||
        length.isEmpty ||
        width.isEmpty ||
        height.isEmpty ||
        _selectedImages.isEmpty) {
      _showSnackBar(
        'Please fill all required fields and upload at least one image.',
      );
      return;
    }

    final parsedPrice = double.tryParse(price);
    final parsedStock = int.tryParse(stock);
    final parsedLength = double.tryParse(length);
    final parsedWidth = double.tryParse(width);
    final parsedHeight = double.tryParse(height);

    if (parsedPrice == null ||
        parsedStock == null ||
        parsedLength == null ||
        parsedWidth == null ||
        parsedHeight == null) {
      _showSnackBar('Price, stock, and dimensions must be valid numbers.');
      return;
    }

    if (parsedPrice <= 0 ||
        parsedStock < 0 ||
        parsedLength <= 0 ||
        parsedWidth <= 0 ||
        parsedHeight <= 0) {
      _showSnackBar('Use values greater than zero for price and dimensions.');
      return;
    }

    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('x-auth-token')?.trim() ?? '';
    if (token.isEmpty) {
      _showSnackBar('Please log in with a seller account first.');
      return;
    }

    setState(() => _isSubmitting = true);

    try {
      final response = await _service.createProduct(
        token: token,
        title: title,
        description: description,
        category: _selectedCategory,
        price: price,
        stock: stock,
        length: length,
        width: width,
        height: height,
        images: _selectedImages,
      );

      if (!mounted) return;

      _resetForm();
      _showSnackBar(
        response['msg']?.toString() ?? 'Product created successfully.',
        isError: false,
      );
      await widget.onProductSaved?.call();
    } catch (error) {
      if (!mounted) return;
      _showSnackBar(error.toString().replaceFirst('Exception: ', ''));
    } finally {
      if (mounted) {
        setState(() => _isSubmitting = false);
      }
    }
  }

  void _resetForm() {
    _titleController.clear();
    _descriptionController.clear();
    _priceController.clear();
    _stockController.clear();
    _lengthController.clear();
    _widthController.clear();
    _heightController.clear();
    setState(() {
      _selectedCategory = _productCategories.first;
      for (int i = 0; i < _images.length; i++) {
        _images[i] = null;
      }
    });
  }

  void _showSnackBar(String message, {bool isError = true}) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: isError ? Colors.redAccent : Colors.green,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.fromLTRB(16, 10, 16, 24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Add Product Details',
            style: TextStyle(
              color: textColor,
              fontSize: 22,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 8),
          const Text(
            'Create a listing with the fields required by the seller and product APIs.',
            style: TextStyle(color: hintText, fontSize: 13),
          ),
          const SizedBox(height: 28),
          const Text(
            'Images',
            style: TextStyle(
              color: kOrange,
              fontWeight: FontWeight.bold,
              fontSize: 18,
            ),
          ),
          const SizedBox(height: 10),
          GridView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: _images.length,
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2,
              mainAxisSpacing: 10,
              crossAxisSpacing: 10,
              childAspectRatio: 1.35,
            ),
            itemBuilder: (context, index) => GestureDetector(
              onTap: () => _pickImage(index),
              child: Container(
                decoration: BoxDecoration(
                  color: cardColor,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: Colors.white24),
                ),
                child: _images[index] != null
                    ? ClipRRect(
                        borderRadius: BorderRadius.circular(12),
                        child: Stack(
                          fit: StackFit.expand,
                          children: [
                            Image.file(_images[index]!, fit: BoxFit.cover),
                            Positioned(
                              top: 8,
                              right: 8,
                              child: Container(
                                decoration: const BoxDecoration(
                                  color: Colors.black54,
                                  shape: BoxShape.circle,
                                ),
                                child: IconButton(
                                  onPressed: () =>
                                      setState(() => _images[index] = null),
                                  icon: const Icon(
                                    Icons.close,
                                    color: Colors.white,
                                    size: 18,
                                  ),
                                  constraints: const BoxConstraints(),
                                  padding: const EdgeInsets.all(6),
                                  visualDensity: VisualDensity.compact,
                                ),
                              ),
                            ),
                          ],
                        ),
                      )
                    : const Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            Icons.add_photo_alternate_outlined,
                            color: hintText,
                            size: 34,
                          ),
                          SizedBox(height: 8),
                          Text(
                            'Tap to add image',
                            style: TextStyle(color: hintText, fontSize: 12),
                          ),
                        ],
                      ),
              ),
            ),
          ),
          const SizedBox(height: 10),
          const Text(
            'You can upload up to 4 images for a product.',
            style: TextStyle(color: hintText, fontSize: 12),
          ),
          const SizedBox(height: 28),
          _field(
            'Product name',
            controller: _titleController,
            textInputAction: TextInputAction.next,
          ),
          const SizedBox(height: 16),
          _field(
            'Description',
            controller: _descriptionController,
            maxLines: 4,
            textInputAction: TextInputAction.newline,
          ),
          const SizedBox(height: 16),
          _categoryField(),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: _field(
                  'Price (LKR)',
                  controller: _priceController,
                  keyboardType: const TextInputType.numberWithOptions(
                    decimal: true,
                  ),
                  textInputAction: TextInputAction.next,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _field(
                  'Stock quantity',
                  controller: _stockController,
                  keyboardType: TextInputType.number,
                  textInputAction: TextInputAction.next,
                ),
              ),
            ],
          ),
          const SizedBox(height: 28),
          const Text(
            'Dimensions (cm)',
            style: TextStyle(
              color: kOrange,
              fontWeight: FontWeight.bold,
              fontSize: 18,
            ),
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: _field(
                  'Length',
                  controller: _lengthController,
                  keyboardType: const TextInputType.numberWithOptions(
                    decimal: true,
                  ),
                  textInputAction: TextInputAction.next,
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: _field(
                  'Width',
                  controller: _widthController,
                  keyboardType: const TextInputType.numberWithOptions(
                    decimal: true,
                  ),
                  textInputAction: TextInputAction.next,
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: _field(
                  'Height',
                  controller: _heightController,
                  keyboardType: const TextInputType.numberWithOptions(
                    decimal: true,
                  ),
                  textInputAction: TextInputAction.done,
                ),
              ),
            ],
          ),
          const SizedBox(height: 40),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: _isSubmitting ? null : _submitProduct,
              style: ElevatedButton.styleFrom(
                backgroundColor: kOrange,
                disabledBackgroundColor: kOrange.withOpacity(0.5),
                padding: const EdgeInsets.symmetric(vertical: 16),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
              child: _isSubmitting
                  ? const SizedBox(
                      height: 20,
                      width: 20,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        valueColor: AlwaysStoppedAnimation<Color>(Colors.black),
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
        ],
      ),
    );
  }

  Widget _categoryField() {
    return DropdownButtonFormField<String>(
      value: _selectedCategory,
      dropdownColor: cardColor,
      decoration: InputDecoration(
        filled: true,
        fillColor: cardColor,
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 14,
          vertical: 16,
        ),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: BorderSide.none,
        ),
      ),
      style: const TextStyle(color: textColor, fontSize: 14),
      iconEnabledColor: textColor,
      items: _productCategories
          .map(
            (category) => DropdownMenuItem<String>(
              value: category,
              child: Text(category),
            ),
          )
          .toList(),
      onChanged: (value) {
        if (value == null) return;
        setState(() => _selectedCategory = value);
      },
    );
  }

  Widget _field(
    String hint, {
    required TextEditingController controller,
    TextInputType? keyboardType,
    TextInputAction? textInputAction,
    int maxLines = 1,
  }) {
    return TextField(
      controller: controller,
      keyboardType: keyboardType,
      textInputAction: textInputAction,
      maxLines: maxLines,
      style: const TextStyle(color: textColor),
      decoration: InputDecoration(
        hintText: hint,
        hintStyle: const TextStyle(color: hintText, fontSize: 13),
        filled: true,
        fillColor: cardColor,
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 14,
          vertical: 16,
        ),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: BorderSide.none,
        ),
      ),
    );
  }
}

class SellerProductsList extends StatelessWidget {
  const SellerProductsList({
    super.key,
    required this.isLoading,
    required this.error,
    required this.listings,
    required this.onRefresh,
  });

  final bool isLoading;
  final String? error;
  final List<Map<String, dynamic>> listings;
  final Future<void> Function() onRefresh;

  @override
  Widget build(BuildContext context) {
    if (isLoading && listings.isEmpty) {
      return const Center(
        child: CircularProgressIndicator(
          valueColor: AlwaysStoppedAnimation<Color>(kOrange),
        ),
      );
    }

    if (error != null && listings.isEmpty) {
      return _StateView(
        icon: Icons.error_outline,
        title: error!,
        actionLabel: 'Try again',
        onPressed: onRefresh,
      );
    }

    return RefreshIndicator(
      color: kOrange,
      backgroundColor: cardColor,
      onRefresh: onRefresh,
      child: ListView(
        physics: const AlwaysScrollableScrollPhysics(),
        padding: const EdgeInsets.fromLTRB(16, 16, 16, 24),
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                '${listings.length} product${listings.length == 1 ? '' : 's'}',
                style: const TextStyle(
                  color: textColor,
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
              IconButton(
                onPressed: onRefresh,
                icon: const Icon(Icons.refresh, color: kOrange),
              ),
            ],
          ),
          if (error != null) ...[
            const SizedBox(height: 8),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.redAccent.withOpacity(0.12),
                borderRadius: BorderRadius.circular(10),
                border: Border.all(color: Colors.redAccent.withOpacity(0.35)),
              ),
              child: Text(
                error!,
                style: const TextStyle(color: Colors.white70, fontSize: 13),
              ),
            ),
          ],
          if (listings.isEmpty) ...[
            const SizedBox(height: 48),
            const _StateView(
              icon: Icons.inventory_2_outlined,
              title: 'No seller listings yet.',
              subtitle: 'Products you create will appear here.',
            ),
          ] else ...[
            const SizedBox(height: 12),
            ...listings.map((listing) => _ListingCard(item: listing)),
          ],
        ],
      ),
    );
  }
}

class _ListingCard extends StatelessWidget {
  const _ListingCard({required this.item});

  final Map<String, dynamic> item;

  @override
  Widget build(BuildContext context) {
    final images = _stringList(item['images']);
    final imageUrl = images.isNotEmpty ? images.first : '';
    final isActive = item['active'] == true;

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: cardColor,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.white10),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(10),
            child: imageUrl.isNotEmpty
                ? Image.network(
                    imageUrl,
                    height: 92,
                    width: 92,
                    fit: BoxFit.cover,
                    errorBuilder: (_, __, ___) => _placeholderImage(),
                  )
                : _placeholderImage(),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 4,
                      ),
                      decoration: BoxDecoration(
                        color: isActive
                            ? const Color(0xFF163320)
                            : const Color(0xFF3A2828),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Text(
                        isActive ? 'Active' : 'Out of stock',
                        style: TextStyle(
                          color: isActive
                              ? const Color(0xFF57D486)
                              : const Color(0xFFFF8B8B),
                          fontSize: 11,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                    const Spacer(),
                    Text(
                      _priceLabel(item),
                      style: const TextStyle(
                        color: kOrange,
                        fontSize: 15,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 10),
                Text(
                  _text(item['name'], fallback: 'Untitled product'),
                  style: const TextStyle(
                    color: textColor,
                    fontSize: 15,
                    fontWeight: FontWeight.w700,
                  ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 4),
                Text(
                  _text(item['category'], fallback: 'Uncategorized'),
                  style: const TextStyle(color: hintText, fontSize: 12),
                ),
                const SizedBox(height: 10),
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: [
                    _chip(Icons.inventory_2_outlined, 'Stock ${item['stock'] ?? 0}'),
                    _chip(Icons.visibility_outlined, 'Views ${item['views'] ?? 0}'),
                    _chip(
                      Icons.star_border_rounded,
                      'Rating ${_text(item['averageRating'], fallback: '0')}',
                    ),
                    _chip(
                      Icons.view_in_ar_outlined,
                      '3D ${_text(item['model3DStatus'], fallback: 'pending')}',
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _chip(IconData icon, String label) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.04),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 14, color: kOrange),
          const SizedBox(width: 4),
          Text(
            label,
            style: const TextStyle(color: Colors.white70, fontSize: 11),
          ),
        ],
      ),
    );
  }

  Widget _placeholderImage() {
    return Container(
      height: 92,
      width: 92,
      color: const Color(0xFF2B2B2B),
      alignment: Alignment.center,
      child: const Icon(Icons.image_not_supported_outlined, color: hintText),
    );
  }

  static List<String> _stringList(dynamic value) {
    if (value is! List) {
      final single = value?.toString().trim() ?? '';
      return single.isEmpty ? const [] : [single];
    }

    return value
        .map((item) => item.toString().trim())
        .where((item) => item.isNotEmpty)
        .toList();
  }

  static String _text(dynamic value, {String fallback = ''}) {
    final result = value?.toString().trim() ?? '';
    return result.isEmpty ? fallback : result;
  }

  static String _priceLabel(Map<String, dynamic> item) {
    final formatted = _text(item['formattedPrice']);
    if (formatted.isNotEmpty) {
      return 'LKR $formatted';
    }

    final price = item['price'];
    if (price == null) {
      return 'LKR 0';
    }

    return 'LKR ${price.toString()}';
  }
}

class _StateView extends StatelessWidget {
  const _StateView({
    required this.icon,
    required this.title,
    this.subtitle,
    this.actionLabel,
    this.onPressed,
  });

  final IconData icon;
  final String title;
  final String? subtitle;
  final String? actionLabel;
  final Future<void> Function()? onPressed;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, size: 48, color: hintText),
            const SizedBox(height: 12),
            Text(
              title,
              textAlign: TextAlign.center,
              style: const TextStyle(
                color: textColor,
                fontSize: 16,
                fontWeight: FontWeight.w600,
              ),
            ),
            if (subtitle != null) ...[
              const SizedBox(height: 8),
              Text(
                subtitle!,
                textAlign: TextAlign.center,
                style: const TextStyle(color: hintText, fontSize: 13),
              ),
            ],
            if (actionLabel != null && onPressed != null) ...[
              const SizedBox(height: 16),
              ElevatedButton(
                onPressed: () => onPressed!.call(),
                style: ElevatedButton.styleFrom(
                  backgroundColor: kOrange,
                  foregroundColor: Colors.black,
                ),
                child: Text(actionLabel!),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
