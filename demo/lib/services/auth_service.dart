import 'dart:convert';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import '../Constants.dart';


class AuthService {
  final GoogleSignIn _googleSignIn;
  AuthService({required GoogleSignIn googleSignIn})
      : _googleSignIn = googleSignIn;

  Future<Map<String, dynamic>> login({
    required String email,
    required String password,
  }) async {
    final res = await http.post(
      Uri.parse('${Constants.authUri}/login'),
      body: jsonEncode({'email': email, 'password': password}),
      headers: {'Content-Type': 'application/json; charset=UTF-8'},
    );
    if (res.statusCode != 200) {
      throw Exception(jsonDecode(res.body)['msg'] ?? res.body);
    }
    return jsonDecode(res.body);
  }

  Future<Map<String, dynamic>> signUpUser({
    required String email,
    required String name,
    required String password,
  }) async {
    final res = await http.post(
      Uri.parse('${Constants.authUri}/register'),
      body: jsonEncode({'name': name, 'email': email, 'password': password}),
      headers: {'Content-Type': 'application/json; charset=UTF-8'},
    );
    if (res.statusCode != 200 && res.statusCode != 201) {
      throw Exception(jsonDecode(res.body)['msg'] ?? res.body);
    }
    return jsonDecode(res.body);
  }

  Future<Map<String, dynamic>> signInWithGoogle({required String mode}) async {
    await _googleSignIn.signOut();
    final googleUser = await _googleSignIn.signIn();
    if (googleUser == null) throw Exception('Google sign-in cancelled');

    final res = await http.post(
      Uri.parse('${Constants.authUri}/googleAuth'),
      body: jsonEncode({
        'email': googleUser.email,
        'name': googleUser.displayName ?? '',
        'profilePicture': googleUser.photoUrl ?? '',
        'mode': mode,
      }),
      headers: {'Content-Type': 'application/json; charset=UTF-8'},
    );
    if (res.statusCode != 200 && res.statusCode != 201) {
      throw Exception(jsonDecode(res.body)['msg'] ?? res.body);
    }
    return jsonDecode(res.body);
  }

  Future<void> resetPassword({required String email}) async {
    await http.post(
      Uri.parse('${Constants.authUri}/forgotPassword'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({'email': email.trim()}),
    );
  }

  Future<void> signout() async {
    final prefs = await SharedPreferences.getInstance();
    await _googleSignIn.signOut();
    await prefs.setString('x-auth-token', '');
    await prefs.setString('userId', '');
  }
}