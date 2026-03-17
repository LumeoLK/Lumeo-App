import 'package:shared_preferences/shared_preferences.dart';

Future<String> getAuthToken() async {
  final prefs = await SharedPreferences.getInstance();
  return prefs.getString('x-auth-token') ?? '';
}

Future<void> setAuthToken(String token) async {
  final prefs = await SharedPreferences.getInstance();
  await prefs.setString('x-auth-token', token);
}

Future<void> clearAuthToken() async {
  final prefs = await SharedPreferences.getInstance();
  await prefs.remove('x-auth-token');
  await prefs.remove('userId');
}