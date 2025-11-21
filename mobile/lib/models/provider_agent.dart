import 'ai_provider.dart';

class ProviderAgent {
  final String id;
  final String name;
  final String description;
  final AIProvider provider;
  final String modelId; // e.g., 'gpt-4', 'claude-3-opus', 'gemini-pro'
  final bool isDefault;

  ProviderAgent({
    required this.id,
    required this.name,
    required this.description,
    required this.provider,
    required this.modelId,
    this.isDefault = false,
  });

  static List<ProviderAgent> getDefaultAgents() {
    return [
      // Auto mode - no specific agent
      ProviderAgent(
        id: 'auto',
        name: 'Auto Select',
        description: 'Automatically chooses the best model',
        provider: AIProvider.auto,
        modelId: 'auto',
        isDefault: true,
      ),
      
      // OpenAI Agents
      ProviderAgent(
        id: 'openai-gpt-4',
        name: 'GPT-4',
        description: 'Most capable model, best for complex tasks',
        provider: AIProvider.openai,
        modelId: 'gpt-4',
      ),
      ProviderAgent(
        id: 'openai-gpt-4-turbo',
        name: 'GPT-4 Turbo',
        description: 'Faster GPT-4, great balance',
        provider: AIProvider.openai,
        modelId: 'gpt-4-turbo',
      ),
      ProviderAgent(
        id: 'openai-gpt-3.5-turbo',
        name: 'GPT-3.5 Turbo',
        description: 'Fast and cost-effective',
        provider: AIProvider.openai,
        modelId: 'gpt-3.5-turbo',
        isDefault: true,
      ),
      
      // Claude Agents
      ProviderAgent(
        id: 'claude-opus',
        name: 'Claude Opus',
        description: 'Most powerful Claude model',
        provider: AIProvider.claude,
        modelId: 'claude-3-opus-20240229',
      ),
      ProviderAgent(
        id: 'claude-sonnet',
        name: 'Claude Sonnet',
        description: 'Balanced performance and speed',
        provider: AIProvider.claude,
        modelId: 'claude-3-sonnet-20240229',
        isDefault: true,
      ),
      ProviderAgent(
        id: 'claude-haiku',
        name: 'Claude Haiku',
        description: 'Fastest Claude model',
        provider: AIProvider.claude,
        modelId: 'claude-3-haiku-20240307',
      ),
      
      // Gemini Agents
      ProviderAgent(
        id: 'gemini-ultra',
        name: 'Gemini Ultra',
        description: 'Most advanced Gemini model',
        provider: AIProvider.gemini,
        modelId: 'gemini-ultra',
      ),
      ProviderAgent(
        id: 'gemini-pro',
        name: 'Gemini Pro',
        description: 'Best for most tasks',
        provider: AIProvider.gemini,
        modelId: 'gemini-pro',
        isDefault: true,
      ),
      ProviderAgent(
        id: 'gemini-flash',
        name: 'Gemini Flash',
        description: 'Fast and efficient',
        provider: AIProvider.gemini,
        modelId: 'gemini-flash',
      ),
    ];
  }

  static List<ProviderAgent> getAgentsForProvider(AIProvider provider) {
    if (provider == AIProvider.auto) {
      return [getDefaultAgents().first];
    }
    return getDefaultAgents()
        .where((agent) => agent.provider == provider)
        .toList();
  }

  static ProviderAgent? getDefaultAgentForProvider(AIProvider provider) {
    final agents = getAgentsForProvider(provider);
    return agents.firstWhere(
      (agent) => agent.isDefault,
      orElse: () => agents.first,
    );
  }

  /// Create ProviderAgent from JSON (backend format)
  factory ProviderAgent.fromJson(Map<String, dynamic> json) {
    return ProviderAgent(
      id: json['id'] as String,
      name: json['name'] as String,
      description: json['description'] as String? ?? '',
      provider: aiProviderFromString(json['provider'] as String? ?? 'auto'),
      modelId: json['model_id'] as String? ?? json['id'] as String,
      isDefault: json['is_default'] as bool? ?? false,
    );
  }

  /// Convert to JSON for backend
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'description': description,
      'provider': provider.apiValue,
      'model_id': modelId,
      'is_default': isDefault,
    };
  }
}

