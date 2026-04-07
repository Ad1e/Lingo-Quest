import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:iconsax/iconsax.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:language_learning_app/config/theme.dart';
import 'package:language_learning_app/views/widgets/app_button.dart';
import 'package:language_learning_app/views/widgets/app_card.dart';
import 'package:language_learning_app/views/widgets/section_header.dart';
import 'package:language_learning_app/views/widgets/stat_chip.dart';
import 'package:language_learning_app/views/widgets/bottom_nav_bar.dart';

class HomeScreen extends StatefulWidget {
  final String userId;
  const HomeScreen({super.key, required this.userId});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _selectedIndex = 0;

  Widget _getTab() {
    switch (_selectedIndex) {
      case 0: return const _DashboardTab();
      case 1: return const _LessonsTab();
      case 2: return const _PracticeTab();
      case 3: return const _SocialTab();
      case 4: return const _ProfileTab();
      default: return const SizedBox.shrink();
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Scaffold(
      backgroundColor: isDark ? AppColors.bgDark : const Color(0xFFF5F7FA),
      extendBody: true,
      body: _getTab(),
      bottomNavigationBar: BottomNavBar(
        selectedIndex: _selectedIndex,
        onTap: (i) => setState(() => _selectedIndex = i),
      ),
    );
  }
}

// ══════════════════════════════════════════════════════════════════════════════
// DASHBOARD TAB
// ══════════════════════════════════════════════════════════════════════════════

class _DashboardTab extends StatelessWidget {
  const _DashboardTab();

  @override
  Widget build(BuildContext context) {
    final user  = FirebaseAuth.instance.currentUser;
    final name  = user?.displayName ?? user?.email?.split('@').first ?? 'Learner';
    final initials = name.isNotEmpty ? name[0].toUpperCase() : 'L';
    final hour  = DateTime.now().hour;
    final greeting = hour < 12 ? 'Good morning' : hour < 17 ? 'Good afternoon' : 'Good evening';
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return CustomScrollView(
      slivers: [
        // ── Hero header ────────────────────────────────────────────────────
        SliverToBoxAdapter(
          child: Container(
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                colors: [Color(0xFF1557C0), Color(0xFF1A73E8)],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
            ),
            child: SafeArea(
              bottom: false,
              child: Padding(
                padding: const EdgeInsets.fromLTRB(20, 16, 20, 28),
                child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [

                  // Top row
                  Row(children: [
                    CircleAvatar(
                      radius: 22,
                      backgroundColor: Colors.white.withValues(alpha: 0.2),
                      child: Text(initials, style: const TextStyle(
                        color: Colors.white, fontSize: 16, fontWeight: FontWeight.w700,
                      )),
                    ),
                    const SizedBox(width: 12),
                    Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                      Text('$greeting 👋', style: TextStyle(
                        color: Colors.white.withValues(alpha: 0.85), fontSize: 13,
                      )),
                      Text(name, style: GoogleFonts.plusJakartaSans(
                        color: Colors.white, fontSize: 17, fontWeight: FontWeight.w700,
                      )),
                    ])),
                    _NotificationBell(),
                  ]),

                  const SizedBox(height: 24),

                  // Streak + XP pill row
                  Row(children: [
                    _HeroPill(
                      icon: Iconsax.flash_1,
                      iconColor: AppColors.amber,
                      label: '7-day streak',
                      value: '🔥 7',
                    ),
                    const SizedBox(width: 12),
                    _HeroPill(
                      icon: Iconsax.flash_circle,
                      iconColor: Colors.white,
                      label: 'Total XP',
                      value: '⚡ 2,450',
                    ),
                  ]),
                ]),
              ),
            ),
          ),
        ),

        // ── Body ───────────────────────────────────────────────────────────
        SliverPadding(
          padding: const EdgeInsets.fromLTRB(20, 24, 20, 110),
          sliver: SliverList(
            delegate: SliverChildListDelegate([

              // ── Continue learning ──────────────────────────────────────
              SectionHeader(title: 'Continue learning', onSeeAll: () {}),
              const SizedBox(height: 12),
              _ContinueLearningCard(),

              const SizedBox(height: 28),

              // ── Due for review ─────────────────────────────────────────
              SectionHeader(title: 'Due for review', onSeeAll: () {}),
              const SizedBox(height: 12),
              _ReviewCard(),

              const SizedBox(height: 28),

              // ── Daily challenge ────────────────────────────────────────
              SectionHeader(title: 'Daily challenge'),
              const SizedBox(height: 12),
              _DailyChallengeCard(),

              const SizedBox(height: 28),

              // ── Quick stats ────────────────────────────────────────────
              SectionHeader(title: 'Quick stats', onSeeAll: () {}),
              const SizedBox(height: 12),
              GridView.count(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                crossAxisCount: 2,
                mainAxisSpacing: 12,
                crossAxisSpacing: 12,
                childAspectRatio: 1.55,
                children: const [
                  _StatCard(value: '350', label: 'Total cards', icon: Iconsax.card, iconColor: AppColors.primary),
                  _StatCard(value: 'Lv. 5', label: 'Current level', icon: Iconsax.medal, iconColor: AppColors.amber),
                  _StatCard(value: '7', label: 'Day streak', icon: Iconsax.flash_1, iconColor: AppColors.amber),
                  _StatCard(value: '12', label: 'Lessons done', icon: Iconsax.book, iconColor: AppColors.primary),
                ],
              ),
            ]),
          ),
        ),
      ],
    );
  }
}

