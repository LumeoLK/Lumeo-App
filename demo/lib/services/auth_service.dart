import 'package:demo/Constants.dart';
import 'package:demo/model/user.dart';
import 'package:demo/pages/homePage.dart';
import 'package:demo/pages/login.dart';
import 'package:demo/utils/utils.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/legacy.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

final currentUserProvider = StateProvider<User?>((ref) => null);

final authProvider = Provider(
  (ref) => AuthService(googleSignIn: GoogleSignIn()),
);

class AuthService {
  void signUpUser({
    required BuildContext context,
    required String email,
    required String name,
    required String password,
  }) async {
    try {
      final Map<String, dynamic> userData = {
        'name': name,
        'email': email,
        'password': password,
      };

      http.Response res = await http.post(
        Uri.parse('${Constants.uri}/register'),
        body: jsonEncode(userData),
        headers: <String, String>{
          'Content-Type': 'application/json; charset=UTF-8',
        },
      );

      httpErrorHandle(
        response: res,
        context: context,
        onSuccess: () {
          showSnackBar(context, 'Registered successfully!');
          Navigator.of(context).pushAndRemoveUntil(
            MaterialPageRoute(builder: (context) => const Homepage()),
            (route) => false,
          );
        },
      );
    } catch (e) {
      showSnackBar(context, e.toString());
    }
  }

  void login({
    required BuildContext context,
    required String email,
    required String password,
    required WidgetRef ref,
  }) async {
    try {
      final navigator = Navigator.of(context);
      http.Response res = await http.post(
        Uri.parse('${Constants.uri}/login'),
        body: jsonEncode({'email': email, 'password': password}),
        headers: <String, String>{
          'Content-Type': 'application/json; charset=UTF-8',
        },
      );

      httpErrorHandle(
        response: res,
        context: context,
        onSuccess: () async {
          SharedPreferences prefs = await SharedPreferences.getInstance();
          final body = jsonDecode(res.body);
          ref.read(currentUserProvider.notifier).state = User.fromJson(
            body['user'],
          );

          await prefs.setString('x-auth-token', jsonDecode(res.body)['token']);
          navigator.pushAndRemoveUntil(
            MaterialPageRoute(builder: (context) => const Homepage()),
            (route) => false,
          );
        },
      );
    } catch (e) {
      showSnackBar(context, e.toString());
    }
  }

  void signout(BuildContext context) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    prefs.setString('x-auth-token', '');
    Navigator.of(context).pushAndRemoveUntil(
      MaterialPageRoute(builder: (context) => Login()),
      (route) => false,
    );
  }

  final GoogleSignIn _googleSignIn;
  AuthService({required GoogleSignIn googleSignIn})
    : _googleSignIn = googleSignIn;

  void signInWithGoogle({
    required BuildContext context,
    required String mode,
  }) async {
    try {
      await _googleSignIn.signOut();
      final GoogleSignInAccount? user = await _googleSignIn.signIn();
      if (user != null) {
        final userAcc = User(
          email: user.email,
          name: user.displayName ?? "No name",
          profilePicture: user.photoUrl ?? '',
          id: '',
          token: '',
        );

        http.Response res = await http.post(
          Uri.parse('${Constants.uri}/googleAuth'),
          body: jsonEncode({...userAcc.toJson(), 'mode': mode}),
          headers: <String, String>{
            'Content-Type': 'application/json; charset=UTF-8',
          },
        );
        httpErrorHandle(
          response: res,
          context: context,
          onSuccess: () async {
            SharedPreferences prefs = await SharedPreferences.getInstance();

            await prefs.setString(
              'x-auth-token',
              jsonDecode(res.body)['token'],
            );
            Navigator.pushAndRemoveUntil(
              context,
              MaterialPageRoute(builder: (_) => const Homepage()),
              (_) => false,
            );
          },
        );
      }
    } catch (e) {
      showSnackBar(context, e.toString());
    }
  }
}
