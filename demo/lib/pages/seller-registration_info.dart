import 'package:flutter/material.dart';

class SellerRegistrationInfoScreen extends StatelessWidget {
  const SellerRegistrationInfoScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF111111),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 20),
          child: Column(
            children: [
              const SizedBox(height: 20),

              /// Title
              const Text(
                "Seller Registration",
                style: TextStyle(
                  fontSize: 26,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),

              const SizedBox(height: 30),

              /// Profile Circle
              Container(
                height: 160,
                width: 160,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: Colors.white.withOpacity(0.05),
                ),
                child: const Center(
                  child: Icon(
                    Icons.add,
                    size: 40,
                    color: Colors.white70,
                  ),
                ),
              ),

              const SizedBox(height: 15),

              const Text(
                "Upload Profile Picture",
                style: TextStyle(
                  color: Colors.white70,
                  fontSize: 16,
                ),
              ),

              const SizedBox(height: 30),

              /// Form Fields
              buildTextField("Full Name"),
              buildTextField("Shop Name"),
              buildTextField("Display Name"),
              buildTextField("Phone Number"),
              buildTextField("Email"),
              buildTextField("Business Address"),
              buildTextField("Business Registration Number"),
              buildTextField("Password", isPassword: true),
              buildTextField("Confirm Password", isPassword: true),

              const SizedBox(height: 20),

              /// Upload ID Buttons
              buildUploadButton("Upload ID / NIC (Front Side)"),
              const SizedBox(height: 15),
              buildUploadButton("Upload ID / NIC (Back Side)"),

              const SizedBox(height: 30),

              /// Submit Button
              Container(
                width: double.infinity,
                height: 55,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(30),
                  color: Color(0xFFFBB040),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.orange.withOpacity(0.5),
                      blurRadius: 15,
                      offset: const Offset(0, 5),
                    )
                  ],
                ),
                child: const Center(
                  child: Text(
                    "SUBMIT",
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                      color: Colors.black,
                    ),
                  ),
                ),
              ),

              const SizedBox(height: 30),
            ],
          ),
        ),
      ),
    );
  }

  /// Reusable TextField
  Widget buildTextField(String hint, {bool isPassword = false}) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 18),
      child: TextField(
        obscureText: isPassword,
        style: const TextStyle(color: Colors.white),
        decoration: InputDecoration(
          hintText: hint,
          hintStyle: const TextStyle(color: Colors.white54),
          filled: true,
          fillColor: Colors.white.withOpacity(0.05),
          contentPadding:
              const EdgeInsets.symmetric(horizontal: 20, vertical: 18),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(18),
            borderSide: BorderSide.none,
          ),
        ),
      ),
    );
  }

  /// Reusable Upload Button
  Widget buildUploadButton(String text) {
    return Container(
      width: double.infinity,
      height: 55,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(18),
        color: Colors.white.withOpacity(0.05),
      ),
      child: Center(
        child: Text(
          text,
          style: const TextStyle(
            color: Colors.white70,
            fontSize: 15,
          ),
        ),
      ),
    );
  }
}