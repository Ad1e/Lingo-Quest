import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../providers/progress_provider.dart';
import '../../utils/gamification_models.dart';

/// Widget to display user level and XP progress
class LevelDisplay extends ConsumerWidget {
  final String userId;
  final Size levelBadgeSize;
  final bool showDetails;

  const LevelDisplay({
    Key? key,
    required this.userId,
    this.levelBadgeSize = const Size(80, 80),
    this.showDetails = true,
  }) : super(key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final progressState = ref.watch(progressProvider(userId));

    return progressState.when(
      data: (progress) {
        return Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            _buildLevelBadge(context, progress),
            if (showDetails) ...[
              const SizedBox(height: 16),
              _buildXpProgressBar(context, progress),
              const SizedBox(height: 8),
              _buildXpStats(context, progress),
            ],
          ],
        );
      },
      loading: () => SizedBox(
        width: levelBadgeSize.width,
        height: levelBadgeSize.height,
        child: const Center(child: CircularProgressIndicator()),
      ),
      error: (error, stackTrace) => Center(
        child: Text('Error loading level: $error'),
      ),
    );
  }

  Widget _buildLevelBadge(BuildContext context, ProgressState progress) {
    return Container(
      width: levelBadgeSize.width,
      height: levelBadgeSize.height,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        gradient: LinearGradient(
          colors: [
            Colors.purple.shade600,
            Colors.indigo.shade600,
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.purple.withOpacity(0.5),
            blurRadius: 20,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: Stack(
        alignment: Alignment.center,
        children: [
          Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                'LEVEL',
                style: Theme.of(context).textTheme.labelSmall?.copyWith(
                      color: Colors.white70,
                      fontWeight: FontWeight.w600,
                      letterSpacing: 1,
                    ),
              ),
              const SizedBox(height: 4),
              Text(
                '${progress.level}',
                style: Theme.of(context).textTheme.displaySmall?.copyWith(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                    ),
              ),
            ],
          ),
          Positioned(
            bottom: 8,
            right: 8,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
              decoration: BoxDecoration(
                color: Colors.amber.shade600,
                borderRadius: BorderRadius.circular(8),
              ),
              child: Text(
                '+${progress.recentXpEvents.isNotEmpty ? progress.recentXpEvents.first.amount : 0}',
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 10,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildXpProgressBar(BuildContext context, ProgressState progress) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        ClipRRect(
          borderRadius: BorderRadius.circular(12),
          child: LinearProgressIndicator(
            value: progress.levelProgress,
            minHeight: 12,
            backgroundColor: Colors.grey.shade300,
            valueColor: AlwaysStoppedAnimation<Color>(
              Colors.purple.shade600,
            ),
          ),
        ),
        const SizedBox(height: 8),
      ],
    );
  }

  Widget _buildXpStats(BuildContext context, ProgressState progress) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Text(
          '${progress.xpInCurrentLevel}',
          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                fontWeight: FontWeight.bold,
                color: Colors.purple.shade600,
              ),
        ),
        Text(
          ' / ${progress.xpNeededForLevel} XP',
          style: Theme.of(context).textTheme.bodySmall?.copyWith(
                color: Colors.grey.shade600,
              ),
        ),
      ],
    );
  }
}

/// Widget to display achievements
class AchievementDisplay extends ConsumerWidget {
  final String userId;
  final int maxShowCount;

  const AchievementDisplay({
    Key? key,
    required this.userId,
    this.maxShowCount = 6,
  }) : super(key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final progressState = ref.watch(progressProvider(userId));

    return progressState.when(
      data: (progress) {
        final achievements = progress.unlockedAchievements;

        if (achievements.isEmpty) {
          return Center(
            child: Text(
              'No achievements yet. Keep studying!',
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: Colors.grey.shade600,
                  ),
            ),
          );
        }

        return GridView.builder(
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 3,
            crossAxisSpacing: 12,
            mainAxisSpacing: 12,
          ),
          itemCount:
              achievements.length > maxShowCount ? maxShowCount : achievements.length,
          itemBuilder: (context, index) {
            final achievement = achievements[index];
            return _buildAchievementTile(context, achievement);
          },
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
        );
      },
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (error, stackTrace) => Center(
        child: Text('Error loading achievements: $error'),
      ),
    );
  }

  Widget _buildAchievementTile(
    BuildContext context,
    AchievementUnlock achievement,
  ) {
    return GestureDetector(
      onTap: () {
        _showAchievementDetail(context, achievement);
      },
      child: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [
              Colors.amber.shade600,
              Colors.orange.shade600,
            ],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: Colors.amber.withOpacity(0.3),
              blurRadius: 8,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Stack(
          alignment: Alignment.center,
          children: [
            Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  '🏆',
                  style: Theme.of(context).textTheme.headlineSmall,
                ),
                const SizedBox(height: 4),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 4),
                  child: Text(
                    achievement.title,
                    textAlign: TextAlign.center,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: Theme.of(context).textTheme.labelSmall?.copyWith(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                        ),
                  ),
                ),
              ],
            ),
            Positioned(
              top: 4,
              right: 4,
              child: Container(
                width: 24,
                height: 24,
                decoration: BoxDecoration(
                  color: Colors.green.shade600,
                  shape: BoxShape.circle,
                ),
                child: const Center(
                  child: Text(
                    '✓',
                    style: TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                      fontSize: 14,
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showAchievementDetail(
    BuildContext context,
    AchievementUnlock achievement,
  ) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
        title: Row(
          children: [
            const Text('🏆'),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                achievement.title,
                style: Theme.of(context).textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
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
              style: Theme.of(context).textTheme.bodyMedium,
            ),
            const SizedBox(height: 16),
            Text(
              'Unlocked on ${achievement.unlockedAt.toString().split('.')[0]}',
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: Colors.grey.shade600,
                  ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Close'),
          ),
        ],
      ),
    );
  }
}

/// Widget to show streak information
class StreakDisplay extends ConsumerWidget {
  final String userId;
  final bool showFlame;

  const StreakDisplay({
    Key? key,
    required this.userId,
    this.showFlame = true,
  }) : super(key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final progressState = ref.watch(progressProvider(userId));

    return progressState.when(
      data: (progress) {
        return Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [
                Colors.red.shade600,
                Colors.orange.shade600,
              ],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            borderRadius: BorderRadius.circular(12),
            boxShadow: [
              BoxShadow(
                color: Colors.red.withOpacity(0.3),
                blurRadius: 8,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              if (showFlame) ...[
                const Text('🔥', style: TextStyle(fontSize: 24)),
                const SizedBox(width: 8),
              ],
              Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Streak',
                    style: Theme.of(context).textTheme.labelSmall?.copyWith(
                          color: Colors.white70,
                          fontWeight: FontWeight.w600,
                        ),
                  ),
                  Text(
                    '${progress.streak} days',
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                        ),
                  ),
                ],
              ),
            ],
          ),
        );
      },
      loading: () => const SizedBox.shrink(),
      error: (error, stackTrace) => SizedBox.shrink(),
    );
  }
}
