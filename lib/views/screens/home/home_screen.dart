import 'package:flutter/material.dart';
import 'package:iconsax/iconsax.dart';
import 'package:language_learning_app/config/theme.dart';
import 'package:language_learning_app/views/widgets/app_button.dart';
import 'package:language_learning_app/views/widgets/app_card.dart';
import 'package:language_learning_app/views/widgets/section_header.dart';
import 'package:language_learning_app/views/widgets/stat_chip.dart';
import 'package:language_learning_app/views/widgets/bottom_nav_bar.dart';
import 'package:language_learning_app/views/screens/home/dashboard_screen.dart';

class HomeScreen extends StatefulWidget {
  final String userId;
  const HomeScreen({super.key, required this.userId});
  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _selectedIndex = 0;

  Widget _buildBody() {
    switch (_selectedIndex) {
      case 0: return _DashboardTab(userId: widget.userId);
      case 1: return _LessonsTab();
      case 2: return _PracticeTab();
      case 3: return _SocialTab();
      case 4: return _ProfileTab();
      default: return const SizedBox.shrink();
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Scaffold(
      backgroundColor: isDark ? AppColors.bgDark : AppColors.surfaceLight,
      body: _buildBody(),
      extendBody: true,
      bottomNavigationBar: BottomNavBar(
        selectedIndex: _selectedIndex,
        onTap: (i) => setState(() => _selectedIndex = i),
      ),
    );
  }
}

// ── Dashboard Tab ────────────────────────────────────────────────────────────

class _DashboardTab extends StatelessWidget {
  final String userId;
  const _DashboardTab({required this.userId});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return CustomScrollView(
      slivers: [
        SliverToBoxAdapter(
          child: SafeArea(
            bottom: false,
            child: Padding(
              padding: const EdgeInsets.fromLTRB(
                  AppSpacing.screenH, AppSpacing.screenTop,
                  AppSpacing.screenH, 0),
              child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [

                // ── Top row ───────────────────────────────────────
                Row(children: [
                  CircleAvatar(
                    radius: 20,
                    backgroundColor: AppColors.primaryMid,
                    child: Text('J', style: AppTextStyles.bodySemiBold(color: AppColors.primary)),
                  ),
                  const SizedBox(width: AppSpacing.inlineGap),
                  Expanded(
                    child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                      Text('Good morning 👋', style: AppTextStyles.caption()),
                      Text('John Doe', style: AppTextStyles.sectionHeading()),
                    ]),
                  ),
                  Stack(children: [
                    Icon(Iconsax.notification, size: 24, color: isDark ? AppColors.textPrimaryDark : AppColors.neutralDark),
                    Positioned(top: 0, right: 0,
                      child: Container(width: 8, height: 8,
                        decoration: const BoxDecoration(color: AppColors.primary, shape: BoxShape.circle))),
                  ]),
                ]),

                const SizedBox(height: 20),

                // ── Streak + XP row ───────────────────────────────
                AppCard(
                  padding: const EdgeInsets.symmetric(horizontal: AppSpacing.cardH, vertical: 14),
                  child: Row(children: [
                    Icon(Iconsax.flash_1, size: 20, color: AppColors.amber),
                    const SizedBox(width: 6),
                    Text('7', style: AppTextStyles.bodySemiBold(color: AppColors.amber)),
                    Text(' day streak', style: AppTextStyles.caption()),
                    Container(width: 1, height: 20, color: AppColors.borderLight, margin: const EdgeInsets.symmetric(horizontal: 16)),
                    Icon(Iconsax.flash_circle, size: 20, color: AppColors.primary),
                    const SizedBox(width: 6),
                    Text('2,450', style: AppTextStyles.bodySemiBold(color: AppColors.primary)),
                    Text(' XP', style: AppTextStyles.caption()),
                  ]),
                ),

                const SizedBox(height: AppSpacing.sectionGap),

                // ── Continue learning ─────────────────────────────
                SectionHeader(title: 'Continue learning', onSeeAll: () {}),
                const SizedBox(height: AppSpacing.itemGap),
                AppCard(
                  child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                    Row(children: [
                      Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                        Text('Beginner Spanish', style: AppTextStyles.bodySemiBold()),
                        const SizedBox(height: 4),
                        Text('Unit 1 · Greetings & Numbers', style: AppTextStyles.caption()),
                      ])),
                      AppChip(label: '60%', variant: AppChipVariant.blue),
                    ]),
                    const SizedBox(height: 14),
                    ClipRRect(
                      borderRadius: BorderRadius.circular(99),
                      child: LinearProgressIndicator(
                        value: 0.6,
                        minHeight: 6,
                        backgroundColor: AppColors.neutralLight,
                        valueColor: const AlwaysStoppedAnimation(AppColors.primary),
                      ),
                    ),
                    const SizedBox(height: 14),
                    Align(
                      alignment: Alignment.centerRight,
                      child: AppButton(
                        label: 'Continue',
                        onPressed: () {},
                        fullWidth: false,
                        height: 38,
                      ),
                    ),
                  ]),
                ),

