import 'package:demo/pages/customFurniture.dart';
import 'package:demo/pages/login.dart';
import 'package:demo/pages/userProfile.dart';
import 'package:demo/providers/user_provider.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:provider/provider.dart';

void main() {
  runApp(
    MultiProvider(
      providers: [ChangeNotifierProvider(create: (_) => UserProvider())],
      child: const MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return GetMaterialApp(
      title: 'Lumeo',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
      ),
      home: CustomFurniturePage(),
      debugShowCheckedModeBanner: false,
    );
  }
}
