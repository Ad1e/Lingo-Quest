import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:iconsax/iconsax.dart';
import 'package:language_learning_app/config/theme.dart';
import 'package:language_learning_app/domain/repositories/flashcard_repository.dart';
import 'package:language_learning_app/providers/app_providers.dart';
import 'package:language_learning_app/providers/auth_provider.dart';
import 'package:language_learning_app/views/widgets/xp_toast.dart';

class FlashcardStudyScreen extends ConsumerStatefulWidget {
  final String deckName;
  final String deckId;

  const FlashcardStudyScreen({
    super.key,
    this.deckName = 'My Deck',
    required this.deckId,
  });

  @override
  ConsumerState<FlashcardStudyScreen> createState() =>
      _FlashcardStudyScreenState();
}

class _FlashcardStudyScreenState extends ConsumerState<FlashcardStudyScreen>
    with TickerProviderStateMixin {
  int _current = 0;
  bool _flipped = false;
  bool _showHint = true;
  bool _isLoading = true;
  bool _isSaving = false;
  String? _error;
  List<Flashcard> _cards = [];
  DateTime _cardStartTime = DateTime.now();

  late AnimationController _flipCtrl;
  late Animation<double> _flipAnim;

  @override
  void initState() {
    super.initState();
    _flipCtrl = AnimationController(
        vsync: this, duration: const Duration(milliseconds: 380));
    _flipAnim = Tween<double>(begin: 0, end: 1).animate(
        CurvedAnimation(parent: _flipCtrl, curve: Curves.easeInOutCubic));
    _loadCards();
  }

  @override
  void dispose() {
    _flipCtrl.dispose();
    super.dispose();
  }

  Future<void> _loadCards() async {
    try {
      final repo = ref.read(flashcardRepositoryProvider);
      final cards = await repo.getCardsDueForReview(widget.deckId);
      if (mounted) {
        setState(() {
          _cards = cards;
          _isLoading = false;
          _cardStartTime = DateTime.now();
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _error = e.toString();
          _isLoading = false;
        });
      }
    }
  }

  void _flip() {
    setState(() => _showHint = false);
    if (_flipped) {
      _flipCtrl.reverse();
    } else {
      _flipCtrl.forward();
    }
    setState(() => _flipped = !_flipped);
  }

  /// Rating: 0=Again, 1=Hard, 2=Good, 3=Easy
  Future<void> _rate(int rating) async {
    if (_isSaving || _cards.isEmpty) return;
    setState(() => _isSaving = true);

    final card = _cards[_current];
    final durationMs =
        DateTime.now().difference(_cardStartTime).inMilliseconds;
    final user = ref.read(currentUserProvider);

    // Compute XP to show in toast — mirrors StudyFlashcardUseCase._calculateXP
    final baseXp = 10;
    final qualityBonus = [0, 5, 10, 20][rating.clamp(0, 3)];
    final timeBonus = (durationMs ~/ 60000).clamp(0, 5);
    final xpGain = baseXp + qualityBonus + timeBonus;

    try {
      final useCase = ref.read(studyFlashcardUseCaseProvider);
      await useCase(
        userId: user?.id ?? 'anonymous',
        card: card,
        rating: rating,
        duration: durationMs,
      );
    } catch (_) {
      // Silent — still advance card; SM-2 failure shouldn't block the user
    }

    if (!mounted) return;

    // Show XP toast
    showXpToast(context, xpGain);

    setState(() => _isSaving = false);

    if (_current < _cards.length - 1) {
      _flipCtrl.reset();
      setState(() {
        _current++;
        _flipped = false;
        _showHint = true;
        _cardStartTime = DateTime.now();
      });
    } else {
      Navigator.pop(context);
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final bg = isDark ? AppColors.bgDark : AppColors.surfaceLight;

    if (_isLoading) {
      return Scaffold(
        backgroundColor: bg,
        body: const Center(child: CircularProgressIndicator()),
      );
    }

    if (_error != null) {
      return Scaffold(
        backgroundColor: bg,
        body: Center(
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(Icons.error_outline, size: 48, color: Colors.red),
                const SizedBox(height: 12),
                Text('Failed to load cards:\n$_error',
                    textAlign: TextAlign.center),
                const SizedBox(height: 16),
                ElevatedButton(
                    onPressed: () {
                      setState(() {
                        _isLoading = true;
                        _error = null;
                      });
                      _loadCards();
                    },
                    child: const Text('Retry')),
              ],
            ),
          ),
        ),
      );
    }

    if (_cards.isEmpty) {
      return Scaffold(
        backgroundColor: bg,
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Iconsax.tick_circle,
                  size: 64, color: AppColors.primary),
              const SizedBox(height: 16),
              Text('All caught up!',
                  style: AppTextStyles.headline(
                      color: isDark
                          ? AppColors.textPrimaryDark
                          : AppColors.neutralDark)),
              const SizedBox(height: 8),
              Text('No cards due for review right now.',
                  style: AppTextStyles.body(color: AppColors.neutralMid)),
              const SizedBox(height: 24),
              ElevatedButton(
                  onPressed: () => Navigator.pop(context),
                  child: const Text('Go Back')),
            ],
          ),
        ),
      );
    }

    final card = _cards[_current];
    final total = _cards.length;
    final progress = (_current + 1) / total;

    return Scaffold(
      backgroundColor: bg,
      body: SafeArea(
        child: Column(children: [
          // ── Top bar ────────────────────────────────────────────
          Padding(
            padding: const EdgeInsets.symmetric(
                horizontal: AppSpacing.screenH, vertical: 12),
            child: Row(children: [
              GestureDetector(
                onTap: () => Navigator.pop(context),
                child: Container(
                  width: 40,
                  height: 40,
                  decoration: BoxDecoration(
                    color: isDark
                        ? AppColors.surfaceDark
                        : AppColors.neutralLight,
                    shape: BoxShape.circle,
                  ),
                  child: Icon(Iconsax.arrow_left_2,
                      size: 20,
                      color: isDark
                          ? AppColors.textPrimaryDark
                          : AppColors.neutralDark),
                ),
              ),
              Expanded(
                child: Column(children: [
                  ClipRRect(
                    borderRadius: BorderRadius.circular(99),
                    child: LinearProgressIndicator(
                      value: progress,
                      minHeight: 6,
                      backgroundColor: isDark
                          ? AppColors.surfaceDark
                          : AppColors.neutralLight,
                      valueColor:
                          const AlwaysStoppedAnimation(AppColors.primary),
                    ),
                  ),
                  const SizedBox(height: 6),
                  Text('${_current + 1} / $total',
                      style: AppTextStyles.caption()),
                ]),
              ),
              const SizedBox(width: 8),
              GestureDetector(
                onTap: () => Navigator.pop(context),
                child: Container(
                  width: 40,
                  height: 40,
                  decoration: BoxDecoration(
                    color: isDark
                        ? AppColors.surfaceDark
                        : AppColors.neutralLight,
                    shape: BoxShape.circle,
                  ),
                  child: Icon(Iconsax.close_circle,
                      size: 20, color: AppColors.neutralMid),
                ),
              ),
            ]),
          ),

          const SizedBox(height: 20),

          // ── Flashcard ──────────────────────────────────────────
          Expanded(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: AppSpacing.screenH),
              child: GestureDetector(
                onTap: _flip,
                child: AnimatedBuilder(
                  animation: _flipAnim,
                  builder: (_, __) {
                    final angle = _flipAnim.value * 3.14159;
                    final isFront = angle < 1.5708;
                    return Transform(
                      transform: Matrix4.identity()
                        ..setEntry(3, 2, 0.001)
                        ..rotateY(angle),
                      alignment: Alignment.center,
                      child: isFront
                          ? _CardFront(card: card, isDark: isDark)
                          : Transform(
                              transform:
                                  Matrix4.identity()..rotateY(3.14159),
                              alignment: Alignment.center,
                              child:
                                  _CardBack(card: card, isDark: isDark),
                            ),
                    );
                  },
                ),
              ),
            ),
          ),

          // Hint
          AnimatedOpacity(
            opacity: _showHint ? 1.0 : 0.0,
            duration: const Duration(milliseconds: 300),
            child: Padding(
              padding: const EdgeInsets.only(top: 12),
              child: Text('Tap card to reveal answer',
                  style: AppTextStyles.caption()),
            ),
          ),

          const SizedBox(height: 20),

          // ── Rating buttons ─────────────────────────────────────
          AnimatedOpacity(
            opacity: _flipped ? 1.0 : 0.0,
            duration: const Duration(milliseconds: 250),
            child: IgnorePointer(
              ignoring: !_flipped || _isSaving,
              child: Padding(
                padding: const EdgeInsets.symmetric(
                    horizontal: AppSpacing.screenH),
                child: Row(children: [
                  _RatingButton(
                      label: 'Again',
                      icon: Iconsax.refresh,
                      xp: 10,
                      onTap: () => _rate(0)),
                  const SizedBox(width: 8),
                  _RatingButton(
                      label: 'Hard',
                      icon: Iconsax.danger,
                      xp: 15,
                      onTap: () => _rate(1)),
                  const SizedBox(width: 8),
                  _RatingButton(
                      label: 'Good',
                      icon: Iconsax.like_1,
                      xp: 20,
                      onTap: () => _rate(2),
                      variant: _RatingVariant.blue),
                  const SizedBox(width: 8),
                  _RatingButton(
                      label: 'Easy',
                      icon: Iconsax.flash_1,
                      xp: 30,
                      onTap: () => _rate(3),
                      variant: _RatingVariant.amber),
                ]),
              ),
            ),
          ),

          const SizedBox(height: 32),
        ]),
      ),
    );
  }
}