                const SizedBox(height: AppSpacing.sectionGap),

                // ── Due for review ────────────────────────────────
                SectionHeader(title: 'Due for review', onSeeAll: () {}),
                const SizedBox(height: AppSpacing.itemGap),
                AppCard(
                  child: Row(children: [
                    Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                      Text('Spanish Vocabulary', style: AppTextStyles.bodySemiBold()),
                      const SizedBox(height: 4),
                      Row(children: [
                        AppChip(label: '12 cards', variant: AppChipVariant.amber),
                        const SizedBox(width: 8),
                        Text('~8 min', style: AppTextStyles.caption()),
                      ]),
                    ])),
                    AppButton(label: 'Study', onPressed: () {}, fullWidth: false, height: 38),
                  ]),
                ),

                const SizedBox(height: AppSpacing.sectionGap),

                // ── Daily challenge ───────────────────────────────
                SectionHeader(title: 'Daily challenge', onSeeAll: null),
                const SizedBox(height: AppSpacing.itemGap),
                Container(
                  decoration: BoxDecoration(
                    color: isDark ? AppColors.surfaceDark : AppColors.bgLight,
                    borderRadius: BorderRadius.circular(AppRadius.card),
                    boxShadow: isDark ? null : AppShadows.card,
                    border: isDark ? Border.all(color: AppColors.borderDark) : null,
                  ),
                  child: Row(children: [
                    Container(
                      width: 4,
                      height: 80,
                      decoration: BoxDecoration(
                        color: AppColors.amber,
                        borderRadius: const BorderRadius.horizontal(left: Radius.circular(AppRadius.card)),
                      ),
                    ),
                    Expanded(
                      child: Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                        child: Row(children: [
                          Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                            Text('Translate 10 sentences', style: AppTextStyles.bodySemiBold()),
                            const SizedBox(height: 4),
                            Row(children: [
                              AppChip(label: '+50 XP', variant: AppChipVariant.amber),
                              const SizedBox(width: 8),
                              Text('3h left', style: AppTextStyles.caption()),
                            ]),
                          ])),
                          AppButton(label: 'Start', onPressed: () {}, variant: AppButtonVariant.secondary, fullWidth: false, height: 38),
                        ]),
                      ),
                    ),
                  ]),
                ),

                const SizedBox(height: AppSpacing.sectionGap),

                // ── Quick stats ───────────────────────────────────
                SectionHeader(title: 'Quick stats', onSeeAll: () {}),
                const SizedBox(height: AppSpacing.itemGap),
                GridView.count(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  crossAxisCount: 2,
                  mainAxisSpacing: AppSpacing.itemGap,
                  crossAxisSpacing: AppSpacing.itemGap,
                  childAspectRatio: 1.6,
                  children: const [
                    StatCard(value: '350', label: 'TOTAL CARDS'),
                    StatCard(value: '5', label: 'CURRENT LEVEL'),
                    StatCard(value: '7', label: 'DAY STREAK', valueColor: AppColors.amber),
                    StatCard(value: '12', label: 'LESSONS DONE'),
                  ],
                ),

                // Bottom padding for floating nav
                const SizedBox(height: 100),
              ]),
            ),
          ),
        ),
      ],
    );
  }
}

