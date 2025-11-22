import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../../core/constants/app_constants.dart';
import '../../../../core/constants/app_text_styles.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../core/widgets/star_background.dart';
import 'package:provider/provider.dart';
import '../../../../services/subscription_service.dart';
import '../../../../services/auth_service.dart';
import '../../../../services/usage_service.dart';
import '../../../chat/presentation/screens/chat_list_screen.dart';
import '../../../chat/presentation/screens/chat_screen.dart';
import '../../widgets/premium_banner.dart' show PremiumBanner;
import '../../../subscription/presentation/screens/subscription_screen.dart';
import '../../widgets/feature_card.dart';
import '../../widgets/task_card.dart';
import '../../../settings/presentation/screens/debug_menu_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  @override
  void initState() {
    super.initState();
    // Refresh token status from backend when screen appears
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<UsageService>().refresh();
    });
  }

  @override
  Widget build(BuildContext context) {
    final subscriptionService = context.watch<SubscriptionService>();
    final authService = context.watch<AuthService>();
    final usageService = context.watch<UsageService>();
    final isPremium = subscriptionService.isPremiumActive;

    return Scaffold(
      backgroundColor: AppTheme.backgroundColor,
      body: Stack(
        children: [
          StarBackground(
            child: Container(),
          ),
          SafeArea(
            child: Column(
              children: [
                // Top Bar
                _buildTopBar(context, authService, subscriptionService, usageService),
                
                // Main Content
                Expanded(
                  child: SingleChildScrollView(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Premium Banner
                        if (!isPremium) const PremiumBanner(),
                        
                        const SizedBox(height: AppConstants.spacingL),
                        
                        // Premium Features Section
                        _buildPremiumFeaturesSection(context, isPremium),
                        
                        const SizedBox(height: AppConstants.spacingXXL),
                        
                        // Get Help with Any Task Section
                        _buildTasksSection(context),
                        
                        const SizedBox(height: AppConstants.spacingXXL),
                        
                        // Themed Section (placeholder)
                        _buildThemedSection(context),
                        
                        const SizedBox(height: AppConstants.spacingXXXL),
                      ],
                    ),
                  ),
                ),
                
                // Bottom Input Bar
                _buildInputBar(context),
              ],
            ),
          ),
        ],
      ),
      bottomNavigationBar: _buildBottomNavigation(context),
    );
  }

  Widget _buildTopBar(
    BuildContext context,
    AuthService authService,
    SubscriptionService subscriptionService,
    UsageService usageService,
  ) {
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: AppConstants.spacingL,
        vertical: AppConstants.spacingM,
      ),
      child: Row(
        children: [
          // Settings Icon (with debug menu access)
          _SettingsIconWithDebugMenu(),
          
          // App Title
          Expanded(
            child: Center(
              child: Text(
                'ChatX',
                style: AppTextStyles.heading2,
              ),
            ),
          ),
          
          // Premium Status or Token Count
          Container(
            padding: const EdgeInsets.symmetric(
              horizontal: AppConstants.spacingM,
              vertical: AppConstants.spacingXS,
            ),
            decoration: BoxDecoration(
              color: subscriptionService.isPremiumActive
                  ? AppTheme.primaryColor
                  : Colors.grey[800],
              borderRadius: BorderRadius.circular(AppConstants.radiusCircular),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  subscriptionService.isPremiumActive
                      ? Icons.star
                      : Icons.bolt,
                  color: Colors.white,
                  size: AppConstants.iconSizeS,
                ),
                const SizedBox(width: AppConstants.spacingXS),
                Text(
                  subscriptionService.isPremiumActive 
                      ? 'PRO' 
                      : '${usageService.tokensRemaining}',
                  style: AppTextStyles.labelMedium.copyWith(
                    color: Colors.white,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPremiumFeaturesSection(BuildContext context, bool isPremium) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: AppConstants.spacingL),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Text('👑', style: TextStyle(fontSize: 20)),
              const SizedBox(width: AppConstants.spacingS),
              Text(
                'Premium Features',
                style: AppTextStyles.heading4,
              ),
            ],
          ),
          const SizedBox(height: AppConstants.spacingM),
          SizedBox(
            height: 130,
            child: ListView(
              scrollDirection: Axis.horizontal,
              children: [
                FeatureCard(
                  title: 'Pic Transformer',
                  description: 'Apply styles to photos',
                  icon: Icons.transform,
                  gradient: [Colors.purple, Colors.pink],
                  onTap: () {
                    if (!isPremium) {
                      _showPremiumDialog(context);
                    } else {
                      // Navigate to Pic Transformer
                    }
                  },
                ),
                const SizedBox(width: AppConstants.spacingM),
                FeatureCard(
                  title: 'AI Keyboard',
                  description: 'Boost your typing',
                  icon: Icons.keyboard,
                  gradient: [Colors.purple, Colors.indigo],
                  onTap: () {
                    if (!isPremium) {
                      _showPremiumDialog(context);
                    } else {
                      // Navigate to AI Keyboard
                    }
                  },
                ),
                const SizedBox(width: AppConstants.spacingM),
                FeatureCard(
                  title: 'Doc',
                  description: 'Work with documents',
                  icon: Icons.description,
                  gradient: [Colors.blue, Colors.cyan],
                  onTap: () {
                    if (!isPremium) {
                      _showPremiumDialog(context);
                    } else {
                      // Navigate to Doc
                    }
                  },
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTasksSection(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: AppConstants.spacingL),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Get Help with Any Task',
            style: AppTextStyles.heading4,
          ),
          const SizedBox(height: AppConstants.spacingM),
          GridView.count(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            crossAxisCount: 2,
            crossAxisSpacing: AppConstants.spacingM,
            mainAxisSpacing: AppConstants.spacingM,
            childAspectRatio: 1.1,
            children: [
              TaskCard(
                title: 'Image Generation',
                description: 'Turn words into images',
                icon: Icons.palette,
                gradient: [Colors.purple, Colors.pink],
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const ChatScreen(),
                    ),
                  );
                },
              ),
              TaskCard(
                title: 'Summary',
                description: 'Summarize text from photos',
                icon: Icons.camera_alt,
                gradient: [Colors.blue, Colors.cyan],
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const ChatScreen(),
                    ),
                  );
                },
              ),
              TaskCard(
                title: 'Socials',
                description: 'Create an engaging post',
                icon: Icons.chat_bubble_outline,
                gradient: [Colors.green, Colors.teal],
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const ChatScreen(),
                    ),
                  );
                },
              ),
              TaskCard(
                title: 'Create',
                description: 'Compose the story',
                icon: Icons.create,
                gradient: [Colors.orange, Colors.red],
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const ChatScreen(),
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

  Widget _buildThemedSection(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: AppConstants.spacingL),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Themed',
            style: AppTextStyles.heading4,
          ),
          const SizedBox(height: AppConstants.spacingM),
          // Placeholder for themed content
          Container(
            height: 100,
            decoration: BoxDecoration(
              color: Colors.grey[900],
              borderRadius: BorderRadius.circular(AppConstants.radiusL),
            ),
            child: Center(
              child: Text(
                'Themed content coming soon',
                style: AppTextStyles.caption,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInputBar(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(AppConstants.spacingM),
      decoration: BoxDecoration(
        color: Colors.grey[900],
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.3),
            blurRadius: 10,
            offset: const Offset(0, -2),
          ),
        ],
      ),
      child: SafeArea(
        child: Row(
          children: [
            IconButton(
              icon: const Icon(Icons.add, color: Colors.white70),
              onPressed: () {
                // Show attachment options
              },
            ),
            Expanded(
              child: InkWell(
                onTap: () {
                  // Navigate to chat screen when tapped
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const ChatScreen(),
                    ),
                  );
                },
                borderRadius: BorderRadius.circular(AppConstants.radiusXXL),
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: AppConstants.spacingL,
                    vertical: AppConstants.spacingM,
                  ),
                  decoration: BoxDecoration(
                    color: Colors.grey[800],
                    borderRadius: BorderRadius.circular(AppConstants.radiusXXL),
                  ),
                  child: Row(
                    children: [
                      Expanded(
                        child: Text(
                          'Type your message...',
                          style: AppTextStyles.caption.copyWith(
                            color: Colors.white.withOpacity(0.5),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
            IconButton(
              icon: const Icon(Icons.mic, color: Colors.white70),
              onPressed: () {
                // Navigate to chat screen for voice input
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const ChatScreen(),
                  ),
                );
              },
            ),
            Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [AppTheme.primaryColor, AppTheme.primaryColor.withOpacity(0.8)],
                ),
                shape: BoxShape.circle,
              ),
              child: IconButton(
                icon: const Icon(Icons.send, color: Colors.white),
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const ChatScreen(),
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildBottomNavigation(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.grey[900],
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.3),
            blurRadius: 10,
            offset: const Offset(0, -2),
          ),
        ],
      ),
      child: SafeArea(
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: [
            _buildNavItem(
              context,
              icon: Icons.chat_bubble_outline,
              label: 'Chat',
              isSelected: true,
              onTap: () {},
            ),
            _buildNavItem(
              context,
              icon: Icons.assignment,
              label: 'Tasks for AI',
              isSelected: false,
              onTap: () {},
            ),
            _buildNavItem(
              context,
              icon: Icons.history,
              label: 'History',
              isSelected: false,
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const ChatListScreen(),
                  ),
                );
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildNavItem(
    BuildContext context, {
    required IconData icon,
    required String label,
    required bool isSelected,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(
          horizontal: AppConstants.spacingM,
          vertical: AppConstants.spacingS,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              icon,
              color: isSelected ? AppTheme.primaryColor : Colors.white70,
              size: AppConstants.iconSizeL,
            ),
            const SizedBox(height: AppConstants.spacingXS),
            Text(
              label,
              style: AppTextStyles.captionSmall.copyWith(
                color: isSelected ? AppTheme.primaryColor : Colors.white70,
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showPremiumDialog(BuildContext context) {
    // Navigate directly to subscription screen
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => const SubscriptionScreen(),
      ),
    );
  }
}

/// Settings icon with debug menu access (tap 5 times)
class _SettingsIconWithDebugMenu extends StatefulWidget {
  const _SettingsIconWithDebugMenu();

  @override
  State<_SettingsIconWithDebugMenu> createState() => _SettingsIconWithDebugMenuState();
}

class _SettingsIconWithDebugMenuState extends State<_SettingsIconWithDebugMenu> {
  int _tapCount = 0;
  DateTime? _lastTapTime;

  void _handleTap() {
    final now = DateTime.now();
    
    // Reset counter if more than 2 seconds passed
    if (_lastTapTime == null || now.difference(_lastTapTime!) > const Duration(seconds: 2)) {
      _tapCount = 1;
    } else {
      _tapCount++;
    }
    
    _lastTapTime = now;

    // Open debug menu after 5 taps
    if (_tapCount >= 5) {
      _tapCount = 0;
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => const DebugMenuScreen(),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return IconButton(
      icon: const Icon(Icons.settings, color: Colors.white70),
      onPressed: _handleTap,
    );
  }
}

