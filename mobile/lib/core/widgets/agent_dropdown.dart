import 'package:flutter/material.dart';
import '../../models/provider_agent.dart';
import '../../models/ai_provider.dart';
import '../constants/app_constants.dart';
import '../constants/app_text_styles.dart';

/// Reusable agent dropdown widget
class AgentDropdown extends StatelessWidget {
  final ProviderAgent? selectedAgent;
  final List<ProviderAgent> allAgents;
  final bool isLoading;
  final ValueChanged<ProviderAgent>? onChanged;

  const AgentDropdown({
    super.key,
    required this.selectedAgent,
    required this.allAgents,
    this.isLoading = false,
    this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    if (isLoading || allAgents.isEmpty) {
      return _buildLoadingIndicator();
    }

    final agent = selectedAgent ?? allAgents.first;
    final providerColor = Color(agent.provider.color);

    return Container(
      constraints: const BoxConstraints(maxWidth: AppConstants.dropdownMaxWidth),
      padding: const EdgeInsets.symmetric(
        horizontal: AppConstants.spacingS,
        vertical: AppConstants.spacingXS,
      ),
      decoration: BoxDecoration(
        color: providerColor.withOpacity(0.2),
        borderRadius: BorderRadius.circular(AppConstants.radiusXL),
        border: Border.all(
          color: providerColor.withOpacity(0.5),
          width: 1,
        ),
      ),
      child: DropdownButton<ProviderAgent>(
        value: agent,
        isDense: true,
        isExpanded: true,
        underline: const SizedBox.shrink(),
        icon: Icon(
          Icons.arrow_drop_down,
          color: providerColor,
          size: AppConstants.iconSizeM,
        ),
        dropdownColor: Colors.grey[900],
        menuMaxHeight: AppConstants.dropdownMenuMaxHeight,
        style: AppTextStyles.labelMedium,
        items: _buildDropdownItems(agent, providerColor),
        onChanged: onChanged != null
            ? (ProviderAgent? newAgent) {
                if (newAgent != null) {
                  onChanged!(newAgent);
                }
              }
            : null,
        selectedItemBuilder: (context) => _buildSelectedItems(providerColor),
      ),
    );
  }

  Widget _buildLoadingIndicator() {
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: AppConstants.spacingM,
        vertical: 6,
      ),
      decoration: BoxDecoration(
        color: Colors.grey[800],
        borderRadius: BorderRadius.circular(AppConstants.radiusXL),
        border: Border.all(
          color: Colors.grey[700]!,
          width: 1,
        ),
      ),
      child: const SizedBox(
        width: 16,
        height: 16,
        child: CircularProgressIndicator(
          strokeWidth: 2,
          color: Colors.white70,
        ),
      ),
    );
  }

  List<DropdownMenuItem<ProviderAgent>> _buildDropdownItems(
    ProviderAgent selectedAgent,
    Color providerColor,
  ) {
    return allAgents.map((agent) {
      final agentProviderColor = Color(agent.provider.color);
      final isSelected = agent.id == selectedAgent.id;
      return DropdownMenuItem<ProviderAgent>(
        value: agent,
        child: Container(
          constraints: const BoxConstraints(
            maxWidth: AppConstants.dropdownMenuMaxWidth,
          ),
          height: AppConstants.dropdownItemHeight,
          padding: const EdgeInsets.symmetric(horizontal: AppConstants.spacingM),
          child: Row(
            children: [
              Container(
                width: 32,
                height: 32,
                decoration: BoxDecoration(
                  color: agentProviderColor.withOpacity(0.2),
                  shape: BoxShape.circle,
                  border: Border.all(
                    color: agentProviderColor.withOpacity(0.5),
                    width: 1,
                  ),
                ),
                child: Center(
                  child: Text(
                    agent.provider.icon,
                    style: const TextStyle(fontSize: 16),
                  ),
                ),
              ),
              const SizedBox(width: AppConstants.spacingM),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      agent.name,
                      style: AppTextStyles.bodySmall.copyWith(
                        fontWeight: FontWeight.w600,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 2),
                    Text(
                      agent.description,
                      style: AppTextStyles.captionSmall,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
              ),
              if (isSelected) ...[
                const SizedBox(width: 6),
                Icon(
                  Icons.check_circle,
                  color: agentProviderColor,
                  size: 18,
                ),
              ],
            ],
          ),
        ),
      );
    }).toList();
  }

  List<Widget> _buildSelectedItems(Color providerColor) {
    return allAgents.map((agent) {
      return Container(
        alignment: Alignment.centerLeft,
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              agent.provider.icon,
              style: const TextStyle(fontSize: 12),
            ),
            const SizedBox(width: 4),
            Flexible(
              child: Text(
                agent.name,
                style: AppTextStyles.labelSmall.copyWith(
                  color: providerColor,
                ),
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ],
        ),
      );
    }).toList();
  }
}

