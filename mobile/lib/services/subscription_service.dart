import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:firebase_auth/firebase_auth.dart' as firebase_auth;

/// Service to manage user subscription status
class SubscriptionService extends ChangeNotifier {
  static const String _isPremiumKey = 'is_premium';
  static const String _premiumExpiryKey = 'premium_expiry';
  
  bool _isPremium = false;
  DateTime? _premiumExpiry;
  bool _isLoading = false;

  bool get isPremium => _isPremium;
  DateTime? get premiumExpiry => _premiumExpiry;
  bool get isLoading => _isLoading;

  SubscriptionService() {
    _loadSubscriptionStatus();
  }

  /// Load subscription status from local storage
  Future<void> _loadSubscriptionStatus() async {
    _isLoading = true;
    notifyListeners();

    try {
      final prefs = await SharedPreferences.getInstance();
      _isPremium = prefs.getBool(_isPremiumKey) ?? false;
      
      final expiryTimestamp = prefs.getInt(_premiumExpiryKey);
      if (expiryTimestamp != null) {
        _premiumExpiry = DateTime.fromMillisecondsSinceEpoch(expiryTimestamp);
        // Check if premium has expired
        if (_premiumExpiry!.isBefore(DateTime.now())) {
          _isPremium = false;
          await prefs.setBool(_isPremiumKey, false);
        }
      }

      // Also check with backend if user is authenticated
      final user = firebase_auth.FirebaseAuth.instance.currentUser;
      if (user != null) {
        await _syncWithBackend(user.uid);
      }
    } catch (e) {
      print('Error loading subscription status: $e');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  /// Sync subscription status with backend
  Future<void> _syncWithBackend(String userId) async {
    try {
      // TODO: Call backend API to get subscription status
      // For now, we'll use local storage
    } catch (e) {
      print('Error syncing subscription with backend: $e');
    }
  }

  /// Activate premium subscription
  Future<void> activatePremium({DateTime? expiryDate}) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      _isPremium = true;
      _premiumExpiry = expiryDate ?? DateTime.now().add(const Duration(days: 30));
      
      await prefs.setBool(_isPremiumKey, true);
      await prefs.setInt(_premiumExpiryKey, _premiumExpiry!.millisecondsSinceEpoch);
      
      // Sync with backend if user is authenticated
      final user = firebase_auth.FirebaseAuth.instance.currentUser;
      if (user != null) {
        // TODO: Update backend subscription status
      }
      
      notifyListeners();
    } catch (e) {
      print('Error activating premium: $e');
      rethrow;
    }
  }

  /// Cancel premium subscription
  Future<void> cancelPremium() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      _isPremium = false;
      _premiumExpiry = null;
      
      await prefs.setBool(_isPremiumKey, false);
      await prefs.remove(_premiumExpiryKey);
      
      // Sync with backend if user is authenticated
      final user = firebase_auth.FirebaseAuth.instance.currentUser;
      if (user != null) {
        // TODO: Update backend subscription status
      }
      
      notifyListeners();
    } catch (e) {
      print('Error canceling premium: $e');
      rethrow;
    }
  }

  /// Check if premium is active
  bool get isPremiumActive {
    if (!_isPremium) return false;
    if (_premiumExpiry == null) return true;
    return _premiumExpiry!.isAfter(DateTime.now());
  }

  /// Refresh subscription status
  Future<void> refresh() async {
    await _loadSubscriptionStatus();
  }
}

