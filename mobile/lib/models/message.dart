class Message {
  final String id;
  final String text;
  final bool isUser;
  final DateTime timestamp;
  final String? agentId;
  final String? provider; // AI provider used (e.g., 'auto', 'openai', 'claude', 'gemini')

  Message({
    required this.id,
    required this.text,
    required this.isUser,
    required this.timestamp,
    this.agentId,
    this.provider,
  });

  Message copyWith({
    String? id,
    String? text,
    bool? isUser,
    DateTime? timestamp,
    String? agentId,
    String? provider,
  }) {
    return Message(
      id: id ?? this.id,
      text: text ?? this.text,
      isUser: isUser ?? this.isUser,
      timestamp: timestamp ?? this.timestamp,
      agentId: agentId ?? this.agentId,
      provider: provider ?? this.provider,
    );
  }
}

