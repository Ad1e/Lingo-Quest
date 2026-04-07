import 'package:flutter/material.dart';

/// Model for an achievement badge
class Achievement {
  final String id;
  final String title;
  final String description;
  final IconData icon;
  final Color color;
  final DateTime? unlockedDate;

  bool get isUnlocked => unlockedDate != null;

  const Achievement({
    required this.id,
    required this.title,
    required this.description,
    required this.icon,
    required this.color,
    this.unlockedDate,
  });
}

/// Single achievement badge widget
class AchievementBadge extends StatelessWidget {
  /// Achievement data
  final Achievement achievement;

  /// Callback when badge is tapped
  final Function(Achievement)? onTap;

  const AchievementBadge({
    super.key,
    required this.achievement,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return GestureDetector(
      onTap: () => onTap?.call(achievement),
      child: Card(
        child: Stack(
          alignment: Alignment.center,
          children: [
            // Badge content
            Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                // Icon container
                Container(
                  width: 60,
                  height: 60,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: achievement.isUnlocked
                        ? achievement.color.withValues(alpha: 0.2)
                        : Colors.grey.withValues(alpha: 0.1),
                  ),
                  child: Icon(
                    achievement.icon,
                    color: achievement.isUnlocked
                        ? achievement.color
                        : Colors.grey[400],
                    size: 32,
                  ),
                ),
                const SizedBox(height: 12),
                // Title
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 8),
                  child: Text(
                    achievement.title,
                    textAlign: TextAlign.center,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: theme.textTheme.labelMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                      color: achievement.isUnlocked
                          ? Colors.black87
                          : Colors.grey[500],
                    ),
                  ),
                ),
              ],
            ),

            // Lock overlay (if not unlocked)
            if (!achievement.isUnlocked)
              Container(
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: Colors.black.withValues(alpha: 0.4),
                ),
                child: Icon(
                  Icons.lock,
                  color: Colors.white,
                  size: 32,
                ),
              ),

            // Unlock date (if unlocked)
            if (achievement.isUnlocked)
              Positioned(
                bottom: 8,
                right: 8,
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 6,
                    vertical: 3,
                  ),
                  decoration: BoxDecoration(
                    color: achievement.color,
                    borderRadius: BorderRadius.circular(4),
                  ),
                  child: Text(
                    _formatDate(achievement.unlockedDate!),
                    style: theme.textTheme.labelSmall?.copyWith(
                      color: Colors.white,
                      fontSize: 10,
                    ),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }

  /// Format unlock date
  String _formatDate(DateTime date) {
    final now = DateTime.now();
    final difference = now.difference(date);

    if (difference.inDays == 0) {
      return 'Today';
    } else if (difference.inDays == 1) {
      return 'Yesterday';
    } else if (difference.inDays < 7) {
      return '${difference.inDays}d ago';
    } else if (difference.inDays < 30) {
      final weeks = (difference.inDays / 7).floor();
      return '${weeks}w ago';
    } else {
      final months = (difference.inDays / 30).floor();
      return '${months}m ago';
    }
  }
}
