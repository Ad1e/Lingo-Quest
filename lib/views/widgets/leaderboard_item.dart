import 'package:flutter/material.dart';

/// Model for a leaderboard entry
class LeaderboardEntry {
  final int rank;
  final String userId;
  final String username;
  final int xp;
  final String? avatarUrl;
  final bool isCurrentUser;

  const LeaderboardEntry({
    required this.rank,
    required this.userId,
    required this.username,
    required this.xp,
    this.avatarUrl,
    this.isCurrentUser = false,
  });
}

/// Leaderboard item widget showing a single entry
class LeaderboardItem extends StatelessWidget {
  /// Leaderboard entry data
  final LeaderboardEntry entry;

  /// Callback when item is tapped
  final Function(String userId)? onTap;

  const LeaderboardItem({
    super.key,
    required this.entry,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isCurrentUser = entry.isCurrentUser;

    return GestureDetector(
      onTap: () => onTap?.call(entry.userId),
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: isCurrentUser
              ? theme.primaryColor.withValues(alpha: 0.1)
              : Colors.white,
          border: Border.all(
            color: isCurrentUser
                ? theme.primaryColor
                : Colors.grey[300]!,
            width: isCurrentUser ? 2 : 1,
          ),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Row(
          children: [
            // Rank badge
            Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: _getRankColor(entry.rank),
              ),
              child: Center(
                child: Text(
                  entry.rank.toString(),
                  style: theme.textTheme.labelLarge?.copyWith(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
            const SizedBox(width: 12),

            // Avatar and username
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      ClipRRect(
                        borderRadius: BorderRadius.circular(6),
                        child: Container(
                          width: 32,
                          height: 32,
                          color: theme.primaryColor.withValues(alpha: 0.2),
                          child: Center(
                            child: Text(
                              entry.username.substring(0, 1).toUpperCase(),
                              style: theme.textTheme.labelMedium?.copyWith(
                                color: theme.primaryColor,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          entry.username,
                          style: theme.textTheme.titleSmall?.copyWith(
                            fontWeight: FontWeight.w600,
                          ),
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      if (isCurrentUser)
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 8,
                            vertical: 4,
                          ),
                          decoration: BoxDecoration(
                            color: theme.primaryColor,
                            borderRadius: BorderRadius.circular(4),
                          ),
                          child: Text(
                            'You',
                            style: theme.textTheme.labelSmall?.copyWith(
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                    ],
                  ),
                ],
              ),
            ),

            const SizedBox(width: 12),

            // XP display
            Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text(
                  '${entry.xp} XP',
                  style: theme.textTheme.titleSmall?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: isCurrentUser ? theme.primaryColor : null,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  /// Get color for rank badge
  Color _getRankColor(int rank) {
    switch (rank) {
      case 1:
        return Colors.amber;
      case 2:
        return Colors.grey[400] ?? Colors.grey;
      case 3:
        return Colors.orange[700] ?? Colors.orange;
      default:
        return Colors.blue.withValues(alpha: 0.6);
    }
  }
}
