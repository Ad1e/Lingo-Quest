import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:fl_chart/fl_chart.dart';

/// Statistics screen showing XP progress, study metrics, and performance
class StatsScreen extends ConsumerWidget {
  /// User ID for data fetching
  final String userId;

  const StatsScreen({
    super.key,
    required this.userId,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);

    // TODO: Fetch stats from progressProvider.family(userId)
    // For now, using mock data
    final last30DaysXP = _generateMockXPData();
    final deckStats = _generateMockDeckStats();

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // 7-day streak calendar
          _buildStreakCalendar(theme),

          const SizedBox(height: 20),

          // Overall stats
          _buildOverallStats(theme),

          const SizedBox(height: 20),

          // 30-day XP chart
          _buildXPChart(last30DaysXP, theme),

          const SizedBox(height: 20),

          // Deck performance chart
          _buildDeckChart(deckStats, theme),

          const SizedBox(height: 20),

          // Study time
          _buildStudyTimeCard(theme),

          const SizedBox(height: 16),
        ],
      ),
    );
  }

  /// Build 7-day streak calendar
  Widget _buildStreakCalendar(ThemeData theme) {
    final today = DateTime.now();
    final last7Days = List.generate(7, (index) => today.subtract(Duration(days: 6 - index)));

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              '7-Day Streak',
              style: theme.textTheme.labelMedium?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 12),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: last7Days.map((date) {
                final isToday = _isSameDay(date, today);
                final studied = DateTime.now().millisecond % 2 == 0; // Mock data

                return Column(
                  children: [
                    // Day letter
                    Text(
                      _getDayLetter(date.weekday),
                      style: theme.textTheme.labelSmall?.copyWith(
                        color: Colors.grey[600],
                      ),
                    ),
                    const SizedBox(height: 6),
                    // Day number circle
                    Container(
                      width: 40,
                      height: 40,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        border: Border.all(
                          color: isToday ? theme.primaryColor : Colors.grey[300]!,
                          width: isToday ? 2 : 1,
                        ),
                        color: studied
                            ? theme.primaryColor.withValues(alpha: 0.2)
                            : Colors.transparent,
                      ),
                      child: Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text(
                              date.day.toString(),
                              style: theme.textTheme.labelMedium?.copyWith(
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            if (studied)
                              Icon(
                                Icons.check,
                                size: 14,
                                color: theme.primaryColor,
                              ),
                          ],
                        ),
                      ),
                    ),
                  ],
                );
              }).toList(),
            ),
          ],
        ),
      ),
    );
  }

  /// Build overall stats
  Widget _buildOverallStats(ThemeData theme) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Progress Overview',
              style: theme.textTheme.labelMedium?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            // Level and XP
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Level 5',
                      style: theme.textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    Text(
                      '450 / 550 XP',
                      style: theme.textTheme.labelSmall?.copyWith(
                        color: Colors.grey[600],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                ClipRRect(
                  borderRadius: BorderRadius.circular(4),
                  child: LinearProgressIndicator(
                    value: 450 / 550,
                    minHeight: 8,
                    backgroundColor: Colors.grey[300],
                    valueColor: AlwaysStoppedAnimation<Color>(
                      theme.primaryColor,
                    ),
                  ),
                ),
                const SizedBox(height: 12),
                Text(
                  '${(82).toString()}% to Level 6',
                  style: theme.textTheme.labelSmall?.copyWith(
                    color: Colors.grey[600],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            // Stats grid
            GridView.count(
              crossAxisCount: 3,
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              crossAxisSpacing: 12,
              mainAxisSpacing: 12,
              children: [
                _buildStatBox(
                  icon: Icons.library_books,
                  label: 'Cards Studied',
                  value: '1,245',
                  color: Colors.blue,
                  theme: theme,
                ),
                _buildStatBox(
                  icon: Icons.local_fire_department,
                  label: 'Current Streak',
                  value: '7 days',
                  color: Colors.orange,
                  theme: theme,
                ),
                _buildStatBox(
                  icon: Icons.timer,
                  label: 'Study Time',
                  value: '42 hrs',
                  color: Colors.green,
                  theme: theme,
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  /// Build stat box
  Widget _buildStatBox({
    required IconData icon,
    required String label,
    required String value,
    required Color color,
    required ThemeData theme,
  }) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.05),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: color.withValues(alpha: 0.2)),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(icon, color: color, size: 24),
          const SizedBox(height: 6),
          Text(
            value,
            style: theme.textTheme.labelMedium?.copyWith(
              fontWeight: FontWeight.bold,
              color: color,
            ),
          ),
          const SizedBox(height: 2),
          Text(
            label,
            textAlign: TextAlign.center,
            style: theme.textTheme.labelSmall?.copyWith(
              fontSize: 9,
              color: Colors.grey[600],
            ),
          ),
        ],
      ),
    );
  }

  /// Build XP progress chart
  Widget _buildXPChart(List<FlSpot> data, ThemeData theme) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'XP Earned - Last 30 Days',
              style: theme.textTheme.labelMedium?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            SizedBox(
              height: 200,
              child: LineChart(
                LineChartData(
                  gridData: FlGridData(
                    show: true,
                    drawVerticalLine: false,
                    verticalInterval: 50,
                    horizontalInterval: 50,
                    getDrawingHorizontalLine: (value) {
                      return FlLine(
                        color: Colors.grey[300] ?? Colors.grey,
                        strokeWidth: 0.5,
                      );
                    },
                  ),
                  titlesData: FlTitlesData(
                    show: true,
                    leftTitles: AxisTitles(
                      sideTitles: SideTitles(
                        showTitles: true,
                        reservedSize: 40,
                        getTitlesWidget: (value, meta) {
                          return Text(
                            '${value.toInt()}',
                            style: theme.textTheme.labelSmall,
                          );
                        },
                      ),
                    ),
                    bottomTitles: AxisTitles(
                      sideTitles: SideTitles(
                        showTitles: true,
                        reservedSize: 30,
                        interval: 5,
                        getTitlesWidget: (value, meta) {
                          return Text(
                            value.toInt().toString(),
                            style: theme.textTheme.labelSmall,
                          );
                        },
                      ),
                    ),
                    rightTitles: AxisTitles(
                      sideTitles: SideTitles(showTitles: false),
                    ),
                    topTitles: AxisTitles(
                      sideTitles: SideTitles(showTitles: false),
                    ),
                  ),
                  borderData: FlBorderData(
                    show: true,
                    border: Border.all(color: Colors.grey[300] ?? Colors.grey),
                  ),
                  lineBarsData: [
                    LineChartBarData(
                      spots: data,
                      isCurved: true,
                      color: theme.primaryColor,
                      barWidth: 2,
                      isStrokeCapRound: true,
                      dotData: FlDotData(
                        show: true,
                        getDotPainter: (spot, percent, barData, index) {
                          return FlDotCirclePainter(
                            radius: 4,
                            color: theme.primaryColor,
                            strokeWidth: 0,
                          );
                        },
                      ),
                      belowBarData: BarAreaData(
                        show: true,
                        color: theme.primaryColor.withValues(alpha: 0.1),
                      ),
                    ),
                  ],
                  minX: 0,
                  maxX: 30,
                  minY: 0,
                  maxY: 200,
                  lineTouchData: LineTouchData(
                    enabled: true,
                    touchTooltipData: LineTouchTooltipData(
                      getTooltipItems: (touchedSpots) {
                        return touchedSpots.map((touchedSpot) {
                          final textStyle = TextStyle(
                            color: touchedSpot.bar.color ?? Colors.blueGrey,
                            fontWeight: FontWeight.bold,
                            fontSize: 12,
                          );
                          return LineTooltipItem(
                            '${touchedSpot.y.toInt()} XP',
                            textStyle,
                          );
                        }).toList();
                      },
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

  /// Build deck performance chart
  Widget _buildDeckChart(List<BarChartGroupData> data, ThemeData theme) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Cards Reviewed by Deck',
              style: theme.textTheme.labelMedium?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            SizedBox(
              height: 200,
              child: BarChart(
                BarChartData(
                  gridData: FlGridData(
                    show: true,
                    drawVerticalLine: false,
                    horizontalInterval: 100,
                    getDrawingHorizontalLine: (value) {
                      return FlLine(
                        color: Colors.grey[300] ?? Colors.grey,
                        strokeWidth: 0.5,
                      );
                    },
                  ),
                  titlesData: FlTitlesData(
                    show: true,
                    leftTitles: AxisTitles(
                      sideTitles: SideTitles(
                        showTitles: true,
                        reservedSize: 40,
                        getTitlesWidget: (value, meta) {
                          return Text(
                            '${value.toInt()}',
                            style: theme.textTheme.labelSmall,
                          );
                        },
                      ),
                    ),
                    bottomTitles: AxisTitles(
                      sideTitles: SideTitles(
                        showTitles: true,
                        reservedSize: 40,
                        getTitlesWidget: (value, meta) {
                          final decks = ['Vocab', 'Grammar', 'Phrases'];
                          return Text(
                            decks[value.toInt()],
                            style: theme.textTheme.labelSmall,
                          );
                        },
                      ),
                    ),
                    rightTitles: AxisTitles(
                      sideTitles: SideTitles(showTitles: false),
                    ),
                    topTitles: AxisTitles(
                      sideTitles: SideTitles(showTitles: false),
                    ),
                  ),
                  borderData: FlBorderData(
                    show: true,
                    border: Border.all(color: Colors.grey[300] ?? Colors.grey),
                  ),
                  barGroups: data,
                  maxY: 500,
                  barTouchData: BarTouchData(
                    enabled: true,
                    touchTooltipData: BarTouchTooltipData(
                      getTooltipItem: (group, groupIndex, rod, rodIndex) {
                        return BarTooltipItem(
                          '${rod.toY.toInt()} cards',
                          TextStyle(
                            color: rod.color ?? Colors.blueGrey,
                            fontWeight: FontWeight.bold,
                          ),
                        );
                      },
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

  /// Build study time card
  Widget _buildStudyTimeCard(ThemeData theme) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Daily Study Habit',
              style: theme.textTheme.labelMedium?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Average Daily Study Time',
                      style: theme.textTheme.labelSmall?.copyWith(
                        color: Colors.grey[600],
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      '42 min',
                      style: theme.textTheme.headlineSmall?.copyWith(
                        fontWeight: FontWeight.bold,
                        color: theme.primaryColor,
                      ),
                    ),
                  ],
                ),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Text(
                      'Most Active',
                      style: theme.textTheme.labelSmall?.copyWith(
                        color: Colors.grey[600],
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      '10:00 - 11:00 AM',
                      style: theme.textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  /// Generate mock XP data for last 30 days
  List<FlSpot> _generateMockXPData() {
    return List.generate(
      30,
      (index) => FlSpot(
        index.toDouble(),
        50 + (index * 2 + (DateTime.now().millisecond % 100)).toDouble(),
      ),
    );
  }

  /// Generate mock deck statistics
  List<BarChartGroupData> _generateMockDeckStats() {
    return [
      BarChartGroupData(
        x: 0,
        barRods: [
          BarChartRodData(toY: 320, color: Colors.blue, width: 20),
        ],
      ),
      BarChartGroupData(
        x: 1,
        barRods: [
          BarChartRodData(toY: 280, color: Colors.green, width: 20),
        ],
      ),
      BarChartGroupData(
        x: 2,
        barRods: [
          BarChartRodData(toY: 240, color: Colors.orange, width: 20),
        ],
      ),
    ];
  }

  /// Get day letter from weekday number
  String _getDayLetter(int weekday) {
    const days = ['M', 'T', 'W', 'T', 'F', 'S', 'S'];
    return days[weekday - 1];
  }

  /// Check if two dates are the same day
  bool _isSameDay(DateTime date1, DateTime date2) {
    return date1.year == date2.year &&
        date1.month == date2.month &&
        date1.day == date2.day;
  }
}
