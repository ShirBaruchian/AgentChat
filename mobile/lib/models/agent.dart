class Agent {
  final String id;
  final String name;
  final String description;
  final String? persona;
  final String? avatarUrl;
  final String? category;
  // UI-specific fields (not from backend)
  final String? icon;
  final int? color;

  Agent({
    required this.id,
    required this.name,
    required this.description,
    this.persona,
    this.avatarUrl,
    this.category,
    this.icon,
    this.color,
  });

  /// Create Agent from JSON (backend format)
  factory Agent.fromJson(Map<String, dynamic> json) {
    // Map backend agent to UI agent
    // Default icons and colors based on agent name/type
    final agentId = json['id'] as String;
    final agentName = json['name'] as String;
    
    return Agent(
      id: agentId,
      name: agentName,
      description: json['description'] as String? ?? '',
      persona: json['persona'] as String?,
      avatarUrl: json['avatar_url'] as String?,
      category: json['category'] as String?,
      icon: _getIconForAgent(agentId, agentName),
      color: _getColorForAgent(agentId, agentName),
    );
  }

  /// Convert to JSON for backend
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'description': description,
      if (persona != null) 'persona': persona,
      if (avatarUrl != null) 'avatar_url': avatarUrl,
      if (category != null) 'category': category,
    };
  }

  /// Get icon for agent based on ID or name
  static String _getIconForAgent(String id, String name) {
    final lowerId = id.toLowerCase();
    final lowerName = name.toLowerCase();
    
    if (lowerId.contains('ceo') || lowerName.contains('ceo')) {
      return 'Icons.business_center';
    } else if (lowerId.contains('writer') || lowerName.contains('writer')) {
      return 'Icons.edit';
    } else if (lowerId.contains('tech') || lowerName.contains('tech')) {
      return 'Icons.code';
    } else if (lowerId.contains('life') || lowerName.contains('life')) {
      return 'Icons.favorite';
    }
    return 'Icons.chat_bubble_outline';
  }

  /// Get color for agent based on ID or name
  static int _getColorForAgent(String id, String name) {
    final lowerId = id.toLowerCase();
    final lowerName = name.toLowerCase();
    
    if (lowerId.contains('ceo') || lowerName.contains('ceo')) {
      return 0xFF2196F3; // Blue
    } else if (lowerId.contains('writer') || lowerName.contains('writer')) {
      return 0xFF9C27B0; // Purple
    } else if (lowerId.contains('tech') || lowerName.contains('tech')) {
      return 0xFF4CAF50; // Green
    } else if (lowerId.contains('life') || lowerName.contains('life')) {
      return 0xFFE91E63; // Pink
    }
    return 0xFF757575; // Grey
  }
}