// ── Lessons Tab ──────────────────────────────────────────────────────────────

class _LessonsTab extends StatefulWidget {
  @override
  State<_LessonsTab> createState() => _LessonsTabState();
}

class _LessonsTabState extends State<_LessonsTab> {
  int _selectedLevel = 0;
  final _levels = ['All', 'Beginner', 'Intermediate', 'Advanced'];

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      bottom: false,
      child: CustomScrollView(
        slivers: [
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(AppSpacing.screenH, AppSpacing.screenTop, AppSpacing.screenH, 0),
              child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                Text('Lessons', style: AppTextStyles.screenTitle()),
                const SizedBox(height: 16),
                SizedBox(
                  height: 36,
                  child: ListView.separated(
                    scrollDirection: Axis.horizontal,
                    itemCount: _levels.length,
                    separatorBuilder: (_, __) => const SizedBox(width: 8),
                    itemBuilder: (_, i) {
                      final active = i == _selectedLevel;
                      return GestureDetector(
                        onTap: () => setState(() => _selectedLevel = i),
                        child: Container(
                          padding: const EdgeInsets.symmetric(horizontal: 16),
                          decoration: BoxDecoration(
                            color: active ? AppColors.primary : Colors.transparent,
                            borderRadius: BorderRadius.circular(AppRadius.chip),
                            border: Border.all(color: active ? AppColors.primary : AppColors.neutralMid.withValues(alpha: 0.4)),
                          ),
                          alignment: Alignment.center,
                          child: Text(_levels[i], style: AppTextStyles.label(color: active ? Colors.white : AppColors.neutralMid)),
                        ),
                      );
                    },
                  ),
                ),
                const SizedBox(height: 20),
              ]),
            ),
          ),
          SliverPadding(
            padding: const EdgeInsets.fromLTRB(AppSpacing.screenH, 0, AppSpacing.screenH, 100),
            sliver: SliverList(
              delegate: SliverChildBuilderDelegate(
                (ctx, i) => Padding(
                  padding: const EdgeInsets.only(bottom: AppSpacing.itemGap),
                  child: _LessonCard(
                    number: i + 1,
                    title: ['Greetings & Numbers', 'Colors & Shapes', 'Food & Drinks', 'Family & Friends', 'Travel Phrases'][i % 5],
                    subtitle: 'Vocabulary · 20 cards',
                    progress: [1.0, 0.6, 0.3, 0.0, 0.0][i % 5],
                    isDone: i == 0,
                    isLocked: i > 2,
                  ),
                ),
                childCount: 8,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _LessonCard extends StatelessWidget {
  final int number;
  final String title;
  final String subtitle;
  final double progress;
  final bool isDone;
  final bool isLocked;

  const _LessonCard({required this.number, required this.title, required this.subtitle,
    required this.progress, required this.isDone, required this.isLocked});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return AppCard(
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Row(children: [
          Container(
            width: 36, height: 36,
            decoration: BoxDecoration(
              color: isDone ? AppColors.primary : isLocked ? AppColors.neutralLight : AppColors.primaryMid,
              borderRadius: BorderRadius.circular(AppRadius.iconBox),
            ),
            alignment: Alignment.center,
            child: Text('$number', style: AppTextStyles.bodySemiBold(color: isDone ? Colors.white : isLocked ? AppColors.neutralMid : AppColors.primary).copyWith(fontSize: 14)),
          ),
          const SizedBox(width: AppSpacing.inlineGap),
          Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Text(title, style: AppTextStyles.bodySemiBold()),
            Text(subtitle, style: AppTextStyles.caption()),
          ])),
          Icon(
            isDone ? Iconsax.tick_circle5 : isLocked ? Iconsax.lock : Iconsax.arrow_right_3,
            size: 20,
            color: isDone ? AppColors.primary : AppColors.neutralMid,
          ),
        ]),
        if (progress > 0 && progress < 1) ...[
          const SizedBox(height: 12),
          ClipRRect(
            borderRadius: BorderRadius.circular(99),
            child: LinearProgressIndicator(
              value: progress, minHeight: 4,
              backgroundColor: AppColors.neutralLight,
              valueColor: const AlwaysStoppedAnimation(AppColors.primary),
            ),
          ),
        ],
      ]),
    );
  }
}

