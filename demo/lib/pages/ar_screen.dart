import 'package:flutter/material.dart';
import 'package:flutter_embed_unity/flutter_embed_unity.dart';
import '../services/model_downloader.dart';

class ARScreen extends StatefulWidget {
  final String modelUrl;
  const ARScreen({super.key, required this.modelUrl});

  @override
  State<ARScreen> createState() => _ARScreenState();
}

class _ARScreenState extends State<ARScreen> {
  static bool _hasUnityEverLoaded = false;
  bool _isUnityLoaded = _hasUnityEverLoaded;
  bool _isDownloading = false;
  bool _isModelPlaced = false;
  bool _isScanning = true;
  double _downloadProgress = 0;
  String? _localModelPath;
  String? _errorMessage;
  double _currentRotation = 0;
  bool _showStatusMessage = true;
  bool _hasTappedOnce = false;
  String _displayMessage = "Scanning for surfaces...";

  @override
  void initState() {
    super.initState();
    _downloadModel();
  }

  Future<void> _downloadModel() async {
    if (widget.modelUrl.isEmpty) {
      setState(() {
        _errorMessage = '3D model not available for this product.';
        _isDownloading = false;
      });
      return;
    }

    setState(() => _isDownloading = true);

    try {
      final path = await ModelDownloader.downloadModel(
        widget.modelUrl,
        onProgress: (received, total) {
          if (total > 0) {
            setState(() => _downloadProgress = received / total);
          }
        },
      );

      setState(() {
        _localModelPath = path;
        _isDownloading = false;
      });

      // If Unity already loaded send model immediately
      if (_isUnityLoaded) {
        sendToUnity('ModelLoader', 'LoadModelFromPath', path);
      }
    } catch (e) {
      setState(() {
        _errorMessage = 'Failed to download model: $e';
        _isDownloading = false;
      });
    }
  }

  void _onUnityMessage(String message) {
    if (message == 'scene_loaded') {
      _hasUnityEverLoaded = true;
      setState(() => _isUnityLoaded = true);
      if (_localModelPath != null) {
        sendToUnity('ModelLoader', 'LoadModelFromPath', _localModelPath!);
      }
    }

    if (message == 'plane_detected' && _isScanning) {
      setState(() {
        _isScanning = false;
        _displayMessage = "Surface detected!";
      });
      Future.delayed(const Duration(seconds: 2), () {
        if (mounted) {
          setState(() => _showStatusMessage = false);
        }
      });
    }

    if (message == 'object_placed') {
      setState(() {
        _isModelPlaced = true;
        _showStatusMessage = false;
      });
    }
  }

  void _onTap(TapDownDetails details, BuildContext context) {
    if (!_hasTappedOnce) {
      setState(() {
        _hasTappedOnce = true;
        _showStatusMessage = false;
      });
    }
    final size = MediaQuery.of(context).size;
    final x = details.globalPosition.dx / size.width;
    final y = details.globalPosition.dy / size.height;
    sendToUnity('XR_Origin', 'OnTapFromFlutter', '$x,$y');
  }

  void _rotate(double degrees) {
    setState(() => _currentRotation += degrees);
    sendToUnity('ModelLoader', 'RotateModel', degrees.toString());
  }

  void _reset() {
    setState(() {
      _currentRotation = 0;
      _isModelPlaced = false;
      _isScanning = true;
      _showStatusMessage = true;
      _hasTappedOnce = false;
      _displayMessage = "Scanning for surfaces...";
    });
    sendToUnity('ModelLoader', 'ResetModel', '');
  }

