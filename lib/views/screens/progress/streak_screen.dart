import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// Streak screen showing a heatmap-style calendar of study activity
class StreakScreen extends ConsumerWidget {
  /// User ID for data fetching
  final String userId;

  const StreakScreen({
    super.key,
    required this.userId,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);

    // TODO: Fetch activity data from progressProvider.family(userId)
    final activityData = _generateMockActivityData();

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header
          Text(
            'Study Activity',
            style: theme.textTheme.titleLarge?.copyWith(
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Green indicates more activity',
            style: theme.textTheme.labelSmall?.copyWith(
              color: Colors.grey[600],
            ),
          ),

          const SizedBox(height: 20),

          // Heatmap calendar
          _buildHeatmap(activityData, theme),

          const SizedBox(height: 24),

          // Legend
          _buildLegend(theme),

          const SizedBox(height: 24),

          // Statistics
          _buildStatistics(activityData, theme),

          const SizedBox(height: 16),
        ],
      ),
    );
  }

  /// Build heatmap calendar
  Widget _buildHeatmap(Map<DateTime, int> activityData, ThemeData theme) {
    final now = DateTime.now();
    final oneYearAgo = DateTime(now.year - 1, now.month, now.day);

    // Organize data by week and day
    final weeks = <List<MapEntry<DateTime, int>>>[];
    var currentWeek = <MapEntry<DateTime, int>>[];

    for (var date = oneYearAgo;
        date.isBefore(now) || date.isAtSameMomentAs(now);
        date = date.add(const Duration(days: 1))) {
      final dayOfWeek = date.weekday;

      // Add empty cells for the first week
      if (currentWeek.isEmpty && dayOfWeek > 1) {
        for (var i = 1; i < dayOfWeek; i++) {
          currentWeek.add(MapEntry(DateTime(2000), 0));
        }
      }

      currentWeek.add(MapEntry(date, activityData[date] ?? 0));

      if (dayOfWeek == 7) {
        weeks.add(currentWeek);
        currentWeek = [];
      }
    }

    if (currentWeek.isNotEmpty) {
      weeks.add(currentWeek);
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Month labels
        Padding(
          padding: const EdgeInsets.only(left: 32),
          child: SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              children: _buildMonthLabels(oneYearAgo, now),
            ),
          ),
        ),
        const SizedBox(height: 8),
        // Heatmap grid
        SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Day of week labels
              Column(
                mainAxisAlignment: MainAxisAlignment.start,
                children: [
                  const SizedBox(height: 4),
                  ..._buildDayLabels(),
                ],
              ),
              const SizedBox(width: 8),
              // Heatmap cells
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  for (var week in weeks)
                    Padding(
                      padding: const EdgeInsets.only(bottom: 4),
                      child: Row(
                        children: [
                          for (var entry in week)
                            Padding(
                              padding: const EdgeInsets.only(right: 4),
                              child: _buildHeatmapCell(
                                date: entry.key,
                                count: entry.value,
                              ),
                            ),
                        ],
                      ),
                    ),
                ],
              ),
            ],
          ),
        ),
      ],
    );
  }

  /// Build month labels
  List<Widget> _buildMonthLabels(DateTime startDate, DateTime endDate) {
    final labels = <Widget>[];
    var currentMonth = startDate.month;
    var width = 0;

    for (var date = startDate;
        date.isBefore(endDate) || date.isAtSameMomentAs(endDate);
        date = date.add(const Duration(days: 1))) {
      if (date.month != currentMonth) {
        if (width > 0) {
          labels.add(
            SizedBox(
              width: (width * 8).toDouble(),
              child: Text(
                _getMonthName(currentMonth),
                style: const TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          );
        }
        currentMonth = date.month;
        width = 0;
      }
      width++;
    }

    if (width > 0) {
      labels.add(
        SizedBox(
          width: (width * 8).toDouble(),
          child: Text(
            _getMonthName(currentMonth),
            style: const TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
      );
    }

    return labels;
  }

  /// Get month name
  String _getMonthName(int month) {
    const months = [
      'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun',
      'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'
    ];
    return months[month - 1];
  }

  /// Build day of week labels
  List<Widget> _buildDayLabels() {
    const dayLabels = ['', 'M', '', 'W', '', 'F', ''];
    return dayLabels
        .map((label) => SizedBox(
              width: 10,
              height: 10,
              child: Text(
                label,
                textAlign: TextAlign.center,
                style: const TextStyle(fontSize: 9, fontWeight: FontWeight.bold),
              ),
            ))
        .toList();
  }

  /// Build single heatmap cell
  Widget _buildHeatmapCell({
    required DateTime date,
    required int count,
  }) {
    if (date.year == 2000) {
      return SizedBox(
        width: 8,
        height: 8,
        child: Container(
          color: Colors.transparent,
        ),
      );
    }

    // Color intensity based on activity count
    Color getColor() {
      if (count == 0) {
        return Colors.grey[200]!;
      } else if (count < 5) {
        return Colors.green.withValues(alpha: 0.2);
      } else if (count < 10) {
        return Colors.green.withValues(alpha: 0.4);
      } else if (count < 20) {
        return Colors.green.withValues(alpha: 0.6);
      } else {
        return Colors.green.withValues(alpha: 0.9);
      }
    }

    return Tooltip(
      message: '$count cards on ${date.month}/${date.day}',
      child: Container(
        width: 8,
        height: 8,
        decoration: BoxDecoration(
          color: getColor(),
          border: Border.all(color: Colors.grey[300]!, width: 0.5),
          borderRadius: BorderRadius.circular(1),
        ),
      ),
    );
  }

  /// Build legend
  Widget _buildLegend(ThemeData theme) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Activity Legend',
              style: theme.textTheme.labelSmall?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 12),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                _buildLegendItem('No activity', Colors.grey[200]!, theme),
                _buildLegendItem('Low', Colors.green.withValues(alpha: 0.2), theme),
                _buildLegendItem('Medium', Colors.green.withValues(alpha: 0.5), theme),
                _buildLegendItem('High', Colors.green.withValues(alpha: 0.8), theme),
              ],
            ),
          ],
        ),
      ),
    );
  }

  /// Build legend item
  Widget _buildLegendItem(String label, Color color, ThemeData theme) {
    return Column(
      children: [
        Container(
          width: 16,
          height: 16,
          decoration: BoxDecoration(
            color: color,
            border: Border.all(color: Colors.grey[300]!),
            borderRadius: BorderRadius.circular(2),
          ),
        ),
        const SizedBox(height: 4),
        Text(
          label,
          style: theme.textTheme.labelSmall?.copyWith(
            fontSize: 10,
          ),
        ),
      ],
    );
  }

  /// Build statistics
  Widget _buildStatistics(Map<DateTime, int> activityData, ThemeData theme) {
    final totalDays = activityData.length;
    final totalCards = activityData.values.fold<int>(0, (sum, val) => sum + val);
    final avgPerDay = totalDays > 0 ? (totalCards / totalDays).toStringAsFixed(1) : '0';

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Year Statistics',
              style: theme.textTheme.labelMedium?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            GridView.count(
              crossAxisCount: 2,
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              crossAxisSpacing: 12,
              mainAxisSpacing: 12,
              children: [
                _buildStatCard(
                  label: 'Study Days',
                  value: totalDays.toString(),
                  theme: theme,
                ),
                _buildStatCard(
                  label: 'Total Cards',
                  value: totalCards.toString(),
                  theme: theme,
                ),
                _buildStatCard(
                  label: 'Average/Day',
                  value: avgPerDay,
                  theme: theme,
                ),
                _buildStatCard(
                  label: 'Consistency',
                  value: '${((totalDays / 365) * 100).toStringAsFixed(0)}%',
                  theme: theme,
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  /// Build stat card
  Widget _buildStatCard({
    required String label,
    required String value,
    required ThemeData theme,
  }) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: theme.primaryColor.withValues(alpha: 0.05),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(
          color: theme.primaryColor.withValues(alpha: 0.2),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            value,
            style: theme.textTheme.titleLarge?.copyWith(
              fontWeight: FontWeight.bold,
              color: theme.primaryColor,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            label,
            style: theme.textTheme.labelSmall?.copyWith(
              color: Colors.grey[600],
            ),
          ),
        ],
      ),
    );
  }

  /// Generate mock activity data for demo
  Map<DateTime, int> _generateMockActivityData() {
    final data = <DateTime, int>{};
    final now = DateTime.now();

    for (var i = 0; i < 365; i++) {
      final date = now.subtract(Duration(days: i));
      // Simulate more activity on weekdays
      final dayOfWeek = date.weekday;
      final baseActivity = dayOfWeek < 6 ? 15 : 8;
      data[date] = baseActivity + (DateTime.now().millisecond % 15).toInt();
    }

    return data;
  }
}
