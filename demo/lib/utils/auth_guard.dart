import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../services/auth_service.dart';
import '../widgets/login_required_dialog.dart';

/// Checks if the user is authenticated. If not, shows the LoginRequiredDialog.
///
/// Returns `true` if the user IS logged in (safe to proceed).
/// Returns `false` if the user is NOT logged in (dialog was shown).
///
/// Usage (in any ConsumerWidget / ConsumerState):
/// ```dart
/// onPressed: () async {
///   if (!await requireAuth(context, ref)) return;
///   // user is logged in — do the authenticated action
///   await ref.read(cartProvider.notifier).addToCart(productId, price);
/// }
/// ```
Future<bool> requireAuth(BuildContext context, WidgetRef ref) async {
  // 1) Check the Riverpod user state
  final user = ref.read(currentUserProvider);
  if (user != null && user.id.isNotEmpty) {
    return true;
  }

  // 2) Fallback: check SharedPreferences token (in case the app restarted
  //    but the provider wasn't re-hydrated yet)
  final prefs = await SharedPreferences.getInstance();
  final token = prefs.getString('x-auth-token') ?? '';
  if (token.isNotEmpty) {
    return true;
  }

  // 3) User is not logged in — show the dialog
  if (context.mounted) {
    await LoginRequiredDialog.show(context);
  }
  return false;
}
