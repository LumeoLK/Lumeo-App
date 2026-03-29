import 'package:flutter/material.dart';
import 'package:model_viewer_plus/model_viewer_plus.dart';
import 'package:image_picker/image_picker.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'dart:io';

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

class _BlueprintContentState extends State<BlueprintContent> {
  // YOUR BACKEND URL
  final String backendUrl = "https://your-backend-url.com";

  File? _selectedFile;
  String _status = 'idle'; // idle, uploading, processing, complete, failed
  String? _model3DUrl;
  String? _jobId;

  final ImagePicker _picker = ImagePicker();

  Future<void> _pickImage() async {
    final picked = await _picker.pickImage(source: ImageSource.gallery);
    if (picked != null) {
      setState(() {
        _selectedFile = File(picked.path);
        _status = 'idle';
        _model3DUrl = null;
      });
    }
  }

  Future<void> _startProcessing() async {
    if (_selectedFile == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Please upload a blueprint first!")),
      );
      return;
    }

    setState(() => _status = 'uploading');

    try {
      // 1️⃣ Upload blueprint to backend
      final request = http.MultipartRequest(
        'POST',
        Uri.parse('$backendUrl/api/blueprint/create'),
      );
      request.files.add(
        await http.MultipartFile.fromPath('blueprint', _selectedFile!.path),
      );

      final response = await request.send();
      final body = json.decode(await response.stream.bytesToString());

      if (response.statusCode != 200) {
        setState(() => _status = 'failed');
        return;
      }

      _jobId = body['jobId'];
      setState(() => _status = 'processing');

      // 2️⃣ Poll for job completion
      await _pollJobStatus(_jobId!);
    } catch (e) {
      setState(() => _status = 'failed');
    }
  }

  Future<void> _pollJobStatus(String jobId) async {
    // Poll every 5 seconds for up to 10 minutes
    for (int i = 0; i < 120; i++) {
      await Future.delayed(const Duration(seconds: 5));

      try {
        final response = await http.get(
          Uri.parse('$backendUrl/api/blueprint/status/$jobId'),
        );
        final body = json.decode(response.body);

        if (body['status'] == 'completed') {
          setState(() {
            _status = 'complete';
            _model3DUrl = body['model3DUrl'];
          });
          return;
        } else if (body['status'] == 'failed') {
          setState(() => _status = 'failed');
          return;
        }
      } catch (e) {
        continue;
      }
    }

    setState(() => _status = 'failed');
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
            style: TextStyle(color: Colors.grey, fontSize: 14),
          ),
          const SizedBox(height: 25),

          // Upload Card
          GestureDetector(
            onTap: _pickImage,
            child: Container(
              height: 150,
              width: double.infinity,
              decoration: BoxDecoration(
                color: Colors.grey[900],
                borderRadius: BorderRadius.circular(20),
                border: _selectedFile != null
                    ? Border.all(color: Colors.orange, width: 2)
                    : null,
              ),
              child: _selectedFile != null
                  ? ClipRRect(
                      borderRadius: BorderRadius.circular(20),
                      child: Image.file(_selectedFile!, fit: BoxFit.cover),
                    )
                  : const Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          CircleAvatar(
                            radius: 24,
                            backgroundColor: Colors.orange,
                            child: Icon(
                              Icons.upload,
                              color: Colors.white,
                              size: 26,
                            ),
                          ),
                          SizedBox(height: 10),
                          Text(
                            "Upload Blueprint",
                            style: TextStyle(
                              color: Colors.orange,
                              fontSize: 18,
                            ),
                          ),
                          Text(
                            "(JPG, PNG)",
                            style: TextStyle(color: Colors.grey),
                          ),
                        ],
                      ),
                    ),
            ),
          ),

          const SizedBox(height: 25),

          // Convert Button
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.orange,
              padding: const EdgeInsets.symmetric(horizontal: 60, vertical: 15),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(30),
              ),
            ),
            onPressed: _status == 'idle' || _status == 'failed'
                ? _startProcessing
                : null,
            child: const Text(
              "CONVERT TO 3D",
              style: TextStyle(
                color: Colors.black,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),

          const SizedBox(height: 20),

          // Status Bar
          if (_status != 'idle') _buildStatusBar(),

          const SizedBox(height: 20),
          const Text(
            "Preview 3D Model",
            style: TextStyle(
              color: Colors.orange,
              fontSize: 18,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 15),

          // 3D Preview
          Container(
            height: 260,
            width: double.infinity,
            decoration: BoxDecoration(
              color: Colors.grey[900],
              borderRadius: BorderRadius.circular(20),
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(20),
              child: _model3DUrl != null
                  ? ModelViewer(
                      src: _model3DUrl!,
                      alt: "3D Model",
                      autoRotate: true,
                      cameraControls: true,
                      backgroundColor: Colors.transparent,
                    )
                  : const Center(
                      child: Text(
                        "3D model will appear here",
                        style: TextStyle(color: Colors.grey),
                      ),
                    ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatusBar() {
    String label;
    Color color;

    switch (_status) {
      case 'uploading':
        label = 'Uploading blueprint...';
        color = Colors.blue;
        break;
      case 'processing':
        label = 'Generating 3D model... (this may take a few minutes)';
        color = Colors.orange;
        break;
      case 'complete':
        label = 'Processing Complete ✓';
        color = Colors.green;
        break;
      case 'failed':
        label = 'Failed. Please try again.';
        color = Colors.red;
        break;
      default:
        label = '';
        color = Colors.grey;
    }

    return Container(
      height: 48,
      width: double.infinity,
      decoration: BoxDecoration(
        color: Colors.grey[900],
        borderRadius: BorderRadius.circular(12),
      ),
      child: Center(
        child: _status == 'processing'
            ? Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const SizedBox(
                    width: 16,
                    height: 16,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      color: Colors.orange,
                    ),
                  ),
                  const SizedBox(width: 10),
                  Text(label, style: TextStyle(color: color, fontSize: 13)),
                ],
              )
            : Text(
                label,
                style: TextStyle(
                  color: color,
                  fontWeight: FontWeight.w500,
                  fontSize: 14,
                ),
              ),
      ),
    );
  }
}
