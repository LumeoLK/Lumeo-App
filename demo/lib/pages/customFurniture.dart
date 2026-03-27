import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:lumeo_v2/widgets/secondary_app_bar.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:lumeo_v2/providers/auth_provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:image_picker/image_picker.dart';
import 'package:lumeo_v2/widgets/login_required_dialog.dart';
import 'dart:convert';
import 'dart:io';

import '../Constants.dart';
import '../providers/custom_request_provider.dart';

class CustomFurniturePage extends ConsumerStatefulWidget {
  const CustomFurniturePage({super.key});

  @override
  ConsumerState<CustomFurniturePage> createState() =>
      _CustomFurniturePageState();
}

class _CustomFurniturePageState extends ConsumerState<CustomFurniturePage> {
  final TextEditingController _titleController = TextEditingController();
  final TextEditingController _descriptionController = TextEditingController();
  final TextEditingController _budgetController = TextEditingController();
  final bool _isSubmitting = false;
  final String _searchQuery = '';
  final ImagePicker _picker = ImagePicker();
  File? _image1;
  File? _image2;
  bool _isLoggedIn = false;

  bool _matchesSearch(String input) {
    if (_searchQuery.isEmpty) return true;
    return input.toLowerCase().contains(_searchQuery.toLowerCase());
  }

  @override
  void initState() {
    super.initState();
    Future.microtask(() async {
      await _checkLoginStatus();
    });
  }

  Future<void> _checkLoginStatus() async {
    final user = ref.read(currentUserProvider);
    if (user != null && user.id.isNotEmpty) {
      if (mounted) setState(() => _isLoggedIn = true);
      return;
    }
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('x-auth-token') ?? '';
    if (token.isNotEmpty) {
      if (mounted) setState(() => _isLoggedIn = true);
      return;
    }
    if (mounted) setState(() => _isLoggedIn = false);
  }

  @override
  void dispose() {
    _titleController.dispose();
    _descriptionController.dispose();
    _budgetController.dispose();
    super.dispose();
  }

