import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:firebase_auth/firebase_auth.dart' as firebase_auth;
import '../../../../core/constants/app_constants.dart';
import '../../../../core/constants/app_text_styles.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../services/onboarding_service.dart';
import '../../../../services/subscription_service.dart';
import '../../../../services/auth_service.dart';

/// Debug menu - only accessible in debug mode
/// Access by tapping the settings icon 5 times quickly
class DebugMenuScreen extends StatelessWidget {
  const DebugMenuScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.backgroundColor,
      appBar: AppBar(
        title: const Text('Debug Menu'),
        backgroundColor: Colors.grey[900],
      ),
      body: ListView(
        padding: const EdgeInsets.all(AppConstants.spacingL),
        children: [
          _buildSection(
            context,
            title: 'Reset Options',
            children: [
              _buildResetButton(
                context,
                title: 'Reset Onboarding',
                description: 'Show onboarding screen again',
                onTap: () async {
                  await OnboardingService.resetOnboarding();
                  if (context.mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('Onboarding reset! Restart the app.'),
                        backgroundColor: AppTheme.primaryColor,
                      ),
                    );
                  }
                },
              ),
              const SizedBox(height: AppConstants.spacingM),
              _buildResetButton(
                context,
                title: 'Clear Premium Status',
                description: 'Remove premium subscription',
                onTap: () async {
                  final subscriptionService = context.read<SubscriptionService>();
                  await subscriptionService.cancelPremium();
                  if (context.mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('Premium status cleared!'),
                        backgroundColor: AppTheme.primaryColor,
                      ),
                    );
                  }
                },
              ),
              const SizedBox(height: AppConstants.spacingM),
              _buildResetButton(
                context,
                title: 'Reset All Data',
                description: 'Clear onboarding, premium, and all app data',
                isDestructive: true,
                onTap: () async {
                  await OnboardingService.resetOnboarding();
                  final subscriptionService = context.read<SubscriptionService>();
                  await subscriptionService.cancelPremium();
                  if (context.mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('All data cleared! Restart the app.'),
                        backgroundColor: AppTheme.primaryColor,
                      ),
                    );
                  }
                },
              ),
            ],
          ),
          const SizedBox(height: AppConstants.spacingXXL),
          _buildSection(
            context,
            title: 'User Info',
            children: [
              Consumer<AuthService>(
                builder: (context, authService, _) {
                  final user = authService.currentUser;
                  return Container(
                    padding: const EdgeInsets.all(AppConstants.spacingM),
                    decoration: BoxDecoration(
                      color: Colors.grey[900],
                      borderRadius: BorderRadius.circular(AppConstants.radiusM),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'User ID: ${user?.uid ?? "Not signed in"}',
                          style: AppTextStyles.bodySmall,
                        ),
                        const SizedBox(height: AppConstants.spacingXS),
                        Text(
                          'Email: ${user?.email ?? "Anonymous"}',
                          style: AppTextStyles.caption,
                        ),
                        const SizedBox(height: AppConstants.spacingXS),
                        Text(
                          'Is Anonymous: ${user?.isAnonymous ?? false}',
                          style: AppTextStyles.caption,
                        ),
                      ],
                    ),
                  );
                },
              ),
            ],
          ),
          const SizedBox(height: AppConstants.spacingXXL),
          _buildSection(
            context,
            title: 'Premium Status',
            children: [
              Consumer<SubscriptionService>(
                builder: (context, subscriptionService, _) {
                  return Container(
                    padding: const EdgeInsets.all(AppConstants.spacingM),
                    decoration: BoxDecoration(
                      color: Colors.grey[900],
                      borderRadius: BorderRadius.circular(AppConstants.radiusM),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Is Premium: ${subscriptionService.isPremium}',
                          style: AppTextStyles.bodySmall,
                        ),
                        const SizedBox(height: AppConstants.spacingXS),
                        Text(
                          'Is Active: ${subscriptionService.isPremiumActive}',
                          style: AppTextStyles.caption,
                        ),
                        if (subscriptionService.premiumExpiry != null) ...[
                          const SizedBox(height: AppConstants.spacingXS),
                          Text(
                            'Expires: ${subscriptionService.premiumExpiry}',
                            style: AppTextStyles.caption,
                          ),
                        ],
                      ],
                    ),
                  );
                },
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildSection(
    BuildContext context, {
    required String title,
    required List<Widget> children,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: AppTextStyles.heading4,
        ),
        const SizedBox(height: AppConstants.spacingM),
        ...children,
      ],
    );
  }

  Widget _buildResetButton(
    BuildContext context, {
    required String title,
    required String description,
    required VoidCallback onTap,
    bool isDestructive = false,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: isDestructive ? Colors.red.withOpacity(0.2) : Colors.grey[900],
        borderRadius: BorderRadius.circular(AppConstants.radiusM),
        border: Border.all(
          color: isDestructive ? Colors.red : Colors.grey[800]!,
          width: 1,
        ),
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(AppConstants.radiusM),
          child: Padding(
            padding: const EdgeInsets.all(AppConstants.spacingL),
            child: Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        title,
                        style: AppTextStyles.bodyMedium.copyWith(
                          fontWeight: FontWeight.bold,
                          color: isDestructive ? Colors.red : Colors.white,
                        ),
                      ),
                      const SizedBox(height: AppConstants.spacingXS),
                      Text(
                        description,
                        style: AppTextStyles.caption,
                      ),
                    ],
                  ),
                ),
                Icon(
                  Icons.arrow_forward_ios,
                  color: isDestructive ? Colors.red : Colors.white70,
                  size: 16,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

