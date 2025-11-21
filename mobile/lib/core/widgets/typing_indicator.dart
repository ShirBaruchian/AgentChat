import 'package:flutter/material.dart';
import '../constants/app_constants.dart';

/// Reusable typing indicator widget
class TypingIndicator extends StatelessWidget {
  final Color agentColor;
  final IconData? agentIcon;

  const TypingIndicator({
    super.key,
    required this.agentColor,
    this.agentIcon,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: AppConstants.spacingM),
      child: Row(
        children: [
          _buildAgentAvatar(),
          const SizedBox(width: AppConstants.spacingS),
          _buildTypingBubble(),
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

  Widget _buildTypingBubble() {
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: AppConstants.spacingL,
        vertical: AppConstants.spacingM,
      ),
      decoration: BoxDecoration(
        color: Colors.grey[900],
        borderRadius: const BorderRadius.only(
          topLeft: Radius.circular(AppConstants.radiusXL),
          topRight: Radius.circular(AppConstants.radiusXL),
          bottomLeft: Radius.circular(AppConstants.radiusS),
          bottomRight: Radius.circular(AppConstants.radiusXL),
        ),
        border: Border.all(
          color: const Color(0xFF10B981).withOpacity(0.3),
          width: 1,
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          _buildTypingDot(0),
          const SizedBox(width: AppConstants.spacingXS),
          _buildTypingDot(1),
          const SizedBox(width: AppConstants.spacingXS),
          _buildTypingDot(2),
        ],
      ),
    );
  }

  Widget _buildTypingDot(int index) {
    return TweenAnimationBuilder<double>(
      tween: Tween(begin: 0.0, end: 1.0),
      duration: AppConstants.animationDurationSlow,
      curve: Curves.easeInOut,
      builder: (context, value, child) {
        final delay = index * 0.2;
        final animatedValue = ((value + delay) % 1.0);
        return Container(
          width: 8,
          height: 8,
          decoration: BoxDecoration(
            color: agentColor.withOpacity(0.3 + (animatedValue * 0.5)),
            shape: BoxShape.circle,
          ),
        );
      },
    );
  }
}

