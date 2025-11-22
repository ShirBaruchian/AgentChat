import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:firebase_auth/firebase_auth.dart' as firebase_auth;
import 'package:device_info_plus/device_info_plus.dart';
import 'dart:io';
import 'subscription_service.dart';
import 'api_service.dart';
import '../core/config/api_config.dart';

/// Service to track user usage (tokens/messages) using Firebase Anonymous Auth
/// This works like ChatOn - each device gets a unique anonymous user ID
/// that persists across app restarts without requiring sign-in
class UsageService extends ChangeNotifier {
  static const String _tokensUsedKey = 'tokens_used';
  static const String _deviceIdKey = 'device_id';
  static const int _freeTokensLimit = 6;
  
  int _tokensUsed = 0;
  bool _isLoading = false;
  final SubscriptionService _subscriptionService;
  final ApiService _apiService = ApiService();
  String? _deviceId;

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

  /// Load usage data from backend and sync with local storage
  /// Uses Firebase Anonymous Auth user ID as the key
  Future<void> _loadUsageData() async {
    _isLoading = true;
    notifyListeners();

    try {
      // Get user ID (Firebase UID or device ID)
      final userId = await getUserId();
      
      if (userId == 'anonymous') {
        _isLoading = false;
        notifyListeners();
        return;
      }
      
      // Try to sync with backend first
      try {
        final status = await _apiService.getUsageStatus(userId);
        
        _tokensUsed = status['tokens_used'] as int? ?? 0;
        
        // Update local storage to match backend
        final prefs = await SharedPreferences.getInstance();
        final key = '${_tokensUsedKey}_$userId';
        await prefs.setInt(key, _tokensUsed);
        
        // Update premium status if different
        final isPremium = status['is_premium'] as bool? ?? false;
        if (isPremium != _subscriptionService.isPremiumActive) {
          if (isPremium) {
            await _subscriptionService.activatePremium();
          }
        }
      } catch (e) {
        // Backend sync failed - use local storage as fallback
        final prefs = await SharedPreferences.getInstance();
        final key = '${_tokensUsedKey}_$userId';
        _tokensUsed = prefs.getInt(key) ?? 0;
      }
      
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
  /// Note: Token is actually consumed by the backend when message is sent
  /// This method just updates local state after backend confirms
  /// Returns true if token was used, false if no tokens remaining
  Future<bool> useToken() async {
    // Premium users have unlimited tokens
    if (_subscriptionService.isPremiumActive) {
      return true;
    }

    if (!hasTokensRemaining) {
      return false;
    }

    // Token is consumed by backend when message is sent
    // We'll refresh from backend after message is sent
    // For now, just update local state optimistically
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
  
  /// Sync token status with backend (call after sending message)
  Future<void> syncWithBackend() async {
    _isLoading = true;
    notifyListeners();
    
    try {
      // Get user ID (Firebase UID or device ID)
      final userId = await getUserId();
      
      if (userId == 'anonymous') {
        _isLoading = false;
        notifyListeners();
        return;
      }
      
      final status = await _apiService.getUsageStatus(userId);
      
      final tokensUsed = status['tokens_used'] as int? ?? 0;
      final isPremium = status['is_premium'] as bool? ?? false;
      
      // Only update if premium status changed
      if (isPremium != _subscriptionService.isPremiumActive) {
        if (isPremium) {
          await _subscriptionService.activatePremium();
        }
      }
      
      // Update tokens used
      _tokensUsed = tokensUsed;
      
      // Update local storage
      final prefs = await SharedPreferences.getInstance();
      final key = '${_tokensUsedKey}_$userId';
      await prefs.setInt(key, _tokensUsed);
      
      _isLoading = false;
      notifyListeners();
    } catch (e) {
      _isLoading = false;
      notifyListeners();
      // Continue with local state on error
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

  /// Get device ID as fallback when Firebase Auth is not available
  Future<String> _getDeviceId() async {
    if (_deviceId != null) return _deviceId!;
    
    try {
      final prefs = await SharedPreferences.getInstance();
      _deviceId = prefs.getString(_deviceIdKey);
      
      if (_deviceId == null) {
        final deviceInfo = DeviceInfoPlugin();
        if (Platform.isIOS) {
          final iosInfo = await deviceInfo.iosInfo;
          _deviceId = iosInfo.identifierForVendor ?? 'ios-${DateTime.now().millisecondsSinceEpoch}';
        } else if (Platform.isAndroid) {
          final androidInfo = await deviceInfo.androidInfo;
          _deviceId = androidInfo.id;
        } else {
          _deviceId = 'device-${DateTime.now().millisecondsSinceEpoch}';
        }
        
        await prefs.setString(_deviceIdKey, _deviceId!);
      }
      
      return _deviceId!;
    } catch (e) {
      _deviceId = 'device-${DateTime.now().millisecondsSinceEpoch}';
      return _deviceId!;
    }
  }

  /// Get user ID for API calls
  /// Returns Firebase Anonymous Auth UID if available, otherwise device ID
  Future<String> getUserId() async {
    var user = firebase_auth.FirebaseAuth.instance.currentUser;
    if (user != null) {
      return user.uid;
    }
    
    // Wait for anonymous auth to complete
    await Future.delayed(const Duration(milliseconds: 1000));
    user = firebase_auth.FirebaseAuth.instance.currentUser;
    if (user != null) {
      return user.uid;
    }
    
    // Fallback to device ID if Firebase Auth is not available
    return await _getDeviceId();
  }

  /// Refresh usage data
  Future<void> refresh() async {
    await _loadUsageData();
  }
}
