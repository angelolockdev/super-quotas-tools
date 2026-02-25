/// Repository for Supabase authentication operations.
///
/// Wraps [SupabaseClient.auth] to provide a clean interface
/// for sign-up, sign-in, sign-out, session restore, and
/// auth state streaming.
library;

import 'package:supabase_flutter/supabase_flutter.dart';

import '../../core/utils/logger.dart';

class AuthRepository {
  final SupabaseClient _client;

  AuthRepository(this._client);

  /// Stream of authentication state changes.
  Stream<AuthState> get authStateChanges => _client.auth.onAuthStateChange;

  /// The currently signed-in user, if any.
  User? get currentUser => _client.auth.currentUser;

  /// The current session, if valid.
  Session? get currentSession => _client.auth.currentSession;

  /// Sign up with email and password.
  Future<AuthResponse> signUp({
    required String email,
    required String password,
  }) async {
    SafeLogger.info('Attempting sign-up for email');
    return _client.auth.signUp(email: email, password: password);
  }

  /// Sign in with email and password.
  Future<AuthResponse> signIn({
    required String email,
    required String password,
  }) async {
    SafeLogger.info('Attempting sign-in');
    return _client.auth.signInWithPassword(email: email, password: password);
  }

  /// Sign out the current user.
  Future<void> signOut() async {
    SafeLogger.info('Signing out');
    await _client.auth.signOut();
  }

  /// Restore session from persistent storage.
  Future<Session?> restoreSession() async {
    try {
      final session = _client.auth.currentSession;
      if (session != null) {
        SafeLogger.info('Session restored');
      }
      return session;
    } catch (e, st) {
      SafeLogger.error('Session restore failed', error: e, stackTrace: st);
      return null;
    }
  }
}
