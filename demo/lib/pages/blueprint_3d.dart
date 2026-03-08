import 'package:flutter/material.dart';
import 'package:model_viewer_plus/model_viewer_plus.dart';

class Blueprint3DScreen extends StatelessWidget {
  const Blueprint3DScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0F0F0F),
      appBar: AppBar(
        title: const Text(
          "Blueprint 3D",
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        ),
        centerTitle: true,
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
        actions: const [
          Padding(
            padding: EdgeInsets.only(right: 16),
            child: Icon(Icons.notifications_outlined, color: Colors.white),
          ),
        ],
      ),
      body: const BlueprintContent(),
    );
  }
}

class BlueprintContent extends StatefulWidget {
  const BlueprintContent({super.key});

  @override
  State<BlueprintContent> createState() => _BlueprintContentState();
}

class _BlueprintContentState extends State<BlueprintContent>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _progressAnimation;

  // States: idle, processing, complete
  String _status = 'idle';

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 3),
    );
    _progressAnimation = Tween<double>(begin: 0, end: 1).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeInOut),
    );

    _controller.addStatusListener((status) {
      if (status == AnimationStatus.completed) {
        setState(() => _status = 'complete');
      }
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _startProcessing() {
    if (_status == 'processing') return;
    setState(() => _status = 'processing');
    _controller.forward(from: 0);
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          const SizedBox(height: 10),
          const Text(
            "Upload a furniture blueprint to automatically\nturn it into a 3D preview model.",
            textAlign: TextAlign.center,
            style: TextStyle(
              color: Colors.grey,
              fontSize: 14,
            ),
          ),

          SizedBox(height: 25),

          UploadBlueprintCard(),

          SizedBox(height: 25),

          ConvertButton(),

          SizedBox(height: 20),

          ProcessingStatus(),

          SizedBox(height: 20),

          Text(
            "Preview 3D Model",
            style: TextStyle(
              color: Colors.orange,
              fontSize: 18,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 15),
          const Preview3DBox(),
        ],
      ),
    );
  }
}

class UploadBlueprintCard extends StatelessWidget {
  const UploadBlueprintCard({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 150,
      width: double.infinity,
      decoration: BoxDecoration(
        color: Colors.grey[900],
        borderRadius: BorderRadius.circular(20),
      ),
      child: const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.upload, color: Colors.orange, size: 40),
            SizedBox(height: 10),
            Text(
              "Upload Blueprint",
              style: TextStyle(
                color: Colors.orange,
                fontSize: 18,
              ),
            ),
            Text(
              "(JPG, PNG, PDF)",
              style: TextStyle(color: Colors.grey),
            )
          ],
        ),
      ),
    );
  }
}

class ConvertButton extends StatelessWidget {
  final VoidCallback onPressed;
  const ConvertButton({super.key, required this.onPressed});

  @override
  Widget build(BuildContext context) {
    return ElevatedButton(
      style: ElevatedButton.styleFrom(
        backgroundColor: Colors.orange,
        padding: const EdgeInsets.symmetric(horizontal: 60, vertical: 15),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
      ),
      onPressed: () {},
      child: const Text(
        "CONVERT TO 3D",
        style: TextStyle(color: Colors.black),
      ),
    );
  }
}

class ProcessingStatus extends StatelessWidget {
  const ProcessingStatus({super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: const [
        CircularProgressIndicator(color: Colors.orange),
        SizedBox(height: 10),
        Text(
          "Processing Blueprint...",
          style: TextStyle(color: Colors.grey),
        ),
      ],
    );
  }
}

class Preview3DBox extends StatelessWidget {
  const Preview3DBox({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 260,
      width: double.infinity,
      decoration: BoxDecoration(
        color: Colors.grey[900],
        borderRadius: BorderRadius.circular(20),
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(20),
        child: const ModelViewer(
          src: 'https://modelviewer.dev/shared-assets/models/Astronaut.glb',
          alt: "3D Model",
          autoRotate: true,
          cameraControls: true,
          backgroundColor: Colors.transparent,
        ),
      ),
    );
  }
}
