import 'package:flutter/material.dart';
import 'package:video_player/video_player.dart';
import 'onboarding_page2.dart';

class OnboardingPage1 extends StatefulWidget {
  const OnboardingPage1({super.key});

  @override
  State<OnboardingPage1> createState() => _OnboardingPage1State();
}

class _OnboardingPage1State extends State<OnboardingPage1> {
  late VideoPlayerController _controller;
  bool _initialized = false;

  @override
  void initState() {
    super.initState();

    // Use an asset video (placed at assets/videos/bg.mp4)
    _controller = VideoPlayerController.asset('assets/videos/loop.mp4')
      ..setLooping(true)
      ..initialize().then((_) {
        // Once the video is initialized we start playing
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
      // Make the scaffold background transparent so the video is visible
      backgroundColor: Colors.black,
      body: Stack(
        children: [
          // 1) Video background (cover)
          Positioned.fill(
            child: _initialized
                ? FittedBox(
                    fit: BoxFit.cover,
                    alignment: Alignment.center,
                    child: SizedBox(
                      width: _controller.value.size.width,
                      height: _controller.value.size.height,
                      child: VideoPlayer(_controller),
                    ),
                  )
                : Container(color: Colors.black), // fallback while loading
          ),

          // 2) Optional overlay to darken the video for better contrast
          Positioned.fill(
            child: Container(
              color: Colors.black.withOpacity(0.35), // adjust opacity if needed
            ),
          ),

          // 3) Foreground UI (logo and button)
          SafeArea(
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                children: [
                  const Spacer(),

                  // Replace LUMEO text with image (logo)
                  Center(
                    child: Image.asset(
                      'assets/images/lumeo_transparent.png',
                      width: 180, // adjust to taste
                      height: 80,
                      fit: BoxFit.contain,
                    ),
                  ),

                  const SizedBox(height: 18),

                  const Text(
                    "Transform",
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 22,
                      fontWeight: FontWeight.w500,
                    ),
                  ),

                  const SizedBox(height: 8),

                  const Text(
                    "The Way You Shop Furniture\nPowered by AR & AI.",
                    textAlign: TextAlign.center,
                    style: TextStyle(color: Colors.white70, fontSize: 15),
                  ),

                  const Spacer(),

                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => const OnboardingPage2(),
                          ),
                        );
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.orange,
                        padding: const EdgeInsets.symmetric(vertical: 14),
                      ),
                      child: const Text(
                        "Next",
                        style: TextStyle(fontSize: 16, color: Colors.black),
                      ),
                    ),
                  ),

                  const SizedBox(height: 40),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
