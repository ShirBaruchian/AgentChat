import 'package:flutter/material.dart';
import '../../models/message.dart';
import '../../models/ai_provider.dart';
import '../constants/app_constants.dart';
import '../constants/app_text_styles.dart';

/// Reusable message bubble widget
class MessageBubble extends StatelessWidget {
  final Message message;
  final Color agentColor;
  final IconData? agentIcon;
  final bool showProviderBadge;

  const MessageBubble({
    super.key,
    required this.message,
    required this.agentColor,
    this.agentIcon,
    this.showProviderBadge = true,
  });

  @override
  Widget build(BuildContext context) {
    final isUser = message.isUser;

    return Padding(
      padding: const EdgeInsets.only(bottom: AppConstants.spacingM),
      child: Row(
        mainAxisAlignment: isUser ? MainAxisAlignment.end : MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (!isUser) ...[
            _buildAgentAvatar(),
            const SizedBox(width: AppConstants.spacingS),
          ],
          Flexible(
            child: _buildBubble(isUser),
          ),
          if (isUser) ...[
            const SizedBox(width: AppConstants.spacingS),
            _buildUserAvatar(),
          ],
        ],
      ),
    );
  }

  Widget _buildAgentAvatar() {
    return Container(
      width: AppConstants.avatarSizeM,
      height: AppConstants.avatarSizeM,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            agentColor.withOpacity(0.3),
            agentColor.withOpacity(0.1),
          ],
        ),
        shape: BoxShape.circle,
        border: Border.all(
          color: agentColor.withOpacity(0.5),
          width: 1,
        ),
      ),
      child: Icon(
        agentIcon ?? Icons.chat_bubble_outline,
        color: agentColor,
        size: AppConstants.iconSizeS,
      ),
    );
  }

  Widget _buildUserAvatar() {
    return Container(
      width: AppConstants.avatarSizeM,
      height: AppConstants.avatarSizeM,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            Colors.grey[700]!,
            Colors.grey[800]!,
          ],
        ),
        shape: BoxShape.circle,
        border: Border.all(
          color: Colors.grey[600]!.withOpacity(0.5),
          width: 1,
        ),
      ),
      child: const Icon(
        Icons.person,
        size: AppConstants.iconSizeS,
        color: Colors.white,
      ),
    );
  }

  Widget _buildBubble(bool isUser) {
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: AppConstants.spacingL,
        vertical: AppConstants.spacingM,
      ),
      decoration: BoxDecoration(
        gradient: isUser
            ? LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  agentColor,
                  agentColor.withOpacity(0.8),
                ],
              )
            : null,
        color: isUser ? null : Colors.grey[900],
        borderRadius: BorderRadius.only(
          topLeft: const Radius.circular(AppConstants.radiusXL),
          topRight: const Radius.circular(AppConstants.radiusXL),
          bottomLeft: Radius.circular(isUser ? AppConstants.radiusXL : AppConstants.radiusS),
          bottomRight: Radius.circular(isUser ? AppConstants.radiusS : AppConstants.radiusXL),
        ),
        border: isUser
            ? null
            : Border.all(
                color: const Color(0xFF10B981).withOpacity(0.3),
                width: 1,
              ),
        boxShadow: [
          BoxShadow(
            color: isUser
                ? agentColor.withOpacity(0.3)
                : Colors.black.withOpacity(0.3),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            message.text,
            style: AppTextStyles.messageText,
          ),
          const SizedBox(height: AppConstants.spacingXS),
          Row(
            children: [
              Text(
                _formatTime(message.timestamp),
                style: AppTextStyles.messageTimestamp.copyWith(
                  color: isUser
                      ? Colors.white.withOpacity(0.7)
                      : Colors.white.withOpacity(0.5),
                ),
              ),
              if (!isUser && message.provider != null && showProviderBadge) ...[
                const SizedBox(width: AppConstants.spacingS),
                _buildProviderBadge(message.provider!),
              ],
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildProviderBadge(String providerString) {
    final provider = aiProviderFromString(providerString);
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: 6,
        vertical: 2,
      ),
      decoration: BoxDecoration(
        color: Color(provider.color).withOpacity(0.2),
        borderRadius: BorderRadius.circular(AppConstants.radiusS),
        border: Border.all(
          color: Color(provider.color).withOpacity(0.3),
          width: 0.5,
        ),
      ),
      child: Text(
        provider.icon,
        style: const TextStyle(fontSize: 10),
      ),
    );
  }

  String _formatTime(DateTime timestamp) {
    final now = DateTime.now();
    final difference = now.difference(timestamp);

    if (difference.inMinutes < 1) {
      return 'Just now';
    } else if (difference.inHours < 1) {
      return '${difference.inMinutes}m ago';
    } else if (difference.inDays < 1) {
      return '${difference.inHours}h ago';
    } else {
      return '${timestamp.hour.toString().padLeft(2, '0')}:${timestamp.minute.toString().padLeft(2, '0')}';
    }
  }
}

