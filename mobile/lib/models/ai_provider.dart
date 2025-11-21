enum AIProvider {
  auto,
  openai,
  claude,
  gemini,
}

extension AIProviderExtension on AIProvider {
  String get name {
    switch (this) {
      case AIProvider.auto:
        return 'Auto';
      case AIProvider.openai:
        return 'OpenAI';
      case AIProvider.claude:
        return 'Claude';
      case AIProvider.gemini:
        return 'Gemini';
    }
  }

  String get description {
    switch (this) {
      case AIProvider.auto:
        return 'Balanced quality and speed';
      case AIProvider.openai:
        return 'Fast and reliable';
      case AIProvider.claude:
        return 'High quality responses';
      case AIProvider.gemini:
        return 'Google\'s AI model';
    }
  }

  String get icon {
    switch (this) {
      case AIProvider.auto:
        return '⚡';
      case AIProvider.openai:
        return '🤖';
      case AIProvider.claude:
        return '🧠';
      case AIProvider.gemini:
        return '✨';
    }
  }

  int get color {
    switch (this) {
      case AIProvider.auto:
        return 0xFF10B981; // Green
      case AIProvider.openai:
        return 0xFF74AA9C; // OpenAI green
      case AIProvider.claude:
        return 0xFFD97706; // Claude orange
      case AIProvider.gemini:
        return 0xFF4285F4; // Google blue
    }
  }

  String get apiValue {
    switch (this) {
      case AIProvider.auto:
        return 'auto';
      case AIProvider.openai:
        return 'openai';
      case AIProvider.claude:
        return 'claude';
      case AIProvider.gemini:
        return 'gemini';
    }
  }
}

/// Convert string to AIProvider enum
AIProvider aiProviderFromString(String value) {
  switch (value.toLowerCase()) {
    case 'auto':
      return AIProvider.auto;
    case 'openai':
      return AIProvider.openai;
    case 'claude':
      return AIProvider.claude;
    case 'gemini':
      return AIProvider.gemini;
    default:
      return AIProvider.auto;
  }
}

