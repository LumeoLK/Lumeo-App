import 'dart:convert';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:http/http.dart' as http;
import 'package:lumeo_v2/Constants.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../model/user.dart';
import '../services/auth_service.dart';
import '../services/socket_service.dart';

enum AuthStatus { initial, loading, authenticated, unauthenticated, error }

class AuthState {
  final AuthStatus status;
  final User? user;
  final String? error;

  const AuthState({this.status = AuthStatus.initial, this.user, this.error});

  AuthState copyWith({AuthStatus? status, User? user, String? error}) {
    return AuthState(
      status: status ?? this.status,
      user: user ?? this.user,
      error: error,
    );
  }
}

class AuthNotifier extends Notifier<AuthState> {
  late final AuthService _service;

  @override
  AuthState build() {
    _service = ref.read(authServiceProvider);
    return const AuthState();
  }

  Future<void> login(String email, String password) async {
    state = state.copyWith(status: AuthStatus.loading);
    try {
      final body = await _service.login(email: email, password: password);
      await _saveSession(body);
      print("hi");
      state = state.copyWith(
        status: AuthStatus.authenticated,
        user: User.fromJson(body['user'] ?? body),
      );
    } catch (e) {
      state = state.copyWith(status: AuthStatus.error, error: e.toString());
    }
  }

  Future<void> register(String email, String name, String password) async {
    state = state.copyWith(status: AuthStatus.loading);
    try {
      final body = await _service.signUpUser(
        email: email,
        name: name,
        password: password,
      );
      await _saveSession(body);
      state = state.copyWith(
        status: AuthStatus.authenticated,
        user: User.fromJson(body['user'] ?? body),
      );
    } catch (e) {
      state = state.copyWith(status: AuthStatus.error, error: e.toString());
    }
  }

  Future<void> signInWithGoogle(String mode) async {
    state = state.copyWith(status: AuthStatus.loading);
    try {
      final body = await _service.signInWithGoogle(mode: mode);
      await _saveSession(body);
      state = state.copyWith(
        status: AuthStatus.authenticated,
        user: User.fromJson(body['user'] ?? body),
      );
    } catch (e) {
      state = state.copyWith(status: AuthStatus.error, error: e.toString());
    }
  }

  Future<void> signout() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('x-auth-token', '');
    await prefs.setString('userId', '');
    state = const AuthState(status: AuthStatus.unauthenticated);
  }

  Future<void> _saveSession(Map<String, dynamic> body) async {
    final prefs = await SharedPreferences.getInstance();
    final userId = body['_id'] ?? body['user']?['_id'] ?? '';
    await prefs.setString('x-auth-token', body['token'] ?? '');
    await prefs.setString('userId', userId);
    SocketService().connect(userId);
  }

  Future<void> resetPassword(String email) async {
    await _service.resetPassword(email: email);
  }

  Future<void> updateUser(Map<String, dynamic> userData) async {
    state = state.copyWith(
      status: AuthStatus.authenticated,
      user: User.fromJson(userData),
    );
  }

  Future<void> checkSellerVerification() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString('x-auth-token') ?? '';
      if (token.isEmpty) return;

      final res = await http.get(
        Uri.parse('${Constants.sellersUri}/profile'),
        headers: {'Authorization': 'Bearer $token'},
      );
      if (res.statusCode == 200) {
        final body = jsonDecode(res.body);
        final isVerified = body['data']?['isVerified'] ?? false;
        final prefs2 = await SharedPreferences.getInstance();
        await prefs2.setBool('seller_is_verified', isVerified);
      }
    } catch (_) {}
  }
}

// Providers
final authServiceProvider = Provider(
  (ref) => AuthService(googleSignIn: GoogleSignIn()),
);

final authProvider = NotifierProvider<AuthNotifier, AuthState>(
  () => AuthNotifier(),
);

// Convenience provider — use this anywhere you need the current user
final currentUserProvider = Provider<User?>(
  (ref) => ref.watch(authProvider).user,
);
