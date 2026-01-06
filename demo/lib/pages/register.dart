import 'package:demo/pages/homePage.dart';
import 'package:demo/services/auth_service.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:get/get.dart';

class Register extends ConsumerStatefulWidget {
  Register({super.key});

  @override
  ConsumerState<Register> createState() => _RegisterState();
}

class _RegisterState extends ConsumerState<Register> {
  final _formKey = GlobalKey<FormState>();
  TextEditingController username = TextEditingController();
  TextEditingController email = TextEditingController();
  TextEditingController password = TextEditingController();
  TextEditingController confirmPassword = TextEditingController();
  void signInWithGoogle(WidgetRef ref, BuildContext context) {
    ref.read(authProvider).signInWithGoogle(context: context, mode: "register");
  }

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
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Text(
                      "Register",
                      style: TextStyle(
                        fontSize: 28,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ), // text over image
                      textAlign: TextAlign.left,
                    ),
                    SizedBox(height: 65),
                    TextFormField(
                      controller: username,
                      decoration: InputDecoration(
                        hintText: "User name",
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                        fillColor: Colors.white,

                        filled: true,
                      ),
                      validator: (value) {
                        if (value == null || value.isEmpty)
                          return "Username cannot be empty";
                        return null;
                      },
                    ),
                    SizedBox(height: 20),
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
                    SizedBox(height: 20),
                    TextFormField(
                      controller: password,
                      obscureText: true,
                      decoration: InputDecoration(
                        hintText: 'Enter password',
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                        fillColor: Colors.white,

                        filled: true,
                      ),

                      validator: (value) {
                        if (value == null || value.isEmpty)
                          return "Password cannot be empty";
                        return null;
                      },
                    ),
                    SizedBox(height: 20),
                    TextFormField(
                      controller: confirmPassword,
                      obscureText: true,
                      decoration: InputDecoration(
                        hintText: 'Confirm password',
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                        fillColor: Colors.white,

                        filled: true,
                      ),

                      validator: (value) {
                        if (value == null || value.isEmpty)
                          return "Confirm password cannot be empty";
                        if (value != password.text)
                          return "Passwords do not match";
                        return null;
                      },
                    ),
                    SizedBox(height: 30),
                    Align(
                      alignment: Alignment.center,
                      child: ElevatedButton(
                        onPressed: () {
                          if (_formKey.currentState!.validate()) {
                            try {
                              authService.signUpUser(
                                context: context,
                                email: email.text,
                                name: username.text,
                                password: password.text,
                              );
                            } catch (e) {
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(content: Text(e.toString())),
                              );
                            }
                          }
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
                          "REGISTER",
                          style: TextStyle(color: Colors.black),
                        ),
                      ),
                    ),
                    SizedBox(height: 150),
                    Text(
                      "Or register with social account",
                      style: TextStyle(color: Colors.white),
                      textAlign: TextAlign.center,
                    ),
                    SizedBox(height: 20),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: [
                        ElevatedButton(
                          onPressed: () async {
                            try {
                              signInWithGoogle(ref, context);
                            } catch (e) {
                              print("Google Sign-In Error: $e");
                            }
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.white,
                          ),
                          child: Container(
                            width: 80,
                            height: 60,
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(10),
                            ),
                            padding: EdgeInsets.all(12),
                            child: Image.asset(
                              "assets/googleLogo.png",
                              height: 5,
                              width: 5,
                            ),
                          ),
                        ),

                        ElevatedButton(
                          onPressed: () async {
                            try {
                              print("FB login");
                            } catch (e) {
                              print("Facebook Sign-In Error: $e");
                            }
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.white,
                          ),

                          child: Container(
                            width: 80,
                            height: 60,
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(10),
                            ),
                            padding: EdgeInsets.all(8),
                            child: Image.asset(
                              "assets/facebookLogo.png",
                              height: 2,
                              width: 2,
                            ),
                          ),
                        ),
                      ],
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
