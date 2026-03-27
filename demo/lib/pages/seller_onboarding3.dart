
import 'package:flutter/material.dart';
import 'package:video_player/video_player.dart';
import 'seller-registration_info.dart';
class SellerOnboardingPage3 extends StatefulWidget {
  const SellerOnboardingPage3({super.key});

  @override
  State<SellerOnboardingPage3> createState() => _SellerOnboardingPageState();
}

class _SellerOnboardingPageState extends State<SellerOnboardingPage3> {
  // video manager
  late VideoPlayerController _videoController;

  @override
  void initState() {
    super.initState();

    // load video from asset folder
    _videoController = VideoPlayerController.asset('assets/videos/loop.mp4')
    ..setVolume(0)
    ..setLooping(true)
    ..initialize().then((_) {

        setState(() {});
        _videoController.play();
      });
  }

  @override
  void dispose() {
    // always clean the controller when leaving the page
    _videoController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black, // fallback color while video loads
      body: Stack(
        //using stack lets layer widgets on top of each other
        children: [
          //LAYER 1: Background Video 
          if (_videoController.value.isInitialized)
            SizedBox.expand(
              //fill the whole screen with video
              child: FittedBox(
                fit: BoxFit.cover, //crop to fill
                child: SizedBox(
                  width: _videoController.value.size.width,
                  height: _videoController.value.size.height,
                  child: VideoPlayer(_videoController),
                ),
              ),
            ),

          //LAYER 2: dark overlay to read text
          Container(
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [
                  Colors.transparent,          // top: full transparent
                  Color(0xCC000000),            // bottom: semi dark black
                ],
                stops: [0.4, 1.0],             // gradient starts at 40% down
              ),
            ),
          ),

          //LAYER 3: Text+Button
          SafeArea(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.end, // push content to bottom
              children: [
                // Title
                const Text(
                  'Blueprint to 3D Model',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 26,
                    fontWeight: FontWeight.bold,
                  ),
                  textAlign: TextAlign.center,
                ),

                const SizedBox(height: 12), //space between title and subtitle

                //Subtitle
                const Padding(
                padding: EdgeInsets.symmetric(horizontal: 40),
                child: 
                    Text("Sellers can turn furniture blueprints into detailed 3D models, ready for AR previews and custom orders.",
                    style: TextStyle(
                    color: Colors.white70,
                    fontSize: 15,
                    height: 1.5,
                    ),
                    textAlign: TextAlign.center,
                ),
                ),

                const SizedBox(height: 32),

                //NEXT Button
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 40),
                  child: SizedBox(
                    width: double.infinity, //full width button
                    height: 54,
                    child: ElevatedButton(
                      onPressed: () {  //go to page 3
                        Navigator.push(
                        context,
                        MaterialPageRoute(builder:(_)=> const SellerRegistrationInfoScreen()),
                        );
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFFFBB040), 
                        foregroundColor: Colors.black,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(30), //pill shape
                        ),
                        elevation: 0,
                      ),
                      child: const Text(
                        'CONTINUE',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          letterSpacing: 1.5,
                        ),
                      ),
                    ),
                  ),
                ),

                const SizedBox(height: 40), //space from bottom
              ],
            ),
          ),
        ],
      ),
    );
  }
}