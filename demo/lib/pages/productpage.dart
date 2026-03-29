import 'dart:io';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:model_viewer_plus/model_viewer_plus.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;
import 'package:path_provider/path_provider.dart';
import 'package:shelf/shelf_io.dart' as shelf_io;
import 'package:shelf_static/shelf_static.dart';
import '../services/productservice.dart';

class ProductDetailPage extends StatefulWidget {
  final String productId;

  const ProductDetailPage({super.key, required this.productId});

  @override
  State<ProductDetailPage> createState() => _ProductDetailPageState();
}

class _ProductDetailPageState extends State<ProductDetailPage> {
  final ProductService _productService = ProductService();

  bool _isLoading = true;
  String? _error;
  Map<String, dynamic> _product = const {};

  // 3D model state
  bool _isDownloadingModel = false;
  String? _localModelUrl;
  String? _modelError;
  bool _isRetrying = false;
  HttpServer? _localServer;

  int _selectedImageIndex = 0;

  @override
  void initState() {
    super.initState();
    _loadProduct();
  }

  @override
  void dispose() {
    _localServer?.close(force: true);
    super.dispose();
  }

  // ── Helpers ───────────────────────────────────────────────

  String _text(dynamic value, {String fallback = ''}) {
    final result = value?.toString().trim() ?? '';
    return result.isEmpty ? fallback : result;
  }

  Map<String, dynamic> _asMap(dynamic value) {
    if (value is Map<String, dynamic>) return value;
    if (value is Map) return value.map((k, v) => MapEntry('$k', v));
    return const {};
  }

  List<String> _imageList() {
    final raw = _product['images'];
    if (raw is List) return raw.map((e) => e.toString()).toList();
    return [];
  }

  String get _model3DStatus =>
      _asMap(_product['model3D'])['status']?.toString() ?? 'pending';

  String get _model3DUrl =>
      _asMap(_product['model3D'])['url']?.toString() ?? '';

  String get _model3DMessage =>
      _asMap(_product['model3D'])['message']?.toString() ?? '';

  Map<String, dynamic> get _dimensions => _asMap(_product['dimensions']);

  // ── Data loading ──────────────────────────────────────────

