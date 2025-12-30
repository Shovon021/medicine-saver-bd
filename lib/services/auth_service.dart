import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

/// User model that maps from Supabase Auth User
class AppUser {
  final String id;
  final String email;
  final String? name;
  final String? photoUrl;

  AppUser({
    required this.id,
    required this.email,
    this.name,
    this.photoUrl,
  });

  factory AppUser.fromSupabaseUser(User user) {
    return AppUser(
      id: user.id,
      email: user.email ?? '',
      name: user.userMetadata?['full_name'] ?? 
            user.userMetadata?['name'] ?? 
            user.email?.split('@').first,
      photoUrl: user.userMetadata?['avatar_url'],
    );
  }
}

class AuthService extends ChangeNotifier {
  static final AuthService instance = AuthService._();
  AuthService._();

  final _supabase = Supabase.instance.client;
  static const _guestModeKey = 'is_guest_mode';

  AppUser? _currentUser;
  bool _isLoading = false;
  bool _isGuest = false;

  AppUser? get currentUser => _currentUser;
  bool get isLoading => _isLoading;
  bool get isLoggedIn => _currentUser != null;
  bool get isGuest => _isGuest;

  /// Initialize by checking current session or guest mode
  Future<void> init() async {
    // Check if user chose guest mode
    final prefs = await SharedPreferences.getInstance();
    _isGuest = prefs.getBool(_guestModeKey) ?? false;

    // Check Supabase session
    final session = _supabase.auth.currentSession;
    if (session != null) {
      _currentUser = AppUser.fromSupabaseUser(session.user);
      _isGuest = false; // Not a guest if logged in
      notifyListeners();
    }

    // Listen to auth state changes
    _supabase.auth.onAuthStateChange.listen((data) {
      final user = data.session?.user;
      if (user != null) {
        _currentUser = AppUser.fromSupabaseUser(user);
        _isGuest = false;
      } else {
        _currentUser = null;
      }
      notifyListeners();
    });
  }

  /// Set guest mode (skips login)
  Future<void> setGuestMode(bool value) async {
    _isGuest = value;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_guestModeKey, value);
    notifyListeners();
  }

  /// Sign In with Google using Supabase OAuth (opens web view)
  Future<String?> signInWithGoogle() async {
    _isLoading = true;
    notifyListeners();

    try {
      // Use Supabase's built-in OAuth flow
      // This opens a web view for Google Sign-In
      final success = await _supabase.auth.signInWithOAuth(
        OAuthProvider.google,
        redirectTo: 'io.supabase.flutter://login-callback/',
      );

      if (!success) {
        _isLoading = false;
        notifyListeners();
        return 'Sign in was cancelled';
      }

      // The auth state listener will handle updating _currentUser
      _isGuest = false;
      await setGuestMode(false);
      _isLoading = false;
      notifyListeners();
      return null; // Success
      
    } on AuthException catch (e) {
      _isLoading = false;
      notifyListeners();
      return e.message;
    } catch (e) {
      _isLoading = false;
      notifyListeners();
      debugPrint('Google Sign-In error: $e');
      return 'Sign in failed: ${e.toString()}';
    }
  }

  /// Sign Up with Email and Password
  Future<String?> signUp(String email, String password) async {
    _isLoading = true;
    notifyListeners();

    try {
      final response = await _supabase.auth.signUp(
        email: email,
        password: password,
      );

      if (response.user != null) {
        _currentUser = AppUser.fromSupabaseUser(response.user!);
        _isLoading = false;
        notifyListeners();
        return null; // Success
      } else {
        _isLoading = false;
        notifyListeners();
        return 'Sign up failed. Please try again.';
      }
    } on AuthException catch (e) {
      _isLoading = false;
      notifyListeners();
      return e.message;
    } catch (e) {
      _isLoading = false;
      notifyListeners();
      return e.toString();
    }
  }

  /// Sign In with Email and Password
  Future<String?> signIn(String email, String password) async {
    _isLoading = true;
    notifyListeners();

    try {
      final response = await _supabase.auth.signInWithPassword(
        email: email,
        password: password,
      );

      if (response.user != null) {
        _currentUser = AppUser.fromSupabaseUser(response.user!);
        _isLoading = false;
        notifyListeners();
        return null; // Success
      } else {
        _isLoading = false;
        notifyListeners();
        return 'Sign in failed. Please check your credentials.';
      }
    } on AuthException catch (e) {
      _isLoading = false;
      notifyListeners();
      return e.message;
    } catch (e) {
      _isLoading = false;
      notifyListeners();
      return e.toString();
    }
  }

  /// Sign Out
  Future<void> signOut() async {
    _isLoading = true;
    notifyListeners();

    await _supabase.auth.signOut();

    _currentUser = null;
    _isLoading = false;
    notifyListeners();
  }

  /// Reset Password
  Future<String?> resetPassword(String email) async {
    try {
      await _supabase.auth.resetPasswordForEmail(email);
      return null; // Success
    } on AuthException catch (e) {
      return e.message;
    } catch (e) {
      return e.toString();
    }
  }
}
