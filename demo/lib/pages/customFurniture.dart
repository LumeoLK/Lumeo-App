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

  // Colors matching your app theme
  static const Color _bg = Color(0xFF1E1E1E);
  static const Color _card = Color(0xFF2A2A2A);
  static const Color _accent = Color(0xFFFDB04B);

  @override
  void initState() {
    super.initState();
    _initCamera();
    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 2),
    )..repeat(reverse: true);
    _pulseAnimation = Tween<double>(begin: 0.85, end: 1.0).animate(
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

    return Scaffold(
      backgroundColor: _bg,
      body: SafeArea(
        child: Column(
          children: [
            _buildHeader(hasResults, results.length),
            _buildCameraSection(isLoading),
            if (!isLoading && !hasResults) _buildHintSection(),
            if (isLoading) _buildLoadingSection(),
            if (!isLoading && hasResults)
              _buildResultsSection(results),
          ],
        ),
      ),
    );
  }

  // ── Header ──────────────────────────────────────────────────────────────
  Widget _buildHeader(bool hasResults, int count) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 0),
      child: Row(
        children: [
          IconButton(
            icon: const Icon(Icons.arrow_back_ios,
                color: Colors.white, size: 20),
            onPressed: () => Navigator.pop(context),
          ),
          const SizedBox(width: 4),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Scan Your Room',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
              Text(
                hasResults
                    ? '$count matching products found'
                    : 'Point at your room to find matching furniture',
                style: const TextStyle(
                    color: Colors.white54, fontSize: 12),
              ),
            ],
          ),
        ],
      ),
    );
  }

  // ── Camera / Preview Section ─────────────────────────────────────────────
  Widget _buildCameraSection(bool isLoading) {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(20),
        child: Stack(
          children: [
            // Camera or captured image
            SizedBox(
              height: 260,
              width: double.infinity,
              child: _capturedImage != null
                  ? Image.file(_capturedImage!, fit: BoxFit.cover)
                  : _cameraReady
                      ? CameraPreview(_cameraController!)
                      : Container(
                          color: _card,
                          child: const Center(
                            child: CircularProgressIndicator(
                                color: _accent),
                          ),
                        ),
            ),

            // Scanning overlay — only on live camera
            if (_capturedImage == null && _cameraReady && !isLoading)
              Positioned.fill(
                child: _buildScanOverlay(),
              ),

            // Captured flash overlay
            if (_capturedImage != null)
              Positioned.fill(
                child: Container(
                  decoration: BoxDecoration(
                    border: Border.all(color: _accent, width: 2),
                    borderRadius: BorderRadius.circular(20),
                  ),
                ),
              ),

            // Bottom bar with buttons
            Positioned(
              bottom: 0,
              left: 0,
              right: 0,
              child: Container(
                padding: const EdgeInsets.symmetric(
                    horizontal: 16, vertical: 12),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.bottomCenter,
                    end: Alignment.topCenter,
                    colors: [
                      Colors.black.withOpacity(0.8),
                      Colors.transparent,
                    ],
                  ),
                ),
                child: Row(
                  children: [
                    if (_capturedImage != null)
                      Expanded(
                        child: _buildCameraButton(
                          icon: Icons.refresh,
                          label: 'Retake',
                          onTap: _retake,
                          outlined: true,
                        ),
                      ),
                    if (_capturedImage != null)
                      const SizedBox(width: 12),
                    Expanded(
                      flex: 2,
                      child: _buildCameraButton(
                        icon: Icons.camera_alt,
                        label: _capturedImage == null
                            ? 'Scan Room'
                            : 'Scan Again',
                        onTap: isLoading ? null : _captureAndSearch,
                        outlined: false,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // Corner scan overlay effect
  Widget _buildScanOverlay() {
    return AnimatedBuilder(
      animation: _pulseAnimation,
      builder: (context, child) {
        return CustomPaint(
          painter: _ScannerPainter(
            opacity: _pulseAnimation.value,
            color: _accent,
          ),
        );
      },
    );
  }

  Widget _buildCameraButton({
    required IconData icon,
    required String label,
    required VoidCallback? onTap,
    required bool outlined,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 10),
        decoration: BoxDecoration(
          color: outlined ? Colors.transparent : _accent,
          borderRadius: BorderRadius.circular(30),
          border: outlined
              ? Border.all(color: Colors.white54)
              : null,
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon,
                color: outlined ? Colors.white : Colors.black,
                size: 18),
            const SizedBox(width: 6),
            Text(
              label,
              style: TextStyle(
                color: outlined ? Colors.white : Colors.black,
                fontWeight: FontWeight.bold,
                fontSize: 14,
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ── Hint Section ─────────────────────────────────────────────────────────
  Widget _buildHintSection() {
    return Expanded(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 24),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.tips_and_updates_outlined,
                color: _accent.withOpacity(0.6), size: 40),
            const SizedBox(height: 16),
            const Text(
              'How it works',
              style: TextStyle(
                color: Colors.white,
                fontSize: 16,
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 20),
            _buildHintRow(
                '1', 'Point camera at your room or space'),
            _buildHintRow(
                '2', 'Tap "Scan Room" to capture'),
            _buildHintRow(
                '3', 'AI finds furniture that matches your style'),
            _buildHintRow(
                '4', 'View any item in AR before buying'),
          ],
        ),
      ),
    );
  }

  Widget _buildHintRow(String step, String text) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        children: [
          Container(
            width: 28,
            height: 28,
            decoration: BoxDecoration(
              color: _accent.withOpacity(0.15),
              shape: BoxShape.circle,
              border: Border.all(
                  color: _accent.withOpacity(0.4)),
            ),
            child: Center(
              child: Text(
                step,
                style: const TextStyle(
                    color: _accent,
                    fontSize: 12,
                    fontWeight: FontWeight.bold),
              ),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              text,
              style: const TextStyle(
                  color: Colors.white60, fontSize: 14),
            ),
          ),
        ],
      ),
    );
  }

  // ── Loading Section ───────────────────────────────────────────────────────
  Widget _buildLoadingSection() {
    return Expanded(
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Animated loading indicator
            SizedBox(
              width: 64,
              height: 64,
              child: Stack(
                alignment: Alignment.center,
                children: [
                  const CircularProgressIndicator(
                    color: _accent,
                    strokeWidth: 3,
                  ),
                  const Icon(Icons.chair,
                      color: _accent, size: 24),
                ],
              ),
            ),
            const SizedBox(height: 20),
            const Text(
              'Analyzing your room...',
              style: TextStyle(
                  color: Colors.white,
                  fontSize: 16,
                  fontWeight: FontWeight.w600),
            ),
            const SizedBox(height: 8),
            const Text(
              'Finding furniture that matches\nyour style and colors',
              style:
                  TextStyle(color: Colors.white54, fontSize: 13),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  // ── Results Section ───────────────────────────────────────────────────────
  Widget _buildResultsSection(List<dynamic> results) {
    return Expanded(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Results header
          Padding(
            padding:
                const EdgeInsets.symmetric(horizontal: 16),
            child: Row(
              children: [
                const Icon(Icons.auto_awesome,
                    color: _accent, size: 16),
                const SizedBox(width: 6),
                Text(
                  '${results.length} matches · sorted by style',
                  style: const TextStyle(
                      color: Colors.white60, fontSize: 13),
                ),
              ],
            ),
          ),
          const SizedBox(height: 10),

          // Results list
          Expanded(
            child: ListView.builder(
              padding:
                  const EdgeInsets.symmetric(horizontal: 16),
              itemCount: results.length,
              itemBuilder: (context, index) {
                return _ProductCard(
                    product: results[index], index: index);
              },
            ),
          ),
        ],
      ),
    );
  }
}

// ── Scanner Corner Painter ──────────────────────────────────────────────────
class _ScannerPainter extends CustomPainter {
  final double opacity;
  final Color color;
  _ScannerPainter({required this.opacity, required this.color});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color.withOpacity(opacity)
      ..strokeWidth = 3
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round;

    const cornerSize = 24.0;
    const margin = 20.0;

    // Top left
    canvas.drawLine(Offset(margin, margin),
        Offset(margin + cornerSize, margin), paint);
    canvas.drawLine(Offset(margin, margin),
        Offset(margin, margin + cornerSize), paint);

    // Top right
    canvas.drawLine(
        Offset(size.width - margin, margin),
        Offset(size.width - margin - cornerSize, margin),
        paint);
    canvas.drawLine(
        Offset(size.width - margin, margin),
        Offset(size.width - margin, margin + cornerSize),
        paint);

    // Bottom left
    canvas.drawLine(
        Offset(margin, size.height - margin),
        Offset(margin + cornerSize, size.height - margin),
        paint);
    canvas.drawLine(
        Offset(margin, size.height - margin),
        Offset(margin, size.height - margin - cornerSize),
        paint);

    // Bottom right
    canvas.drawLine(
        Offset(size.width - margin, size.height - margin),
        Offset(size.width - margin - cornerSize,
            size.height - margin),
        paint);
    canvas.drawLine(
        Offset(size.width - margin, size.height - margin),
        Offset(size.width - margin,
            size.height - margin - cornerSize),
        paint);
  }

  @override
  bool shouldRepaint(_ScannerPainter old) =>
      old.opacity != opacity;
}

// ── Product Card ────────────────────────────────────────────────────────────
class _ProductCard extends StatelessWidget {
  final Map<String, dynamic> product;
  final int index;

  static const Color _card = Color(0xFF2A2A2A);
  static const Color _accent = Color(0xFFFDB04B);

  const _ProductCard({required this.product, required this.index});

  @override
  Widget build(BuildContext context) {
    final images = List<String>.from(product['images'] ?? []);
    final dimensions =
        product['dimensions'] as Map<String, dynamic>?;
    final score =
        ((product['score'] as num) * 100).toStringAsFixed(0);
    final model3D =
        product['model3D'] as Map<String, dynamic>?;
    final has3DModel = model3D?['status'] == 'success' &&
        (model3D?['url'] as String?)?.isNotEmpty == true;
    final dominantColor =
        product['dominantColor'] as List<dynamic>?;

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: _card,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        children: [
          Row(
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
                        width: 110,
                        height: 130,
                        fit: BoxFit.cover,
                        errorBuilder: (_, __, ___) =>
                            _placeholder(),
                      )
                    : _placeholder(),
              ),

              // Product details
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.all(12),
                  child: Column(
                    crossAxisAlignment:
                        CrossAxisAlignment.start,
                    children: [
                      // Title + match score
                      Row(
                        crossAxisAlignment:
                            CrossAxisAlignment.start,
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
                          _buildScoreBadge(int.parse(score)),
                        ],
                      ),
                      const SizedBox(height: 4),

                      // Category
                      Text(
                        product['category'] ?? '',
                        style: const TextStyle(
                            color: Colors.white38,
                            fontSize: 12),
                      ),
                      const SizedBox(height: 6),

                      // Dimensions
                      if (dimensions != null)
                        _buildDimensionsRow(dimensions),

                      const SizedBox(height: 6),

                      // Color swatch
                      if (dominantColor != null &&
                          dominantColor.length == 3)
                        _buildColorSwatch(dominantColor),

                      const SizedBox(height: 8),

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
                            _buildARButton(
                                context, model3D!['url']),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ],
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
        border:
            Border.all(color: badgeColor.withOpacity(0.5)),
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

  Widget _buildDimensionsRow(Map<String, dynamic> dimensions) {
    final unit = dimensions['unit'] ?? 'cm';
    return Row(
      children: [
        const Icon(Icons.straighten,
            color: Colors.white24, size: 12),
        const SizedBox(width: 4),
        Text(
          '${dimensions['length']}×${dimensions['width']}×${dimensions['height']} $unit',
          style: const TextStyle(
              color: Colors.white38, fontSize: 11),
        ),
      ],
    );
  }

  Widget _buildColorSwatch(List<dynamic> rgb) {
    final color = Color.fromRGBO(
      (rgb[0] as num).toInt(),
      (rgb[1] as num).toInt(),
      (rgb[2] as num).toInt(),
      1,
    );
    return Row(
      children: [
        Container(
          width: 14,
          height: 14,
          decoration: BoxDecoration(
            color: color,
            shape: BoxShape.circle,
            border: Border.all(
                color: Colors.white24, width: 1),
          ),
        ),
        const SizedBox(width: 6),
        const Text(
          'Dominant color',
          style: TextStyle(
              color: Colors.white38, fontSize: 11),
        ),
      ],
    );
  }

  Widget _buildARButton(BuildContext context, String modelUrl) {
    return GestureDetector(
      onTap: () {
        // ✅ Actually navigate to AR screen
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (_) => ARScreen(modelUrl: modelUrl),
          ),
        );
      },
      child: Container(
        padding: const EdgeInsets.symmetric(
            horizontal: 10, vertical: 6),
        decoration: BoxDecoration(
          color: _accent,
          borderRadius: BorderRadius.circular(8),
        ),
        child: const Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.view_in_ar,
                color: Colors.black, size: 14),
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
    );
  }

  Widget _placeholder() {
    return Container(
      width: 110,
      height: 130,
      color: const Color(0xFF333333),
      child: const Icon(Icons.chair,
          color: Colors.white24, size: 32),
    );
  }
}