// ── Card face widgets ─────────────────────────────────────────────────────────

class _CardFront extends StatelessWidget {
  final Flashcard card;
  final bool isDark;
  const _CardFront({required this.card, required this.isDark});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        color: isDark ? AppColors.surfaceDark : AppColors.bgLight,
        borderRadius: BorderRadius.circular(20),
        boxShadow: isDark ? null : AppShadows.card,
        border: isDark ? Border.all(color: AppColors.borderDark) : null,
      ),
      padding: const EdgeInsets.all(28),
      child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
        Text(card.front,
            style: AppTextStyles.display(
                color: isDark
                    ? AppColors.textPrimaryDark
                    : AppColors.neutralDark)),
        const SizedBox(height: 24),
        Container(
          width: 52,
          height: 52,
          decoration: BoxDecoration(
              color: AppColors.primaryMid, shape: BoxShape.circle),
          child: const Icon(Iconsax.volume_high,
              size: 22, color: AppColors.primary),
        ),
      ]),
    );
  }
}

class _CardBack extends StatelessWidget {
  final Flashcard card;
  final bool isDark;
  const _CardBack({required this.card, required this.isDark});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        color: isDark ? AppColors.surfaceDark : AppColors.bgLight,
        borderRadius: BorderRadius.circular(20),
        boxShadow: isDark ? null : AppShadows.card,
        border: isDark ? Border.all(color: AppColors.borderDark) : null,
      ),
      padding: const EdgeInsets.all(28),
      child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
        Text(card.back,
            style: AppTextStyles.display(
                    color: isDark
                        ? AppColors.textPrimaryDark
                        : AppColors.neutralDark)
                .copyWith(fontSize: 28, fontWeight: FontWeight.w700)),
        if (card.exampleSentence != null) ...[
          const SizedBox(height: 16),
          Text(card.exampleSentence!,
              style: AppTextStyles.body(color: AppColors.neutralMid)
                  .copyWith(fontStyle: FontStyle.italic),
              textAlign: TextAlign.center),
        ],
        const SizedBox(height: 24),
        Row(mainAxisAlignment: MainAxisAlignment.center, children: [
          Container(
            width: 44,
            height: 44,
            decoration: BoxDecoration(
                color: AppColors.primaryMid, shape: BoxShape.circle),
            child: const Icon(Iconsax.volume_high,
                size: 20, color: AppColors.primary),
          ),
          const SizedBox(width: 12),
          Container(
            padding:
                const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(AppRadius.chip),
              border: Border.all(color: AppColors.primary, width: 1.5),
            ),
            child: Row(mainAxisSize: MainAxisSize.min, children: [
              const Icon(Iconsax.microphone_2,
                  size: 16, color: AppColors.primary),
              const SizedBox(width: 6),
              Text('Tap to practice',
                  style: AppTextStyles.caption(color: AppColors.primary)
                      .copyWith(fontWeight: FontWeight.w600)),
            ]),
          ),
        ]),
      ]),
    );
  }
}

