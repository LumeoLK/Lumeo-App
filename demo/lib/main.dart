import 'package:flutter/material.dart';
import 'package:flutter_embed_unity/flutter_embed_unity.dart';

void main() => runApp(const MyApp());

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'AR Furniture',
      home: const HomeScreen(),
    );
  }
}

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('AR Furniture App')),
      body: Center(
        child: ElevatedButton(
          onPressed: () {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => const UnityScreen()),
            );
          },
          style: ElevatedButton.styleFrom(
            padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 20),
          ),
          child: const Text('Open AR Camera'),
        ),
      ),
    );
  }
}

class UnityScreen extends StatefulWidget {
  const UnityScreen({super.key});

  @override
  State<UnityScreen> createState() => _UnityScreenState();
}

class _UnityScreenState extends State<UnityScreen> {
  bool _isUnityLoaded = false;

  void _onTap(TapDownDetails details, BuildContext context) {
    final size = MediaQuery.of(context).size;
    final x = details.globalPosition.dx / size.width;
    final y = details.globalPosition.dy / size.height;
    
    print('Flutter: Sending tap to Unity: $x, $y');
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
                print('Flutter: Message from Unity: $message');
                if (message == 'scene_loaded') {
                  setState(() {
                    _isUnityLoaded = true;
                  });
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