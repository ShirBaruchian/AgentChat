import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:firebase_auth/firebase_auth.dart' as firebase_auth;
import '../core/config/api_config.dart';
import '../models/agent.dart';
import '../models/message.dart';

class ApiService {
  final http.Client _client;
  final firebase_auth.FirebaseAuth _auth;

  ApiService({
    http.Client? client,
    firebase_auth.FirebaseAuth? auth,
  })  : _client = client ?? http.Client(),
        _auth = auth ?? firebase_auth.FirebaseAuth.instance;

  /// Get authentication headers with Firebase ID token
  Future<Map<String, String>> _getHeaders() async {
    final headers = <String, String>{
      'Content-Type': 'application/json',
    };

    // Get Firebase ID token for authentication if available
    final user = _auth.currentUser;
    if (user != null) {
      try {
        final token = await user.getIdToken();
        headers['Authorization'] = 'Bearer $token';
      } catch (e) {
        print('Error getting ID token: $e');
      }
    }

    return headers;
  }

  /// Send a chat message to the backend
  Future<String> sendMessage({
    required String userId,
    required String agentId,
    required String message,
    List<Map<String, dynamic>>? conversationHistory,
  }) async {
    try {
      final headers = await _getHeaders();
      final url = Uri.parse('${ApiConfig.baseUrl}${ApiConfig.chatEndpoint}');

      final body = {
        'user_id': userId,
        'agent_id': agentId,
        'message': message,
        if (conversationHistory != null)
          'conversation_history': conversationHistory,
      };

      final response = await _client
          .post(
            url,
            headers: headers,
            body: jsonEncode(body),
          )
          .timeout(ApiConfig.sendTimeout);

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body) as Map<String, dynamic>;
        return data['response'] as String;
      } else if (response.statusCode == 429) {
        throw Exception('Rate limit exceeded. Please upgrade your plan.');
      } else if (response.statusCode == 400) {
        final error = jsonDecode(response.body) as Map<String, dynamic>;
        throw Exception(error['detail'] ?? 'Invalid request');
      } else {
        throw Exception(
            'Server error: ${response.statusCode} - ${response.body}');
      }
    } catch (e) {
      if (e is Exception) {
        rethrow;
      }
      throw Exception('Network error: ${e.toString()}');
    }
  }

  /// Get list of available agents
  Future<List<Agent>> getAgents() async {
    try {
      final headers = await _getHeaders();
      final url = Uri.parse('${ApiConfig.baseUrl}${ApiConfig.agentsEndpoint}');

      final response = await _client
          .get(
            url,
            headers: headers,
          )
          .timeout(ApiConfig.receiveTimeout);

      if (response.statusCode == 200) {
        final List<dynamic> data = jsonDecode(response.body);
        return data.map((json) => Agent.fromJson(json)).toList();
      } else {
        throw Exception(
            'Failed to load agents: ${response.statusCode} - ${response.body}');
      }
    } catch (e) {
      if (e is Exception) {
        rethrow;
      }
      throw Exception('Network error: ${e.toString()}');
    }
  }

  /// Get subscription status
  Future<Map<String, dynamic>> getSubscriptionStatus(String userId) async {
    try {
      final headers = await _getHeaders();
      final url = Uri.parse(
          '${ApiConfig.baseUrl}${ApiConfig.subscriptionEndpoint}/status/$userId');

      final response = await _client
          .get(
            url,
            headers: headers,
          )
          .timeout(ApiConfig.receiveTimeout);

      if (response.statusCode == 200) {
        return jsonDecode(response.body) as Map<String, dynamic>;
      } else {
        throw Exception(
            'Failed to load subscription status: ${response.statusCode}');
      }
    } catch (e) {
      if (e is Exception) {
        rethrow;
      }
      throw Exception('Network error: ${e.toString()}');
    }
  }

  /// Check if backend is healthy
  Future<bool> checkHealth() async {
    try {
      final url = Uri.parse('${ApiConfig.baseUrl}${ApiConfig.healthEndpoint}');
      final response = await _client
          .get(url)
          .timeout(const Duration(seconds: 5));

      return response.statusCode == 200;
    } catch (e) {
      return false;
    }
  }

  void dispose() {
    _client.close();
  }
}

