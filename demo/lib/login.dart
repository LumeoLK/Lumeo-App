import 'package:demo/forgotPassword.dart';
import 'package:demo/homePage.dart';
import 'package:demo/register.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

class Login extends StatefulWidget {
  Login({super.key});

  @override
  State<Login> createState() => _LoginState();
}

class _LoginState extends State<Login> {
  final _formKey = GlobalKey<FormState>();
  TextEditingController email = TextEditingController();
  TextEditingController password = TextEditingController();

  signIn() async {
    try {
      await FirebaseAuth.instance.signInWithEmailAndPassword(
        email: email.text,
        password: password.text,
      );
      print("Login successful");
    } catch (e) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(e.toString())));
    }
  }

  Future googleLogin() async {
    final googleSignIn = GoogleSignIn();

    // 1. Sign in user
    final googleUser = await googleSignIn.signIn();
    if (googleUser == null) return;

    // 2. Get authentication (tokens)
    final googleAuth = await googleUser.authentication;

    // 3. Create credential
    final credential = GoogleAuthProvider.credential(
      accessToken: googleAuth.accessToken,
      idToken: googleAuth.idToken,
    );

    // 4. Sign in to Firebase
    await FirebaseAuth.instance.signInWithCredential(credential);
    // Get.offAll(() => Homepage());
  }

  @override
  Widget build(BuildContext context) {
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

          // 2. Login form scrollable
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
                      "Login",
                      style: TextStyle(
                        fontSize: 28,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ), // text over image
                      textAlign: TextAlign.left,
                    ),
                    SizedBox(height: 65),
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
                    SizedBox(height: 15),
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
                        if (value == null || value.isEmpty) {
                          return "Password cannot be empty";
                        }
                        if (value.length < 6) {
                          return "Password must be at least 6 characters";
                        }
                        return null; // valid
                      },
                    ),
                    SizedBox(height: 10),
                    TextButton(
                      onPressed: () => Get.to(() => Forgotpassword()),
                      child: Align(
                        alignment: Alignment.centerRight,
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Text(
                              "Forgot your password?",
                              textAlign: TextAlign.right,
                              style: TextStyle(
                                fontSize: 16,
                                color: const Color.fromARGB(255, 255, 255, 255),
                              ),
                            ),

                            SizedBox(width: 8),
                            Transform.rotate(
                              angle:
                                  3 *
                                  3.14 /
                                  2, // rotates 90 degrees (in radians)
                              child: Icon(
                                FontAwesomeIcons.arrowDown,
                                size: 20,
                                color: Color.fromARGB(255, 224, 157, 59),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                    SizedBox(height: 10),

                    Align(
                      alignment: Alignment.center,
                      child: ElevatedButton(
                        onPressed: () async {
                          if (_formKey.currentState!.validate()) {
                            try {
                              await signIn();
                            } catch (e) {
                              // Display Firebase errors
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(content: Text(e.toString())),
                              );
                            }
                          }
                          // If invalid, the error messages automatically show below each field
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
                          "LOGIN",
                          style: TextStyle(color: Colors.black),
                        ),
                      ),
                    ),

                    TextButton(
                      onPressed: () => Get.to(() => Register()),
                      child: Padding(
                        padding: const EdgeInsets.all(12.0),
                        child: Text(
                          "Haven't Registered Yet?",
                          style: TextStyle(color: Colors.white),
                        ),
                      ),
                    ),
                    SizedBox(height: 170),
                    Text(
                      "Or login with social account",
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
                              await googleLogin();
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
                              await googleLogin();
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
                    SizedBox(height: 45), // spacing for bottom button
                    TextButton(
                      onPressed: () => Get.to(() => Homepage()),
                      child: Text(
                        "Skip >>",
                        style: TextStyle(
                          fontSize: 16,
                          color: const Color.fromARGB(255, 255, 255, 255),
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
