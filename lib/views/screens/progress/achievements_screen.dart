import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:language_learning_app/views/widgets/achievement_badge.dart';

/// Achievements screen showing all unlockable badges
class AchievementsScreen extends ConsumerWidget {
  /// User ID for data fetching
  final String userId;

  const AchievementsScreen({
    super.key,
    required this.userId,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);

    // TODO: Fetch achievements from progressProvider.family(userId)
    final achievements = _generateMockAchievements();
    final unlockedCount = achievements.where((a) => a.isUnlocked).length;
    final totalCount = achievements.length;

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header with progress
          _buildHeader(unlockedCount, totalCount, theme),

          const SizedBox(height: 20),

          // Achievement categories
          _buildAchievementSectionWrapper(
            context,
            title: 'Streaks',
            achievements: achievements
                .where((a) => a.id.contains('streak'))
                .toList(),
            theme: theme,
            onBadgeTap: (achievement) => _showAchievementDetails(context, achievement),
          ),

          const SizedBox(height: 20),

          _buildAchievementSectionWrapper(
            context,
            title: 'Milestones',
            achievements: achievements
                .where((a) => a.id.contains('milestone'))
                .toList(),
            theme: theme,
            onBadgeTap: (achievement) => _showAchievementDetails(context, achievement),
          ),

          const SizedBox(height: 20),

          _buildAchievementSectionWrapper(
            context,
            title: 'Dedication',
            achievements: achievements
                .where((a) => a.id.contains('dedication'))
                .toList(),
            theme: theme,
            onBadgeTap: (achievement) => _showAchievementDetails(context, achievement),
          ),

          const SizedBox(height: 20),

          _buildAchievementSectionWrapper(
            context,
            title: 'Mastery',
            achievements: achievements
                .where((a) => a.id.contains('mastery'))
                .toList(),
            theme: theme,
            onBadgeTap: (achievement) => _showAchievementDetails(context, achievement),
          ),

          const SizedBox(height: 16),
        ],
      ),
    );
  }

  /// Build header with progress
  Widget _buildHeader(int unlocked, int total, ThemeData theme) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Achievements',
                  style: theme.textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 6,
                  ),
                  decoration: BoxDecoration(
                    color: Colors.amber.withValues(alpha: 0.2),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(
                    '$unlocked / $total',
                    style: theme.textTheme.labelMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                      color: Colors.amber[700],
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            ClipRRect(
              borderRadius: BorderRadius.circular(4),
              child: LinearProgressIndicator(
                value: unlocked / total,
                minHeight: 8,
                backgroundColor: Colors.grey[300],
                valueColor: AlwaysStoppedAnimation<Color>(
                  Colors.amber,
                ),
              ),
            ),
            const SizedBox(height: 8),
            Text(
              '${((unlocked / total) * 100).toStringAsFixed(0)}% Complete',
              style: theme.textTheme.labelSmall?.copyWith(
                color: Colors.grey[600],
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// Build achievement section
  Widget _buildAchievementSectionWrapper(
    BuildContext context, {
    required String title,
    required List<Achievement> achievements,
    required ThemeData theme,
    required Function(Achievement) onBadgeTap,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: theme.textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 12),
        GridView.builder(
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 4,
            crossAxisSpacing: 8,
            mainAxisSpacing: 8,
            childAspectRatio: 0.85,
          ),
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          itemCount: achievements.length,
          itemBuilder: (context, index) {
            return AchievementBadge(
              achievement: achievements[index],
              onTap: onBadgeTap,
            );
          },
        ),
      ],
    );
  }

  /// Show achievement details dialog
  void _showAchievementDetails(
    BuildContext context,
    Achievement achievement,
  ) {
    final theme = Theme.of(context);

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: achievement.color.withValues(alpha: 0.2),
              ),
              child: Icon(
                achievement.icon,
                color: achievement.color,
                size: 32,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    achievement.title,
                    style: theme.textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  if (achievement.isUnlocked)
                    Text(
                      'Unlocked ${_formatDate(achievement.unlockedDate!)}',
                      style: theme.textTheme.labelSmall?.copyWith(
                        color: achievement.color,
                      ),
                    ),
                ],
              ),
            ),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              achievement.description,
              style: theme.textTheme.bodyMedium,
            ),
            const SizedBox(height: 16),
            if (!achievement.isUnlocked)
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.grey[100],
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Row(
                  children: [
                    Icon(
                      Icons.lock,
                      color: Colors.grey[600],
                      size: 20,
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        'Keep working to unlock this achievement',
                        style: theme.textTheme.labelSmall?.copyWith(
                          color: Colors.grey[600],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Close'),
          ),
        ],
      ),
    );
  }

  /// Format date
  String _formatDate(DateTime date) {
    final now = DateTime.now();
    final difference = now.difference(date);

    if (difference.inDays == 0) {
      return 'Today';
    } else if (difference.inDays == 1) {
      return 'Yesterday';
    } else if (difference.inDays < 7) {
      return '${difference.inDays} days ago';
    } else {
      return 'on ${date.month}/${date.day}/${date.year}';
    }
  }

  /// Generate mock achievements
  List<Achievement> _generateMockAchievements() {
    final now = DateTime.now();

    return [
      // Streaks
      Achievement(
        id: 'streak_3',
        title: '3-Day Streak',
        description: 'Study for 3 consecutive days',
        icon: Icons.local_fire_department,
        color: Colors.orange,
        unlockedDate: now.subtract(const Duration(days: 10)),
      ),
      Achievement(
        id: 'streak_7',
        title: '7-Day Streak',
        description: 'Study for 7 consecutive days',
        icon: Icons.local_fire_department,
        color: Colors.deepOrange,
        unlockedDate: now.subtract(const Duration(days: 5)),
      ),
      Achievement(
        id: 'streak_30',
        title: 'Inferno',
        description: 'Study for 30 consecutive days',
        icon: Icons.local_fire_department,
        color: Colors.red,
      ),
      Achievement(
        id: 'streak_100',
        title: 'Legendary',
        description: 'Study for 100 consecutive days',
        icon: Icons.diamond,
        color: Colors.amber,
      ),
      // Milestones
      Achievement(
        id: 'milestone_100',
        title: 'Century',
        description: 'Complete 100 cards',
        icon: Icons.flag,
        color: Colors.blue,
        unlockedDate: now.subtract(const Duration(days: 30)),
      ),
      Achievement(
        id: 'milestone_500',
        title: 'Guru',
        description: 'Complete 500 cards',
        icon: Icons.auto_awesome,
        color: Colors.purple,
      ),
      Achievement(
        id: 'milestone_1000',
        title: 'Polyglot',
        description: 'Complete 1,000 cards',
        icon: Icons.travel_explore,
        color: Colors.indigo,
      ),
      Achievement(
        id: 'milestone_5000',
        title: 'Legend',
        description: 'Complete 5,000 cards',
        icon: Icons.stars,
        color: Colors.amber,
      ),
      // Dedication
      Achievement(
        id: 'dedication_level5',
        title: 'Rising Star',
        description: 'Reach Level 5',
        icon: Icons.trending_up,
        color: Colors.green,
        unlockedDate: now.subtract(const Duration(days: 15)),
      ),
      Achievement(
        id: 'dedication_level10',
        title: 'Master',
        description: 'Reach Level 10',
        icon: Icons.military_tech,
        color: Colors.teal,
      ),
      Achievement(
        id: 'dedication_xp1000',
        title: 'Grind Time',
        description: 'Earn 1,000 XP',
        icon: Icons.emoji_events,
        color: Colors.cyan,
        unlockedDate: now.subtract(const Duration(days: 8)),
      ),
      Achievement(
        id: 'dedication_xp5000',
        title: 'XP Master',
        description: 'Earn 5,000 XP',
        icon: Icons.star_rate,
        color: Colors.lightBlue,
      ),
      // Mastery
      Achievement(
        id: 'mastery_perfect',
        title: 'Perfect Session',
        description: 'Get all cards correct in one session',
        icon: Icons.check_circle,
        color: Colors.green,
        unlockedDate: now.subtract(const Duration(days: 3)),
      ),
      Achievement(
        id: 'mastery_speed',
        title: 'Speed Demon',
        description: 'Complete 20 cards in under 5 minutes',
        icon: Icons.speed,
        color: Colors.red,
      ),
      Achievement(
        id: 'mastery_versatile',
        title: 'Versatile',
        description: 'Study all available decks',
        icon: Icons.collections,
        color: Colors.purple,
      ),
      Achievement(
        id: 'mastery_early',
        title: 'Early Bird',
        description: 'Complete a study session before 8 AM',
        icon: Icons.sunny,
        color: Colors.amber,
      ),
    ];
  }
}
