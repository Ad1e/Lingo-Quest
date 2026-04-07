import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:language_learning_app/views/screens/progress/stats_screen.dart';
import 'package:language_learning_app/views/screens/progress/achievements_screen.dart';
import 'package:language_learning_app/views/screens/progress/streak_screen.dart';

/// Progress screen with tabs for stats, achievements, and streaks
class ProgressScreen extends ConsumerStatefulWidget {
  /// User ID for data fetching
  final String userId;

  const ProgressScreen({
    super.key,
    required this.userId,
  });

  @override
  ConsumerState<ProgressScreen> createState() => _ProgressScreenState();
}

class _ProgressScreenState extends ConsumerState<ProgressScreen>
    with TickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Progress'),
        centerTitle: true,
        elevation: 0,
        backgroundColor: theme.primaryColor,
        foregroundColor: Colors.white,
        bottom: TabBar(
          controller: _tabController,
          tabs: const [
            Tab(
              icon: Icon(Icons.show_chart),
              text: 'Stats',
            ),
            Tab(
              icon: Icon(Icons.emoji_events),
              text: 'Achievements',
            ),
            Tab(
              icon: Icon(Icons.calendar_today),
              text: 'Streak',
            ),
          ],
          indicatorColor: Colors.white,
          labelColor: Colors.white,
          unselectedLabelColor: Colors.white.withValues(alpha: 0.7),
          indicatorWeight: 3,
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          // Stats tab
          StatsScreen(userId: widget.userId),

          // Achievements tab
          AchievementsScreen(userId: widget.userId),

          // Streak tab
          StreakScreen(userId: widget.userId),
        ],
      ),
    );
  }
}
