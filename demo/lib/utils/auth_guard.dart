import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../providers/auth_provider.dart';
import '../pages/login.dart';

// Returns true if the user is logged in and can proceed.
// Returns false if not logged in — and redirects them to Login.

Future<bool> requireAuth(BuildContext context, WidgetRef ref) async {
  final user = ref.read(currentUserProvider);

  if (user != null) {
    // Already logged in — let them through
    return true;
  }

  // Not logged in — show a message and redirect to Login
  if (context.mounted) {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Please log in to continue'),
        duration: Duration(seconds: 2),
      ),
    );

    await Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => const Login()),
    );

    // After returning from Login, check again if they logged in
    final userAfterLogin = ref.read(currentUserProvider);
    return userAfterLogin != null;
  }

  return false;
}