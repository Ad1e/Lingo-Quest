import 'package:flutter/material.dart';
import 'package:iconsax/iconsax.dart';
import 'package:language_learning_app/config/theme.dart';
import 'package:language_learning_app/views/widgets/app_card.dart';
import 'package:language_learning_app/views/widgets/section_header.dart';
import 'package:language_learning_app/views/widgets/stat_chip.dart';

class ProgressScreen extends StatelessWidget {
  const ProgressScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: isDark ? AppColors.bgDark : AppColors.surfaceLight,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(AppSpacing.screenH, AppSpacing.screenTop, AppSpacing.screenH, 32),
          child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [

            Text('Your progress', style: AppTextStyles.screenTitle()),
            const SizedBox(height: AppSpacing.sectionGap),

            // ── Level card ───────────────────────────────────────
            AppCard(
              child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                Row(children: [
                  TweenAnimationBuilder<int>(
                    tween: IntTween(begin: 0, end: 12),
                    duration: const Duration(milliseconds: 700),
                    curve: Curves.easeOutExpo,
                    builder: (_, v, __) => Text('Level $v',
                      style: AppTextStyles.display(color: AppColors.primary).copyWith(fontSize: 32)),
                  ),
                  const Spacer(),
                  AppChip(label: '62% to next', variant: AppChipVariant.blue),
                ]),
                const SizedBox(height: 16),
                ClipRRect(
                  borderRadius: BorderRadius.circular(99),
                  child: TweenAnimationBuilder<double>(
                    tween: Tween(begin: 0, end: 0.62),
                    duration: const Duration(milliseconds: 500),
                    curve: Curves.easeInOut,
                    builder: (_, v, __) => LinearProgressIndicator(
                      value: v, minHeight: 10,
                      backgroundColor: AppColors.neutralLight,
                      valueColor: const AlwaysStoppedAnimation(AppColors.primary),
                    ),
                  ),
                ),
                const SizedBox(height: 8),
                Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
                  Text('1,240 XP', style: AppTextStyles.caption()),
                  Text('2,000 XP', style: AppTextStyles.caption()),
                ]),
              ]),
            ),

            const SizedBox(height: AppSpacing.sectionGap),

            // ── Stats grid ───────────────────────────────────────
            GridView.count(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              crossAxisCount: 2,
              mainAxisSpacing: AppSpacing.itemGap,
              crossAxisSpacing: AppSpacing.itemGap,
              childAspectRatio: 1.6,
              children: [
                TweenAnimationBuilder<int>(
                  tween: IntTween(begin: 0, end: 7),
                  duration: const Duration(milliseconds: 700),
                  curve: Curves.easeOutExpo,
                  builder: (_, v, __) => StatCard(value: '$v', label: 'DAY STREAK', valueColor: AppColors.amber),
                ),
                TweenAnimationBuilder<int>(
                  tween: IntTween(begin: 0, end: 350),
                  duration: const Duration(milliseconds: 700),
                  curve: Curves.easeOutExpo,
                  builder: (_, v, __) => StatCard(value: '$v', label: 'CARDS MASTERED'),
                ),
                TweenAnimationBuilder<int>(
                  tween: IntTween(begin: 0, end: 12),
                  duration: const Duration(milliseconds: 700),
                  curve: Curves.easeOutExpo,
                  builder: (_, v, __) => StatCard(value: '$v', label: 'LESSONS DONE'),
                ),
                TweenAnimationBuilder<int>(
                  tween: IntTween(begin: 0, end: 87),
                  duration: const Duration(milliseconds: 700),
                  curve: Curves.easeOutExpo,
                  builder: (_, v, __) => StatCard(value: '$v%', label: 'ACCURACY'),
                ),
              ],
            ),

            const SizedBox(height: AppSpacing.sectionGap),

            // ── Activity chart ────────────────────────────────────
            SectionHeader(title: 'Activity'),
            const SizedBox(height: AppSpacing.itemGap),
            AppCard(
              child: _ActivityChart(),
            ),

            const SizedBox(height: AppSpacing.sectionGap),

            // ── Achievements ──────────────────────────────────────
            SectionHeader(title: 'Achievements', onSeeAll: () {}),
            const SizedBox(height: AppSpacing.itemGap),
            SizedBox(
              height: 110,
              child: ListView.separated(
                scrollDirection: Axis.horizontal,
                itemCount: 6,
                separatorBuilder: (_, __) => const SizedBox(width: 12),
                itemBuilder: (_, i) => _AchievementBadge(
                  label: ['7-Day\nStreak', 'First\nLesson', '100\nCards', 'Speed\nReader', 'Night\nOwl', 'Master'][i],
                  unlocked: i < 3,
                ),
              ),
            ),

            const SizedBox(height: AppSpacing.sectionGap),

            // ── Streak calendar ───────────────────────────────────
            SectionHeader(title: 'Streak calendar'),
            const SizedBox(height: AppSpacing.itemGap),
            AppCard(child: _StreakCalendar()),
          ]),
        ),
      ),
    );
  }
}

