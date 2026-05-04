import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart' as supabase;
import '../../../../core/services/supabase_service.dart';

/// State for authentication
class AuthState {
  final bool isLoading;
  final String? errorMessage;
  final supabase.User? user;

  AuthState({
    this.isLoading = false,
    this.errorMessage,
    this.user,
  });

  bool get isAuthenticated => user != null;

  AuthState copyWith({
    bool? isLoading,
    String? errorMessage,
    supabase.User? user,
  }) {
    return AuthState(
      isLoading: isLoading ?? this.isLoading,
      errorMessage: errorMessage,
      user: user ?? this.user,
    );
  }
}

/// Notifier for authentication state
class AuthNotifier extends StateNotifier<AuthState> {
  final SupabaseService _supabaseService;

  AuthNotifier(this._supabaseService) : super(AuthState(user: _supabaseService.currentUser)) {
    // Listen to auth state changes
    _supabaseService.authStateChanges.listen((event) {
      state = state.copyWith(user: event.session?.user);
    });
  }

  /// Sign up with email and password
  Future<void> signUp({
    required String email,
    required String password,
    String? fullName,
  }) async {
    state = state.copyWith(isLoading: true, errorMessage: null);
    try {
      await _supabaseService.signUpWithEmail(
        email: email,
        password: password,
      );

      if (fullName != null) {
        // Wait a bit for the session to be established
        await Future.delayed(const Duration(milliseconds: 500));
        await _supabaseService.updateUserProfile(
          data: {'full_name': fullName},
        );
      }
      
      state = state.copyWith(isLoading: false);
    } catch (e) {
      state = state.copyWith(isLoading: false, errorMessage: e.toString());
    }
  }

  /// Sign in with email and password
  Future<void> signIn({
    required String email,
    required String password,
  }) async {
    state = state.copyWith(isLoading: true, errorMessage: null);
    try {
      await _supabaseService.signInWithEmail(
        email: email,
        password: password,
      );
      state = state.copyWith(isLoading: false);
    } catch (e) {
      state = state.copyWith(isLoading: false, errorMessage: e.toString());
    }
  }

  /// Sign in with Google
  Future<void> signInWithGoogle() async {
    state = state.copyWith(isLoading: true, errorMessage: null);
    try {
      await _supabaseService.signInWithGoogle();
      state = state.copyWith(isLoading: false);
    } catch (e) {
      state = state.copyWith(isLoading: false, errorMessage: e.toString());
    }
  }

  /// Sign out
  Future<void> signOut() async {
    state = state.copyWith(isLoading: true, errorMessage: null);
    try {
      await _supabaseService.signOut();
      state = state.copyWith(isLoading: false);
    } catch (e) {
      state = state.copyWith(isLoading: false, errorMessage: e.toString());
    }
  }

  /// Clear error message
  void clearError() {
    state = state.copyWith(errorMessage: null);
  }
}

/// Provider for AuthNotifier
final authProvider = StateNotifierProvider<AuthNotifier, AuthState>((ref) {
  final supabaseService = ref.watch(supabaseServiceProvider);
  return AuthNotifier(supabaseService);
});
