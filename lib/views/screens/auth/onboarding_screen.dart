import 'package:flutter/material.dart';
import 'package:iconsax/iconsax.dart';
import 'package:language_learning_app/config/theme.dart';
import 'package:language_learning_app/views/widgets/app_button.dart';

class OnboardingScreen extends StatefulWidget {
  final VoidCallback? onComplete;
  const OnboardingScreen({super.key, this.onComplete});
  @override
  State<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen> with TickerProviderStateMixin {
  final PageController _pageCtrl = PageController();
  int _page = 0;
  String? _selectedLanguage;
  int? _selectedGoal;
  int? _selectedLevel;

  // Blob painter colors per page
  static const _blobColors = [
    Color(0xFFEBF2FD), Color(0xFFF0F7FF), Color(0xFFE8F3FA), Color(0xFFEBF2FD),
  ];

  void _next() {
    if (_page < 3) {
      _pageCtrl.nextPage(duration: const Duration(milliseconds: 350), curve: Curves.easeOutCubic);
    } else {
      widget.onComplete?.call();
    }
  }

  @override
  void dispose() { _pageCtrl.dispose(); super.dispose(); }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.bgLight,
      body: Stack(
        children: [
          // Blob background
          AnimatedSwitcher(
            duration: const Duration(milliseconds: 400),
            child: CustomPaint(
              key: ValueKey(_page),
              painter: _BlobPainter(color: _blobColors[_page]),
              size: Size(MediaQuery.of(context).size.width, MediaQuery.of(context).size.height * 0.42),
            ),
          ),

          SafeArea(
            child: Column(children: [
              // Skip
              Align(
                alignment: Alignment.topRight,
                child: Padding(
                  padding: const EdgeInsets.only(right: AppSpacing.screenH, top: 8),
                  child: TextButton(
                    onPressed: widget.onComplete,
                    child: Text('Skip', style: AppTextStyles.caption(color: AppColors.neutralMid)),
                  ),
                ),
              ),

              // PageView
              Expanded(
                child: PageView(
                  controller: _pageCtrl,
                  onPageChanged: (i) => setState(() => _page = i),
                  children: [
                    _LanguagePage(selected: _selectedLanguage, onSelect: (l) => setState(() => _selectedLanguage = l)),
                    _GoalPage(selected: _selectedGoal, onSelect: (g) => setState(() => _selectedGoal = g)),
                    _LevelPage(selected: _selectedLevel, onSelect: (l) => setState(() => _selectedLevel = l)),
                    _SummaryPage(language: _selectedLanguage, goal: _selectedGoal, level: _selectedLevel),
                  ],
                ),
              ),

              // Dots + button
              Padding(
                padding: const EdgeInsets.fromLTRB(AppSpacing.screenH, 0, AppSpacing.screenH, 24),
                child: Column(children: [
                  Row(mainAxisAlignment: MainAxisAlignment.center, children: List.generate(4, (i) {
                    final active = i == _page;
                    return AnimatedContainer(
                      duration: const Duration(milliseconds: 300),
                      margin: const EdgeInsets.symmetric(horizontal: 4),
                      width: active ? 24 : 8,
                      height: 8,
                      decoration: BoxDecoration(
                        color: active ? AppColors.primary : AppColors.neutralLight,
                        borderRadius: BorderRadius.circular(AppRadius.chip),
                      ),
                    );
                  })),
                  const SizedBox(height: 20),
                  AppButton(
                    label: _page == 3 ? 'Start learning' : 'Continue',
                    onPressed: _next,
                    trailingIcon: _page < 3 ? Iconsax.arrow_right_3 : null,
                  ),
                ]),
              ),
            ]),
          ),
        ],
      ),
    );
  }
}

// ── Pages ────────────────────────────────────────────────────────────────────

class _LanguagePage extends StatelessWidget {
  final String? selected;
  final ValueChanged<String> onSelect;
  const _LanguagePage({this.selected, required this.onSelect});

