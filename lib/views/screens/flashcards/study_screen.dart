import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:language_learning_app/domain/repositories/flashcard_repository.dart';
import 'package:language_learning_app/providers/app_providers.dart';

/// Study screen for flashcard review using SM-2 algorithm
class StudyScreen extends ConsumerStatefulWidget {
  /// Deck ID to study
  final String deckId;

  /// User ID for tracking progress
  final String userId;

  /// Callback when study session is complete
  final Function(int xpEarned, int cardsReviewed)? onSessionComplete;

  const StudyScreen({
    super.key,
    required this.deckId,
    required this.userId,
    this.onSessionComplete,
  });

  @override
  ConsumerState<StudyScreen> createState() => _StudyScreenState();
}

class _StudyScreenState extends ConsumerState<StudyScreen> {
  bool _isFlipped = false;
  int _currentIndex = 0;
  int _totalCards = 0;
  int _xpEarned = 0;
  bool _isLoading = true;
  String? _errorMessage;
  List<Flashcard> _cards = [];
  bool _sessionComplete = false;
  DateTime _cardStartTime = DateTime.now();

  @override
  void initState() {
    super.initState();
    _loadCards();
  }

  /// Load cards due for review from the real flashcard repository
  Future<void> _loadCards() async {
    try {
      final flashcardRepository = ref.read(flashcardRepositoryProvider);
      final dueCards = await flashcardRepository.getCardsDueForReview(widget.deckId);
      if (mounted) {
        setState(() {
          _cards = dueCards;
          _totalCards = dueCards.length;
          _isLoading = false;
          _cardStartTime = DateTime.now();
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _isLoading = false;
          _errorMessage = 'Failed to load cards: $e';
        });
      }
    }
  }

