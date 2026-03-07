import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:get/get.dart';
import 'package:shared_preferences/shared_preferences.dart';

// Import your pages
import '../pages/home_page.dart';
import '../pages/login.dart';
import 'pages/onboarding_page1.dart';
import '../providers/user_provider.dart';

void main() {
  runApp(const ProviderScope(child: MyApp()));
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return GetMaterialApp(
      title: 'Lumeo',
      darkTheme: ThemeData.dark(),
      themeMode: ThemeMode.dark,
      // Senior Tip: Point "home" to SplashScreen so the app flow starts correctly
      home: const SplashScreen(), 
      debugShowCheckedModeBanner: false,
    );
  }
}

class SplashScreen extends StatefulWidget {        
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    super.initState();
    // Transition to Onboarding after 3 seconds
    Timer(const Duration(seconds: 3), () {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (context) => const OnboardingPage1(),
        ),
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFFBB040), // Lumeo Orange
      body: Center(
        child: Image.asset(
          "assets/images/lumeo_brandmark.png",
          width: 150,
          height: 150,
        ),
      ),
    );
  }
}