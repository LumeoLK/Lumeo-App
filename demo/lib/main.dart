import 'package:flutter/material.dart';
//import 'package:lumeo/pages/user/cart_page.dart';
//import 'package:lumeo/pages/seller/onboarding_page1.dart';
//import 'package:lumeo/pages/seller/onboarding_page2.dart';
import 'package:lumeo/pages/seller/onboarding_page3.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Furniture AR App',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: const SellerOnboardingPage3(),
      debugShowCheckedModeBanner: false,
    );
  }
}