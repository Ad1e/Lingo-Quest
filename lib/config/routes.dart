import 'package:flutter/material.dart';

/// Route names for the application
class AppRoutes {
  // Auth Routes
  static const String login = '/login';
  static const String signup = '/signup';
  static const String onboarding = '/onboarding';

  // Main Navigation Routes
  static const String home = '/home';
  static const String dashboard = '/dashboard';

  // Lessons Routes
  static const String lessons = '/lessons';
  static const String lessonDetail = '/lesson_detail';

  // Flashcard Routes
  static const String flashcardLibrary = '/flashcard_library';
  static const String study = '/study';

  // Challenges Routes
  static const String dailyChallenge = '/daily_challenge';

  // Social Routes
  static const String leaderboard = '/leaderboard';
  static const String friends = '/friends';

  // Progress Routes
  static const String progress = '/progress';
  static const String stats = '/stats';
  static const String achievements = '/achievements';

  // Profile Routes
  static const String profile = '/profile';
  static const String settings = '/settings';

  /// Generate routes for the application
  static Route<dynamic> generateRoute(RouteSettings settings) {
    switch (settings.name) {
      case login:
        return _buildRoute(
          const Placeholder(), // Replace with actual LoginScreen
          settings,
        );
      case signup:
        return _buildRoute(
          const Placeholder(), // Replace with actual SignupScreen
          settings,
        );
      case onboarding:
        return _buildRoute(
          const Placeholder(), // Replace with actual OnboardingScreen
          settings,
        );
      case home:
        return _buildRoute(
          const Placeholder(), // Replace with actual HomeScreen
          settings,
        );
      case dashboard:
        return _buildRoute(
          const Placeholder(), // Replace with actual DashboardScreen
          settings,
        );
      case lessons:
        return _buildRoute(
          const Placeholder(), // Replace with actual LessonsScreen
          settings,
        );
      case lessonDetail:
        return _buildRoute(
          const Placeholder(), // Replace with actual LessonDetailScreen
          settings,
        );
      case flashcardLibrary:
        return _buildRoute(
          const Placeholder(), // Replace with actual FlashcardLibraryScreen
          settings,
        );
      case study:
        return _buildRoute(
          const Placeholder(), // Replace with actual StudyScreen
          settings,
        );
      case dailyChallenge:
        return _buildRoute(
          const Placeholder(), // Replace with actual DailyChallengeScreen
          settings,
        );
      case leaderboard:
        return _buildRoute(
          const Placeholder(), // Replace with actual LeaderboardScreen
          settings,
        );
      case friends:
        return _buildRoute(
          const Placeholder(), // Replace with actual FriendsScreen
          settings,
        );
      case progress:
        return _buildRoute(
          const Placeholder(), // Replace with actual ProgressScreen
          settings,
        );
      case stats:
        return _buildRoute(
          const Placeholder(), // Replace with actual StatsScreen
          settings,
        );
      case achievements:
        return _buildRoute(
          const Placeholder(), // Replace with actual AchievementsScreen
          settings,
        );
      case profile:
        return _buildRoute(
          const Placeholder(), // Replace with actual ProfileScreen
          settings,
        );
      case settings:
        return _buildRoute(
          const Placeholder(), // Replace with actual SettingsScreen
          settings,
        );
      default:
        return _buildRoute(
          const Scaffold(
            body: Center(
              child: Text('No route defined for this path'),
            ),
          ),
          settings,
        );
    }
  }

  static Route<dynamic> _buildRoute(
    Widget page,
    RouteSettings settings,
  ) {
    return MaterialPageRoute(
      builder: (_) => page,
      settings: settings,
    );
  }
}

/// Named route arguments helper class
class RouteArguments {
  final Map<String, dynamic> data;

  RouteArguments(this.data);

  T? get<T>(String key) => data[key] as T?;
  bool containsKey(String key) => data.containsKey(key);
}