  @override
  Widget build(BuildContext context) {
    if (_isDownloading) {
      return Scaffold(
        backgroundColor: Colors.black,
        appBar: AppBar(
          backgroundColor: Colors.transparent,
          title: const Text('AR View',
              style: TextStyle(color: Colors.white)),
          leading: IconButton(
            icon: const Icon(Icons.arrow_back, color: Colors.white),
            onPressed: () => Navigator.pop(context),
          ),
        ),
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Text('Downloading 3D Model...',
                  style: TextStyle(color: Colors.white, fontSize: 18)),
              const SizedBox(height: 24),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 40),
                child: LinearProgressIndicator(
                  value: _downloadProgress,
                  color: const Color(0xFFFDB04B),
                  backgroundColor: Colors.white24,
                  minHeight: 6,
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
              const SizedBox(height: 12),
              Text(
                '${(_downloadProgress * 100).toStringAsFixed(0)}%',
                style: const TextStyle(
                    color: Colors.white70, fontSize: 14),
              ),
            ],
          ),
        ),
      );
    }

    if (_errorMessage != null) {
      return Scaffold(
        backgroundColor: Colors.black,
        appBar: AppBar(
          backgroundColor: Colors.transparent,
          title: const Text('AR View',
              style: TextStyle(color: Colors.white)),
          leading: IconButton(
            icon: const Icon(Icons.arrow_back, color: Colors.white),
            onPressed: () => Navigator.pop(context),
          ),
        ),
        body: Center(
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(Icons.error_outline,
                    color: Colors.red, size: 48),
                const SizedBox(height: 16),
                Text(
                  _errorMessage!,
                  style: const TextStyle(
                      color: Colors.white, fontSize: 15),
                  textAlign: TextAlign.center,
                ),
              ],
            ),
          ),
        ),
      );
    }

    return Scaffold(
      backgroundColor: Colors.black,
      body: Stack(
        children: [
          // ✅ Unity AR view — full screen
          GestureDetector(
            onTapDown: (details) {
              if (!_isModelPlaced) {
                _onTap(details, context);
              }
            },
            child: EmbedUnity(onMessageFromUnity: _onUnityMessage),
          ),

          // Back button
          Positioned(
            top: 0,
            left: 16,
            child: SafeArea(
              child: GestureDetector(
                onTap: () => Navigator.pop(context),
                child: Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: Colors.black.withOpacity(0.5),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(Icons.arrow_back,
                      color: Colors.white),
                ),
              ),
            ),
          ),

          // Loading overlay
          if (!_isUnityLoaded)
            Container(
              color: Colors.black87,
              child: const Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    CircularProgressIndicator(
                        color: Color(0xFFFDB04B)),
                    SizedBox(height: 16),
                    Text('Initializing AR...',
                        style: TextStyle(
                            color: Colors.white, fontSize: 18)),
                  ],
                ),
              ),
            ),

          // Status message
          if (_isUnityLoaded && _showStatusMessage)
            Positioned(
              top: 60,
              left: 40,
              right: 40,
              child: AnimatedOpacity(
                duration: const Duration(milliseconds: 500),
                opacity: _showStatusMessage ? 1.0 : 0.0,
                child: Container(
                  padding: const EdgeInsets.symmetric(
                      vertical: 12, horizontal: 20),
                  decoration: BoxDecoration(
                    color: Colors.black54,
                    borderRadius: BorderRadius.circular(30),
                    border: Border.all(color: Colors.white10),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      if (_isScanning)
                        const SizedBox(
                          width: 16,
                          height: 16,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            color: Color(0xFFFDB04B),
                          ),
                        ),
                      if (!_isScanning)
                        const Icon(Icons.check_circle,
                            color: Color(0xFFFDB04B), size: 18),
                      const SizedBox(width: 12),
                      Text(
                        _displayMessage,
                        style: const TextStyle(
                            color: Colors.white, fontSize: 14),
                      ),
                    ],
                  ),
                ),
              ),
            ),

          // Rotation control bar
          if (_isModelPlaced)
            Positioned(
              bottom: 30,
              left: 20,
              right: 20,
              child: Column(
                children: [
                  Text(
                    '${_currentRotation.toStringAsFixed(0)}°',
                    style: const TextStyle(
                        color: Colors.white70, fontSize: 14),
                  ),
                  const SizedBox(height: 10),
                  Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 16, vertical: 12),
                    decoration: BoxDecoration(
                      color: Colors.black.withOpacity(0.75),
                      borderRadius: BorderRadius.circular(30),
                      border: Border.all(
                          color: Colors.white12, width: 1),
                    ),
                    child: Row(
                      mainAxisAlignment:
                          MainAxisAlignment.spaceEvenly,
                      children: [
                        _buildControlButton(
                          icon: Icons.rotate_left,
                          label: '45°',
                          onTap: () => _rotate(-45),
                        ),
                        _buildControlButton(
                          icon: Icons.rotate_left,
                          label: '15°',
                          onTap: () => _rotate(-15),
                        ),
                        GestureDetector(
                          onTap: _reset,
                          child: Container(
                            padding: const EdgeInsets.all(12),
                            decoration: const BoxDecoration(
                              color: Color(0xFFFDB04B),
                              shape: BoxShape.circle,
                            ),
                            child: const Icon(Icons.refresh,
                                color: Colors.black, size: 22),
                          ),
                        ),
                        _buildControlButton(
                          icon: Icons.rotate_right,
                          label: '15°',
                          onTap: () => _rotate(15),
                        ),
                        _buildControlButton(
                          icon: Icons.rotate_right,
                          label: '45°',
                          onTap: () => _rotate(45),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildControlButton({
    required IconData icon,
    required String label,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding:
            const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        decoration: BoxDecoration(
          color: Colors.white10,
          borderRadius: BorderRadius.circular(20),
        ),
        child: Row(
          children: [
            Icon(icon, color: Colors.white, size: 18),
            const SizedBox(width: 4),
            Text(label,
                style: const TextStyle(
                    color: Colors.white, fontSize: 12)),
          ],
        ),
      ),
    );
  }
}