// ── Hero Pill ────────────────────────────────────────────────────────────────

class _HeroPill extends StatelessWidget {
  final IconData icon;
  final Color iconColor;
  final String label;
  final String value;
  const _HeroPill({required this.icon, required this.iconColor, required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
        decoration: BoxDecoration(
          color: Colors.white.withValues(alpha: 0.15),
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: Colors.white.withValues(alpha: 0.2)),
        ),
        child: Row(children: [
          Text(value, style: GoogleFonts.plusJakartaSans(
            color: Colors.white, fontSize: 15, fontWeight: FontWeight.w700,
          )),
          const SizedBox(width: 6),
          Text(label, style: TextStyle(color: Colors.white.withValues(alpha: 0.75), fontSize: 12)),
        ]),
      ),
    );
  }
}

class _NotificationBell extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Stack(clipBehavior: Clip.none, children: [
      Container(
        width: 40, height: 40,
        decoration: BoxDecoration(
          color: Colors.white.withValues(alpha: 0.15),
          shape: BoxShape.circle,
        ),
        child: const Icon(Iconsax.notification, size: 20, color: Colors.white),
      ),
      Positioned(top: 8, right: 8,
        child: Container(width: 8, height: 8,
          decoration: BoxDecoration(color: AppColors.amber, shape: BoxShape.circle,
            border: Border.all(color: AppColors.primary, width: 1.5)))),
    ]);
  }
}

// ── Continue Learning Card ───────────────────────────────────────────────────

class _ContinueLearningCard extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Container(
      decoration: BoxDecoration(
        color: isDark ? AppColors.surfaceDark : Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: isDark ? null : AppShadows.card,
        border: isDark ? Border.all(color: AppColors.borderDark) : null,
      ),
      child: Column(children: [
        // Color header strip
        Container(
          height: 6,
          decoration: const BoxDecoration(
            gradient: LinearGradient(colors: [Color(0xFF1A73E8), Color(0xFF4CA8FF)]),
            borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
          ),
        ),
        Padding(
          padding: const EdgeInsets.all(18),
          child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [

            Row(children: [
              // Flag/icon
              Container(
                width: 44, height: 44,
                decoration: BoxDecoration(
                  color: AppColors.primaryMid,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Center(child: Text('🇪🇸', style: TextStyle(fontSize: 24))),
              ),
              const SizedBox(width: 12),
              Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                Text('Beginner Spanish', style: AppTextStyles.bodySemiBold()),
                const SizedBox(height: 2),
                Text('Unit 1 · Greetings & Numbers', style: AppTextStyles.caption()),
              ])),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: AppColors.primaryMid, borderRadius: BorderRadius.circular(99),
                ),
                child: Text('60%', style: GoogleFonts.plusJakartaSans(
                  fontSize: 12, fontWeight: FontWeight.w700, color: AppColors.primary,
                )),
              ),
            ]),

            const SizedBox(height: 14),

            // Progress bar
            ClipRRect(
              borderRadius: BorderRadius.circular(99),
              child: LinearProgressIndicator(
                value: 0.6, minHeight: 6,
                backgroundColor: AppColors.neutralLight,
                valueColor: const AlwaysStoppedAnimation(AppColors.primary),
              ),
            ),
            const SizedBox(height: 6),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text('3 of 5 lessons done', style: AppTextStyles.label()),
                Text('~15 min left', style: AppTextStyles.label()),
              ],
            ),

            const SizedBox(height: 16),

            // Continue button – full-width but styled
            SizedBox(
              width: double.infinity,
              height: 46,
              child: ElevatedButton.icon(
                onPressed: () {},
                icon: const Icon(Iconsax.play_circle, size: 18, color: Colors.white),
                label: Text('Continue lesson', style: GoogleFonts.plusJakartaSans(
                  fontSize: 15, fontWeight: FontWeight.w600, color: Colors.white,
                )),
                style: ElevatedButton.styleFrom(
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                ),
              ),
            ),
          ]),
        ),
      ]),
    );
  }
}

