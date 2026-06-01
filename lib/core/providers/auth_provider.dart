// lib/core/providers/auth_provider.dart

import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../../data/models/user_model.dart';
import '../../data/repositories/auth_repository.dart';

// ---------------------------------------------------------------------------
// Supabase client provider
// ---------------------------------------------------------------------------
final supabaseClientProvider = Provider<SupabaseClient>((ref) {
  return Supabase.instance.client;
});

// Auth repository provider
final authRepositoryProvider = Provider<AuthRepository>((ref) {
  return AuthRepository(ref.watch(supabaseClientProvider));
});

// ---------------------------------------------------------------------------
// Authentication state
// ---------------------------------------------------------------------------
class AuthState {
  final UserModel? user;
  final bool isLoading;
  final String? error;

  const AuthState({
    this.user,
    this.isLoading = false,
    this.error,
  });

  bool get isAuthenticated => user != null;

  // FIX: use role field instead of non-existent isAdmin getter on UserModel
  bool get isAdmin => user?.role == 'admin';

  AuthState copyWith({
    UserModel? user,
    bool? isLoading,
    String? error,
    bool clearUser = false,
    bool clearError = false,
  }) {
    return AuthState(
      user: clearUser ? null : user ?? this.user,
      isLoading: isLoading ?? this.isLoading,
      error: clearError ? null : error ?? this.error,
    );
  }
}

// ---------------------------------------------------------------------------
// Authentication notifier
// ---------------------------------------------------------------------------
class AuthNotifier extends StateNotifier<AuthState> {
  final AuthRepository _repo;
  StreamSubscription<AuthState>? _authSub;

  AuthNotifier(this._repo) : super(const AuthState(isLoading: true)) {
    _init();
  }

  // -------------------------------------------------------------------------
  // Initialise — check existing session + listen for future auth events
  // -------------------------------------------------------------------------
  void _init() {
    final authUser = _repo.currentAuthUser;

    if (authUser != null) {
      // Already logged in — load profile
      _loadProfile(authUser.id);
    } else {
      state = const AuthState(isLoading: false);
    }

    // React to Supabase auth events (signIn / signOut / tokenRefresh …)
    _authSub = _repo.authStateChanges.listen((supabaseAuthState) async {
      if (supabaseAuthState.event == AuthChangeEvent.signedIn &&
          supabaseAuthState.session != null) {
        await _loadProfile(supabaseAuthState.session!.user.id);
      } else if (supabaseAuthState.event == AuthChangeEvent.signedOut) {
        state = const AuthState(isLoading: false);
      }
    }) as StreamSubscription<AuthState>?;
  }

  // -------------------------------------------------------------------------
  // Load profile from public.users
  // FIX: do NOT call signOut when profile is missing — only set error state
  // -------------------------------------------------------------------------
  Future<void> _loadProfile(String userId) async {
    state = state.copyWith(isLoading: true, clearError: true);

    try {
      final profile = await _repo.getUserProfile(userId);

      if (profile != null) {
        state = AuthState(user: profile); // isLoading defaults to false
      } else {
        // Profile row missing in public.users — inform user but keep session
        // so they can retry or the admin can fix the DB trigger.
        state = const AuthState(
          isLoading: false,
          error:
              'Profile not found. Please contact support or try again later.',
        );
        debugPrint('[AuthNotifier] No profile row for uid=$userId');
      }
    } catch (e) {
      state = AuthState(
        isLoading: false,
        error: _parseError(e.toString()),
      );
      debugPrint('[AuthNotifier] _loadProfile error: $e');
    }
  }

  // -------------------------------------------------------------------------
  // Login
  // FIX: call signIn() not login() — matches AuthRepository API
  // -------------------------------------------------------------------------
  Future<bool> login(String email, String password) async {
    state = state.copyWith(isLoading: true, clearError: true);

    try {
      await _repo.signIn(email: email, password: password);
      // Profile will be loaded by the authStateChanges listener above
      return true;
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        error: _parseError(e.toString()),
      );
      return false;
    }
  }

  // -------------------------------------------------------------------------
  // Register
  // FIX: call signUp() not register() — matches AuthRepository API
  // -------------------------------------------------------------------------
  Future<bool> register({
    required String name,
    required String email,
    required String phone,
    required String password,
  }) async {
    state = state.copyWith(isLoading: true, clearError: true);

    try {
      await _repo.signUp(
        name: name,
        email: email,
        phone: phone,
        password: password,
      );
      // Profile will be loaded by the authStateChanges listener above
      return true;
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        error: _parseError(e.toString()),
      );
      return false;
    }
  }

  // -------------------------------------------------------------------------
  // Logout
  // FIX: call signOut() not logout() — matches AuthRepository API
  // -------------------------------------------------------------------------
  Future<void> logout() async {
    state = state.copyWith(isLoading: true, clearError: true);
    try {
      await _repo.signOut();
      state = const AuthState(isLoading: false);
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        error: _parseError(e.toString()),
      );
    }
  }

  // -------------------------------------------------------------------------
  // Error parser
  // -------------------------------------------------------------------------
  String _parseError(String raw) {
    if (raw.contains('Invalid login credentials')) {
      return 'Invalid email or password';
    }
    if (raw.contains('User already registered')) {
      return 'This email is already registered';
    }
    if (raw.contains('Password should be at least')) {
      return 'Password must contain at least 6 characters';
    }
    if (raw.contains('network') || raw.contains('SocketException')) {
      return 'No internet connection. Please try again';
    }
    if (raw.contains('profile') || raw.contains('not found')) {
      return 'Profile not found. Please contact support.';
    }
    return 'An error occurred. Please try again';
  }

  @override
  void dispose() {
    _authSub?.cancel();
    super.dispose();
  }
}

// ---------------------------------------------------------------------------
// Providers
// ---------------------------------------------------------------------------
final authProvider = StateNotifierProvider<AuthNotifier, AuthState>((ref) {
  return AuthNotifier(ref.watch(authRepositoryProvider));
});

final currentUserProvider = Provider<UserModel?>((ref) {
  return ref.watch(authProvider).user;
});

final isAdminProvider = Provider<bool>((ref) {
  return ref.watch(authProvider).isAdmin;
});
