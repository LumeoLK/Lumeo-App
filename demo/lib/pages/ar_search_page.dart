import 'dart:io';
import 'package:camera/camera.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../services/ar_search_service.dart';

class ARSearchPage extends ConsumerStatefulWidget {
  const ARSearchPage({super.key});

  @override
  ConsumerState<ARSearchPage> createState() => _ARSearchPageState();
}

class _ARSearchPageState extends ConsumerState<ARSearchPage> {
  CameraController? _cameraController;
  List<CameraDescription>? _cameras;
  File? _capturedImage;
  bool _cameraReady = false;

  @override
  void initState() {
    super.initState();
    _initCamera();
  }

  Future<void> _initCamera() async {
    try {
      _cameras = await availableCameras();
      if (_cameras!.isEmpty) return;

      _cameraController = CameraController(
        _cameras![0],
        ResolutionPreset.medium,
        enableAudio: false,
      );

      await _cameraController!.initialize();

      if (mounted) {
        setState(() => _cameraReady = true);
      }
    } catch (e) {
      print('Camera init error: $e');
    }
  }

  Future<void> _captureAndSearch() async {
    if (_cameraController == null || !_cameraController!.value.isInitialized) {
      return;
    }

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

  @override
  void dispose() {
    _cameraController?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isLoading = ref.watch(searchLoadingProvider);
    final results = ref.watch(searchResultsProvider);

    return Scaffold(
      backgroundColor: const Color(0xFF1A1A1A),
      appBar: AppBar(
        title: const Text('Find Furniture'),
        backgroundColor: const Color(0xFF1A1A1A),
        foregroundColor: Colors.white,
        elevation: 0,
      ),
      body: Column(
        children: [

          // ── Camera preview or captured image ──────────────────────────
          SizedBox(
            height: 280,
            width: double.infinity,
            child: _capturedImage != null
                ? Image.file(_capturedImage!, fit: BoxFit.cover)
                : _cameraReady
                    ? CameraPreview(_cameraController!)
                    : const Center(
                        child: CircularProgressIndicator(color: Colors.white),
                      ),
          ),

          // ── Scan button ───────────────────────────────────────────────
          Padding(
            padding: const EdgeInsets.all(16),
            child: SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed: isLoading ? null : _captureAndSearch,
                icon: const Icon(Icons.camera_alt),
                label: Text(
                  _capturedImage == null ? 'Scan Room' : 'Scan Again',
                  style: const TextStyle(fontSize: 16),
                ),
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  backgroundColor: Colors.white,
                  foregroundColor: Colors.black,
                  disabledBackgroundColor: Colors.grey,
                ),
              ),
            ),
          ),

          // ── Loading ───────────────────────────────────────────────────
          if (isLoading)
            const Expanded(
              child: Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    CircularProgressIndicator(color: Colors.white),
                    SizedBox(height: 16),
                    Text(
                      'Finding matching furniture...',
                      style: TextStyle(color: Colors.white70),
                    ),
                  ],
                ),
              ),
            ),

          // ── Results ───────────────────────────────────────────────────
          if (!isLoading && results.isNotEmpty)
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    child: Text(
                      '${results.length} matches found',
                      style: const TextStyle(
                          color: Colors.white54, fontSize: 13),
                    ),
                  ),
                  const SizedBox(height: 8),
                  Expanded(
                    child: ListView.builder(
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      itemCount: results.length,
                      itemBuilder: (context, index) {
                        return _ProductCard(product: results[index]);
                      },
                    ),
                  ),
                ],
              ),
            ),

          // ── Empty state ───────────────────────────────────────────────
          if (!isLoading && results.isEmpty && _capturedImage == null && !_cameraReady)
            const Expanded(
              child: Center(
                child: Text(
                  'Initializing camera...',
                  style: TextStyle(color: Colors.white54),
                ),
              ),
            ),
        ],
      ),
    );
  }
}

// ── Product Card ───────────────────────────────────────────────────────────
class _ProductCard extends StatelessWidget {
  final Map<String, dynamic> product;
  const _ProductCard({required this.product});

  @override
  Widget build(BuildContext context) {
    final images = List<String>.from(product['images'] ?? []);
    final dimensions = product['dimensions'] as Map<String, dynamic>?;
    final score = ((product['score'] as num) * 100).toStringAsFixed(0);
    final model3D = product['model3D'] as Map<String, dynamic>?;
    final has3DModel = model3D?['status'] == 'success' &&
        (model3D?['url'] as String?)?.isNotEmpty == true;

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: const Color(0xFF2A2A2A),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          ClipRRect(
            borderRadius: const BorderRadius.only(
              topLeft: Radius.circular(12),
              bottomLeft: Radius.circular(12),
            ),
            child: images.isNotEmpty
                ? Image.network(
                    images[0],
                    width: 110,
                    height: 110,
                    fit: BoxFit.cover,
                    errorBuilder: (_, __, ___) => _placeholder(),
                  )
                : _placeholder(),
          ),
          Expanded(
            child: Padding(
              padding: const EdgeInsets.all(10),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Expanded(
                        child: Text(
                          product['title'] ?? '',
                          style: const TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                            fontSize: 14,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 6, vertical: 2),
                        decoration: BoxDecoration(
                          color: Colors.green.withOpacity(0.15),
                          borderRadius: BorderRadius.circular(4),
                          border: Border.all(
                              color: Colors.greenAccent.withOpacity(0.3)),
                        ),
                        child: Text(
                          '$score%',
                          style: const TextStyle(
                            color: Colors.greenAccent,
                            fontSize: 11,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 4),
                  Text(
                    product['category'] ?? '',
                    style: const TextStyle(
                        color: Colors.white38, fontSize: 12),
                  ),
                  const SizedBox(height: 4),
                  if (dimensions != null)
                    Text(
                      '${dimensions['length']} × ${dimensions['width']} × ${dimensions['height']} ${dimensions['unit'] ?? 'cm'}',
                      style: const TextStyle(
                          color: Colors.white24, fontSize: 11),
                    ),
                  const SizedBox(height: 8),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        '\$${product['price']}',
                        style: const TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                          fontSize: 15,
                        ),
                      ),
                      if (has3DModel)
                        GestureDetector(
                          onTap: () {
                            print('View in AR: ${product['title']}');
                            print('Model URL: ${model3D?['url']}');
                          },
                          child: Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 10, vertical: 5),
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(6),
                            ),
                            child: const Text(
                              'View in AR',
                              style: TextStyle(
                                color: Colors.black,
                                fontSize: 12,
                                fontWeight: FontWeight.bold,
                              ),
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

  Widget _placeholder() {
    return Container(
      width: 110,
      height: 110,
      color: const Color(0xFF333333),
      child: const Icon(Icons.chair, color: Colors.white24, size: 32),
    );
  }
}