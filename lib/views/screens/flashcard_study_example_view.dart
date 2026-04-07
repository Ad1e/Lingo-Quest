import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:language_learning_app/providers/progress_provider.dart';
import 'package:language_learning_app/utils/gamification_models.dart';
import 'package:language_learning_app/views/widgets/xp_gain_overlay.dart';
import 'package:language_learning_app/views/widgets/gamification_widgets.dart';

/// Example integration of the XP system in a flashcard study view
/// This demonstrates how to:
/// 1. Award XP when users study flashcards
/// 2. Show visual feedback with animations
/// 3. Display gamification elements
/// 4. Handle level ups and achievements
class FlashcardStudyExampleView extends ConsumerStatefulWidget {
  final String userId;
  final String languageId;

  const FlashcardStudyExampleView({
    Key? key,
    required this.userId,
    required this.languageId,
  }) : super(key: key);

  @override
  ConsumerState<FlashcardStudyExampleView> createState() =>
      _FlashcardStudyExampleViewState();
}

class _FlashcardStudyExampleViewState
    extends ConsumerState<FlashcardStudyExampleView>
    with TickerProviderStateMixin {
  late OverlayEntry? _notificationOverlay;
  final GlobalKey<XpNotificationOverlayState> _overlayKey = GlobalKey();

  @override
  void initState() {
    super.initState();
    _setupNotificationOverlay();
  }

  void _setupNotificationOverlay() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) {
        final overlay = Overlay.of(context);
        _notificationOverlay = OverlayEntry(
          builder: (context) => XpNotificationOverlay(
            key: _overlayKey,
            child: SizedBox.expand(),
          ),
        );
        overlay.insert(_notificationOverlay!);
      }
    });
  }

  @override
  void dispose() {
    _notificationOverlay?.remove();
    super.dispose();
  }

  /// Called when user studies a flashcard
  Future<void> _onFlashcardStudied(String cardId) async {
    final progressNotifier =
        ref.read(progressProvider(widget.userId).notifier);

    try {
      // Award XP with streak bonus
      final (xpAdded, newLevel, achievement) =
          await progressNotifier.addXpForEvent(
        XpEventType.flashcardStudied,
        streakBonus: true,
      );

      if (mounted) {
        // Show XP gain notification
        _overlayKey.currentState?.showXpGain(xpAdded);

        // Show level up notification if applicable
        if (newLevel != null) {
          Future.delayed(const Duration(milliseconds: 500), () {
            if (mounted) {
              _overlayKey.currentState?.showLevelUp(newLevel);
            }
          });
        }

        // Show achievement notification if applicable
        if (achievement != null) {
          Future.delayed(const Duration(milliseconds: 1200), () {
            if (mounted) {
              _overlayKey.currentState?.showAchievementUnlock(achievement);
            }
          });
        }
      }

      // Increment total cards studied
      await progressNotifier.incrementCardsStudied();

      // You can show a toast or snackbar here if desired
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Earned +$xpAdded XP'),
          duration: const Duration(milliseconds: 800),
        ),
      );
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: $e')),
        );
      }
    }
  }

  /// Called when user rates a card as "Easy"
  Future<void> _onCardRatedEasy(String cardId) async {
    final progressNotifier =
        ref.read(progressProvider(widget.userId).notifier);

    try {
      // Award double XP bonus for easy-rated cards
      final (xpAdded, newLevel, achievement) =
          await progressNotifier.addXpForEvent(
        XpEventType.flashcardRatedEasy,
        streakBonus: true,
      );

      if (mounted) {
        _overlayKey.currentState?.showXpGain(xpAdded);

        if (newLevel != null) {
          Future.delayed(const Duration(milliseconds: 500), () {
            if (mounted) {
              _overlayKey.currentState?.showLevelUp(newLevel);
            }
          });
        }

        if (achievement != null) {
          Future.delayed(const Duration(milliseconds: 1200), () {
            if (mounted) {
              _overlayKey.currentState?.showAchievementUnlock(achievement);
            }
          });
        }

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Bonus! Earned +$xpAdded XP for rating Easy'),
            duration: const Duration(milliseconds: 800),
            backgroundColor: Colors.green.shade600,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: $e')),
        );
      }
    }
  }

  /// Called when lesson is completed
  Future<void> _onLessonCompleted(int cardsStudiedInLesson) async {
    final progressNotifier =
        ref.read(progressProvider(widget.userId).notifier);

    try {
      // Award XP for lesson completion
      final (xpAdded, newLevel, achievement) =
          await progressNotifier.addXpForEvent(
        XpEventType.lessonCompleted,
        streakBonus: true,
      );

      if (mounted) {
        _overlayKey.currentState?.showXpGain(xpAdded);

        if (newLevel != null) {
          Future.delayed(const Duration(milliseconds: 500), () {
            if (mounted) {
              _overlayKey.currentState?.showLevelUp(newLevel);
              _showLessonCompleteDialog(newLevel, xpAdded);
            }
          });
        } else {
          _showLessonCompleteDialog(null, xpAdded);
        }

        if (achievement != null) {
          Future.delayed(const Duration(milliseconds: 1200), () {
            if (mounted) {
              _overlayKey.currentState?.showAchievementUnlock(achievement);
            }
          });
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: $e')),
        );
      }
    }
  }

  void _showLessonCompleteDialog(int? newLevel, int totalXp) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
        title: const Text('🎉 Lesson Complete!'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              'You earned $totalXp XP',
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: Colors.purple.shade600,
                  ),
            ),
            if (newLevel != null) ...[
              const SizedBox(height: 16),
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.purple.shade100,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  'NEW LEVEL: $newLevel',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    color: Colors.purple.shade600,
                  ),
                  textAlign: TextAlign.center,
                ),
              ),
            ],
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Continue'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final progressState = ref.watch(progressProvider(widget.userId));

    return Scaffold(
      appBar: AppBar(
        title: const Text('Study Flashcards'),
        elevation: 0,
        actions: [
          // Show level badge in app bar
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: progressState.when(
              data: (progress) => Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                decoration: BoxDecoration(
                  color: Colors.purple.shade600,
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Text(
                      '⭐',
                      style: TextStyle(fontSize: 16),
                    ),
                    const SizedBox(width: 4),
                    Text(
                      'L${progress.level}',
                      style: const TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ),
              loading: () => const SizedBox.shrink(),
              error: (_, __) => const SizedBox.shrink(),
            ),
          ),
        ],
      ),
      body: progressState.when(
        data: (progress) => SingleChildScrollView(
          child: Column(
            children: [
              // Gamification Header
              Container(
                color: Colors.grey.shade100,
                padding: const EdgeInsets.all(16),
                child: Column(
                  children: [
                    // Level Display
                    LevelDisplay(
                      userId: widget.userId,
                      levelBadgeSize: const Size(100, 100),
                      showDetails: true,
                    ),
                    const SizedBox(height: 20),

                    // Streak Display
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: [
                        StreakDisplay(
                          userId: widget.userId,
                          showFlame: true,
                        ),
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 16,
                            vertical: 12,
                          ),
                          decoration: BoxDecoration(
                            gradient: LinearGradient(
                              colors: [
                                Colors.blue.shade600,
                                Colors.cyan.shade600,
                              ],
                              begin: Alignment.topLeft,
                              end: Alignment.bottomRight,
                            ),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Cards',
                                style: Theme.of(context)
                                    .textTheme
                                    .labelSmall
                                    ?.copyWith(
                                      color: Colors.white70,
                                      fontWeight: FontWeight.w600,
                                    ),
                              ),
                              Text(
                                '${progress.totalCardsStudied}',
                                style: Theme.of(context)
                                    .textTheme
                                    .titleMedium
                                    ?.copyWith(
                                      color: Colors.white,
                                      fontWeight: FontWeight.bold,
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

              const SizedBox(height: 24),

              // Achievements Section
              Padding(
                padding: const EdgeInsets.horizontal: 16,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Achievements',
                      style: Theme.of(context).textTheme.titleLarge?.copyWith(
                            fontWeight: FontWeight.bold,
                          ),
                    ),
                    const SizedBox(height: 12),
                    AchievementDisplay(
                      userId: widget.userId,
                      maxShowCount: 6,
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 24),

              // Example Flashcard Study Area
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Study Cards',
                      style: Theme.of(context).textTheme.titleLarge?.copyWith(
                            fontWeight: FontWeight.bold,
                          ),
                    ),
                    const SizedBox(height: 16),

                    // Flashcard example
                    Card(
                      elevation: 4,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16),
                      ),
                      child: Container(
                        padding: const EdgeInsets.all(24),
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            colors: [
                              Colors.blue.shade400,
                              Colors.indigo.shade400,
                            ],
                          ),
                          borderRadius: BorderRadius.circular(16),
                        ),
                        child: Column(
                          children: [
                            const Text(
                              'English Word',
                              style: TextStyle(
                                color: Colors.white70,
                                fontSize: 14,
                              ),
                            ),
                            const SizedBox(height: 16),
                            const Text(
                              'Example Card',
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 28,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            const SizedBox(height: 32),
                            ElevatedButton(
                              onPressed: () {
                                _onFlashcardStudied('card-1');
                              },
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.white,
                                foregroundColor: Colors.indigo,
                              ),
                              child: const Text('Mark as Studied'),
                            ),
                          ],
                        ),
                      ),
                    ),

                    const SizedBox(height: 16),

                    // Action buttons
                    Row(
                      children: [
                        Expanded(
                          child: OutlinedButton(
                            onPressed: () {
                              _onCardRatedEasy('card-1');
                            },
                            child: const Text('Easy ⭐'),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: OutlinedButton(
                            onPressed: () {
                              // Handle other rating
                            },
                            child: const Text('Hard'),
                          ),
                        ),
                      ],
                    ),

                    const SizedBox(height: 16),

                    ElevatedButton.icon(
                      onPressed: () {
                        _onLessonCompleted(10);
                      },
                      icon: const Icon(Icons.check_circle),
                      label: const Text('Complete Lesson'),
                      style: ElevatedButton.styleFrom(
                        minimumSize: const Size.fromHeight(48),
                        backgroundColor: Colors.green.shade600,
                      ),
                    ),

                    const SizedBox(height: 32),
                  ],
                ),
              ),
            ],
          ),
        ),
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (error, stackTrace) => Center(
          child: Text('Error: $error'),
        ),
      ),
    );
  }
}

/// Riverpod state key extension for accessing overlay methods
extension on GlobalKey<XpNotificationOverlayState> {
  XpNotificationOverlayState? get _state => currentState;
}
