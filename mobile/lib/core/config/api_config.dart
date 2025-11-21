class ApiConfig {
  // Backend API base URL
  // For local development: 'http://localhost:8000'
  // For production: 'https://your-api-domain.com'
  static const String baseUrl = String.fromEnvironment(
    'API_BASE_URL',
    defaultValue: 'http://localhost:8000',
  );

  // API endpoints
  static const String chatEndpoint = '/api/chat/message';
  static const String agentsEndpoint = '/api/agents';
  static const String providerAgentsEndpoint = '/api/provider-agents'; // Endpoint for AI provider models
  static const String subscriptionEndpoint = '/api/subscription';
  static const String healthEndpoint = '/health';

  // Timeout durations
  static const Duration connectTimeout = Duration(seconds: 30);
  static const Duration receiveTimeout = Duration(seconds: 30);
  static const Duration sendTimeout = Duration(seconds: 30);
}