// ── Review Card ──────────────────────────────────────────────────────────────

class _ReviewCard extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: isDark ? AppColors.surfaceDark : Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: isDark ? null : AppShadows.card,
        border: isDark ? Border.all(color: AppColors.borderDark) : null,
      ),
      child: Row(children: [
        Container(
          width: 48, height: 48,
          decoration: BoxDecoration(
            color: AppColors.amberMid,
            borderRadius: BorderRadius.circular(14),
          ),
          child: const Icon(Iconsax.cards, size: 22, color: AppColors.amber),
        ),
        const SizedBox(width: 14),
        Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Text('Spanish Vocabulary', style: AppTextStyles.bodySemiBold()),
          const SizedBox(height: 4),
          Row(children: [
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
              decoration: BoxDecoration(color: AppColors.amberMid, borderRadius: BorderRadius.circular(99)),
              child: Text('12 due', style: GoogleFonts.plusJakartaSans(
                fontSize: 11, fontWeight: FontWeight.w700, color: AppColors.amberText,
              )),
            ),
            const SizedBox(width: 8),
            Text('≈ 8 min', style: AppTextStyles.caption()),
          ]),
        ])),
        const SizedBox(width: 8),
        SizedBox(
          height: 40,
          child: ElevatedButton(
            onPressed: () {},
            style: ElevatedButton.styleFrom(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
            ),
            child: Text('Study now', style: GoogleFonts.plusJakartaSans(
              fontSize: 13, fontWeight: FontWeight.w600, color: Colors.white,
            )),
          ),
        ),
      ]),
    );
  }
}

// ── Daily Challenge Card ─────────────────────────────────────────────────────

class _DailyChallengeCard extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFFFFF8EC), Color(0xFFFEF3DC)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AppColors.amber.withValues(alpha: 0.25)),
      ),
      child: Padding(
        padding: const EdgeInsets.all(18),
        child: Row(children: [
          Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Row(children: [
              const Text('🏆', style: TextStyle(fontSize: 16)),
              const SizedBox(width: 6),
              Text('DAILY CHALLENGE', style: GoogleFonts.plusJakartaSans(
                fontSize: 11, fontWeight: FontWeight.w700,
                color: AppColors.amberText, letterSpacing: 0.5,
              )),
            ]),
            const SizedBox(height: 6),
            Text('Translate 10 sentences', style: AppTextStyles.bodySemiBold()),
            const SizedBox(height: 8),
            Row(children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(color: AppColors.amber.withValues(alpha: 0.2), borderRadius: BorderRadius.circular(99)),
                child: Text('⚡ +50 XP', style: GoogleFonts.plusJakartaSans(
                  fontSize: 12, fontWeight: FontWeight.w700, color: AppColors.amberText,
                )),
              ),
              const SizedBox(width: 10),
              Icon(Iconsax.clock, size: 14, color: AppColors.amberText),
              const SizedBox(width: 4),
              Text('3h left', style: AppTextStyles.caption(color: AppColors.amberText)),
            ]),
          ])),
          const SizedBox(width: 12),
          SizedBox(
            height: 44,
            child: OutlinedButton(
              onPressed: () {},
              style: OutlinedButton.styleFrom(
                foregroundColor: AppColors.amberText,
                side: BorderSide(color: AppColors.amber.withValues(alpha: 0.5), width: 1.5),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                padding: const EdgeInsets.symmetric(horizontal: 16),
                backgroundColor: Colors.white.withValues(alpha: 0.6),
              ),
              child: Text('Start', style: GoogleFonts.plusJakartaSans(
                fontSize: 14, fontWeight: FontWeight.w600, color: AppColors.amberText,
              )),
            ),
          ),
        ]),
      ),
    );
  }
}

// ── Stat Card (2×2 grid) ─────────────────────────────────────────────────────

