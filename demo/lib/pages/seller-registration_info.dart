import 'dart:io'; // Needed for the File class
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart'; // Needed for picking images

class SellerRegistrationInfoScreen extends StatefulWidget {
  const SellerRegistrationInfoScreen({super.key});

  @override
  State<SellerRegistrationInfoScreen> createState() =>
      _SellerRegistrationInfoScreenState();
}

class _SellerRegistrationInfoScreenState
    extends State<SellerRegistrationInfoScreen> {
  // --- Text Controllers ---
  final TextEditingController shopNameController = TextEditingController();
  final TextEditingController displayNameController = TextEditingController();
  final TextEditingController phoneNumberController = TextEditingController();
  final TextEditingController businessAddressController =
      TextEditingController();
  final TextEditingController businessRegController = TextEditingController();

  // --- STEP 2: Image State Variables ---
  // We use File? because initially, no image is selected (it's null).
  File? logoImage;
  File? nicFrontImage;
  File? nicBackImage;

  final ImagePicker _picker = ImagePicker();

  @override
  void dispose() {
    shopNameController.dispose();
    displayNameController.dispose();
    phoneNumberController.dispose();
    businessAddressController.dispose();
    businessRegController.dispose();
    super.dispose();
  }

  // --- STEP 2: The Image Picker Function ---
  // This function opens the gallery and assigns the chosen image to the correct variable.
  Future<void> _pickImage(String imageType) async {
    try {
      final XFile? pickedFile = await _picker.pickImage(
        source: ImageSource.gallery,
      );

      if (pickedFile != null) {
        setState(() {
          if (imageType == 'logo') {
            logoImage = File(pickedFile.path);
          } else if (imageType == 'nicFront') {
            nicFrontImage = File(pickedFile.path);
          } else if (imageType == 'nicBack') {
            nicBackImage = File(pickedFile.path);
          }
        });
      }
    } catch (e) {
      print("Error picking image: $e");
      // In a real app, we might show a SnackBar here to tell the user something went wrong.
    }
  }

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
              const Text(
                "Seller Registration",
                style: TextStyle(
                  fontSize: 26,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
              const SizedBox(height: 25),

              /// Profile Circle (Logo) - Now clickable!
              GestureDetector(
                onTap: () => _pickImage('logo'),
                child: Container(
                  height: 160,
                  width: 160,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: Colors.white.withOpacity(0.05),
                    // If an image is selected, show it as the background
                    image: logoImage != null
                        ? DecorationImage(
                            image: FileImage(logoImage!),
                            fit: BoxFit.cover,
                          )
                        : null,
                  ),
                  child: logoImage == null
                      ? const Center(
                          child: Icon(
                            Icons.add_a_photo,
                            size: 40,
                            color: Colors.white70,
                          ),
                        )
                      : null, // Hide icon if image exists
                ),
              ),
              const SizedBox(height: 15),
              const Text(
                "Upload Shop Logo",
                style: TextStyle(color: Colors.white70, fontSize: 16),
              ),
              const SizedBox(height: 30),

              /// Form Fields
              buildTextField("Shop Name", shopNameController),
              buildTextField("Display Name", displayNameController),
              buildTextField("Phone Number", phoneNumberController),
              buildTextField("Business Address", businessAddressController),
              buildTextField(
                "Business Registration Number",
                businessRegController,
              ),
              const SizedBox(height: 20),

              /// Upload ID Buttons - Now clickable and dynamic!
              buildUploadButton(
                text: "Upload ID / NIC (Front Side)",
                selectedFile: nicFrontImage,
                onTap: () => _pickImage('nicFront'),
              ),
              const SizedBox(height: 15),
              buildUploadButton(
                text: "Upload ID / NIC (Back Side)",
                selectedFile: nicBackImage,
                onTap: () => _pickImage('nicBack'),
              ),

              const SizedBox(height: 30),

              /// Submit Button
              GestureDetector(
                onTap: () {
                  print("Checking Data before API call:");
                  print("Shop Name: ${shopNameController.text}");
                  print("Logo Selected: ${logoImage != null}");
                  print("NIC Front Selected: ${nicFrontImage != null}");
                  print("NIC Back Selected: ${nicBackImage != null}");
                },
                child: Container(
                  width: double.infinity,
                  height: 55,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(30),
                    color: const Color(0xFFFBB040),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.orange.withOpacity(0.5),
                        blurRadius: 15,
                        offset: const Offset(0, 5),
                      ),
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
              ),
              const SizedBox(height: 30),
            ],
          ),
        ),
      ),
    );
  }

  Widget buildTextField(String hint, TextEditingController controller) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 18),
      child: TextField(
        controller: controller,
        style: const TextStyle(color: Colors.white),
        decoration: InputDecoration(
          hintText: hint,
          hintStyle: const TextStyle(color: Colors.white54),
          filled: true,
          fillColor: Colors.white.withOpacity(0.05),
          contentPadding: const EdgeInsets.symmetric(
            horizontal: 20,
            vertical: 18,
          ),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(18),
            borderSide: BorderSide.none,
          ),
        ),
      ),
    );
  }

  /// Reusable Upload Button - Updated to show success state
  Widget buildUploadButton({
    required String text,
    File? selectedFile,
    required VoidCallback onTap,
  }) {
    bool isSelected = selectedFile != null;

    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: double.infinity,
        height: 55,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(18),
          // Change color slightly if selected to give visual feedback
          color: isSelected
              ? Colors.green.withOpacity(0.1)
              : Colors.white.withOpacity(0.05),
          border: isSelected
              ? Border.all(color: Colors.green.withOpacity(0.5))
              : null,
        ),
        child: Center(
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                isSelected ? Icons.check_circle : Icons.upload_file,
                color: isSelected ? Colors.green : Colors.white70,
                size: 20,
              ),
              const SizedBox(width: 10),
              Text(
                isSelected ? "Image Selected" : text,
                style: TextStyle(
                  color: isSelected ? Colors.green : Colors.white70,
                  fontSize: 15,
                  fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
