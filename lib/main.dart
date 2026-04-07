import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'config/theme.dart';
import 'firebase_options.dart';
import 'views/screens/auth/login_screen.dart';
import 'views/screens/auth/onboarding_screen.dart';
import 'views/screens/home/home_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  runApp(const ProviderScope(child: LingoQuestApp()));
}

class LingoQuestApp extends StatelessWidget {
  const LingoQuestApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'LingoQuest',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.lightTheme,
      darkTheme: AppTheme.darkTheme,
      themeMode: ThemeMode.system,
      home: const _AppRouter(),
    );
  }
}

/// Root router: Not logged in → LoginScreen
///              Logged in + first time → OnboardingScreen → HomeScreen
///              Logged in + returning → HomeScreen
class _AppRouter extends StatelessWidget {
  const _AppRouter();

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<User?>(
      stream: FirebaseAuth.instance.authStateChanges(),
      builder: (context, snapshot) {
        // Still resolving auth state
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Scaffold(
            body: Center(child: CircularProgressIndicator()),
          );
        }

        final user = snapshot.data;

        // Not authenticated → show login
        if (user == null) {
          return const LoginScreen();
        }

        // Authenticated → check onboarding
        return _PostAuthRouter(userId: user.uid);
      },
    );
  }
}

/// After auth, check if user has completed onboarding.
class _PostAuthRouter extends StatefulWidget {
  final String userId;
  const _PostAuthRouter({super.key, required this.userId});

  @override
  State<_PostAuthRouter> createState() => _PostAuthRouterState();
}

class _PostAuthRouterState extends State<_PostAuthRouter> {
  bool? _onboardingDone;

  @override
  void initState() {
    super.initState();
    _checkOnboarding();
  }

  Future<void> _checkOnboarding() async {
    final prefs = await SharedPreferences.getInstance();
    final done  = prefs.getBool('onboarding_done_${widget.userId}') ?? false;
    if (mounted) setState(() => _onboardingDone = done);
  }

  Future<void> _completeOnboarding() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('onboarding_done_${widget.userId}', true);
    if (mounted) setState(() => _onboardingDone = true);
  }

  @override
  Widget build(BuildContext context) {
    // Still loading prefs
    if (_onboardingDone == null) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }

    // First-time user → language/goal/level onboarding
    if (!_onboardingDone!) {
      return OnboardingScreen(onComplete: _completeOnboarding);
    }

    // Returning user → home
    return HomeScreen(userId: widget.userId);
  }
}