class _StatCard extends StatelessWidget {
  final String value;
  final String label;
  final IconData icon;
  final Color iconColor;
  const _StatCard({required this.value, required this.label, required this.icon, required this.iconColor});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final iconBg = iconColor == AppColors.amber ? AppColors.amberMid : AppColors.primaryMid;
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: isDark ? AppColors.surfaceDark : Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: isDark ? null : AppShadows.card,
        border: isDark ? Border.all(color: AppColors.borderDark) : null,
      ),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
        Container(
          width: 36, height: 36,
          decoration: BoxDecoration(color: iconBg, borderRadius: BorderRadius.circular(10)),
          child: Icon(icon, size: 18, color: iconColor),
        ),
        Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Text(value, style: GoogleFonts.plusJakartaSans(
            fontSize: 22, fontWeight: FontWeight.w800,
            color: isDark ? AppColors.textPrimaryDark : AppColors.neutralDark,
          )),
          Text(label, style: AppTextStyles.label()),
        ]),
      ]),
    );
  }
}

// ══════════════════════════════════════════════════════════════════════════════
// LESSONS TAB
// ══════════════════════════════════════════════════════════════════════════════

class _LessonsTab extends StatefulWidget {
  const _LessonsTab();
  @override
  State<_LessonsTab> createState() => _LessonsTabState();
}

class _LessonsTabState extends State<_LessonsTab> {
  int _level = 0;
  final _levels = ['All', 'Beginner', 'Intermediate', 'Advanced'];

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return SafeArea(
      bottom: false,
      child: CustomScrollView(
        slivers: [
          SliverToBoxAdapter(child: Padding(
            padding: const EdgeInsets.fromLTRB(20, 16, 20, 0),
            child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Text('Lessons', style: AppTextStyles.screenTitle()),
              const SizedBox(height: 16),
              SizedBox(height: 36, child: ListView.separated(
                scrollDirection: Axis.horizontal,
                itemCount: _levels.length,
                separatorBuilder: (_, __) => const SizedBox(width: 8),
                itemBuilder: (_, i) {
                  final active = i == _level;
                  return GestureDetector(
                    onTap: () => setState(() => _level = i),
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 200),
                      padding: const EdgeInsets.symmetric(horizontal: 18),
                      decoration: BoxDecoration(
                        color: active ? AppColors.primary : (isDark ? AppColors.surfaceDark : Colors.white),
                        borderRadius: BorderRadius.circular(99),
                        border: Border.all(color: active ? AppColors.primary : AppColors.neutralMid.withValues(alpha: 0.3)),
                      ),
                      alignment: Alignment.center,
                      child: Text(_levels[i], style: GoogleFonts.plusJakartaSans(
                        fontSize: 13, fontWeight: FontWeight.w600,
                        color: active ? Colors.white : AppColors.neutralMid,
                      )),
                    ),
                  );
                },
              )),
              const SizedBox(height: 20),
            ]),
          )),
          SliverPadding(
            padding: const EdgeInsets.fromLTRB(20, 0, 20, 110),
            sliver: SliverList(delegate: SliverChildBuilderDelegate(
              (_, i) => Padding(
                padding: const EdgeInsets.only(bottom: 12),
                child: _LessonCard(
                  number: i + 1,
                  title: ['Greetings & Numbers', 'Colors & Shapes', 'Food & Drinks', 'Family & Friends', 'Travel Phrases', 'At the Hotel', 'Shopping', 'Directions'][i % 8],
                  tag: i < 3 ? 'Beginner' : i < 6 ? 'Intermediate' : 'Advanced',
                  progress: [1.0, 0.6, 0.3, 0.0, 0.0, 0.0, 0.0, 0.0][i % 8],
                  isDone: i == 0,
                  isLocked: i > 3,
                ),
              ),
              childCount: 8,
            )),
          ),
        ],
      ),
    );
  }
}

