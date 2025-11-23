import 'package:flutter/material.dart';
import 'package:video_player/video_player.dart';

class OnboardingPage2 extends StatefulWidget {
  const OnboardingPage2({super.key});

  @override
  State<OnboardingPage2> createState() => _OnboardingPage2State();
}

class _OnboardingPage2State extends State<OnboardingPage2> {
  late VideoPlayerController _controller;
  bool _initialized = false;

  @override
  void initState() {
    super.initState();

    // Same video loop as Page 1
    _controller = VideoPlayerController.asset('assets/videos/loop.mp4')
      ..setLooping(true)
      ..initialize().then((_) {
        setState(() {
          _initialized = true;
        });
        _controller.play();
      });
  }

  @override
  void dispose() {
    _controller.pause();
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: Stack(
        children: [
          // 🔹 1) Video Background
          Positioned.fill(
            child: _initialized
                ? FittedBox(
                    fit: BoxFit.cover,
                    child: SizedBox(
                      width: _controller.value.size.width,
                      height: _controller.value.size.height,
                      child: VideoPlayer(_controller),
                    ))
                : Container(color: Colors.black),
          ),

          // 🔹 2) Dark Overlay
          Positioned.fill(
            child: Container(
              color: Colors.black.withOpacity(0.50),
            ),
          ),

          // 🔹 3) Foreground UI
          SafeArea(
            child: Column(
              children: [
                const SizedBox(height: 60),

                // 🔸 Center Text "Try it / Before you / Buy it"
                Column(
                  children: const [
                    Text(
                      "Try it",
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 32,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    SizedBox(height: 4),
                    Text(
                      "Before You",
                      style: TextStyle(
                        color: Colors.white70,
                        fontSize: 16,
                      ),
                    ),
                    SizedBox(height: 4),
                    Text(
                      "Buy it",
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 28,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 40),

                // 🔹 4) Phone + Sofa Image
                Expanded(
                  child: Center(
                    child: Image.asset(
                      "assets/images/img1.png",
                      width: 260,
                      fit: BoxFit.contain,
                    ),
                  ),
                ),

                // 🔹 5) Get Started Button
                Padding(
                  padding: const EdgeInsets.symmetric(
                      horizontal: 20, vertical: 20),
                  child: SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: () {
                        // TODO: Navigate to home or next page
                        print("Get Started pressed");
                      },
                      style: ElevatedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(30),
                        ),
                        backgroundColor: Colors.orange,
                      ),
                      child: const Text(
                        "Get Started",
                        style: TextStyle(fontSize: 16, color: Colors.black),
                      ),
                    ),
                  ),
                ),

                const SizedBox(height: 20),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
