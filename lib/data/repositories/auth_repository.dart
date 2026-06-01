// lib/data/repositories/auth_repository.dart

import 'package:flutter/foundation.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../../core/constants/supabase_constants.dart';
import '../models/user_model.dart';

class AuthRepository {
  final SupabaseClient _client;

  AuthRepository(this._client);

  // Current auth user
  User? get currentAuthUser => _client.auth.currentUser;

  // Auth state stream
  Stream<AuthState> get authStateChanges => _client.auth.onAuthStateChange;

  // ---------------------------------------------------------------------------
  // Sign up
  // ---------------------------------------------------------------------------
  Future<AuthResponse> signUp({
    required String email,
    required String password,
    required String name,
    String phone = '',
    String role = 'user',
  }) async {
    final response = await _client.auth.signUp(
      email: email,
      password: password,
      data: {
        'name': name,
        'phone': phone,
        'role': role,
      },
    );
    return response;
  }

  // ---------------------------------------------------------------------------
  // Sign in
  // ---------------------------------------------------------------------------
  Future<AuthResponse> signIn({
    required String email,
    required String password,
  }) async {
    final response = await _client.auth.signInWithPassword(
      email: email,
      password: password,
    );
    return response;
  }

  // ---------------------------------------------------------------------------
  // Sign out
  // ---------------------------------------------------------------------------
  Future<void> signOut() async {
    await _client.auth.signOut();
  }

  // ---------------------------------------------------------------------------
  // Get user profile from public.users
  //
  // FIX 1: Use .maybeSingle() instead of .single()
  //        .single() throws an exception when 0 rows found — which was being
  //        silently caught and returning null, hiding the real error.
  //        .maybeSingle() returns null cleanly when no row exists.
  //
  // FIX 2: Re-throw the exception so AuthNotifier can show the real error
  //        message instead of always saying "profile not found".
  // ---------------------------------------------------------------------------
  Future<UserModel?> getUserProfile(String userId) async {
    try {
      final response = await _client
          .from(SupabaseConstants.usersTable)
          .select()
          .eq('id', userId)
          .maybeSingle(); // ← KEY FIX: was .single()

      if (response == null) {
        debugPrint('[AuthRepository] No profile row found for uid=$userId');
        return null;
      }

      return UserModel.fromJson(response);
    } on PostgrestException catch (e) {
      // Log the real Supabase error (RLS violation, network, etc.)
      debugPrint(
          '[AuthRepository] PostgrestException: ${e.code} — ${e.message}');
      debugPrint('[AuthRepository] Details: ${e.details}');
      debugPrint('[AuthRepository] Hint: ${e.hint}');
      rethrow; // Let AuthNotifier handle it and show proper message
    } catch (e) {
      debugPrint('[AuthRepository] Unexpected error in getUserProfile: $e');
      rethrow;
    }
  }

  // ---------------------------------------------------------------------------
  // Update user profile
  // ---------------------------------------------------------------------------
  Future<void> updateUserProfile(
    String userId,
    Map<String, dynamic> data,
  ) async {
    await _client
        .from(SupabaseConstants.usersTable)
        .update(data)
        .eq('id', userId);
  }
}
