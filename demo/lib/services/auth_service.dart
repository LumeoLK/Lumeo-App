import 'dart:convert';
import 'dart:async';
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
    try {
      final res = await http.post(
        Uri.parse('${Constants.authUri}/login'),
        body: jsonEncode({'email': email, 'password': password}),
        headers: {'Content-Type': 'application/json; charset=UTF-8'},
      ).timeout(
        const Duration(seconds: 20),
        onTimeout: () => throw Exception('Server error. Please try again later.'),
      );
      
      if (res.statusCode != 200) {
        throw Exception(jsonDecode(res.body)['msg'] ?? res.body);
      }
      return jsonDecode(res.body);
    } on TimeoutException {
      throw Exception('Server error. Please try again later.');
    } catch (e) {
      rethrow;
    }
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
    final res = await http.post(
      Uri.parse('${Constants.authUri}/forgotPassword'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({'email': email.trim()}),
    );
    if (res.statusCode != 200) {
      throw Exception(jsonDecode(res.body)['msg'] ?? res.body);
    }
  }

  Future<void> signout() async {
    final prefs = await SharedPreferences.getInstance();
    await _googleSignIn.signOut();
    await prefs.setString('x-auth-token', '');
    await prefs.setString('userId', '');
  }

  Future<Map<String, dynamic>> getCurrentUser({required String token}) async {
    print('[AuthService] Fetching current user details...');
    final res = await http.get(
      Uri.parse('${Constants.authUri}/me'),
      headers: {
        'Content-Type': 'application/json; charset=UTF-8',
        'Authorization': 'Bearer $token',
      },
    );

    if (res.statusCode != 200) {
      print('[AuthService] Error fetching user: ${res.statusCode}');
      throw Exception(jsonDecode(res.body)['msg'] ?? 'Failed to fetch user details');
    }

    final data = jsonDecode(res.body);
    print('[AuthService] User details fetched successfully: ${data['user']}');
    return data;
  }
}