<<<<<<< HEAD
import 'dart:async';

import '../providers/user_provider.dart';
=======
import 'package:demo/pages/login.dart';
import 'package:demo/pages/my_orders.dart';
import 'package:demo/providers/user_provider.dart';
>>>>>>> my-orders
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../pages/home_page.dart';
import '../pages/login.dart';
import 'package:get/get.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';                      
import 'pages/onboarding_page1.dart';           
void main() {
  runApp(
    const ProviderScope(child: const MyApp(),)
      
    );
 
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});


      
  @override
  Widget build(BuildContext context) {
<<<<<<< HEAD
    return MaterialApp(
=======
    return GetMaterialApp(
      title: 'Lumeo',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
      ),
      home: MyOrders(),
>>>>>>> my-orders
      debugShowCheckedModeBanner: false,
      title: 'Lumeo',
      darkTheme: ThemeData.dark(), 
      themeMode: ThemeMode.dark, 
      home: const SplashScreen(),
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

    // Wait 3 seconds → go to next page
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
      backgroundColor: const Color(0xFFFBB040), //orange color
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