  static const _langs = [
    ('🇪🇸', 'Spanish'), ('🇫🇷', 'French'), ('🇩🇪', 'German'), ('🇯🇵', 'Japanese'),
    ('🇰🇷', 'Korean'), ('🇮🇹', 'Italian'),
  ];

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: AppSpacing.screenH),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        const SizedBox(height: 16),
        Text('Choose your\nlanguage', style: AppTextStyles.display().copyWith(fontSize: 24, fontWeight: FontWeight.w800), textAlign: TextAlign.left),
        const SizedBox(height: 8),
        Text('Pick the language you want to learn today', style: AppTextStyles.caption()),
        const SizedBox(height: 24),
        Expanded(
          child: GridView.builder(
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2, mainAxisSpacing: 12, crossAxisSpacing: 12, childAspectRatio: 2.2,
            ),
            itemCount: _langs.length,
            itemBuilder: (_, i) {
              final lang = _langs[i];
              final active = selected == lang.$2;
              return GestureDetector(
                onTap: () => onSelect(lang.$2),
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 200),
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  decoration: BoxDecoration(
                    color: active ? AppColors.primaryMid : AppColors.surfaceLight,
                    borderRadius: BorderRadius.circular(AppRadius.card),
                    border: Border.all(color: active ? AppColors.primary : AppColors.borderLight, width: active ? 2 : 1),
                    boxShadow: active ? null : AppShadows.card,
                  ),
                  child: Row(children: [
                    Text(lang.$1, style: const TextStyle(fontSize: 24)),
                    const SizedBox(width: 10),
                    Text(lang.$2, style: AppTextStyles.bodySemiBold(color: active ? AppColors.primary : null)),
                  ]),
                ),
              );
            },
          ),
        ),
      ]),
    );
  }
}

class _GoalPage extends StatelessWidget {
  final int? selected;
  final ValueChanged<int> onSelect;
  const _GoalPage({this.selected, required this.onSelect});

  static const _goals = [
    (5, 'Casual', Iconsax.cup),
    (10, 'Regular', Iconsax.medal),
    (15, 'Serious', Iconsax.award),
    (20, 'Intense', Iconsax.flash_1),
  ];

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: AppSpacing.screenH),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        const SizedBox(height: 16),
        Text('Set your\ndaily goal', style: AppTextStyles.display().copyWith(fontSize: 24, fontWeight: FontWeight.w800)),
        const SizedBox(height: 8),
        Text('How much time can you dedicate each day?', style: AppTextStyles.caption()),
        const SizedBox(height: 24),
        ...List.generate(_goals.length, (i) {
          final g = _goals[i];
          final active = selected == g.$1;
          return Padding(
            padding: const EdgeInsets.only(bottom: 12),
            child: GestureDetector(
              onTap: () => onSelect(g.$1),
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: active ? AppColors.primaryMid : AppColors.bgLight,
                  borderRadius: BorderRadius.circular(AppRadius.card),
                  border: Border.all(color: active ? AppColors.primary : AppColors.borderLight, width: active ? 2 : 1),
                  boxShadow: active ? null : AppShadows.card,
                ),
                child: Row(children: [
                  Container(
                    width: 40, height: 40,
                    decoration: BoxDecoration(
                      color: active ? AppColors.primary : AppColors.neutralLight,
                      borderRadius: BorderRadius.circular(AppRadius.iconBox),
                    ),
                    child: Icon(g.$3, size: 20, color: active ? Colors.white : AppColors.neutralMid),
                  ),
                  const SizedBox(width: 14),
                  Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                    Text('${g.$1} min / day', style: AppTextStyles.bodySemiBold(color: active ? AppColors.primary : null)),
                    Text(g.$2, style: AppTextStyles.caption()),
                  ])),
                  if (active) const Icon(Iconsax.tick_circle5, color: AppColors.primary, size: 20),
                ]),
              ),
            ),
          );
        }),
      ]),
    );
  }
}

class _LevelPage extends StatelessWidget {
  final int? selected;
  final ValueChanged<int> onSelect;
  const _LevelPage({this.selected, required this.onSelect});

