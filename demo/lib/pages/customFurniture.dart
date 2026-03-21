import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:lumeo_v2/widgets/secondary_app_bar.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:lumeo_v2/providers/auth_provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';

import '../Constants.dart';

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
  bool _isSubmitting = false;
  String _searchQuery = '';

  bool _matchesSearch(String input) {
    if (_searchQuery.isEmpty) return true;
    return input.toLowerCase().contains(_searchQuery.toLowerCase());
  }

  @override
  void dispose() {
    _titleController.dispose();
    _descriptionController.dispose();
    _budgetController.dispose();
    super.dispose();
  }

  Future<void> _submitCustomOrder() async {
    final title = _titleController.text.trim();
    final description = _descriptionController.text.trim();
    final budget = double.tryParse(_budgetController.text.trim());

    if (title.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please enter a title for your custom order')),
      );
      return;
    }

    if (description.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please enter a description')),
      );
      return;
    }

    if (budget == null || budget <= 0) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please enter a valid budget amount')),
      );
      return;
    }

    setState(() {
      _isSubmitting = true;
    });

    try {
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString('x-auth-token') ?? '';

      if (token.isEmpty) {
        throw Exception('Please login first');
      }

      final response = await http.post(
        Uri.parse('${Constants.requestsUri}/create'),
        headers: {
          'Content-Type': 'application/json; charset=UTF-8',
          'Authorization': 'Bearer $token',
        },
        body: jsonEncode({
          'title': title,
          'description': description,
          'budget': budget,
        }),
      );

      final data = jsonDecode(response.body);

      if (response.statusCode == 201) {
        print('[CustomFurniturePage] Custom order submitted successfully');
        if (!mounted) return;

        _titleController.clear();
        _descriptionController.clear();
        _budgetController.clear();

        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Custom order submitted successfully')),
        );
        return;
      }

      throw Exception(data['msg'] ?? 'Failed to submit custom order');
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(e.toString().replaceFirst('Exception: ', ''))),
      );
    } finally {
      if (mounted) {
        setState(() {
          _isSubmitting = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
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
    const Color accentColor = Color(0xFF1a1a1a); // Orange/Gold

    return Scaffold(
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
                          hasProfileImage ? NetworkImage(user!.profilePicture) : null,
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
                    _buildUploadBox(cardColor),
                    const SizedBox(width: 15),
                    _buildUploadBox(cardColor),
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
  Widget _buildUploadBox(Color color) {
    return Container(
      width: 100,
      height: 100,
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(15),
      ),
      child: IconButton(
        icon: const Icon(Icons.add, color: Colors.white70, size: 30),
        onPressed: () {
          // Handle image upload
        },
      ),
    );
  }
}