// ── Practice Tab ─────────────────────────────────────────────────────────────

class _PracticeTab extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return SafeArea(
      bottom: false,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: AppSpacing.screenH),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          const SizedBox(height: AppSpacing.screenTop),
          Text('Practice', style: AppTextStyles.screenTitle()),
          const SizedBox(height: AppSpacing.sectionGap),
          Expanded(
            child: Center(
              child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
                Container(
                  width: 80, height: 80,
                  decoration: BoxDecoration(color: AppColors.primaryMid, shape: BoxShape.circle),
                  child: const Icon(Iconsax.cards, size: 36, color: AppColors.primary),
                ),
                const SizedBox(height: 20),
                Text('Flashcard Practice', style: AppTextStyles.sectionHeading()),
                const SizedBox(height: 8),
                Text('Start a study session with your due cards', style: AppTextStyles.caption(), textAlign: TextAlign.center),
                const SizedBox(height: 24),
                AppButton(label: 'Start practice session', onPressed: () {}),
              ]),
            ),
          ),
          const SizedBox(height: 100),
        ]),
      ),
    );
  }
}

// ── Social Tab ───────────────────────────────────────────────────────────────

class _SocialTab extends StatefulWidget {
  @override
  State<_SocialTab> createState() => _SocialTabState();
}

class _SocialTabState extends State<_SocialTab> {
  int _tabIndex = 0;

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      bottom: false,
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(AppSpacing.screenH, AppSpacing.screenTop, AppSpacing.screenH, 0),
          child: Row(children: [
            Expanded(child: Text('Leaderboard', style: AppTextStyles.screenTitle())),
            AppButton(label: '+ Add friend', onPressed: () {}, variant: AppButtonVariant.secondary, fullWidth: false, height: 36),
          ]),
        ),
        const SizedBox(height: 16),

        // Tab row
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: AppSpacing.screenH),
          child: Row(children: ['Weekly', 'Monthly', 'All-time'].asMap().entries.map((e) {
            final active = e.key == _tabIndex;
            return GestureDetector(
              onTap: () => setState(() => _tabIndex = e.key),
              child: Container(
                padding: const EdgeInsets.only(bottom: 8, right: 20),
                decoration: BoxDecoration(
                  border: Border(bottom: BorderSide(
                    color: active ? AppColors.primary : Colors.transparent, width: 2,
                  )),
                ),
                child: Text(e.value, style: active
                    ? AppTextStyles.bodySemiBold(color: AppColors.primary)
                    : AppTextStyles.body(color: AppColors.neutralMid)),
              ),
            );
          }).toList()),
        ),
        const Divider(height: 1),

        // Podium
        Padding(
          padding: const EdgeInsets.symmetric(vertical: 24, horizontal: AppSpacing.screenH),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              _PodiumItem(rank: 2, name: 'Maria', xp: '2,100', avatarSize: 48, height: 80),
              _PodiumItem(rank: 1, name: 'You', xp: '2,450', avatarSize: 56, height: 110, isYou: true),
              _PodiumItem(rank: 3, name: 'Carlos', xp: '1,980', avatarSize: 44, height: 60),
            ],
          ),
        ),

        // List
        Expanded(
          child: ListView.separated(
            padding: const EdgeInsets.fromLTRB(AppSpacing.screenH, 0, AppSpacing.screenH, 100),
            itemCount: 7,
            separatorBuilder: (_, __) => const Divider(height: 1),
            itemBuilder: (_, i) => _LeaderboardRow(rank: i + 4, name: 'Player ${i + 4}', xp: '${1800 - i * 120}', isYou: false),
          ),
        ),
      ]),
    );
  }
}

