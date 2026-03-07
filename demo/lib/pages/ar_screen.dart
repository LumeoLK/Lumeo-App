import 'package:flutter/material.dart';
import 'package:flutter_embed_unity/flutter_embed_unity.dart';

class ARScreen extends StatefulWidget {
  const ARScreen({super.key});

  @override
  State<ARScreen> createState() => _ARScreenState();
}

class _ARScreenState extends State<ARScreen> {
  bool _isUnityLoaded = false;

  void _onTap(TapDownDetails details, BuildContext context) {
    final size = MediaQuery.of(context).size;
    final x = details.globalPosition.dx / size.width;
    final y = details.globalPosition.dy / size.height;

    sendToUnity('XR_Origin', 'OnTapFromFlutter', '$x,$y');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('AR View'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: Stack(
        children: [
          GestureDetector(
            onTapDown: (details) => _onTap(details, context),
            child: EmbedUnity(
              onMessageFromUnity: (message) {
                if (message == 'scene_loaded') {
                  setState(() => _isUnityLoaded = true);
                }
              },
            ),
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
