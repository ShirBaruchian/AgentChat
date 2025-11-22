import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:firebase_auth/firebase_auth.dart' as firebase_auth;
import 'subscription_service.dart';

/// Service to track user usage (tokens/messages) using Firebase Anonymous Auth
/// This works like ChatOn - each device gets a unique anonymous user ID
/// that persists across app restarts without requiring sign-in
class UsageService extends ChangeNotifier {
  static const String _tokensUsedKey = 'tokens_used';
  static const int _freeTokensLimit = 6;
  
  int _tokensUsed = 0;
  bool _isLoading = false;
  final SubscriptionService _subscriptionService;

  int get tokensUsed => _tokensUsed;
  int get tokensRemaining => _freeTokensLimit - _tokensUsed;
  bool get hasTokensRemaining => _tokensUsed < _freeTokensLimit;
  bool get isLoading => _isLoading;
  
  /// Get the current user ID (anonymous or authenticated)
  /// This is automatically managed by Firebase Auth
  String? get userId {
    final user = firebase_auth.FirebaseAuth.instance.currentUser;
    return user?.uid;
  }
  
  /// Check if user is anonymous (not signed in with email)
  bool get isAnonymous {
    final user = firebase_auth.FirebaseAuth.instance.currentUser;
    return user?.isAnonymous ?? true;
  }

  UsageService(this._subscriptionService) {
    _loadUsageData();
    // Listen to subscription changes - premium users get unlimited
    _subscriptionService.addListener(_onSubscriptionChanged);
  }

  void _onSubscriptionChanged() {
    // If user becomes premium, reset tokens
    if (_subscriptionService.isPremiumActive) {
      resetTokens();
    }
    notifyListeners();
  }

  @override
  void dispose() {
    _subscriptionService.removeListener(_onSubscriptionChanged);
    super.dispose();
  }

  /// Load usage data from local storage
  /// Uses Firebase Anonymous Auth user ID as the key
  Future<void> _loadUsageData() async {
    _isLoading = true;
    notifyListeners();

    try {
      final prefs = await SharedPreferences.getInstance();
      var user = firebase_auth.FirebaseAuth.instance.currentUser;
      
      if (user == null) {
        // Wait a bit for anonymous auth to complete
        await Future.delayed(const Duration(milliseconds: 500));
        user = firebase_auth.FirebaseAuth.instance.currentUser;
        if (user == null) {
          print('No user found, usage tracking disabled');
          return;
        }
      }
      
      // Use user ID as part of the key for per-device tracking
      final key = '${_tokensUsedKey}_${user.uid}';
      _tokensUsed = prefs.getInt(key) ?? 0;
      
      // Premium users have unlimited tokens
      if (_subscriptionService.isPremiumActive) {
        _tokensUsed = 0; // Reset for premium
      }
    } catch (e) {
      print('Error loading usage data: $e');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  /// Use a token (send a message)
  /// Returns true if token was used, false if no tokens remaining
  Future<bool> useToken() async {
    // Premium users have unlimited tokens
    if (_subscriptionService.isPremiumActive) {
      return true;
    }

    if (!hasTokensRemaining) {
      return false;
    }

    try {
      final prefs = await SharedPreferences.getInstance();
      final user = firebase_auth.FirebaseAuth.instance.currentUser;
      
      if (user == null) {
        print('No user found, cannot track usage');
        return false;
      }
      
      _tokensUsed++;
      final key = '${_tokensUsedKey}_${user.uid}';
      await prefs.setInt(key, _tokensUsed);
      notifyListeners();
      return true;
    } catch (e) {
      print('Error using token: $e');
      return false;
    }
  }

  /// Reset tokens (for testing or subscription activation)
  Future<void> resetTokens() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final user = firebase_auth.FirebaseAuth.instance.currentUser;
      
      if (user != null) {
        final key = '${_tokensUsedKey}_${user.uid}';
        _tokensUsed = 0;
        await prefs.setInt(key, 0);
        notifyListeners();
      }
    } catch (e) {
      print('Error resetting tokens: $e');
    }
  }

  /// Get user ID for API calls
  /// Returns Firebase Anonymous Auth UID (unique per device)
  Future<String> getUserId() async {
    final user = firebase_auth.FirebaseAuth.instance.currentUser;
    if (user != null) {
      return user.uid;
    }
    
    // Wait for anonymous auth to complete
    await Future.delayed(const Duration(milliseconds: 500));
    final currentUser = firebase_auth.FirebaseAuth.instance.currentUser;
    return currentUser?.uid ?? 'anonymous';
  }

  /// Refresh usage data
  Future<void> refresh() async {
    await _loadUsageData();
  }
}
