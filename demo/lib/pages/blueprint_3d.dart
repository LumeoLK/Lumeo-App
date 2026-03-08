import 'package:flutter/material.dart';
import 'package:model_viewer_plus/model_viewer_plus.dart';

class Blueprint3DScreen extends StatelessWidget {
  const Blueprint3DScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0F0F0F),
      appBar: AppBar(
        title: const Text("Blueprint 3D"),
        centerTitle: true,
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      body: const BlueprintContent(),
    );
  }
}

class BlueprintContent extends StatelessWidget {
  const BlueprintContent({super.key});

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        children: const [
          SizedBox(height: 10),

          Text(
            "Upload a furniture blueprint to automatically\nturn it into a 3D preview model.",
            textAlign: TextAlign.center,
            style: TextStyle(color: Colors.grey, fontSize: 14),
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

          SizedBox(height: 15),

          Preview3DBox(),
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
              style: TextStyle(color: Colors.orange, fontSize: 18),
            ),
            Text("(JPG, PNG, PDF)", style: TextStyle(color: Colors.grey)),
          ],
        ),
      ),
    );
  }
}

class ConvertButton extends StatelessWidget {
  const ConvertButton({super.key});

  @override
  Widget build(BuildContext context) {
    return ElevatedButton(
      style: ElevatedButton.styleFrom(
        backgroundColor: Colors.orange,
        padding: const EdgeInsets.symmetric(horizontal: 60, vertical: 15),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
      ),
      onPressed: () {},
      child: const Text("CONVERT TO 3D", style: TextStyle(color: Colors.black)),
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
        Text("Processing Blueprint...", style: TextStyle(color: Colors.grey)),
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
          src:'https://res.cloudinary.com/drno34my4/raw/upload/v1772814761/lumeo_3d_models/product_69ab009a6ee07aee64699fea.glb',
          alt: "3D Model",
          autoRotate: true,
          cameraControls: true,
          backgroundColor: Colors.transparent,
        ),
      ),
    );
  }
}