class _PodiumItem extends StatelessWidget {
  final int rank;
  final String name, xp;
  final double avatarSize, height;
  final bool isYou;
  const _PodiumItem({required this.rank, required this.name, required this.xp,
    required this.avatarSize, required this.height, this.isYou = false});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 80,
      child: Column(children: [
        if (rank == 1) const Icon(Iconsax.crown_1, color: AppColors.amber, size: 22),
        const SizedBox(height: 4),
        Stack(clipBehavior: Clip.none, alignment: Alignment.bottomRight, children: [
          CircleAvatar(radius: avatarSize / 2,
            backgroundColor: isYou ? AppColors.primary : AppColors.primaryMid,
            child: Text(name[0], style: AppTextStyles.bodySemiBold(color: isYou ? Colors.white : AppColors.primary).copyWith(fontSize: avatarSize * 0.4)),
          ),
          Positioned(bottom: -2, right: -2,
            child: Container(
              width: 18, height: 18,
              decoration: const BoxDecoration(color: AppColors.primary, shape: BoxShape.circle),
              child: Center(child: Text('$rank', style: const TextStyle(color: Colors.white, fontSize: 10, fontWeight: FontWeight.w700))),
            ),
          ),
        ]),
        const SizedBox(height: 8),
        Text(name, style: AppTextStyles.caption(color: AppColors.neutralDark).copyWith(fontWeight: FontWeight.w600), textAlign: TextAlign.center),
        Text('$xp XP', style: AppTextStyles.caption(), textAlign: TextAlign.center),
      ]),
    );
  }
}

class _LeaderboardRow extends StatelessWidget {
  final int rank;
  final String name, xp;
  final bool isYou;
  const _LeaderboardRow({required this.rank, required this.name, required this.xp, required this.isYou});

  @override
  Widget build(BuildContext context) {
    return Container(
      color: isYou ? AppColors.primaryMid : Colors.transparent,
      padding: const EdgeInsets.symmetric(vertical: 12),
      child: Row(children: [
        if (isYou) Container(width: 3, height: 40, color: AppColors.primary, margin: const EdgeInsets.only(right: 13))
        else const SizedBox(width: 16),
        SizedBox(width: 28, child: Text('$rank', style: AppTextStyles.bodySemiBold(color: AppColors.neutralMid).copyWith(fontSize: 14))),
        CircleAvatar(radius: 18, backgroundColor: AppColors.primaryMid,
          child: Text(name[0], style: AppTextStyles.caption(color: AppColors.primary).copyWith(fontWeight: FontWeight.w700))),
        const SizedBox(width: 12),
        Expanded(child: Text(name, style: AppTextStyles.bodySemiBold(color: isYou ? AppColors.primary : null))),
        Icon(Iconsax.flash_circle, size: 14, color: AppColors.amber),
        const SizedBox(width: 4),
        Text('$xp XP', style: AppTextStyles.label(color: AppColors.amberText).copyWith(fontSize: 13)),
        const SizedBox(width: 16),
      ]),
    );
  }
}

// ── Profile Tab ──────────────────────────────────────────────────────────────