  Future<String?> _getToken() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString('x-auth-token')?.trim();
  }

  Future<void> _loadProduct() async {
    setState(() {
      _isLoading = true;
      _error = null;
    });

    try {
      final token = await _getToken() ?? '';
      final product = await _productService.fetchProduct(
        widget.productId,
        token,
      );

      if (!mounted) return;
      setState(() {
        _product = product;
        _isLoading = false;
      });

      // Auto-download model if status is success
      if (_model3DStatus == 'success' && _model3DUrl.isNotEmpty) {
        _downloadModel(_model3DUrl);
      }
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _error = e.toString().replaceFirst('Exception: ', '');
        _isLoading = false;
      });
    }
  }

  Future<void> _downloadModel(String url) async {
    setState(() {
      _isDownloadingModel = true;
      _modelError = null;
    });

    try {
      final response = await http.get(Uri.parse(url));

      if (response.statusCode != 200) {
        throw Exception('Failed to download 3D model');
      }

      // Save GLB to temp directory
      final dir = await getTemporaryDirectory();
      final file = File('${dir.path}/${widget.productId}.glb');
      await file.writeAsBytes(response.bodyBytes);

      // Shut down any existing local server
      await _localServer?.close(force: true);

      // Spin up a local HTTP server serving the temp directory
      final handler = createStaticHandler(dir.path);
      _localServer = await shelf_io.serve(handler, '127.0.0.1', 0);

      if (!mounted) return;
      setState(() {
        _localModelUrl =
            'http://127.0.0.1:${_localServer!.port}/${widget.productId}.glb';
        _isDownloadingModel = false;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _modelError = 'Could not load 3D model.';
        _isDownloadingModel = false;
      });
    }
  }

  Future<void> _retryModel3D() async {
    setState(() => _isRetrying = true);

    try {
      final token = await _getToken() ?? '';
      await _productService.retryModel3D(widget.productId, token);

      if (!mounted) return;
      Get.snackbar(
        'Retry requested',
        'Your 3D model is being regenerated.',
        backgroundColor: const Color(0xFF2a2a2a),
        colorText: Colors.white,
        snackPosition: SnackPosition.BOTTOM,
      );

      await _loadProduct();
    } catch (e) {
      if (!mounted) return;
      Get.snackbar(
        'Retry failed',
        e.toString().replaceFirst('Exception: ', ''),
        backgroundColor: const Color(0xFF2a2a2a),
        colorText: Colors.redAccent,
        snackPosition: SnackPosition.BOTTOM,
      );
    } finally {
      if (mounted) setState(() => _isRetrying = false);
    }
  }

  void _showEditDialog() {
    final titleController = TextEditingController(text: _text(_product['title']));
    final descriptionController = TextEditingController(text: _text(_product['description']));
    final priceController = TextEditingController(text: _product['price']?.toString());
    final stockController = TextEditingController(text: _product['stock']?.toString());
    final categoryController = TextEditingController(text: _text(_product['category']));

    showDialog(
      context: context,
      builder: (ctx) {
        return AlertDialog(
          backgroundColor: const Color(0xFF2a2a2a),
          title: const Text('Edit Product', style: TextStyle(color: Colors.white)),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextField(
                  controller: titleController,
                  style: const TextStyle(color: Colors.white),
                  decoration: const InputDecoration(labelText: 'Title', labelStyle: TextStyle(color: Colors.grey)),
                ),
                TextField(
                  controller: descriptionController,
                  style: const TextStyle(color: Colors.white),
                  decoration: const InputDecoration(labelText: 'Description', labelStyle: TextStyle(color: Colors.grey)),
                  maxLines: 3,
                ),
                TextField(
                  controller: priceController,
                  style: const TextStyle(color: Colors.white),
                  keyboardType: TextInputType.number,
                  decoration: const InputDecoration(labelText: 'Price', labelStyle: TextStyle(color: Colors.grey)),
                ),
                TextField(
                  controller: stockController,
                  style: const TextStyle(color: Colors.white),
                  keyboardType: TextInputType.number,
                  decoration: const InputDecoration(labelText: 'Stock', labelStyle: TextStyle(color: Colors.grey)),
                ),
                TextField(
                  controller: categoryController,
                  style: const TextStyle(color: Colors.white),
                  decoration: const InputDecoration(labelText: 'Category', labelStyle: TextStyle(color: Colors.grey)),
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(ctx),
              child: const Text('Cancel', style: TextStyle(color: Colors.grey)),
            ),
            ElevatedButton(
              onPressed: () async {
                Navigator.pop(ctx);
                await _updateProductDetails({
                  'title': titleController.text,
                  'description': descriptionController.text,
                  'price': double.tryParse(priceController.text) ?? 0,
                  'stock': int.tryParse(stockController.text) ?? 0,
                  'category': categoryController.text,
                });
              },
              style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFFFBB040)),
              child: const Text('Save', style: TextStyle(color: Colors.black)),
            ),
          ],
        );
      },
    );
  }

  Future<void> _updateProductDetails(Map<String, dynamic> data) async {
    setState(() => _isLoading = true);
    try {
      final token = await _getToken() ?? '';
      await _productService.updateProduct(widget.productId, token, data);
      
      if (!mounted) return;
      Get.snackbar(
        'Success',
        'Product updated successfully!',
        backgroundColor: const Color(0xFF4BC87A),
        colorText: Colors.white,
      );
      await _loadProduct(); // Reload the product details to reflect changes
    } catch (e) {
      if (!mounted) return;
      setState(() => _isLoading = false);
      Get.snackbar(
        'Failed to update',
        e.toString().replaceFirst('Exception: ', ''),
        backgroundColor: Colors.redAccent,
        colorText: Colors.white,
      );
    }
  }

  // ── Build ─────────────────────────────────────────────────

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF1a1a1a),
      body: _isLoading
          ? const Center(
              child: CircularProgressIndicator(color: Color(0xFFFBB040)),
            )
          : _error != null
          ? _buildError()
          : _buildContent(),
    );
  }

  Widget _buildError() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.error_outline, color: Colors.redAccent, size: 48),
            const SizedBox(height: 16),
            Text(
              _error ?? 'Something went wrong',
              style: const TextStyle(color: Colors.white70, fontSize: 14),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: _loadProduct,
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFFFBB040),
              ),
              child: const Text('Retry', style: TextStyle(color: Colors.white)),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildContent() {
    final images = _imageList();

    return CustomScrollView(
      slivers: [
        // ── App Bar with image ────────────────────────────
        SliverAppBar(
          expandedHeight: 320,
          pinned: true,
          backgroundColor: const Color(0xFF1a1a1a),
          leading: IconButton(
            icon: const Icon(Icons.arrow_back_ios_new, color: Colors.white),
            onPressed: () => Get.back(),
          ),
          actions: [
            IconButton(
              icon: const Icon(Icons.edit, color: Colors.white),
              onPressed: _showEditDialog,
            ),
          ],
          flexibleSpace: FlexibleSpaceBar(
            background: _buildImageSection(images),
          ),
        ),

        // ── Product details ───────────────────────────────
        SliverToBoxAdapter(
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildTitleAndPrice(),
                const SizedBox(height: 16),
                _buildStats(),
                const SizedBox(height: 16),
                _buildDivider(),
                const SizedBox(height: 16),
                _buildDescription(),
                const SizedBox(height: 16),
                _buildDivider(),
                const SizedBox(height: 16),
                _buildDetails(),
                const SizedBox(height: 16),
                _buildDivider(),
                const SizedBox(height: 20),
                _build3DModelSection(),
                const SizedBox(height: 40),
              ],
            ),
          ),
        ),
      ],
    );
  }

  // ── Image section ─────────────────────────────────────────

  Widget _buildImageSection(List<String> images) {
    if (images.isEmpty) {
      return Container(
        color: const Color(0xFF2a2a2a),
        child: const Center(
          child: Icon(Icons.chair_rounded, color: Color(0xFF8A5C2A), size: 80),
        ),
      );
    }

    return Stack(
      fit: StackFit.expand,
      children: [
        Image.network(
          images[_selectedImageIndex],
          fit: BoxFit.cover,
          errorBuilder: (_, __, ___) => Container(
            color: const Color(0xFF2a2a2a),
            child: const Icon(
              Icons.chair_rounded,
              color: Color(0xFF8A5C2A),
              size: 80,
            ),
          ),
        ),

        if (images.length > 1)
          Positioned(
            bottom: 12,
            left: 0,
            right: 0,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: List.generate(images.length, (i) {
                final selected = i == _selectedImageIndex;
                return GestureDetector(
                  onTap: () => setState(() => _selectedImageIndex = i),
                  child: Container(
                    margin: const EdgeInsets.symmetric(horizontal: 4),
                    width: selected ? 36 : 28,
                    height: selected ? 36 : 28,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(6),
                      border: Border.all(
                        color: selected
                            ? const Color(0xFFFBB040)
                            : Colors.transparent,
                        width: 2,
                      ),
                    ),
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(4),
                      child: Image.network(images[i], fit: BoxFit.cover),
                    ),
                  ),
                );
              }),
            ),
          ),
      ],
    );
  }

  // ── Title & price ─────────────────────────────────────────

  Widget _buildTitleAndPrice() {
    final category = _text(_product['category']);
    final stock = _product['stock'];
    final inStock =
        stock != null &&
        (stock is int ? stock : int.tryParse('$stock') ?? 0) > 0;

    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              if (category.isNotEmpty)
                Container(
                  margin: const EdgeInsets.only(bottom: 6),
                  padding: const EdgeInsets.symmetric(
                    horizontal: 8,
                    vertical: 3,
                  ),
                  decoration: BoxDecoration(
                    color: const Color(0xFFFBB040).withOpacity(0.15),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(
                    category,
                    style: const TextStyle(
                      color: Color(0xFFFBB040),
                      fontSize: 10,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              Text(
                _text(_product['title'], fallback: 'Untitled Product'),
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  letterSpacing: -0.3,
                ),
              ),
            ],
          ),
        ),
        const SizedBox(width: 12),
        Column(
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            Text(
              _text(
                _product['formattedPrice'] ?? '₦${_product['price']}',
                fallback: '₦0',
              ),
              style: const TextStyle(
                color: Color(0xFFFBB040),
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 4),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
              decoration: BoxDecoration(
                color: inStock
                    ? const Color(0xFF1C3D27)
                    : const Color(0xFF3D1C1C),
                borderRadius: BorderRadius.circular(20),
              ),
              child: Text(
                inStock ? 'In Stock ($stock)' : 'Out of Stock',
                style: TextStyle(
                  color: inStock ? const Color(0xFF4BC87A) : Colors.redAccent,
                  fontSize: 10,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }

  // ── Stats row ─────────────────────────────────────────────

  Widget _buildStats() {
    final views = _product['views'] ?? 0;
    final rating = _product['averageRating'] ?? 0;
    final reviews = _product['numReviews'] ?? 0;

    return Row(
      children: [
        _buildStatChip(Icons.visibility_outlined, '$views views', Colors.grey),
        const SizedBox(width: 10),
        _buildStatChip(
          Icons.star_rounded,
          '$rating ($reviews reviews)',
          const Color(0xFFFBB040),
        ),
      ],
    );
  }

  Widget _buildStatChip(IconData icon, String label, Color color) {
    return Row(
      children: [
        Icon(icon, size: 14, color: color),
        const SizedBox(width: 4),
        Text(label, style: TextStyle(color: color, fontSize: 12)),
      ],
    );
  }

  // ── Description ───────────────────────────────────────────

  Widget _buildDescription() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Description',
          style: TextStyle(
            color: Colors.white,
            fontSize: 15,
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(height: 8),
        Text(
          _text(_product['description'], fallback: 'No description provided.'),
          style: const TextStyle(color: Colors.grey, fontSize: 13, height: 1.6),
        ),
      ],
    );
  }

  // ── Product details ───────────────────────────────────────

  Widget _buildDetails() {
    final length = _dimensions['length'];
    final width = _dimensions['width'];
    final height = _dimensions['height'];
    final unit = _text(_dimensions['unit'], fallback: 'cm');

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Product Details',
          style: TextStyle(
            color: Colors.white,
            fontSize: 15,
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(height: 12),
        _buildDetailRow('Dimensions', '$length × $width × $height $unit'),
        _buildDetailRow('Category', _text(_product['category'], fallback: '—')),
        _buildDetailRow('Stock', '${_product['stock'] ?? 0} units'),
      ],
    );
  }

  Widget _buildDetailRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        children: [
          SizedBox(
            width: 100,
            child: Text(
              label,
              style: const TextStyle(color: Colors.grey, fontSize: 13),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: const TextStyle(color: Colors.white, fontSize: 13),
            ),
          ),
        ],
      ),
    );
  }

  // ── 3D Model section ──────────────────────────────────────

  Widget _build3DModelSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            const Icon(
              Icons.view_in_ar_rounded,
              color: Color(0xFFFBB040),
              size: 18,
            ),
            const SizedBox(width: 8),
            const Text(
              'BluePrint 3D Model',
              style: TextStyle(
                color: Colors.white,
                fontSize: 15,
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(width: 8),
            _build3DStatusBadge(),
            const Spacer(),
            if (_model3DStatus == 'success')
              _isRetrying
                  ? const SizedBox(
                      width: 16,
                      height: 16,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        color: Color(0xFFFBB040),
                      ),
                    )
                  : IconButton(
                      icon: const Icon(Icons.refresh_rounded, color: Colors.grey, size: 20),
                      onPressed: _retryModel3D,
                      tooltip: 'Regenerate 3D Model',
                      constraints: const BoxConstraints(),
                      padding: EdgeInsets.zero,
                    ),
          ],
        ),
        const SizedBox(height: 14),
        _build3DModelContent(),
      ],
    );
  }

  Widget _build3DStatusBadge() {
    Color color;
    Color bg;
    String label;

    switch (_model3DStatus) {
      case 'success':
        label = 'Ready';
        color = const Color(0xFF4BC87A);
        bg = const Color(0xFF1C3D27);
        break;
      case 'generating':
        label = 'Generating';
        color = const Color(0xFFFBB040);
        bg = const Color(0xFF3D2E1C);
        break;
      case 'failed':
        label = 'Failed';
        color = Colors.redAccent;
        bg = const Color(0xFF3D1C1C);
        break;
      default:
        label = 'Pending';
        color = Colors.grey;
        bg = const Color(0xFF2a2a2a);
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(
        label,
        style: TextStyle(
          color: color,
          fontSize: 10,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }

  Widget _build3DModelContent() {
    // Success — show the 3D viewer
    if (_model3DStatus == 'success') {
      if (_model3DUrl.isEmpty) {
        return _build3DPlaceholder(
          icon: Icons.error_outline,
          message: 'Model URL not available.',
          iconColor: Colors.redAccent,
        );
      }

      return ClipRRect(
        borderRadius: BorderRadius.circular(12),
        child: SizedBox(
          height: 320,
          child: ModelViewer(
            src: _model3DUrl,
            alt: _text(_product['title'], fallback: 'Product 3D Model'),
            ar: true,
            autoRotate: true,
            cameraControls: true,
            backgroundColor: const Color(0xFF2a2a2a),
          ),
        ),
      );
    }

    // Generating
    if (_model3DStatus == 'generating') {
      return _build3DPlaceholder(
        icon: Icons.autorenew_rounded,
        message:
            'Your 3D model is being generated.\nThis may take a few minutes.',
        showSpinner: true,
      );
    }

    // Failed
    if (_model3DStatus == 'failed') {
      return _build3DPlaceholder(
        icon: Icons.broken_image_outlined,
        message: _model3DMessage.isNotEmpty
            ? _model3DMessage
            : '3D model generation failed.',
        iconColor: Colors.redAccent,
        action: _buildRetryButton(),
      );
    }

    // Pending (default)
    return _build3DPlaceholder(
      icon: Icons.view_in_ar_outlined,
      message: '3D model has not been generated yet.',
      action: _buildRetryButton(),
    );
  }

  Widget _build3DPlaceholder({
    required IconData icon,
    required String message,
    Color iconColor = Colors.grey,
    bool showSpinner = false,
    Widget? action,
  }) {
    return Container(
      height: 180,
      decoration: BoxDecoration(
        color: const Color(0xFF2a2a2a),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFF3a3a3a)),
      ),
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            if (showSpinner)
              const SizedBox(
                width: 32,
                height: 32,
                child: CircularProgressIndicator(
                  color: Color(0xFFFBB040),
                  strokeWidth: 2,
                ),
              )
            else
              Icon(icon, color: iconColor, size: 36),
            const SizedBox(height: 12),
            Text(
              message,
              style: const TextStyle(
                color: Colors.grey,
                fontSize: 12,
                height: 1.5,
              ),
              textAlign: TextAlign.center,
            ),
            if (action != null) ...[const SizedBox(height: 14), action],
          ],
        ),
      ),
    );
  }

  Widget _buildRetryButton() {
    return ElevatedButton.icon(
      onPressed: _isRetrying ? null : _retryModel3D,
      icon: _isRetrying
          ? const SizedBox(
              width: 14,
              height: 14,
              child: CircularProgressIndicator(
                strokeWidth: 2,
                color: Colors.white,
              ),
            )
          : const Icon(Icons.refresh_rounded, size: 16),
      label: Text(_isRetrying ? 'Requesting...' : 'Generate 3D Model'),
      style: ElevatedButton.styleFrom(
        backgroundColor: const Color(0xFFFBB040),
        foregroundColor: Colors.white,
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
        textStyle: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
      ),
    );
  }

  Widget _buildDivider() {
    return Container(height: 1, color: const Color(0xFF2a2a2a));
  }
}
