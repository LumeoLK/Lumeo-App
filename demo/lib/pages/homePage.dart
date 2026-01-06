import 'package:demo/services/auth_service.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class Homepage extends ConsumerStatefulWidget {
  const Homepage({super.key});

  @override
  ConsumerState<Homepage> createState() => _HomepageState();
}

class _HomepageState extends ConsumerState<Homepage> {
  void signout(BuildContext context)  {
    final authService = ref.read(authProvider); 
    authService.signout(context);
  }

  @override
  Widget build(BuildContext context) {
    final currentUser = ref.watch(currentUserProvider);

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
