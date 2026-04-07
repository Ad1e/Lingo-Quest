import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:language_learning_app/providers/app_providers.dart';
import 'package:language_learning_app/providers/auth_provider.dart';
import 'package:language_learning_app/providers/flashcard_provider.dart';
import 'package:language_learning_app/providers/progress_provider.dart';

/// Dashboard screen for home tab showing learning progress and quick actions
class DashboardScreen extends ConsumerStatefulWidget {
  /// Callback when start studying is tapped
  final Function()? onStartStudy;

  /// Callback when lessons is tapped
  final Function()? onLessonsPressed;

  /// Callback when leaderboard is tapped
  final Function()? onLeaderboardPressed;

  const DashboardScreen({
    super.key,
    this.onStartStudy,
    this.onLessonsPressed,
    this.onLeaderboardPressed,
  });

  @override
  ConsumerState<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends ConsumerState<DashboardScreen> {
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    // Refresh streak on load
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final user = ref.read(currentUserProvider);
      if (user != null) {
        ref.read(progressProvider(user.id).notifier).checkStreak();
      }
    });
  }

  /// Refresh data from Firebase
  Future<void> _refreshData() async {
    setState(() => _errorMessage = null);
    try {
      final user = ref.read(currentUserProvider);
      if (user != null) {
        await ref.read(progressProvider(user.id).notifier).loadProgress();
        ref.invalidate(deckListProvider(user.id));
      }
    } catch (e) {
      setState(() => _errorMessage = 'Failed to refresh: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final user = ref.watch(currentUserProvider);

    // If logged out, show nothing relevant
    if (user == null) {
      return const Center(child: CircularProgressIndicator());
    }

    final progressState = ref.watch(progressProvider(user.id));
    final deckListState = ref.watch(deckListProvider(user.id));

    // Total due cards across all decks (sum a future)
    final dueCardsAsync = ref.watch(
      _dueCardsCountProvider(user.id),
    );

    return RefreshIndicator(
      onRefresh: _refreshData,
      child: SingleChildScrollView(
        physics: const AlwaysScrollableScrollPhysics(),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Error message
            if (_errorMessage != null)
              Container(
                margin: const EdgeInsets.all(16),
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: theme.colorScheme.error.withValues(alpha: 0.1),
                  border: Border.all(color: theme.colorScheme.error),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Row(
                  children: [
                    Icon(Icons.warning_amber, color: theme.colorScheme.error, size: 20),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        _errorMessage!,
                        style: theme.textTheme.labelSmall?.copyWith(
                          color: theme.colorScheme.error,
                        ),
                      ),
                    ),
                  ],
                ),
              ),

            // Greeting section
            Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Welcome back, ${user.username.isNotEmpty ? user.username : "Learner"}!',
                    style: theme.textTheme.titleMedium?.copyWith(color: Colors.grey[600]),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'Ready to learn today?',
                    style: theme.textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.bold),
                  ),
                ],
              ),
            ),

            // Streak counter widget — real data
            _buildStreakWidget(theme, progressState.streak),

            const SizedBox(height: 16),

            // Due for review card — real data
            dueCardsAsync.when(
              data: (count) => _buildDueForReviewCard(theme, count),
              loading: () => _buildDueForReviewCard(theme, null),
              error: (_, __) => _buildDueForReviewCard(theme, 0),
            ),

            const SizedBox(height: 16),

            // Daily challenge card
            _buildDailyChallengeCard(theme, progressState.totalCardsStudied),

            const SizedBox(height: 16),

            // XP progress — real data
            _buildXPProgressCard(theme, progressState),

            const SizedBox(height: 16),

            // Quick access grid
            _buildQuickAccessGrid(theme),

            const SizedBox(height: 24),
          ],
        ),
      ),
    );
  }

  /// Build streak counter widget
  Widget _buildStreakWidget(ThemeData theme, int streak) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Card(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: Colors.orange.withValues(alpha: 0.2),
                ),
                child: const Icon(Icons.local_fire_department, color: Colors.orange, size: 32),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Current Streak',
                      style: theme.textTheme.labelSmall?.copyWith(color: Colors.grey[600]),
                    ),
                    const SizedBox(height: 4),
                    Row(
                      children: [
                        Text(
                          ' $streak',
                          style: theme.textTheme.headlineSmall?.copyWith(
                            fontWeight: FontWeight.bold,
                            color: Colors.orange,
                          ),
                        ),
                        Text(
                          ' day${streak == 1 ? '' : 's'}',
                          style: theme.textTheme.titleMedium?.copyWith(color: Colors.orange),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text(
                    streak > 0 ? 'Keep it up!' : 'Start today!',
                    style: theme.textTheme.labelSmall?.copyWith(color: Colors.grey[600]),
                  ),
                  const SizedBox(height: 4),
                  Icon(
                    streak > 0 ? Icons.trending_up : Icons.trending_flat,
                    color: streak > 0 ? Colors.green : Colors.grey,
                    size: 24,
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  /// Build due for review card
  Widget _buildDueForReviewCard(ThemeData theme, int? cardsReady) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: GestureDetector(
        onTap: widget.onStartStudy,
        child: Card(
          child: Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(12),
              gradient: LinearGradient(
                colors: [
                  theme.primaryColor.withValues(alpha: 0.1),
                  theme.primaryColor.withValues(alpha: 0.05),
                ],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Due for Review',
                          style: theme.textTheme.labelSmall?.copyWith(color: Colors.grey[600]),
                        ),
                        const SizedBox(height: 8),
                        Row(
                          children: [
                            cardsReady == null
                                ? const SizedBox(
                                    width: 24,
                                    height: 24,
                                    child: CircularProgressIndicator(strokeWidth: 2),
                                  )
                                : Text(
                                    cardsReady.toString(),
                                    style: theme.textTheme.displaySmall?.copyWith(
                                      fontWeight: FontWeight.bold,
                                      color: theme.primaryColor,
                                    ),
                                  ),
                            const SizedBox(width: 8),
                            Text(
                              'flashcards',
                              style: theme.textTheme.bodyMedium?.copyWith(color: Colors.grey[600]),
                            ),
                          ],
                        ),
                      ],
                    ),
                    Icon(
                      Icons.library_books,
                      size: 48,
                      color: theme.primaryColor.withValues(alpha: 0.5),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: widget.onStartStudy,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: theme.primaryColor,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                    ),
                    child: Text(
                      'Start Studying',
                      style: theme.textTheme.labelLarge?.copyWith(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  /// Build daily challenge card
  Widget _buildDailyChallengeCard(ThemeData theme, int totalCardsStudied) {
    final goal = 10;
    final done = totalCardsStudied % goal; // simple daily proxy
    final isComplete = done >= goal;
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Card(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: Colors.purple.withValues(alpha: 0.2),
                ),
                child: const Icon(Icons.emoji_events, color: Colors.purple, size: 32),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      "Today's Challenge",
                      style: theme.textTheme.labelSmall?.copyWith(color: Colors.grey[600]),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'Study $goal flashcards',
                      style: theme.textTheme.bodyMedium?.copyWith(fontWeight: FontWeight.w600),
                    ),
                  ],
                ),
              ),
              Text(
                isComplete ? 'Complete! ✅' : 'In progress',
                style: theme.textTheme.labelSmall?.copyWith(
                  color: isComplete ? Colors.green : Colors.orange,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  /// Build XP progress card — driven by real ProgressState
  Widget _buildXPProgressCard(ThemeData theme, ProgressState progressState) {
    final currentXP = progressState.xpInCurrentLevel;
    final xpNeeded = progressState.xpNeededForLevel;
    final currentLevel = progressState.level;
    final progress = progressState.levelProgress;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Card(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Level $currentLevel',
                    style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
                  ),
                  Text(
                    '$currentXP / $xpNeeded XP',
                    style: theme.textTheme.labelSmall?.copyWith(color: Colors.grey[600]),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              ClipRRect(
                borderRadius: BorderRadius.circular(8),
                child: LinearProgressIndicator(
                  value: progress,
                  minHeight: 8,
                  backgroundColor: Colors.grey[300],
                  valueColor: AlwaysStoppedAnimation<Color>(theme.primaryColor),
                ),
              ),
              const SizedBox(height: 8),
              Text(
                '${(progress * 100).toStringAsFixed(0)}% to Level ${currentLevel + 1}',
                style: theme.textTheme.labelSmall?.copyWith(color: Colors.grey[600]),
              ),
            ],
          ),
        ),
      ),
    );
  }

  /// Build quick access grid
  Widget _buildQuickAccessGrid(ThemeData theme) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Quick Access',
            style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 12),
          GridView.count(
            crossAxisCount: 2,
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            crossAxisSpacing: 12,
            mainAxisSpacing: 12,
            children: [
              _buildGridItem(
                icon: Icons.school,
                label: 'Lessons',
                color: Colors.blue,
                onTap: widget.onLessonsPressed,
                theme: theme,
              ),
              _buildGridItem(
                icon: Icons.leaderboard,
                label: 'Leaderboard',
                color: Colors.red,
                onTap: widget.onLeaderboardPressed,
                theme: theme,
              ),
              _buildGridItem(
                icon: Icons.people,
                label: 'Friends',
                color: Colors.green,
                onTap: null,
                theme: theme,
              ),
              _buildGridItem(
                icon: Icons.settings,
                label: 'Settings',
                color: Colors.grey,
                onTap: null,
                theme: theme,
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildGridItem({
    required IconData icon,
    required String label,
    required Color color,
    required void Function()? onTap,
    required ThemeData theme,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Card(
        child: Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(12),
            color: color.withValues(alpha: 0.05),
          ),
          child: Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: color.withValues(alpha: 0.2),
                  ),
                  child: Icon(icon, color: color, size: 32),
                ),
                const SizedBox(height: 12),
                Text(
                  label,
                  style: theme.textTheme.labelMedium?.copyWith(fontWeight: FontWeight.w600),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

// ── Internal helper provider ──────────────────────────────────────────────────
// Sums due cards across all of the user's decks.
final _dueCardsCountProvider =
    FutureProvider.family<int, String>((ref, userId) async {
  final deckState = ref.watch(deckListProvider(userId));
  if (deckState.isLoading || deckState.decks.isEmpty) return 0;

  final flashcardRepo = ref.watch(flashcardRepositoryProvider);
  int total = 0;
  for (final deck in deckState.decks) {
    final due = await flashcardRepo.getCardsDueForReview(deck.id);
    total += due.length;
  }
  return total;
});
