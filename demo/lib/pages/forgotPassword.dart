// import 'dart:convert';

import 'package:demo/Constants.dart';
import 'package:demo/services/auth_service.dart';
import 'package:demo/utils/utils.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:http/http.dart' as http;

class Forgotpassword extends ConsumerStatefulWidget {
  Forgotpassword({super.key});

  @override
  ConsumerState<Forgotpassword> createState() => _ForgotpasswordState();
}

class _ForgotpasswordState extends ConsumerState<Forgotpassword> {
  final _formKey = GlobalKey<FormState>();
  TextEditingController email = TextEditingController();

  @override
  Widget build(BuildContext context) {
    final authService = ref.read(authProvider);
    return Scaffold(
      body: Stack(
        children: [
          // 1. Full screen background
          Container(
            decoration: BoxDecoration(
              image: DecorationImage(
                image: AssetImage("assets/backgroundImg.jpg"),
                fit: BoxFit.cover,
              ),
            ),
          ),

          SafeArea(
            child: SingleChildScrollView(
              padding: EdgeInsets.only(left: 30, top: 75, right: 30, bottom: 5),
              child: Form(
                key: _formKey,
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Text(
                      "Forgot Password",
                      style: TextStyle(
                        fontSize: 28,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ), // text over image
                      textAlign: TextAlign.left,
                    ),
                    SizedBox(height: 65),
                    Text(
                      "Please, enter your email address. You will receive a link to create a new password via email.",
                      textAlign: TextAlign.left,
                      style: TextStyle(
                        fontSize: 16,
                        color: const Color.fromARGB(255, 255, 255, 255),
                      ),
                    ),
                    SizedBox(height: 50),
                    TextFormField(
                      controller: email,
                      decoration: InputDecoration(
                        hintText: "Enter email",
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                        fillColor: Colors.white,

                        filled: true,
                      ),
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return "Email cannot be empty";
                        }
                        if (!value.trim().endsWith("@gmail.com")) {
                          return "Please use a Gmail address (you@gmail.com)";
                        }
                        return null; // valid
                      },
                    ),
                    SizedBox(height: 150),
                    Align(
                      alignment: Alignment.center,
                      child: ElevatedButton(
                        onPressed: () {
                          // Trigger form validation
                          if (_formKey.currentState!.validate()) {
                            authService.resetPassword(
                              context: context,
                              email: email.text,
                            );
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                content: Text('Password reset email sent!'),
                              ),
                            );
                          }
                          // If invalid, the error message from validator will automatically show below the TextFormField
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Color(0xFFE09D3B),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(30),
                          ),
                          padding: EdgeInsets.symmetric(horizontal: 8),
                          minimumSize: Size(150, 40),
                        ),
                        child: Text(
                          "SEND",
                          style: TextStyle(color: Colors.black),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