  Future<void> _pickImage(int imageIndex) async {
    try {
      final XFile? pickedFile = await _picker.pickImage(
        source: ImageSource.gallery,
      );

      if (pickedFile != null) {
        setState(() {
          if (imageIndex == 1) {
            _image1 = File(pickedFile.path);
          } else if (imageIndex == 2) {
            _image2 = File(pickedFile.path);
          }
        });
      }
    } catch (e) {
      print("Error picking image: $e");
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error picking image: $e')),
        );
      }
    }
  }

  Future<void> _submitCustomOrder() async {
    final title = _titleController.text.trim();
    final description = _descriptionController.text.trim();
    final budgetStr = _budgetController.text.trim();
    final budget = double.tryParse(budgetStr);

    if (title.isEmpty || description.isEmpty || budget == null || budget <= 0) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please fill in all fields correctly')),
      );
      return;
    }

    final success = await ref.read(customRequestProvider.notifier).submitRequest(
      title: title,
      description: description,
      budget: budget,
    );

    if (success) {
      if (!mounted) return;
      _titleController.clear();
      _descriptionController.clear();
      _budgetController.clear();
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Custom order submitted successfully!')),
      );
      // Wait a bit and refresh the list
      ref.read(customRequestProvider.notifier).fetchMyRequests();
    } else {
      if (!mounted) return;
      final error = ref.read(customRequestProvider).error ?? 'Failed to submit';
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(error)),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    if (!_isLoggedIn) {
      return Scaffold(
        backgroundColor: Colors.black,
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.receipt_long, color: Colors.grey, size: 64),
              const SizedBox(height: 16),
              const Text(
                'Login to request Custom Orders',
                style: TextStyle(color: Colors.grey, fontSize: 18),
              ),
              const SizedBox(height: 16),
              ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFFFBB040),
                  foregroundColor: Colors.black,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(20),
                  ),
                ),
                onPressed: () => LoginRequiredDialog.show(context),
                child: const Text('Login'),
              ),
            ],
          ),
        ),
      );
    }


    final user = ref.watch(currentUserProvider);
    final hasProfileImage = user != null && user.profilePicture.isNotEmpty;
    final displayName =
      (user != null && user.name.isNotEmpty) ? user.name : 'Guest User';
    final displayEmail =
      (user != null && user.email.isNotEmpty) ? user.email : 'guest@lumeo.app';

    // Define colors from the design
    const Color backgroundColor = Color(0xFF1E1E1E);
    const Color cardColor = Color(0xFF2C2C2C);
    const Color primaryText = Colors.white;
    const Color secondaryText = Colors.white70;
    const Color accentColor = Color(0xFFFBB040); // Orange/Gold

    return Scaffold(
      appBar: AppBar(
        title: const Text(''),
        backgroundColor: Colors.black,
      ),
      backgroundColor: backgroundColor,
      body: SafeArea(
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.all(20.0),

            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,           
              children: [
                // --- Page Title ---
                const Text(
                  "Custom Furniture",
                  style: TextStyle(
                    color: primaryText,
                    fontSize: 28,
                    fontWeight: FontWeight.bold,
                  ),
                ),

                const SizedBox(height: 25),

                // --- User Profile Section ---
                Row(
                  children: [
                    CircleAvatar(
                      radius: 25,
                      backgroundImage:
                          hasProfileImage ? NetworkImage(user.profilePicture) : null,
                      child: !hasProfileImage
                          ? const Icon(Icons.person, color: Colors.white70)
                          : null,
                    ),
                    const SizedBox(width: 15),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          displayName,
                          style: const TextStyle(
                            color: primaryText,
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        Text(
                          displayEmail,
                          style:
                              const TextStyle(color: secondaryText, fontSize: 14),
                        ),
                      ],
                    ),
                  ],
                ),

                const SizedBox(height: 20),

                // --- Helper Text ---
                const Center(
                  child: Text(
                    "Share your design idea and we'll match it with the right shop.",
                    textAlign: TextAlign.center,
                    style: TextStyle(color: secondaryText, fontSize: 14),
                  ),
                ),

                const SizedBox(height: 25),

                if (_matchesSearch("order title") || _matchesSearch("custom"))
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        "Order Title",
                        style: TextStyle(
                          color: primaryText,
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 10),
                      Container(
                        decoration: BoxDecoration(
                          color: cardColor,
                          borderRadius: BorderRadius.circular(15),
                        ),
                        child: TextField(
                          controller: _titleController,
                          style: const TextStyle(color: primaryText),
                          decoration: const InputDecoration(
                            hintText: 'E.g. L-shaped study table',
                            hintStyle: TextStyle(color: Colors.white24, fontSize: 14),
                            border: InputBorder.none,
                            contentPadding: EdgeInsets.all(15),
                          ),
                        ),
                      ),
                      const SizedBox(height: 20),
                    ],
                  ),

                if (_matchesSearch("description") || _matchesSearch("furniture"))
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        "Description",
                        style: TextStyle(
                          color: primaryText,
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 10),
                      Container(
                        decoration: BoxDecoration(
                          color: cardColor,
                          borderRadius: BorderRadius.circular(15),
                        ),
                        child: TextField(
                          controller: _descriptionController,
                          maxLines: 5,
                          style: const TextStyle(color: primaryText),
                          decoration: const InputDecoration(
                            hintText:
                                "Describe the furniture you want. Mention style, purpose, materials, and any special features.",
                            hintStyle: TextStyle(color: Colors.white24, fontSize: 14),
                            border: InputBorder.none,
                            contentPadding: EdgeInsets.all(15),
                          ),
                        ),
                      ),
                      const SizedBox(height: 25),
                    ],
                  ),

                if (_matchesSearch("budget"))
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        "Budget",
                        style: TextStyle(
                          color: primaryText,
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 10),
                      Container(
                        decoration: BoxDecoration(
                          color: cardColor,
                          borderRadius: BorderRadius.circular(15),
                        ),
                        child: TextField(
                          controller: _budgetController,
                          keyboardType: const TextInputType.numberWithOptions(decimal: true),
                          style: const TextStyle(color: primaryText),
                          decoration: const InputDecoration(
                            hintText: 'Enter your budget amount',
                            hintStyle: TextStyle(color: Colors.white24, fontSize: 14),
                            border: InputBorder.none,
                            contentPadding: EdgeInsets.all(15),
                          ),
                        ),
                      ),
                      const SizedBox(height: 25),
                    ],
                  ),

                // --- Upload Image Section ---
                const Text(
                  "Upload Image",
                  style: TextStyle(
                    color: primaryText,
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 5),
                const Text(
                  "Upload your empty space images with different angles and similar products you want",
                  style: TextStyle(color: secondaryText, fontSize: 12),
                ),
                const SizedBox(height: 15),
                Row(
                  children: [
                    _buildUploadBox(cardColor, 1),
                    const SizedBox(width: 15),
                    _buildUploadBox(cardColor, 2),
                  ],
                ),

                const SizedBox(height: 25),

                // --- Measurements Section ---
                const Text(
                  "Measurements",
                  style: TextStyle(
                    color: primaryText,
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 15),

                // Height Row
                Row(
                  children: [
                    const Text(
                      "Height",
                      style: TextStyle(color: primaryText, fontSize: 16),
                    ),
                    const Spacer(),
                    Container(
                      width: 100,
                      height: 40,
                      decoration: BoxDecoration(
                        color: cardColor,
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: const Center(
                        child: Text(
                          "120", // Example value
                          style: TextStyle(color: primaryText),
                        ),
                      ),
                    ),
                    const SizedBox(width: 10),
                    const Text(
                      "cm",
                      style: TextStyle(
                        color: primaryText,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const Icon(Icons.keyboard_arrow_down, color: primaryText),
                  ],
                ),

                const SizedBox(height: 40),

                // --- Submit Button ---
                SizedBox(
                  width: double.infinity,
                  height: 55,

                  child: ElevatedButton(
                    onPressed: _isSubmitting ? null : _submitCustomOrder,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFFE09D3B),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(30),
                      ),
                    ),
                    child: _isSubmitting
                        ? const SizedBox(
                            width: 22,
                            height: 22,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                            ),
                          )
                        : const Text(
                            "Submit Custom Order",
                            style: TextStyle(
                              color: Colors.black87,
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                  ),
                ),

                // Extra padding at bottom for scrolling comfortably
                const SizedBox(height: 20),
              ],
            ),
          ),
        ),
      ),
    );
  }

  // Helper widget for the square upload buttons
  Widget _buildUploadBox(Color color, int imageIndex) {
    File? imageFile = imageIndex == 1 ? _image1 : _image2;
    bool hasImage = imageFile != null;

    return GestureDetector(
      onTap: () => _pickImage(imageIndex),
      child: Container(
        width: 100,
        height: 100,
        decoration: BoxDecoration(
          color: color,
          borderRadius: BorderRadius.circular(15),
          border: hasImage
              ? Border.all(color: const Color(0xFFFBB040), width: 2)
              : null,
        ),
        child: hasImage
            ? ClipRRect(
                borderRadius: BorderRadius.circular(13),
                child: Image.file(
                  imageFile,
                  fit: BoxFit.cover,
                ),
              )
            : const Center(
                child: Icon(Icons.add, color: Colors.white70, size: 30),
              ),
      ),
    );
  }
}
