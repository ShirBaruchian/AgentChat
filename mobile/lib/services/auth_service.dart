import 'package:flutter/foundation.dart';
import 'package:firebase_auth/firebase_auth.dart' as firebase_auth;

/// Custom exception class for authentication errors
class AuthException implements Exception {
  final String message;
  AuthException(this.message);
  
  @override
  String toString() => message;
}

class AuthService extends ChangeNotifier {
  final firebase_auth.FirebaseAuth _auth = firebase_auth.FirebaseAuth.instance;
  bool _isLoading = false;

  firebase_auth.User? get currentUser => _auth.currentUser;
  bool get isLoading => _isLoading;

  AuthService() {
    // Listen to auth state changes
    _auth.authStateChanges().listen((firebase_auth.User? user) {
      notifyListeners();
    });
    
    // Initialize loading state
    _isLoading = false;
    notifyListeners();
  }

  Future<void> signInWithEmailAndPassword(
    String email,
    String password,
  ) async {
    _isLoading = true;
    notifyListeners();

    try {
      await _auth.signInWithEmailAndPassword(
        email: email.trim(),
        password: password,
      );
      _isLoading = false;
      notifyListeners();
    } on firebase_auth.FirebaseAuthException catch (e) {
      String errorMessage;
      switch (e.code.toLowerCase()) {
        case 'user-not-found':
          errorMessage = 'No user found with that email.';
          break;
        case 'wrong-password':
          errorMessage = 'Wrong password provided.';
          break;
        case 'invalid-credential':
        case 'invalid-login-credentials':
          errorMessage = 'Invalid email or password. Please check your credentials and try again.';
          break;
        case 'invalid-email':
          errorMessage = 'The email address is invalid.';
          break;
        case 'user-disabled':
          errorMessage = 'This user account has been disabled.';
          break;
        case 'too-many-requests':
          errorMessage = 'Too many requests. Please try again later.';
          break;
        case 'operation-not-allowed':
          errorMessage = 'Email/password accounts are not enabled. Please enable it in Firebase Console.';
          break;
        case 'configuration-not-found':
          errorMessage = 'Firebase configuration not found. Please check that Email/Password is enabled in Firebase Console.';
          break;
        default:
          errorMessage = e.message ?? 'An error occurred: ${e.code}';
          if (e.message?.contains('INVALID_LOGIN_CREDENTIALS') == true ||
              e.code.contains('INVALID') || 
              e.code.contains('invalid')) {
            errorMessage = 'Invalid email or password. Please check your credentials and try again.';
          }
      }
      _isLoading = false;
      throw AuthException(errorMessage);
    } catch (e) {
      if (e is AuthException) {
        _isLoading = false;
        rethrow;
      }
      final errorStr = e.toString().toLowerCase();
      if (errorStr.contains('configuration_not_found') || 
          errorStr.contains('invalid_login_credentials') ||
          errorStr.contains('invalid_credential') ||
          errorStr.contains('wrong-password') ||
          errorStr.contains('user-not-found')) {
        _isLoading = false;
        throw AuthException('Invalid email or password. Please check your credentials and try again.');
      }
      _isLoading = false;
      throw AuthException('Failed to sign in: ${e.toString()}');
    }
  }

  Future<void> signUpWithEmailAndPassword(
    String email,
    String password,
  ) async {
    try {
      _isLoading = true;
      notifyListeners();

      await _auth.createUserWithEmailAndPassword(
        email: email.trim(),
        password: password,
      );
    } on firebase_auth.FirebaseAuthException catch (e) {
      String errorMessage;
      switch (e.code) {
        case 'weak-password':
          errorMessage = 'The password provided is too weak.';
          break;
        case 'email-already-in-use':
          errorMessage = 'An account already exists for that email.';
          break;
        case 'invalid-email':
          errorMessage = 'The email address is invalid.';
          break;
        case 'operation-not-allowed':
          errorMessage = 'Email/password accounts are not enabled.';
          break;
        default:
          errorMessage = 'An error occurred: ${e.message}';
      }
      throw AuthException(errorMessage);
    } catch (e) {
      if (e is AuthException) {
        rethrow;
      }
      throw AuthException('Failed to sign up: ${e.toString()}');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> signOut() async {
    try {
      _isLoading = true;
      notifyListeners();
      await _auth.signOut();
    } catch (e) {
      throw Exception('Failed to sign out: ${e.toString()}');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> sendPasswordResetEmail(String email) async {
    try {
      await _auth.sendPasswordResetEmail(email: email.trim());
    } on firebase_auth.FirebaseAuthException catch (e) {
      String errorMessage;
      switch (e.code) {
        case 'user-not-found':
          errorMessage = 'No user found with that email.';
          break;
        case 'invalid-email':
          errorMessage = 'The email address is invalid.';
          break;
        default:
          errorMessage = 'An error occurred: ${e.message}';
      }
      throw Exception(errorMessage);
    } catch (e) {
      throw Exception('Failed to send password reset email: ${e.toString()}');
    }
  }
}
