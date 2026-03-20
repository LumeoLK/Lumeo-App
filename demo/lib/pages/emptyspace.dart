import 'dart:io';
import 'package:camera/camera.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../services/ar_search_service.dart';
import '../pages/ar_screen.dart';

class ARSearchPage extends ConsumerStatefulWidget {
  const ARSearchPage({super.key});

  @override
  ConsumerState<ARSearchPage> createState() => _ARSearchPageState();
}

class _ARSearchPageState extends ConsumerState<ARSearchPage>
    with SingleTickerProviderStateMixin {
  CameraController? _cameraController;
  List<CameraDescription>? _cameras;
  File? _capturedImage;
  bool _cameraReady = false;
  late AnimationController _pulseController;
  late Animation<double> _pulseAnimation;

  static const Color _accent = Color(0xFFFDB04B);
  static const Color _bg = Color(0xFF1E1E1E);
  static const Color _card = Color(0xFF2A2A2A);

  @override
  void initState() {
    super.initState();
    _initCamera();
    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 2),
    )..repeat(reverse: true);
    _pulseAnimation = Tween<double>(begin: 0.6, end: 1.0).animate(
      CurvedAnimation(parent: _pulseController, curve: Curves.easeInOut),
    );
  }

  Future<void> _initCamera() async {
    try {
      _cameras = await availableCameras();
      if (_cameras!.isEmpty) return;
      _cameraController = CameraController(
        _cameras![0],
        ResolutionPreset.high,
        enableAudio: false,
      );
      await _cameraController!.initialize();
      if (mounted) setState(() => _cameraReady = true);
    } catch (e) {
      print('Camera init error: $e');
    }
  }

  Future<void> _captureAndSearch() async {
    if (_cameraController == null ||
        !_cameraController!.value.isInitialized) return;
    try {
      final XFile photo = await _cameraController!.takePicture();
      final imageFile = File(photo.path);
      setState(() => _capturedImage = imageFile);
      if (mounted) {
        await ref.read(arSearchProvider).searchFurniture(
              context: context,
              imageFile: imageFile,
            );
      }
    } catch (e) {
      print('Capture error: $e');
    }
  }

  void _retake() {
    setState(() => _capturedImage = null);
    ref.read(searchResultsProvider.notifier).state = [];
  }

  @override
  void dispose() {
    _cameraController?.dispose();
    _pulseController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isLoading = ref.watch(searchLoadingProvider);
    final results = ref.watch(searchResultsProvider);
    final hasResults = results.isNotEmpty;

    // Show results page when we have results
    if (hasResults && !isLoading) {
      return _ResultsPage(
        results: results,
        capturedImage: _capturedImage,
        onScanAgain: _retake,
      );
    }

    // Full screen camera / loading view
    return Scaffold(
      backgroundColor: Colors.black,
      body: Stack(
        fit: StackFit.expand,
        children: [

          // ── Full screen camera or captured image ──────────────────────
          if (_capturedImage != null)
            Image.file(_capturedImage!, fit: BoxFit.cover)
          else if (_cameraReady)
            CameraPreview(_cameraController!)
          else
            const Center(
              child: CircularProgressIndicator(color: _accent),
            ),

          // ── Dark gradient top — for back button readability ───────────
          Positioned(
            top: 0,
            left: 0,
            right: 0,
            child: Container(
              height: 140,
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    Colors.black.withOpacity(0.7),
                    Colors.transparent,
                  ],
                ),
              ),
            ),
          ),

          // ── Dark gradient bottom — for button readability ─────────────
          Positioned(
            bottom: 0,
            left: 0,
            right: 0,
            child: Container(
              height: 200,
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.bottomCenter,
                  end: Alignment.topCenter,
                  colors: [
                    Colors.black.withOpacity(0.85),
                    Colors.transparent,
                  ],
                ),
              ),
            ),
          ),

          // ── Back button ───────────────────────────────────────────────
          Positioned(
            top: 0,
            left: 0,
            right: 0,
            child: SafeArea(
              child: Padding(
                padding: const EdgeInsets.symmetric(
                    horizontal: 16, vertical: 8),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    GestureDetector(
                      onTap: () => Navigator.pop(context),
                      child: Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: Colors.black.withOpacity(0.4),
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(Icons.arrow_back,
                            color: Colors.white, size: 20),
                      ),
                    ),
                    const Text(
                      'Scan Your Room',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(width: 40), // balance
                  ],
                ),
              ),
            ),
          ),

          // ── Scanning corners overlay ───────────────────────────────────
          if (_capturedImage == null && _cameraReady && !isLoading)
            Positioned.fill(
              child: AnimatedBuilder(
                animation: _pulseAnimation,
                builder: (context, child) {
                  return CustomPaint(
                    painter: _ScannerPainter(
                      opacity: _pulseAnimation.value,
                      color: _accent,
                    ),
                  );
                },
              ),
            ),

          // ── Center hint text ───────────────────────────────────────────
          if (_capturedImage == null && _cameraReady && !isLoading)
            Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  AnimatedBuilder(
                    animation: _pulseAnimation,
                    builder: (context, child) {
                      return Opacity(
                        opacity: _pulseAnimation.value,
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 20, vertical: 10),
                          decoration: BoxDecoration(
                            color: Colors.black.withOpacity(0.4),
                            borderRadius: BorderRadius.circular(30),
                            border: Border.all(
                                color: _accent.withOpacity(0.3)),
                          ),
                          child: const Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(Icons.crop_free,
                                  color: _accent, size: 18),
                              SizedBox(width: 8),
                              Text(
                                'Point at your room',
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 14,
                                ),
                              ),
                            ],
                          ),
                        ),
                      );
                    },
                  ),
                ],
              ),
            ),

          // ── Loading overlay ────────────────────────────────────────────
          if (isLoading)
            Positioned.fill(
              child: Container(
                color: Colors.black.withOpacity(0.6),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    SizedBox(
                      width: 72,
                      height: 72,
                      child: Stack(
                        alignment: Alignment.center,
                        children: [
                          const CircularProgressIndicator(
                            color: _accent,
                            strokeWidth: 3,
                          ),
                          const Icon(Icons.chair,
                              color: _accent, size: 28),
                        ],
                      ),
                    ),
                    const SizedBox(height: 20),
                    const Text(
                      'Analyzing your room...',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 18,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 8),
                    const Text(
                      'Finding furniture that matches\nyour style and colors',
                      style: TextStyle(
                          color: Colors.white60, fontSize: 14),
                      textAlign: TextAlign.center,
                    ),
                  ],
                ),
              ),
            ),

          // ── Bottom buttons ─────────────────────────────────────────────
          if (!isLoading)
            Positioned(
              bottom: 0,
              left: 0,
              right: 0,
              child: SafeArea(
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(24, 0, 24, 24),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      // Tip text
                      if (_capturedImage == null)
                        Padding(
                          padding: const EdgeInsets.only(bottom: 16),
                          child: Text(
                            'Include walls and floor for best results',
                            style: TextStyle(
                              color: Colors.white.withOpacity(0.5),
                              fontSize: 12,
                            ),
                            textAlign: TextAlign.center,
                          ),
                        ),

                      Row(
                        children: [
                          // Retake button — only after capture
                          if (_capturedImage != null) ...[
                            Expanded(
                              child: _buildButton(
                                icon: Icons.refresh,
                                label: 'Retake',
                                onTap: _retake,
                                outlined: true,
                              ),
                            ),
                            const SizedBox(width: 12),
                          ],

                          // Main scan button
                          Expanded(
                            flex: 2,
                            child: _buildButton(
                              icon: _capturedImage == null
                                  ? Icons.camera_alt
                                  : Icons.search,
                              label: _capturedImage == null
                                  ? 'Scan Room'
                                  : 'Find Furniture',
                              onTap: _captureAndSearch,
                              outlined: false,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildButton({
    required IconData icon,
    required String label,
    required VoidCallback? onTap,
    required bool outlined,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 14),
        decoration: BoxDecoration(
          color: outlined ? Colors.transparent : _accent,
          borderRadius: BorderRadius.circular(30),
          border: outlined
              ? Border.all(color: Colors.white54, width: 1.5)
              : null,
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon,
                color: outlined ? Colors.white : Colors.black,
                size: 20),
            const SizedBox(width: 8),
            Text(
              label,
              style: TextStyle(
                color: outlined ? Colors.white : Colors.black,
                fontWeight: FontWeight.bold,
                fontSize: 15,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ── Results Page ─────────────────────────────────────────────────────────────
class _ResultsPage extends StatelessWidget {
  final List<dynamic> results;
  final File? capturedImage;
  final VoidCallback onScanAgain;

  static const Color _accent = Color(0xFFFDB04B);
  static const Color _bg = Color(0xFF1E1E1E);
  static const Color _card = Color(0xFF2A2A2A);

  const _ResultsPage({
    required this.results,
    required this.capturedImage,
    required this.onScanAgain,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _bg,
      body: CustomScrollView(
        slivers: [

          // ── Collapsible header with captured image ───────────────────
          SliverAppBar(
            backgroundColor: _bg,
            expandedHeight: 220,
            pinned: true,
            leading: IconButton(
              icon: const Icon(Icons.arrow_back_ios,
                  color: Colors.white),
              onPressed: () => Navigator.pop(context),
            ),
            actions: [
              TextButton.icon(
                onPressed: onScanAgain,
                icon: const Icon(Icons.refresh,
                    color: _accent, size: 16),
                label: const Text('Scan Again',
                    style: TextStyle(color: _accent)),
              ),
            ],
            flexibleSpace: FlexibleSpaceBar(
              background: Stack(
                fit: StackFit.expand,
                children: [
                  // Captured image as header background
                  if (capturedImage != null)
                    Image.file(capturedImage!, fit: BoxFit.cover)
                  else
                    Container(color: _card),

                  // Gradient overlay for text readability
                  Container(
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                        colors: [
                          Colors.transparent,
                          _bg.withOpacity(0.95),
                        ],
                      ),
                    ),
                  ),

                  // Results summary text
                  Positioned(
                    bottom: 16,
                    left: 16,
                    right: 16,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            const Icon(Icons.auto_awesome,
                                color: _accent, size: 16),
                            const SizedBox(width: 6),
                            Text(
                              '${results.length} matches found',
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 4),
                        const Text(
                          'Sorted by style and color match',
                          style: TextStyle(
                              color: Colors.white60,
                              fontSize: 13),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),

          // ── Product list ─────────────────────────────────────────────
          SliverPadding(
            padding: const EdgeInsets.fromLTRB(16, 8, 16, 24),
            sliver: SliverList(
              delegate: SliverChildBuilderDelegate(
                (context, index) => _ProductCard(
                  product: results[index],
                  index: index,
                ),
                childCount: results.length,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ── Scanner Corner Painter ───────────────────────────────────────────────────
class _ScannerPainter extends CustomPainter {
  final double opacity;
  final Color color;
  _ScannerPainter({required this.opacity, required this.color});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color.withOpacity(opacity)
      ..strokeWidth = 3.5
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round;

    const length = 30.0;
    const margin = 32.0;

    // Top left
    canvas.drawLine(Offset(margin, margin),
        Offset(margin + length, margin), paint);
    canvas.drawLine(Offset(margin, margin),
        Offset(margin, margin + length), paint);

    // Top right
    canvas.drawLine(Offset(size.width - margin, margin),
        Offset(size.width - margin - length, margin), paint);
    canvas.drawLine(Offset(size.width - margin, margin),
        Offset(size.width - margin, margin + length), paint);

    // Bottom left
    canvas.drawLine(Offset(margin, size.height - margin),
        Offset(margin + length, size.height - margin), paint);
    canvas.drawLine(Offset(margin, size.height - margin),
        Offset(margin, size.height - margin - length), paint);

    // Bottom right
    canvas.drawLine(
        Offset(size.width - margin, size.height - margin),
        Offset(size.width - margin - length, size.height - margin),
        paint);
    canvas.drawLine(
        Offset(size.width - margin, size.height - margin),
        Offset(size.width - margin, size.height - margin - length),
        paint);
  }

  @override
  bool shouldRepaint(_ScannerPainter old) =>
      old.opacity != opacity;
}

// ── Product Card ─────────────────────────────────────────────────────────────
class _ProductCard extends StatelessWidget {
  final Map<String, dynamic> product;
  final int index;

  static const Color _accent = Color(0xFFFDB04B);
  static const Color _card = Color(0xFF2A2A2A);

  const _ProductCard({required this.product, required this.index});

  @override
  Widget build(BuildContext context) {
    final images = List<String>.from(product['images'] ?? []);
    final dimensions =
        product['dimensions'] as Map<String, dynamic>?;
    final score =
        ((product['score'] as num) * 100).toStringAsFixed(0);
    final scoreInt = int.parse(score);
    final model3D = product['model3D'] as Map<String, dynamic>?;
    final has3DModel = model3D?['status'] == 'success' &&
        (model3D?['url'] as String?)?.isNotEmpty == true;
    final dominantColor =
        product['dominantColor'] as List<dynamic>?;

    return Container(
      margin: const EdgeInsets.only(bottom: 14),
      decoration: BoxDecoration(
        color: _card,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [

          // Product image
          ClipRRect(
            borderRadius: const BorderRadius.only(
              topLeft: Radius.circular(16),
              bottomLeft: Radius.circular(16),
            ),
            child: images.isNotEmpty
                ? Image.network(
                    images[0],
                    width: 120,
                    height: 150,
                    fit: BoxFit.cover,
                    errorBuilder: (_, __, ___) => _placeholder(),
                  )
                : _placeholder(),
          ),

          // Details
          Expanded(
            child: Padding(
              padding: const EdgeInsets.all(12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [

                  // Title + score
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Expanded(
                        child: Text(
                          product['title'] ?? '',
                          style: const TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                            fontSize: 14,
                          ),
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      const SizedBox(width: 8),
                      _buildScoreBadge(scoreInt),
                    ],
                  ),
                  const SizedBox(height: 4),

                  // Category
                  Text(
                    product['category'] ?? '',
                    style: const TextStyle(
                        color: Colors.white38, fontSize: 12),
                  ),
                  const SizedBox(height: 8),

                  // Dimensions
                  if (dimensions != null) ...[
                    Row(
                      children: [
                        const Icon(Icons.straighten,
                            color: Colors.white24, size: 12),
                        const SizedBox(width: 4),
                        Text(
                          '${dimensions['length']}×'
                          '${dimensions['width']}×'
                          '${dimensions['height']} '
                          '${dimensions['unit'] ?? 'cm'}',
                          style: const TextStyle(
                              color: Colors.white38,
                              fontSize: 11),
                        ),
                      ],
                    ),
                    const SizedBox(height: 6),
                  ],

                  // Color swatch
                  if (dominantColor != null &&
                      dominantColor.length == 3) ...[
                    Row(
                      children: [
                        Container(
                          width: 14,
                          height: 14,
                          decoration: BoxDecoration(
                            color: Color.fromRGBO(
                              (dominantColor[0] as num).toInt(),
                              (dominantColor[1] as num).toInt(),
                              (dominantColor[2] as num).toInt(),
                              1,
                            ),
                            shape: BoxShape.circle,
                            border: Border.all(
                                color: Colors.white24),
                          ),
                        ),
                        const SizedBox(width: 6),
                        const Text(
                          'Color match',
                          style: TextStyle(
                              color: Colors.white38,
                              fontSize: 11),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                  ],

                  // Price + AR button
                  Row(
                    mainAxisAlignment:
                        MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        '\$${product['price']}',
                        style: const TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                        ),
                      ),
                      if (has3DModel)
                        GestureDetector(
                          onTap: () => Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (_) => ARScreen(
                                  modelUrl: model3D!['url']),
                            ),
                          ),
                          child: Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 10, vertical: 6),
                            decoration: BoxDecoration(
                              color: _accent,
                              borderRadius:
                                  BorderRadius.circular(8),
                            ),
                            child: const Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Icon(Icons.view_in_ar,
                                    color: Colors.black,
                                    size: 14),
                                SizedBox(width: 4),
                                Text(
                                  'View in AR',
                                  style: TextStyle(
                                    color: Colors.black,
                                    fontSize: 12,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildScoreBadge(int score) {
    Color badgeColor;
    if (score >= 75) {
      badgeColor = Colors.green;
    } else if (score >= 50) {
      badgeColor = _accent;
    } else {
      badgeColor = Colors.white38;
    }
    return Container(
      padding:
          const EdgeInsets.symmetric(horizontal: 6, vertical: 3),
      decoration: BoxDecoration(
        color: badgeColor.withOpacity(0.15),
        borderRadius: BorderRadius.circular(6),
        border: Border.all(color: badgeColor.withOpacity(0.5)),
      ),
      child: Text(
        '$score%',
        style: TextStyle(
          color: badgeColor,
          fontSize: 11,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }

  Widget _placeholder() {
    return Container(
      width: 120,
      height: 150,
      color: const Color(0xFF333333),
      child: const Icon(Icons.chair,
          color: Colors.white24, size: 32),
    );
  }
}
