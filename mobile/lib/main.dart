import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:firebase_core/firebase_core.dart';
import 'core/theme/app_theme.dart';
import 'core/config/firebase_config.dart';
import 'features/auth/presentation/screens/login_screen.dart';
import 'features/chat/presentation/screens/chat_list_screen.dart';
import 'services/auth_service.dart';

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
          // Add other providers here
        ],
        child: MaterialApp(
          title: 'AI Agent Chat',
          theme: AppTheme.lightTheme,
          darkTheme: AppTheme.darkTheme,
          themeMode: ThemeMode.system,
          home: const AuthWrapper(),
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

class AuthWrapper extends StatelessWidget {
  const AuthWrapper({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<AuthService>(
      builder: (context, authService, _) {
        // Don't show loading screen - let LoginScreen handle its own loading state
        // This prevents rebuilds that would lose error state
        if (authService.currentUser == null) {
          // Use a key to preserve LoginScreen state across rebuilds
          return LoginScreen(key: _loginScreenKey);
        }
        
        return const ChatListScreen();
      },
    );
  }
}

