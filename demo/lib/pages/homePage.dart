import 'package:demo/services/auth_service.dart';
import 'package:flutter/material.dart';

class Homepage extends StatefulWidget {
  const Homepage({super.key});

  @override
  State<Homepage> createState() => _HomepageState();
}

class _HomepageState extends State<Homepage> {
  void signout(BuildContext context) async {
    // AuthService().signout(context);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("Homepage")),
      body: Center(
        // child: Text(
        //   user != null ? '${user!.email}' : 'Welcome',
        //   style: TextStyle(fontSize: 20),
        // ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => signout(context),
        child: Icon(Icons.login_rounded),
      ),
    );
  }
}
