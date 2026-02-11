import 'package:flutter/material.dart';

class CustomFurniturePage extends StatefulWidget {
  const CustomFurniturePage({super.key});

  @override
  State<CustomFurniturePage> createState() => _CustomFurniturePageState();
}

class _CustomFurniturePageState extends State<CustomFurniturePage> {
  @override
  Widget build(BuildContext context) {
    // Define colors from the design
    const Color backgroundColor = Color(0xFF1E1E1E);
    const Color cardColor = Color(0xFF2C2C2C);
    const Color primaryText = Colors.white;
    const Color secondaryText = Colors.white70;
    const Color accentColor = Color(0xFFFFB74D); // Orange/Gold

    return Scaffold(
      backgroundColor: backgroundColor,
      body: SafeArea(
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.all(20.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // --- Top Header (Search & Profile) ---
                Row(
                  children: [
                    Expanded(
                      child: Container(
                        height: 45,
                        decoration: BoxDecoration(
                          color: cardColor,
                          borderRadius: BorderRadius.circular(30),
                        ),
                        child: const TextField(
                          decoration: InputDecoration(
                            hintText: "Office Chairs",
                            hintStyle: TextStyle(color: Colors.white24),
                            prefixIcon: Icon(Icons.search, color: Colors.white),
                            border: InputBorder.none,
                            contentPadding: EdgeInsets.symmetric(vertical: 10),
                          ),
                          style: TextStyle(color: primaryText),
                        ),
                      ),
                    ),
                    const SizedBox(width: 15),
                    const CircleAvatar(
                      backgroundColor: cardColor,
                      child: Icon(Icons.person, color: accentColor),
                    ),
                  ],
                ),

                const SizedBox(height: 25),

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
                    const CircleAvatar(
                      radius: 25,
                      backgroundImage: NetworkImage(
                        'https://i.pravatar.cc/150?img=5',
                      ), // Placeholder image
                    ),
                    const SizedBox(width: 15),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: const [
                        Text(
                          "Matilda Brown",
                          style: TextStyle(
                            color: primaryText,
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        Text(
                          "matildabrown@mail.com",
                          style: TextStyle(color: secondaryText, fontSize: 14),
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

                // --- Description Field ---
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
                  child: const TextField(
                    maxLines: 5,
                    style: TextStyle(color: primaryText),
                    decoration: InputDecoration(
                      hintText:
                          "Describe the furniture you want. Mention style, purpose, materials, and any special features.",
                      hintStyle: TextStyle(color: Colors.white24, fontSize: 14),
                      border: InputBorder.none,
                      contentPadding: EdgeInsets.all(15),
                    ),
                  ),
                ),

                const SizedBox(height: 25),

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
                    onPressed: () {
                      // Handle submit logic
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: accentColor,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(30),
                      ),
                    ),
                    child: const Text(
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