  static const _levels = [
    ('Beginner', "I'm just starting out", Iconsax.star),
    ('Intermediate', 'I know some basics', Iconsax.star_1),
    ('Advanced', 'I can hold conversations', Iconsax.flash_1),
  ];

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: AppSpacing.screenH),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        const SizedBox(height: 16),
        Text("What's your\nlevel?", style: AppTextStyles.display().copyWith(fontSize: 24, fontWeight: FontWeight.w800)),
        const SizedBox(height: 8),
        Text("We'll personalize your learning path", style: AppTextStyles.caption()),
        const SizedBox(height: 24),
        ...List.generate(_levels.length, (i) {
          final l = _levels[i];
          final active = selected == i;
          return Padding(
            padding: const EdgeInsets.only(bottom: 12),
            child: GestureDetector(
              onTap: () => onSelect(i),
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: active ? AppColors.primaryMid : AppColors.bgLight,
                  borderRadius: BorderRadius.circular(AppRadius.card),
                  border: Border.all(color: active ? AppColors.primary : AppColors.borderLight, width: active ? 2 : 1),
                  boxShadow: active ? null : AppShadows.card,
                ),
                child: Row(children: [
                  Icon(l.$3, size: 24, color: active ? AppColors.primary : AppColors.neutralMid),
                  const SizedBox(width: 14),
                  Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                    Text(l.$1, style: AppTextStyles.bodySemiBold(color: active ? AppColors.primary : null)),
                    Text(l.$2, style: AppTextStyles.caption()),
                  ])),
                  if (active) const Icon(Iconsax.tick_circle5, color: AppColors.primary, size: 20),
                ]),
              ),
            ),
          );
        }),
      ]),
    );
  }
}

class _SummaryPage extends StatelessWidget {
  final String? language;
  final int? goal;
  final int? level;
  const _SummaryPage({this.language, this.goal, this.level});

  static const _levelLabels = ['Beginner', 'Intermediate', 'Advanced'];

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: AppSpacing.screenH),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        const SizedBox(height: 16),
        Text("You're all set! 🎉", style: AppTextStyles.display().copyWith(fontSize: 24, fontWeight: FontWeight.w800)),
        const SizedBox(height: 8),
        Text("Here's your personalized learning plan", style: AppTextStyles.caption()),
        const SizedBox(height: 32),
        _SummaryRow(icon: Iconsax.translate, label: 'Language', value: language ?? 'Not selected'),
        _SummaryRow(icon: Iconsax.timer_1, label: 'Daily goal', value: goal != null ? '$goal min / day' : 'Not selected'),
        _SummaryRow(icon: Iconsax.medal, label: 'Level', value: level != null ? _levelLabels[level!] : 'Not selected'),
      ]),
    );
  }
}

class _SummaryRow extends StatelessWidget {
  final IconData icon;
  final String label, value;
  const _SummaryRow({required this.icon, required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Row(children: [
        Container(
          width: 44, height: 44,
          decoration: BoxDecoration(color: AppColors.primaryMid, borderRadius: BorderRadius.circular(AppRadius.iconBox)),
          child: Icon(icon, size: 20, color: AppColors.primary),
        ),
        const SizedBox(width: 14),
        Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Text(label, style: AppTextStyles.caption()),
          Text(value, style: AppTextStyles.bodySemiBold()),
        ])),
      ]),
    );
  }
}

// ── Blob CustomPainter ───────────────────────────────────────────────────────

class _BlobPainter extends CustomPainter {
  final Color color;
  const _BlobPainter({required this.color});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()..color = color;
    final path = Path();
    path.moveTo(0, 0);
    path.lineTo(size.width, 0);
    path.lineTo(size.width, size.height * 0.72);
    path.quadraticBezierTo(size.width * 0.75, size.height, size.width * 0.5, size.height * 0.85);
    path.quadraticBezierTo(size.width * 0.25, size.height * 0.7, 0, size.height * 0.9);
    path.close();
    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(_BlobPainter old) => old.color != color;
}