class _LessonCard extends StatelessWidget {
  final int number;
  final String title, tag;
  final double progress;
  final bool isDone, isLocked;
  const _LessonCard({required this.number, required this.title, required this.tag,
    required this.progress, required this.isDone, required this.isLocked});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: isDark ? AppColors.surfaceDark : Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: isDark ? null : AppShadows.card,
        border: isDark ? Border.all(color: AppColors.borderDark) : null,
      ),
      child: Column(children: [
        Row(children: [
          Container(
            width: 40, height: 40,
            decoration: BoxDecoration(
              color: isDone ? AppColors.primary : isLocked ? AppColors.neutralLight : AppColors.primaryMid,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Center(child: isDone
                ? const Icon(Iconsax.tick_circle5, color: Colors.white, size: 20)
                : isLocked
                    ? Icon(Iconsax.lock, color: AppColors.neutralMid, size: 18)
                    : Text('$number', style: GoogleFonts.plusJakartaSans(
                        fontSize: 15, fontWeight: FontWeight.w800, color: AppColors.primary))),
          ),
          const SizedBox(width: 14),
          Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Text(title, style: AppTextStyles.bodySemiBold()),
            const SizedBox(height: 3),
            Row(children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                decoration: BoxDecoration(
                  color: isDone ? AppColors.primaryMid : isLocked ? AppColors.neutralLight : AppColors.primaryMid,
                  borderRadius: BorderRadius.circular(99),
                ),
                child: Text(tag, style: GoogleFonts.plusJakartaSans(
                  fontSize: 11, fontWeight: FontWeight.w600,
                  color: isLocked ? AppColors.neutralMid : AppColors.primary,
                )),
              ),
            ]),
          ])),
          Icon(
            isDone ? Iconsax.tick_circle5 : isLocked ? Iconsax.lock_1 : Iconsax.arrow_right_3,
            size: 20, color: isDone ? AppColors.primary : AppColors.neutralMid,
          ),
        ]),
        if (progress > 0 && progress < 1.0) ...[
          const SizedBox(height: 12),
          ClipRRect(borderRadius: BorderRadius.circular(99), child: LinearProgressIndicator(
            value: progress, minHeight: 4,
            backgroundColor: AppColors.neutralLight,
            valueColor: const AlwaysStoppedAnimation(AppColors.primary),
          )),
          const SizedBox(height: 4),
          Align(alignment: Alignment.centerRight,
            child: Text('${(progress * 100).round()}% complete', style: AppTextStyles.label())),
        ],
      ]),
    );
  }
}

// ══════════════════════════════════════════════════════════════════════════════
// PRACTICE TAB
// ══════════════════════════════════════════════════════════════════════════════

class _PracticeTab extends StatelessWidget {
  const _PracticeTab();
  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return SafeArea(bottom: false, child: Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        const SizedBox(height: 16),
        Text('Practice', style: AppTextStyles.screenTitle()),
        const SizedBox(height: 24),
        _PracticeModeCard(icon: Iconsax.cards, title: 'Flashcard review', subtitle: '12 cards due today', badge: '12 due', color: AppColors.primary),
        const SizedBox(height: 12),
        _PracticeModeCard(icon: Iconsax.microphone_2, title: 'Pronunciation', subtitle: 'Practice speaking', badge: null, color: const Color(0xFF6C63FF)),
        const SizedBox(height: 12),
        _PracticeModeCard(icon: Iconsax.pen_add, title: 'Writing practice', subtitle: 'Fill in the blanks', badge: null, color: AppColors.amber),
        const SizedBox(height: 12),
        _PracticeModeCard(icon: Iconsax.music, title: 'Listening quiz', subtitle: 'Train your ear', badge: null, color: const Color(0xFF14B8A6)),
      ]),
    ));
  }
}

class _PracticeModeCard extends StatelessWidget {
  final IconData icon;
  final String title, subtitle;
  final String? badge;
  final Color color;
  const _PracticeModeCard({required this.icon, required this.title, required this.subtitle, this.badge, required this.color});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return GestureDetector(
      onTap: () {},
      child: Container(
        padding: const EdgeInsets.all(18),
        decoration: BoxDecoration(
          color: isDark ? AppColors.surfaceDark : Colors.white,
          borderRadius: BorderRadius.circular(18),
          boxShadow: isDark ? null : AppShadows.card,
          border: isDark ? Border.all(color: AppColors.borderDark) : null,
        ),
        child: Row(children: [
          Container(
            width: 50, height: 50,
            decoration: BoxDecoration(color: color.withValues(alpha: 0.12), borderRadius: BorderRadius.circular(14)),
            child: Icon(icon, size: 24, color: color),
          ),
          const SizedBox(width: 14),
          Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Text(title, style: AppTextStyles.bodySemiBold()),
            const SizedBox(height: 2),
            Text(subtitle, style: AppTextStyles.caption()),
          ])),
          if (badge != null) Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
            decoration: BoxDecoration(color: AppColors.amberMid, borderRadius: BorderRadius.circular(99)),
            child: Text(badge!, style: GoogleFonts.plusJakartaSans(fontSize: 12, fontWeight: FontWeight.w700, color: AppColors.amberText)),
          ) else const Icon(Iconsax.arrow_right_3, size: 18, color: AppColors.neutralMid),
        ]),
      ),
    );
  }
}