class _ProfileTab extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return SafeArea(
      bottom: false,
      child: SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(AppSpacing.screenH, AppSpacing.screenTop, AppSpacing.screenH, 100),
        child: Column(crossAxisAlignment: CrossAxisAlignment.center, children: [

          // Avatar
          CircleAvatar(
            radius: 40,
            backgroundColor: AppColors.primaryMid,
            child: Text('J', style: AppTextStyles.display(color: AppColors.primary).copyWith(fontSize: 32)),
          ),
          const SizedBox(height: 12),
          Text('John Doe', style: AppTextStyles.screenTitle()),
          Text('@john.doe', style: AppTextStyles.caption()),
          TextButton(
            onPressed: () {},
            child: Text('Edit profile', style: AppTextStyles.caption(color: AppColors.primary).copyWith(fontWeight: FontWeight.w600)),
          ),

          const SizedBox(height: 20),

          // Stats strip
          AppCard(
            padding: const EdgeInsets.symmetric(vertical: 16),
            child: Row(children: [
              _StatStrip(value: '7', label: 'Streak'),
              _vDivider(),
              _StatStrip(value: '2,450', label: 'Total XP'),
              _vDivider(),
              _StatStrip(value: '14', label: 'Friends'),
            ]),
          ),

          const SizedBox(height: AppSpacing.sectionGap),

          // Settings groups
          _SettingsGroup(label: 'ACCOUNT', items: [
            _SettingsRow(icon: Iconsax.user_edit, label: 'Edit Profile'),
            _SettingsRow(icon: Iconsax.notification, label: 'Notifications'),
            _SettingsRow(icon: Iconsax.translate, label: 'Target language'),
          ]),

          const SizedBox(height: AppSpacing.itemGap),

          _SettingsGroup(label: 'APP', items: [
            _SettingsRow(icon: Iconsax.moon, label: 'Appearance', trailing: _AppearanceToggle()),
            _SettingsRow(icon: Iconsax.clock, label: 'Daily reminder'),
            _SettingsRow(icon: Iconsax.wifi, label: 'Offline mode', trailing: Switch(
              value: false, onChanged: (_) {},
              activeColor: AppColors.primary,
            )),
          ]),

          const SizedBox(height: AppSpacing.itemGap),

          _SettingsGroup(label: 'SUPPORT', items: [
            _SettingsRow(icon: Iconsax.message_question, label: 'Help center'),
            _SettingsRow(icon: Iconsax.star, label: 'Rate the app'),
            _SettingsRow(icon: Iconsax.shield_tick, label: 'Privacy policy'),
          ]),

          const SizedBox(height: 28),

          TextButton(
            onPressed: () {},
            child: Text('Sign out', style: AppTextStyles.body(color: AppColors.neutralMid)),
          ),
        ]),
      ),
    );
  }

  Widget _vDivider() => Container(width: 1, height: 36, color: AppColors.borderLight);
}

class _StatStrip extends StatelessWidget {
  final String value, label;
  const _StatStrip({required this.value, required this.label});
  @override
  Widget build(BuildContext context) {
    return Expanded(child: Column(children: [
      Text(value, style: AppTextStyles.sectionHeading().copyWith(fontSize: 20, fontWeight: FontWeight.w700)),
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
      Padding(
        padding: const EdgeInsets.only(bottom: 8, left: 4),
        child: Text(label, style: AppTextStyles.label()),
      ),
      Container(
        decoration: BoxDecoration(
          color: isDark ? AppColors.surfaceDark : AppColors.bgLight,
          borderRadius: BorderRadius.circular(AppRadius.card),
          boxShadow: isDark ? null : AppShadows.card,
          border: isDark ? Border.all(color: AppColors.borderDark, width: 1) : null,
        ),
        child: Column(
          children: items.asMap().entries.map((e) => Column(
            children: [
              e.value,
              if (e.key < items.length - 1)
                const Divider(height: 1, indent: 52),
            ],
          )).toList(),
        ),
      ),
    ]);
  }
}

class _SettingsRow extends StatelessWidget {
  final IconData icon;
  final String label;
  final Widget? trailing;
  const _SettingsRow({required this.icon, required this.label, this.trailing});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 52,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: AppSpacing.cardH),
        child: Row(children: [
          Icon(icon, size: 20, color: AppColors.primary),
          const SizedBox(width: AppSpacing.inlineGap),
          Expanded(child: Text(label, style: AppTextStyles.body())),
          trailing ?? Icon(Iconsax.arrow_right_3, size: 16, color: AppColors.neutralMid),
        ]),
      ),
    );
  }
}

class _AppearanceToggle extends StatefulWidget {
  @override
  State<_AppearanceToggle> createState() => _AppearanceToggleState();
}
class _AppearanceToggleState extends State<_AppearanceToggle> {
  int _mode = 0; // 0=system 1=light 2=dark
  @override
  Widget build(BuildContext context) {
    return Row(mainAxisSize: MainAxisSize.min, children: [
      Icon(Iconsax.sun_1,  size: 18, color: _mode == 1 ? AppColors.primary : AppColors.neutralMid),
      const SizedBox(width: 4),
      Icon(Iconsax.moon,   size: 18, color: _mode == 2 ? AppColors.primary : AppColors.neutralMid),
    ]);
  }
}
