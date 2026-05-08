// lib/data/repositories/auth_repository.dart

import 'package:supabase_flutter/supabase_flutter.dart';
import '../models/user_model.dart';
import '../../core/constants/supabase_constants.dart';

class AuthRepository {
  final SupabaseClient _client;

  AuthRepository(this._client);

  // Current logged-in user
  User? get currentAuthUser => _client.auth.currentUser;

  // Stream of auth changes
  Stream<AuthState> get authStateChanges => _client.auth.onAuthStateChange;

  // Get user profile from DB
  Future<UserModel?> getUserProfile(String userId) async {
    final response = await _client
        .from(SupabaseConstants.usersTable)
        .select()
        .eq('id', userId)
        .maybeSingle();

    if (response == null) return null;
    return UserModel.fromJson(response);
  }

  // Register
  Future<UserModel> register({
    required String name,
    required String email,
    required String phone,
    required String password,
  }) async {
    final response = await _client.auth.signUp(
      email: email,
      password: password,
      data: {
        'name': name,
        'phone': phone,
        'role': 'user',
      },
    );

    if (response.user == null) {
      throw Exception('Registration failed');
    }

    // Wait briefly for trigger to create profile
    await Future.delayed(const Duration(milliseconds: 500));

    final profile = await getUserProfile(response.user!.id);
    if (profile == null) throw Exception('Profile creation failed');
    return profile;
  }

  // Login
  Future<UserModel> login({
    required String email,
    required String password,
  }) async {
    final response = await _client.auth.signInWithPassword(
      email: email,
      password: password,
    );

    if (response.user == null) throw Exception('Login failed');

    final profile = await getUserProfile(response.user!.id);
    if (profile == null) throw Exception('User profile not found');
    return profile;
  }

  // Logout
  Future<void> logout() async {
    await _client.auth.signOut();
  }
}