// ══════════════════════════════════════════════════════════════════════════════
// SOCIAL / LEADERBOARD TAB
// ══════════════════════════════════════════════════════════════════════════════

class _SocialTab extends StatefulWidget {
  const _SocialTab();
  @override
  State<_SocialTab> createState() => _SocialTabState();
}

class _SocialTabState extends State<_SocialTab> {
  int _tab = 0;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final user = FirebaseAuth.instance.currentUser;
    final myName = user?.displayName ?? user?.email?.split('@').first ?? 'You';

    return SafeArea(bottom: false, child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      Padding(
        padding: const EdgeInsets.fromLTRB(20, 16, 20, 0),
        child: Row(children: [
          Expanded(child: Text('Leaderboard', style: AppTextStyles.screenTitle())),
          OutlinedButton.icon(
            onPressed: () {},
            icon: const Icon(Iconsax.user_add, size: 16),
            label: const Text('Add friend'),
            style: OutlinedButton.styleFrom(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              minimumSize: Size.zero,
              textStyle: GoogleFonts.plusJakartaSans(fontSize: 13, fontWeight: FontWeight.w600),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
            ),
          ),
        ]),
      ),
      const SizedBox(height: 16),
      Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20),
        child: Row(children: ['Weekly', 'Monthly', 'All-time'].asMap().entries.map((e) {
          final active = e.key == _tab;
          return GestureDetector(
            onTap: () => setState(() => _tab = e.key),
            child: Padding(
              padding: const EdgeInsets.only(right: 20),
              child: Column(children: [
                Text(e.value, style: GoogleFonts.plusJakartaSans(
                  fontSize: 15, fontWeight: active ? FontWeight.w700 : FontWeight.w400,
                  color: active ? AppColors.primary : AppColors.neutralMid,
                )),
                const SizedBox(height: 6),
                AnimatedContainer(
                  duration: const Duration(milliseconds: 200),
                  height: 2.5, width: active ? 24 : 0,
                  decoration: BoxDecoration(color: AppColors.primary, borderRadius: BorderRadius.circular(99)),
                ),
              ]),
            ),
          );
        }).toList()),
      ),
      const Divider(height: 1),
      Expanded(child: ListView(
        padding: const EdgeInsets.fromLTRB(20, 20, 20, 100),
        children: [
          // Podium
          Row(mainAxisAlignment: MainAxisAlignment.spaceEvenly, crossAxisAlignment: CrossAxisAlignment.end, children: [
            _PodiumItem(rank: 2, name: 'Maria', xp: 2100, size: 50, podiumH: 70, isDark: isDark),
            _PodiumItem(rank: 1, name: myName, xp: 2450, size: 60, podiumH: 100, isDark: isDark, isYou: true),
            _PodiumItem(rank: 3, name: 'Carlos', xp: 1980, size: 46, podiumH: 50, isDark: isDark),
          ]),
          const SizedBox(height: 24),
          ...List.generate(7, (i) => _LeaderRow(rank: i + 4, name: 'Player ${i+4}', xp: 1800 - i * 120, isYou: false, isDark: isDark)),
        ],
      )),
    ]));
  }
}

class _PodiumItem extends StatelessWidget {
  final int rank;
  final String name;
  final int xp;
  final double size, podiumH;
  final bool isYou, isDark;
  const _PodiumItem({required this.rank, required this.name, required this.xp, required this.size, required this.podiumH, required this.isDark, this.isYou = false});

  @override
  Widget build(BuildContext context) {
    return Column(mainAxisSize: MainAxisSize.min, children: [
      if (rank == 1) const Text('👑', style: TextStyle(fontSize: 22)),
      const SizedBox(height: 4),
      Stack(alignment: Alignment.bottomRight, clipBehavior: Clip.none, children: [
        CircleAvatar(radius: size / 2,
          backgroundColor: isYou ? AppColors.primary : AppColors.primaryMid,
          child: Text(name[0], style: GoogleFonts.plusJakartaSans(
            fontSize: size * 0.35, fontWeight: FontWeight.w800,
            color: isYou ? Colors.white : AppColors.primary,
          ))),
        Positioned(bottom: -2, right: -2, child: Container(
          width: 20, height: 20,
          decoration: BoxDecoration(color: AppColors.primary, shape: BoxShape.circle,
            border: Border.all(color: Colors.white, width: 1.5)),
          child: Center(child: Text('$rank', style: const TextStyle(color: Colors.white, fontSize: 10, fontWeight: FontWeight.w800))),
        )),
      ]),
      const SizedBox(height: 8),
      Text(name, style: GoogleFonts.plusJakartaSans(fontSize: 13, fontWeight: FontWeight.w600,
        color: isYou ? AppColors.primary : (isDark ? AppColors.textPrimaryDark : AppColors.neutralDark))),
      Text('${(xp / 1000).toStringAsFixed(1)}k XP', style: AppTextStyles.caption()),
      const SizedBox(height: 6),
      Container(
        width: 60, height: podiumH,
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: rank == 1
                ? [AppColors.amber.withValues(alpha: 0.8), AppColors.amberMid]
                : [AppColors.primaryMid, Colors.white.withValues(alpha: 0)],
            begin: Alignment.topCenter, end: Alignment.bottomCenter,
          ),
          borderRadius: const BorderRadius.vertical(top: Radius.circular(8)),
        ),
      ),
    ]);
  }
}

