import 'package:flutter/foundation.dart';

// Temporary mock user for development
class MockUser {
  final String uid;
  final String email;
  
  MockUser({required this.uid, required this.email});
}

class AuthService extends ChangeNotifier {
  // TODO: Replace with Firebase Auth when Firebase is configured
  MockUser? _currentUser;
  bool _isLoading = false;

  MockUser? get currentUser => _currentUser;
  bool get isLoading => _isLoading;

  AuthService() {
    // Simulate loading
    Future.delayed(const Duration(milliseconds: 500), () {
      _isLoading = false;
      notifyListeners();
    });
  }

  Future<void> signInWithEmailAndPassword(
    String email,
    String password,
  ) async {
    // Mock authentication for development
    // Accepts any credentials, but you can use these test accounts:
    // Email: test@example.com, Password: password123
    // Email: demo@aiagent.com, Password: demo123
    // Email: user@test.com, Password: test123
    
    await Future.delayed(const Duration(seconds: 1));
    _currentUser = MockUser(uid: 'mock-uid-${DateTime.now().millisecondsSinceEpoch}', email: email);
    notifyListeners();
  }

  Future<void> signUpWithEmailAndPassword(
    String email,
    String password,
  ) async {
    // Mock sign up for development
    // Accepts any email and password (minimum 6 characters)
    
    await Future.delayed(const Duration(seconds: 1));
    _currentUser = MockUser(uid: 'mock-uid-${DateTime.now().millisecondsSinceEpoch}', email: email);
    notifyListeners();
  }

  Future<void> signOut() async {
    _currentUser = null;
    notifyListeners();
  }
}

