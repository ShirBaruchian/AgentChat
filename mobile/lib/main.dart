import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:firebase_core/firebase_core.dart';
import 'core/theme/app_theme.dart';
import 'core/config/firebase_config.dart';
import 'features/auth/presentation/screens/login_screen.dart';
import 'features/chat/presentation/screens/chat_list_screen.dart';
import 'features/onboarding/presentation/screens/onboarding_screen.dart';
import 'features/home/presentation/screens/home_screen.dart';
import 'services/auth_service.dart';
import 'services/onboarding_service.dart';
import 'services/subscription_service.dart';
import 'services/usage_service.dart';

// Global key to preserve LoginScreen state across rebuilds
final _loginScreenKey = GlobalKey();

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  // Initialize Firebase
  try {
    final options = DefaultFirebaseOptions.currentPlatform;
    print('Initializing Firebase for platform: ${options.projectId}');
    await Firebase.initializeApp(
      options: options,
    );
    print('Firebase initialized successfully');
  } catch (e, stackTrace) {
    print('Error initializing Firebase: $e');
    print('Stack trace: $stackTrace');
    // Don't continue - Firebase is required for auth
    rethrow;
  }
  
  // Add error handling
  FlutterError.onError = (FlutterErrorDetails details) {
    FlutterError.presentError(details);
    print('Flutter Error: ${details.exception}');
    print('Stack trace: ${details.stack}');
  };
  
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    try {
      return MultiProvider(
        providers: [
          ChangeNotifierProvider(create: (_) => AuthService()),
          ChangeNotifierProvider(create: (_) => SubscriptionService()),
          ChangeNotifierProxyProvider<SubscriptionService, UsageService>(
            create: (_) {
              // Create a temporary instance - this should never be used
              // as update will always be called
              final tempSubscriptionService = SubscriptionService();
              return UsageService(tempSubscriptionService);
            },
            update: (_, subscriptionService, previous) =>
                previous ?? UsageService(subscriptionService),
          ),
          // Add other providers here
        ],
        child: MaterialApp(
          title: 'AI Agent Chat',
          theme: AppTheme.lightTheme,
          darkTheme: AppTheme.darkTheme,
          themeMode: ThemeMode.system,
          home: const AppInitializer(),
          debugShowCheckedModeBanner: false,
        ),
      );
    } catch (e, stackTrace) {
      print('Error building MyApp: $e');
      print('Stack trace: $stackTrace');
      // Return a simple error widget
      return MaterialApp(
        home: Scaffold(
          body: Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Text('Error loading app'),
                Text('$e'),
                ElevatedButton(
                  onPressed: () => runApp(const MyApp()),
                  child: const Text('Retry'),
                ),
              ],
            ),
          ),
        ),
      );
    }
  }
}

class AppInitializer extends StatefulWidget {
  const AppInitializer({super.key});

  @override
  State<AppInitializer> createState() => _AppInitializerState();
}

class _AppInitializerState extends State<AppInitializer> {
  bool _isLoading = true;
  bool _showOnboarding = false;

  @override
  void initState() {
    super.initState();
    _checkOnboardingStatus();
  }

  Future<void> _checkOnboardingStatus() async {
    final isCompleted = await OnboardingService.isOnboardingCompleted();
    setState(() {
      _showOnboarding = !isCompleted;
      _isLoading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Scaffold(
        body: Center(
          child: CircularProgressIndicator(),
        ),
      );
    }

    if (_showOnboarding) {
      return const OnboardingScreen();
    }

    return const AuthWrapper();
  }
}

class AuthWrapper extends StatelessWidget {
  const AuthWrapper({super.key});

  @override
  Widget build(BuildContext context) {
    // Always show HomeScreen - users can use app anonymously or sign in
    // The HomeScreen will handle showing login if needed
    return const HomeScreen();
  }
}

