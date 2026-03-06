import '../providers/user_provider.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../pages/home_page.dart';
import '../pages/login.dart';
import 'package:get/get.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';                      
import 'pages/onboarding_page1.dart';    
import 'pages/seller-registration_info.dart';       
void main() {
  runApp(
    const ProviderScope(child: const MyApp(),)
      
    );
 
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return GetMaterialApp(
      
      title: 'Lumeo',
      darkTheme: ThemeData.dark(), // Uses default dark colors
      themeMode: ThemeMode.dark, 
      home: const HomePage(),
      debugShowCheckedModeBanner: false,

    );
  }
}