import 'package:flutter/material.dart';

/// Utility class for icon mapping
class IconHelper {
  IconHelper._(); // Private constructor

  /// Get icon for agent name
  static IconData getAgentIcon(String? agentName) {
    switch (agentName) {
      case 'CEO Coach':
        return Icons.business_center;
      case 'Creative Writer':
        return Icons.edit;
      case 'Tech Mentor':
        return Icons.code;
      case 'Life Coach':
        return Icons.favorite;
      default:
        return Icons.chat_bubble_outline;
    }
  }
}