class _LeaderRow extends StatelessWidget {
  final int rank;
  final String name;
  final int xp;
  final bool isYou, isDark;
  const _LeaderRow({required this.rank, required this.name, required this.xp, required this.isYou, required this.isDark});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      decoration: BoxDecoration(
        color: isYou ? AppColors.primaryMid : (isDark ? AppColors.surfaceDark : Colors.white),
        borderRadius: BorderRadius.circular(12),
        border: isYou ? Border.all(color: AppColors.primary.withValues(alpha: 0.3)) : null,
      ),
      child: Row(children: [
        SizedBox(width: 28, child: Text('#$rank', style: GoogleFonts.plusJakartaSans(
          fontSize: 14, fontWeight: FontWeight.w700,
          color: AppColors.neutralMid,
        ))),
        CircleAvatar(radius: 16, backgroundColor: isYou ? AppColors.primary : AppColors.primaryMid,
          child: Text(name[0], style: TextStyle(fontSize: 13, fontWeight: FontWeight.w700,
            color: isYou ? Colors.white : AppColors.primary))),
        const SizedBox(width: 10),
        Expanded(child: Text(name, style: GoogleFonts.plusJakartaSans(
          fontSize: 15, fontWeight: isYou ? FontWeight.w700 : FontWeight.w500,
          color: isYou ? AppColors.primary : (isDark ? AppColors.textPrimaryDark : AppColors.neutralDark),
        ))),
        Icon(Iconsax.flash_circle, size: 14, color: AppColors.amber),
        const SizedBox(width: 4),
        Text('$xp XP', style: GoogleFonts.plusJakartaSans(
          fontSize: 13, fontWeight: FontWeight.w700, color: AppColors.amberText,
        )),
      ]),
    );
  }
}

// ══════════════════════════════════════════════════════════════════════════════
// PROFILE TAB
// ══════════════════════════════════════════════════════════════════════════════

class _ProfileTab extends StatelessWidget {
  const _ProfileTab();

