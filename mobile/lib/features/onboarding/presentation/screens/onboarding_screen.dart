import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../../services/auth_service.dart';
import '../../../../services/onboarding_service.dart';
import '../../../../features/auth/presentation/screens/login_screen.dart';
import '../../../../features/chat/presentation/screens/chat_list_screen.dart';
import 'onboarding_pages/welcome_page.dart';
import 'onboarding_pages/example_prompts_page.dart';
import 'onboarding_pages/writing_features_page.dart';
import 'onboarding_pages/ai_tools_page.dart';
import 'onboarding_pages/social_proof_page.dart';
import 'onboarding_pages/subscription_page.dart';

class OnboardingScreen extends StatefulWidget {
  const OnboardingScreen({super.key});

  @override
  State<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen> {
  final PageController _pageController = PageController();
  int _currentPage = 0;
  final int _totalPages = 6;

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  void _nextPage() {
    if (_currentPage < _totalPages - 1) {
      _pageController.nextPage(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
    } else {
      _completeOnboarding();
    }
  }

  Future<void> _completeOnboarding() async {
    await OnboardingService.completeOnboarding();
    if (mounted) {
      // Navigate to login screen
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(
          builder: (context) => const AuthWrapper(),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0A0A0A), // Dark background
      body: SafeArea(
        child: LayoutBuilder(
          builder: (context, constraints) {
            return Stack(
              children: [
                PageView(
                  controller: _pageController,
                  physics: const ClampingScrollPhysics(),
                  onPageChanged: (index) {
                    setState(() {
                      _currentPage = index;
                    });
                  },
                  children: [
                    SizedBox(
                      width: constraints.maxWidth,
                      height: constraints.maxHeight,
                      child: WelcomePage(onContinue: _nextPage),
                    ),
                    SizedBox(
                      width: constraints.maxWidth,
                      height: constraints.maxHeight,
                      child: ExamplePromptsPage(onContinue: _nextPage),
                    ),
                    SizedBox(
                      width: constraints.maxWidth,
                      height: constraints.maxHeight,
                      child: WritingFeaturesPage(onContinue: _nextPage),
                    ),
                    SizedBox(
                      width: constraints.maxWidth,
                      height: constraints.maxHeight,
                      child: AIToolsPage(onContinue: _nextPage),
                    ),
                    SizedBox(
                      width: constraints.maxWidth,
                      height: constraints.maxHeight,
                      child: SocialProofPage(onContinue: _nextPage),
                    ),
                    SizedBox(
                      width: constraints.maxWidth,
                      height: constraints.maxHeight,
                      child: SubscriptionPage(onContinue: _completeOnboarding),
                    ),
                  ],
                ),
                // Page indicators
                Positioned(
                  bottom: 40,
                  left: 0,
                  right: 0,
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: List.generate(
                      _totalPages,
                      (index) => Container(
                        width: 8,
                        height: 8,
                        margin: const EdgeInsets.symmetric(horizontal: 4),
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: _currentPage == index
                              ? const Color(0xFF10B981) // Green
                              : Colors.grey.withOpacity(0.3),
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            );
          },
        ),
      ),
    );
  }
}

// Temporary AuthWrapper for navigation
class AuthWrapper extends StatelessWidget {
  const AuthWrapper({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<AuthService>(
      builder: (context, authService, _) {
        if (authService.currentUser == null) {
          return const LoginScreen();
        }
        return const ChatListScreen();
      },
    );
  }
}