// ── Rating button ─────────────────────────────────────────────────────────────

enum _RatingVariant { neutral, blue, amber }

class _RatingButton extends StatelessWidget {
  final String label;
  final IconData icon;
  final int xp;
  final VoidCallback onTap;
  final _RatingVariant variant;

  const _RatingButton({
    required this.label,
    required this.icon,
    required this.xp,
    required this.onTap,
    this.variant = _RatingVariant.neutral,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    Color bg, fg;
    switch (variant) {
      case _RatingVariant.blue:
        bg = AppColors.primaryMid;
        fg = AppColors.primary;
        break;
      case _RatingVariant.amber:
        bg = AppColors.amberMid;
        fg = AppColors.amberText;
        break;
      case _RatingVariant.neutral:
        bg = isDark ? AppColors.surfaceDark : AppColors.neutralLight;
        fg = isDark ? AppColors.textPrimaryDark : AppColors.neutralDark;
    }

    return Expanded(
      child: GestureDetector(
        onTap: onTap,
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 12),
          decoration: BoxDecoration(
            color: bg,
            borderRadius: BorderRadius.circular(AppRadius.input),
            border: isDark && variant == _RatingVariant.neutral
                ? Border.all(color: AppColors.borderDark)
                : null,
          ),
          child: Column(mainAxisSize: MainAxisSize.min, children: [
            Icon(icon, size: 20, color: fg),
            const SizedBox(height: 6),
            Text(label, style: AppTextStyles.label(color: fg)),
          ]),
        ),
      ),
    );
  }
}
