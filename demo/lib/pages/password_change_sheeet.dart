import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';

import '../Constants.dart';

class PasswordChangeSheet extends StatefulWidget {
  const PasswordChangeSheet({super.key});

  @override
  State<PasswordChangeSheet> createState() => _PasswordChangeSheetState();
}

class _PasswordChangeSheetState extends State<PasswordChangeSheet> {
  final oldController = TextEditingController();
  final newController = TextEditingController();
  final repeatController = TextEditingController();
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    print('[PasswordChangeSheet] Initializing Password Change Sheet');
  }

  @override
  void dispose() {
    print('[PasswordChangeSheet] Disposing controllers');
    oldController.dispose();
    newController.dispose();
    repeatController.dispose();
    super.dispose();
  }

  Future<void> _savePassword() async {
    print('[PasswordChangeSheet] Save Password button tapped');
    print('[PasswordChangeSheet] Old Password: ${oldController.text.isNotEmpty ? '***' : 'EMPTY'}');
    print('[PasswordChangeSheet] New Password: ${newController.text.isNotEmpty ? '***' : 'EMPTY'}');
    print('[PasswordChangeSheet] Repeat Password: ${repeatController.text.isNotEmpty ? '***' : 'EMPTY'}');

    // Validation
    if (oldController.text.isEmpty) {
      print('[PasswordChangeSheet] ERROR: Old password is empty');
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please enter your old password')),
      );
      return;
    }

    if (newController.text.isEmpty) {
      print('[PasswordChangeSheet] ERROR: New password is empty');
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please enter a new password')),
      );
      return;
    }


    if (newController.text != repeatController.text) {
      print('[PasswordChangeSheet] ERROR: Passwords do not match');
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Passwords do not match')),
      );
      return;
    }

    print('[PasswordChangeSheet] All validations passed');
    print('[PasswordChangeSheet] Submitting password change request...');

    setState(() {
      _isLoading = true;
    });

    try {
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString('x-auth-token') ?? '';

      if (token.isEmpty) {
        throw Exception('Please login first');
      }

      final response = await http.post(
        Uri.parse('${Constants.authUri}/changePassword'),
        headers: {
          'Content-Type': 'application/json; charset=UTF-8',
          'Authorization': 'Bearer $token',
        },
        body: jsonEncode({
          'oldPassword': oldController.text.trim(),
          'newPassword': newController.text.trim(),
        }),
      );

      final data = jsonDecode(response.body);

      if (response.statusCode == 200) {
        print('[PasswordChangeSheet] Password change API request completed successfully');

        if (mounted) {
          setState(() {
            _isLoading = false;
          });

          print('[PasswordChangeSheet] Clearing password fields');
          oldController.clear();
          newController.clear();
          repeatController.clear();

          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Password changed successfully')),
          );

          print('[PasswordChangeSheet] Closing password change sheet');
          Navigator.pop(context);
        }
        return;
      }

      throw Exception(data['msg'] ?? data['message'] ?? 'Failed to change password');
    } catch (e) {
      print('[PasswordChangeSheet] ERROR changing password: $e');
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(e.toString().replaceFirst('Exception: ', ''))),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    print('[PasswordChangeSheet] Building UI');
    return Container(
      padding: EdgeInsets.only(
        bottom: MediaQuery.of(context).viewInsets.bottom,
      ),
      decoration: const BoxDecoration(
        color: Color(0xFF1E1E1E),
        borderRadius: BorderRadius.vertical(top: Radius.circular(25)),
      ),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            /// Drag Handle
            Container(
              width: 40,
              height: 5,
              decoration: BoxDecoration(
                color: Colors.white24,
                borderRadius: BorderRadius.circular(10),
              ),
            ),

            const SizedBox(height: 20),

            const Text(
              "Password Change",
              style: TextStyle(
                color: Colors.white,
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),

            const SizedBox(height: 20),

            _inputField("Old Password", oldController),
            _inputField("New Password", newController),
            _inputField("Repeat New Password", repeatController),

            const SizedBox(height: 20),

            /// Save Button
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: _isLoading ? null : _savePassword,
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFFF5A623),
                  disabledBackgroundColor: Colors.grey[600],
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(30),
                  ),
                ),
                child: _isLoading
                    ? const SizedBox(
                        height: 20,
                        width: 20,
                        child: CircularProgressIndicator(
                          valueColor: AlwaysStoppedAnimation<Color>(Colors.black),
                          strokeWidth: 2,
                        ),
                      )
                    : const Text(
                        "SAVE PASSWORD",
                        style: TextStyle(
                          color: Colors.black,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
              ),
            ),

            const SizedBox(height: 15),

            /// Cancel Button
            SizedBox(
              width: double.infinity,
              child: TextButton(
                onPressed: _isLoading ? null : () {
                  print('[PasswordChangeSheet] Cancel button tapped');
                  Navigator.pop(context);
                },
                child: const Text(
                  "CANCEL",
                  style: TextStyle(color: Colors.white54),
                ),
              ),
            ),

            const SizedBox(height: 10),
          ],
        ),
      ),
    );
  }

  Widget _inputField(String hint, TextEditingController controller) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 15),
      child: TextField(
        controller: controller,
        enabled: !_isLoading,
        obscureText: true,
        style: const TextStyle(color: Colors.white),
        decoration: InputDecoration(
          hintText: hint,
          hintStyle: const TextStyle(color: Colors.white54),
          filled: true,
          fillColor: const Color(0xFF2A2A35),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: const BorderSide(color: Colors.white24),
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: const BorderSide(color: Colors.white24),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: const BorderSide(color: Color(0xFFF5A623)),
          ),
        ),
      ),
    );
  }
}