  @override
  Widget build(BuildContext context) {
    final user = FirebaseAuth.instance.currentUser;
    final name = user?.displayName ?? user?.email?.split('@').first ?? 'Learner';
    final email = user?.email ?? '';
    final initials = name.isNotEmpty ? name[0].toUpperCase() : 'L';
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return SafeArea(bottom: false, child: SingleChildScrollView(
      child: Column(children: [
        // Profile header with gradient
        Container(
          width: double.infinity,
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              colors: [Color(0xFF1557C0), Color(0xFF1A73E8)],
              begin: Alignment.topLeft, end: Alignment.bottomRight,
            ),
          ),
          padding: const EdgeInsets.fromLTRB(20, 20, 20, 36),
          child: Column(children: [
            CircleAvatar(
              radius: 40,
              backgroundColor: Colors.white.withValues(alpha: 0.2),
              child: Text(initials, style: const TextStyle(color: Colors.white, fontSize: 30, fontWeight: FontWeight.w800)),
            ),
            const SizedBox(height: 12),
            Text(name, style: GoogleFonts.plusJakartaSans(color: Colors.white, fontSize: 20, fontWeight: FontWeight.w700)),
            const SizedBox(height: 4),
            Text(email, style: TextStyle(color: Colors.white.withValues(alpha: 0.75), fontSize: 13)),
            const SizedBox(height: 16),
            TextButton(
              onPressed: () {},
              style: TextButton.styleFrom(
                backgroundColor: Colors.white.withValues(alpha: 0.15),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
              ),
              child: Text('Edit profile', style: GoogleFonts.plusJakartaSans(
                color: Colors.white, fontSize: 13, fontWeight: FontWeight.w600,
              )),
            ),
          ]),
        ),

        // Stats strip
        Container(
          margin: const EdgeInsets.fromLTRB(20, 0, 20, 0),
          transform: Matrix4.translationValues(0, -24, 0),
          decoration: BoxDecoration(
            color: isDark ? AppColors.surfaceDark : Colors.white,
            borderRadius: BorderRadius.circular(20),
            boxShadow: AppShadows.card,
          ),
          padding: const EdgeInsets.symmetric(vertical: 18),
          child: Row(children: [
            _ProfileStat(value: '7', label: 'Streak 🔥'),
            Container(width: 1, height: 32, color: AppColors.borderLight),
            _ProfileStat(value: '2,450', label: 'Total XP'),
            Container(width: 1, height: 32, color: AppColors.borderLight),
            _ProfileStat(value: '14', label: 'Friends'),
          ]),
        ),

        Padding(
          padding: const EdgeInsets.fromLTRB(20, 0, 20, 110),
          child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            _SettingsGroup(label: 'ACCOUNT', items: [
              _SettingsItem(icon: Iconsax.user_edit, label: 'Edit Profile', onTap: () {}),
              _SettingsItem(icon: Iconsax.notification, label: 'Notifications', onTap: () {}),
              _SettingsItem(icon: Iconsax.translate, label: 'Target language', onTap: () {}),
            ]),
            const SizedBox(height: 16),
            _SettingsGroup(label: 'APP', items: [
              _SettingsItem(icon: Iconsax.moon, label: 'Appearance', onTap: () {}),
              _SettingsItem(icon: Iconsax.clock, label: 'Daily reminder', onTap: () {}),
            ]),
            const SizedBox(height: 16),
            _SettingsGroup(label: 'SUPPORT', items: [
              _SettingsItem(icon: Iconsax.message_question, label: 'Help center', onTap: () {}),
              _SettingsItem(icon: Iconsax.star, label: 'Rate the app', onTap: () {}),
            ]),
            const SizedBox(height: 24),
            Center(child: TextButton.icon(
              onPressed: () async {
                await FirebaseAuth.instance.signOut();
              },
              icon: Icon(Iconsax.logout, size: 18, color: AppColors.neutralMid),
              label: Text('Sign out', style: GoogleFonts.plusJakartaSans(
                color: AppColors.neutralMid, fontSize: 15, fontWeight: FontWeight.w500,
              )),
            )),
          ]),
        ),
      ]),
    ));
  }
}

class _ProfileStat extends StatelessWidget {
  final String value, label;
  const _ProfileStat({required this.value, required this.label});
  @override
  Widget build(BuildContext context) {
    return Expanded(child: Column(children: [
      Text(value, style: GoogleFonts.plusJakartaSans(fontSize: 20, fontWeight: FontWeight.w800,
          color: AppColors.primary)),
      const SizedBox(height: 4),
      Text(label, style: AppTextStyles.label()),
    ]));
  }
}

class _SettingsGroup extends StatelessWidget {
  final String label;
  final List<Widget> items;
  const _SettingsGroup({required this.label, required this.items});
  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      Padding(padding: const EdgeInsets.only(bottom: 8, left: 2),
        child: Text(label, style: AppTextStyles.label())),
      Container(
        decoration: BoxDecoration(
          color: isDark ? AppColors.surfaceDark : Colors.white,
          borderRadius: BorderRadius.circular(16),
          boxShadow: isDark ? null : AppShadows.card,
          border: isDark ? Border.all(color: AppColors.borderDark) : null,
        ),
        child: Column(children: items.asMap().entries.map((e) => Column(children: [
          e.value,
          if (e.key < items.length - 1) const Divider(height: 1, indent: 54),
        ])).toList()),
      ),
    ]);
  }
}

class _SettingsItem extends StatelessWidget {
  final IconData icon;
  final String label;
  final VoidCallback onTap;
  const _SettingsItem({required this.icon, required this.label, required this.onTap});
  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: SizedBox(height: 52, child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 18),
        child: Row(children: [
          Container(width: 32, height: 32, decoration: BoxDecoration(color: AppColors.primaryMid, borderRadius: BorderRadius.circular(8)),
            child: Icon(icon, size: 16, color: AppColors.primary)),
          const SizedBox(width: 14),
          Expanded(child: Text(label, style: AppTextStyles.body())),
          const Icon(Iconsax.arrow_right_3, size: 16, color: AppColors.neutralMid),
        ]),
      )),
    );
  }
}