// ── Sub-widgets ──────────────────────────────────────────────────────────────

class _ActivityChart extends StatelessWidget {
  static const _days = ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'];
  static const _values = [0.4, 0.7, 0.9, 0.5, 1.0, 0.6, 0.3];

  @override
  Widget build(BuildContext context) {
    return Column(children: [
      SizedBox(
        height: 80,
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.end,
          children: List.generate(_days.length, (i) => Expanded(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 3),
              child: TweenAnimationBuilder<double>(
                tween: Tween(begin: 0, end: _values[i]),
                duration: Duration(milliseconds: 400 + i * 60),
                curve: Curves.easeOut,
                builder: (_, v, __) => FractionallySizedBox(
                  alignment: Alignment.bottomCenter,
                  heightFactor: v,
                  child: Container(
                    decoration: BoxDecoration(
                      color: _values[i] == 1.0 ? AppColors.primary : AppColors.primaryMid,
                      borderRadius: BorderRadius.circular(6),
                    ),
                  ),
                ),
              ),
            ),
          )),
        ),
      ),
      const SizedBox(height: 8),
      Row(children: _days.map((d) => Expanded(
        child: Center(child: Text(d, style: AppTextStyles.label())),
      )).toList()),
    ]);
  }
}

class _AchievementBadge extends StatelessWidget {
  final String label;
  final bool unlocked;
  const _AchievementBadge({required this.label, required this.unlocked});

  @override
  Widget build(BuildContext context) {
    return Opacity(
      opacity: unlocked ? 1.0 : 0.4,
      child: SizedBox(
        width: 80,
        child: Column(children: [
          Container(
            width: 52, height: 52,
            decoration: BoxDecoration(
              color: unlocked ? AppColors.amberMid : AppColors.neutralLight,
              shape: BoxShape.circle,
            ),
            child: Icon(
              unlocked ? Iconsax.medal : Iconsax.lock,
              size: 24,
              color: unlocked ? AppColors.amber : AppColors.neutralMid,
            ),
          ),
          const SizedBox(height: 8),
          Text(label, style: AppTextStyles.label(), textAlign: TextAlign.center, maxLines: 2),
        ]),
      ),
    );
  }
}

class _StreakCalendar extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final now = DateTime.now();
    final studiedDays = {1, 2, 3, 5, 6, 7, 8, 10, 12, 14, now.day};
    final daysInMonth = DateUtils.getDaysInMonth(now.year, now.month);
    final firstWeekday = DateTime(now.year, now.month, 1).weekday % 7;

    final dayLabels = ['S', 'M', 'T', 'W', 'T', 'F', 'S'];

    return Column(children: [
      Row(children: dayLabels.map((d) => Expanded(
        child: Center(child: Text(d, style: AppTextStyles.label())),
      )).toList()),
      const SizedBox(height: 8),
      GridView.builder(
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 7, mainAxisSpacing: 6, crossAxisSpacing: 6,
        ),
        itemCount: firstWeekday + daysInMonth,
        itemBuilder: (_, i) {
          if (i < firstWeekday) return const SizedBox.shrink();
          final day = i - firstWeekday + 1;
          final studied = studiedDays.contains(day);
          final isToday = day == now.day;

          return Container(
            decoration: BoxDecoration(
              color: studied ? AppColors.primary : Colors.transparent,
              shape: BoxShape.circle,
              border: isToday && !studied ? Border.all(color: AppColors.primary, width: 2) : null,
            ),
            child: Center(
              child: Text('$day', style: AppTextStyles.label(
                color: studied ? Colors.white : AppColors.neutralMid,
              )),
            ),
          );
        },
      ),
    ]);
  }
}