  /// Handle rating selection — calls StudyFlashcardUseCase (SM-2 + XP save)
  Future<void> _handleRating(int rating) async {
    if (_currentIndex >= _cards.length) return;

    final card = _cards[_currentIndex];
    final durationMs = DateTime.now().difference(_cardStartTime).inMilliseconds;

    try {
      final studyUseCase = ref.read(studyFlashcardUseCaseProvider);
      await studyUseCase(
        userId: widget.userId,
        card: card,
        rating: rating,
        duration: durationMs,
      );

      // XP shown in UI — mirrors StudyFlashcardUseCase._calculateXP
      final xp = _calculateXP(rating) + (durationMs ~/ 60000).clamp(0, 5);
      setState(() => _xpEarned += xp);

      // Move to next card or complete session
      if (_currentIndex < _cards.length - 1) {
        setState(() {
          _currentIndex++;
          _isFlipped = false;
          _cardStartTime = DateTime.now();
        });
      } else {
        setState(() => _sessionComplete = true);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error saving review: $e')),
        );
        // Still advance card so user isn't stuck
        if (_currentIndex < _cards.length - 1) {
          setState(() {
            _currentIndex++;
            _isFlipped = false;
            _cardStartTime = DateTime.now();
          });
        } else {
          setState(() => _sessionComplete = true);
        }
      }
    }
  }

  /// Calculate XP based on rating
  int _calculateXP(int rating) {
    switch (rating) {
      case 0: // Again
        return 0;
      case 1: // Hard
        return 5;
      case 2: // Good
        return 10;
      case 3: // Easy
        return 20;
      default:
        return 0;
    }
  }

  /// Get rating label
  String _getRatingLabel(int rating) {
    switch (rating) {
      case 0:
        return 'Again';
      case 1:
        return 'Hard';
      case 2:
        return 'Good';
      case 3:
        return 'Easy';
      default:
        return '';
    }
  }

  /// Get rating color
  Color _getRatingColor(int rating) {
    switch (rating) {
      case 0: // Again
        return Colors.red;
      case 1: // Hard
        return Colors.orange;
      case 2: // Good
        return Colors.blue;
      case 3: // Easy
        return Colors.green;
      default:
        return Colors.grey;
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    // Show loading state
    if (_isLoading) {
      return Scaffold(
        appBar: AppBar(
          title: const Text('Study'),
          centerTitle: true,
        ),
        body: const Center(
          child: CircularProgressIndicator(),
        ),
      );
    }

    // Show error state
    if (_errorMessage != null) {
      return Scaffold(
        appBar: AppBar(
          title: const Text('Study'),
          centerTitle: true,
        ),
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                Icons.error_outline,
                size: 64,
                color: theme.colorScheme.error,
              ),
              const SizedBox(height: 16),
              Text(
                _errorMessage!,
                textAlign: TextAlign.center,
                style: theme.textTheme.bodyLarge?.copyWith(
                  color: theme.colorScheme.error,
                ),
              ),
            ],
          ),
        ),
      );
    }

    // Show session complete summary
    if (_sessionComplete) {
      return _buildSessionSummary(theme);
    }

    // Show empty state
    if (_cards.isEmpty) {
      return Scaffold(
        appBar: AppBar(
          title: const Text('Study'),
          centerTitle: true,
        ),
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                Icons.done_all,
                size: 64,
                color: theme.primaryColor,
              ),
              const SizedBox(height: 16),
              Text(
                'All caught up!',
                style: theme.textTheme.headlineSmall?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                'No cards due for review right now.',
                style: theme.textTheme.bodyMedium?.copyWith(
                  color: Colors.grey[600],
                ),
              ),
            ],
          ),
        ),
      );
    }

    final currentCard = _cards[_currentIndex];
    final progress = (_currentIndex + 1) / _totalCards;
    // card.front / card.back are the domain Flashcard fields
    final displayWord = currentCard.front;
    final displayTranslation = currentCard.back;
    final displayExample = currentCard.exampleSentence ?? '';

    return Scaffold(
      appBar: AppBar(
        title: const Text('Study'),
        centerTitle: true,
        elevation: 0,
        backgroundColor: theme.primaryColor,
        foregroundColor: Colors.white,
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Progress section
            Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'Card ${_currentIndex + 1} of $_totalCards',
                        style: theme.textTheme.labelLarge?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Chip(
                        label: Text('$_xpEarned XP'),
                        backgroundColor: theme.primaryColor.withValues(alpha: 0.2),
                        labelStyle: TextStyle(
                          color: theme.primaryColor,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  ClipRRect(
                    borderRadius: BorderRadius.circular(8),
                    child: LinearProgressIndicator(
                      value: progress,
                      minHeight: 6,
                      backgroundColor: Colors.grey[300],
                      valueColor: AlwaysStoppedAnimation<Color>(
                        theme.primaryColor,
                      ),
                    ),
                  ),
                ],
              ),
            ),

            // Flashcard
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 24),
              child: GestureDetector(
                onTap: () {
                  setState(() => _isFlipped = !_isFlipped);
                },
                child: _buildFlashcard(displayWord, displayTranslation, displayExample, theme),
              ),
            ),

            // Flip instruction
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Text(
                'Tap card to flip',
                textAlign: TextAlign.center,
                style: theme.textTheme.labelSmall?.copyWith(
                  color: Colors.grey[600],
                ),
              ),
            ),

            const SizedBox(height: 24),

            // Rating buttons
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'How well did you remember?',
                    style: theme.textTheme.labelLarge?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 12),
                  GridView.count(
                    crossAxisCount: 2,
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    mainAxisSpacing: 12,
                    crossAxisSpacing: 12,
                    children: List.generate(4, (index) {
                      final color = _getRatingColor(index);
                      final label = _getRatingLabel(index);

                      return ElevatedButton(
                        onPressed: () => _handleRating(index),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: color,
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(vertical: 16),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(
                              _getRatingIcon(index),
                              size: 24,
                            ),
                            const SizedBox(height: 8),
                            Text(
                              label,
                              textAlign: TextAlign.center,
                              style: theme.textTheme.labelMedium?.copyWith(
                                color: Colors.white,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ),
                      );
                    }),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 24),
          ],
        ),
      ),
    );
  }

  /// Build flashcard with flip animation
  Widget _buildFlashcard(String word, String translation, String example, ThemeData theme) {
    return AnimatedSwitcher(
      duration: const Duration(milliseconds: 400),
      transitionBuilder: (child, animation) {
        return ScaleTransition(scale: animation, child: child);
      },
      child: _isFlipped
          ? _buildCardBack(translation, example, theme)
          : _buildCardFront(word, theme),
    );
  }

  Widget _buildCardFront(String word, ThemeData theme) {
    return Card(
      key: ValueKey('front'),
      elevation: 4,
      child: Container(
        height: 300,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(16),
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
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              'Word',
              style: theme.textTheme.labelMedium?.copyWith(color: Colors.grey[600]),
            ),
            const SizedBox(height: 16),
            Text(
              word,
              style: theme.textTheme.displaySmall?.copyWith(fontWeight: FontWeight.bold),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 24),
          ],
        ),
      ),
    );
  }

  /// Build back of card (translation, example)
  Widget _buildCardBack(String translation, String example, ThemeData theme) {
    return Card(
      key: const ValueKey('back'),
      elevation: 4,
      child: Container(
        height: 300,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(16),
          gradient: LinearGradient(
            colors: [
              Colors.green.withValues(alpha: 0.1),
              Colors.green.withValues(alpha: 0.05),
            ],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Translation',
                    style: theme.textTheme.labelSmall?.copyWith(
                      color: Colors.grey[600],
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    translation,
                    style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              if (example.isNotEmpty)
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Example',
                      style: theme.textTheme.labelSmall?.copyWith(
                        color: Colors.grey[600],
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      example,
                      style: theme.textTheme.bodySmall?.copyWith(
                        fontStyle: FontStyle.italic,
                        color: Colors.grey[700],
                      ),
                    ),
                  ],
                ),
            ],
          ),
        ),
      ),
    );
  }

  /// Get icon for rating
  IconData _getRatingIcon(int rating) {
    switch (rating) {
      case 0: // Again
        return Icons.close;
      case 1: // Hard
        return Icons.thumb_down;
      case 2: // Good
        return Icons.thumb_up;
      case 3: // Easy
        return Icons.check_circle;
      default:
        return Icons.help;
    }
  }

  /// Build session summary screen
  Widget _buildSessionSummary(ThemeData theme) {
    final cardsReviewed = _currentIndex + 1;
    final cardsRemaining = _totalCards - cardsReviewed;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Session Complete'),
        centerTitle: true,
        elevation: 0,
        backgroundColor: theme.primaryColor,
        foregroundColor: Colors.white,
        automaticallyImplyLeading: false,
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Celebration icon
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 32),
                child: Icon(
                  Icons.celebration,
                  size: 80,
                  color: theme.primaryColor,
                ),
              ),

              // Header
              Text(
                'Great Job!',
                textAlign: TextAlign.center,
                style: theme.textTheme.headlineSmall?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                'You\'ve completed this study session',
                textAlign: TextAlign.center,
                style: theme.textTheme.bodyMedium?.copyWith(
                  color: Colors.grey[600],
                ),
              ),

              const SizedBox(height: 32),

              // Stats cards
              _buildStatCard(
                icon: Icons.star,
                label: 'XP Earned',
                value: _xpEarned.toString(),
                color: Colors.orange,
                theme: theme,
              ),
              const SizedBox(height: 12),
              _buildStatCard(
                icon: Icons.library_books,
                label: 'Cards Reviewed',
                value: cardsReviewed.toString(),
                color: Colors.blue,
                theme: theme,
              ),
              const SizedBox(height: 12),
              _buildStatCard(
                icon: Icons.pending,
                label: 'Cards Remaining',
                value: cardsRemaining.toString(),
                color: Colors.purple,
                theme: theme,
              ),

              const SizedBox(height: 32),

              // Action buttons
              ElevatedButton(
                onPressed: () {
                  widget.onSessionComplete?.call(_xpEarned, cardsReviewed);
                  Navigator.of(context).pop();
                },
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  backgroundColor: theme.primaryColor,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: Text(
                  'Finish',
                  style: theme.textTheme.labelLarge?.copyWith(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              const SizedBox(height: 12),
              OutlinedButton(
                onPressed: () {
                  setState(() {
                    _currentIndex = 0;
                    _xpEarned = 0;
                    _isFlipped = false;
                    _sessionComplete = false;
                  });
                },
                style: OutlinedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: Text(
                  'Study Again',
                  style: theme.textTheme.labelLarge?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  /// Build stat card
  Widget _buildStatCard({
    required IconData icon,
    required String label,
    required String value,
    required Color color,
    required ThemeData theme,
  }) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: color.withValues(alpha: 0.2),
              ),
              child: Icon(icon, color: color, size: 28),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    label,
                    style: theme.textTheme.labelSmall?.copyWith(
                      color: Colors.grey[600],
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    value,
                    style: theme.textTheme.headlineSmall?.copyWith(
                      fontWeight: FontWeight.bold,
                      color: color,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// Model for study card — delegates to domain Flashcard
typedef StudyCard = Flashcard;
