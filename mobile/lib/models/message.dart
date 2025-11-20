class Message {
  final String id;
  final String text;
  final bool isUser;
  final DateTime timestamp;
  final String? agentId;

  Message({
    required this.id,
    required this.text,
    required this.isUser,
    required this.timestamp,
    this.agentId,
  });

  Message copyWith({
    String? id,
    String? text,
    bool? isUser,
    DateTime? timestamp,
    String? agentId,
  }) {
    return Message(
      id: id ?? this.id,
      text: text ?? this.text,
      isUser: isUser ?? this.isUser,
      timestamp: timestamp ?? this.timestamp,
      agentId: agentId ?? this.agentId,
    );
  }
}

