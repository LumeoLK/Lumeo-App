import 'package:flutter/material.dart';
import 'package:flutter_embed_unity/flutter_embed_unity.dart';
import '../services/model_downloader.dart';

class ARScreen extends StatefulWidget {
  final String modelUrl; // 👈 passed in from product page

  const ARScreen({super.key, required this.modelUrl});

  @override
  State<ARScreen> createState() => _ARScreenState();
}

class _ARScreenState extends State<ARScreen> {
  bool _isUnityLoaded = false;
  bool _isDownloading = false;
  double _downloadProgress = 0;
  String? _localModelPath;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    _downloadModel();
  }

  Future<void> _downloadModel() async {
    setState(() => _isDownloading = true);

    try {
      final path = await ModelDownloader.downloadModel(
        widget.modelUrl,
        onProgress: (received, total) {
          if (total > 0) {
            setState(() {
              _downloadProgress = received / total;
            });
          }
        },
      );
      setState(() {
        _localModelPath = path;
        _isDownloading = false;
      });
    } catch (e) {
      setState(() {
        _errorMessage = 'Failed to download model: $e';
        _isDownloading = false;
      });
    }
  }

  void _onTap(TapDownDetails details, BuildContext context) {
    final size = MediaQuery.of(context).size;
    final x = details.globalPosition.dx / size.width;
    final y = details.globalPosition.dy / size.height;
    sendToUnity('XR_Origin', 'OnTapFromFlutter', '$x,$y');
  }

  // Called once Unity finishes loading — we then send the model path
  void _onUnityMessage(String message) {
    if (message == 'scene_loaded') {
      setState(() => _isUnityLoaded = true);

      // 👇 Send the local .glb path to Unity
      if (_localModelPath != null) {
        sendToUnity('ModelLoader', 'LoadModelFromPath', _localModelPath!);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    // Show download progress before opening Unity
    if (_isDownloading) {
      return Scaffold(
        backgroundColor: Colors.black,
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Text(
                'Downloading 3D Model...',
                style: TextStyle(color: Colors.white, fontSize: 18),
              ),
              const SizedBox(height: 24),
              SizedBox(
                width: 200,
                child: LinearProgressIndicator(
                  value: _downloadProgress,
                  color: Colors.blueAccent,
                  backgroundColor: Colors.white24,
                ),
              ),
              const SizedBox(height: 12),
              Text(
                '${(_downloadProgress * 100).toStringAsFixed(0)}%',
                style: const TextStyle(color: Colors.white70),
              ),
            ],
          ),
        ),
      );
    }

    // Show error if download failed
    if (_errorMessage != null) {
      return Scaffold(
        body: Center(
          child: Text(
            _errorMessage!,
            style: const TextStyle(color: Colors.red),
          ),
        ),
      );
    }

    // Show AR view
    return Scaffold(
      appBar: AppBar(title: const Text('AR View')),
      body: Stack(
        children: [
          GestureDetector(
            onTapDown: (details) => _onTap(details, context),
            child: EmbedUnity(onMessageFromUnity: _onUnityMessage),
          ),
          if (!_isUnityLoaded)
            Container(
              color: Colors.black54,
              child: const Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    CircularProgressIndicator(color: Colors.white),
                    SizedBox(height: 16),
                    Text(
                      'Loading AR...',
                      style: TextStyle(color: Colors.white, fontSize: 18),
                    ),
                  ],
                ),
              ),
            ),
        ],
      ),
    );
  }
}
