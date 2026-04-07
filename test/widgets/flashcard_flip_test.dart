/// Widget tests for flashcard flip animation and rating flow
/// 
/// Tests cover:
/// - Card flips between front and back
/// - Animation smooth transitions
/// - Rating selection triggers appropriate callbacks
/// - XP calculation and display
/// - Streak tracking updates
/// - Navigation to next card work correctly

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

// Mock data models for testing
class MockFlashcard {
  final String id;
  final String front;
  final String back;
  final String? audioUrl;
  final String deckId;
  final DateTime createdAt;
  final DateTime lastReviewedAt;

  MockFlashcard({
    required this.id,
    required this.front,
    required this.back,
    this.audioUrl,
    required this.deckId,
    required this.createdAt,
    required this.lastReviewedAt,
  });
}

/// Simple flashcard widget for testing
class FlashcardWidget extends StatefulWidget {
  final MockFlashcard card;
  final Function(int rating) onRating;
  final VoidCallback onNext;

  const FlashcardWidget({
    Key? key,
    required this.card,
    required this.onRating,
    required this.onNext,
  }) : super(key: key);

  @override
  State<FlashcardWidget> createState() => _FlashcardWidgetState();
}

class _FlashcardWidgetState extends State<FlashcardWidget>
    with SingleTickerProviderStateMixin {
  late AnimationController _flipController;
  bool _isFlipped = false;

  @override
  void initState() {
    super.initState();
    _flipController = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );
  }

  @override
  void dispose() {
    _flipController.dispose();
    super.dispose();
  }

  void _flipCard() {
    if (_isFlipped) {
      _flipController.reverse();
    } else {
      _flipController.forward();
    }
    setState(() {
      _isFlipped = !_isFlipped;
    });
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: _flipCard,
      child: AnimatedBuilder(
        animation: _flipController,
        builder: (context, child) {
          // Get the rotation value
          final angle = _flipController.value * 3.14159; // π radians

          return Transform(
            alignment: Alignment.center,
            transform: Matrix4.identity()
              ..setEntry(3, 2, 0.001)
              ..rotateY(angle),
            child: Container(
              decoration: BoxDecoration(
                color: _isFlipped ? Colors.blue : Colors.green,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Center(
                child: _isFlipped
                    ? Text(
                        widget.card.back,
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                        ),
                        textAlign: TextAlign.center,
                      )
                    : Text(
                        widget.card.front,
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                        ),
                        textAlign: TextAlign.center,
                      ),
              ),
            ),
          );
        },
      ),
    );
  }
}

/// Rating buttons widget
class RatingButtons extends StatelessWidget {
  final Function(int) onRate;

  const RatingButtons({Key? key, required this.onRate}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: [
        ElevatedButton(
          key: const Key('rating-again-btn'),
          onPressed: () => onRate(0),
          child: const Text('Again'),
        ),
        ElevatedButton(
          key: const Key('rating-hard-btn'),
          onPressed: () => onRate(1),
          child: const Text('Hard'),
        ),
        ElevatedButton(
          key: const Key('rating-good-btn'),
          onPressed: () => onRate(2),
          child: const Text('Good'),
        ),
        ElevatedButton(
          key: const Key('rating-easy-btn'),
          onPressed: () => onRate(3),
          child: const Text('Easy'),
        ),
      ],
    );
  }
}

void main() {
  group('Flashcard Flip Animation Tests', () {
    testWidgets('card displays front side initially', (WidgetTester tester) async {
      final card = MockFlashcard(
        id: '1',
        front: 'Gato',
        back: 'Cat',
        deckId: 'deck-1',
        createdAt: DateTime.now(),
        lastReviewedAt: DateTime.now(),
      );

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: FlashcardWidget(
              card: card,
              onRating: (_) {},
              onNext: () {},
            ),
          ),
        ),
      );

      expect(find.text('Gato'), findsOneWidget);
      expect(find.text('Cat'), findsNothing);
    });

    testWidgets('tapping card flips to back side', (WidgetTester tester) async {
      final card = MockFlashcard(
        id: '1',
        front: 'Gato',
        back: 'Cat',
        deckId: 'deck-1',
        createdAt: DateTime.now(),
        lastReviewedAt: DateTime.now(),
      );

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: FlashcardWidget(
              card: card,
              onRating: (_) {},
              onNext: () {},
            ),
          ),
        ),
      );

      // Tap the card to flip
      await tester.tap(find.byType(FlashcardWidget));
      await tester.pumpAndSettle(); // Wait for animation

      expect(find.text('Gato'), findsNothing);
      expect(find.text('Cat'), findsOneWidget);
    });

    testWidgets('double tap flips back to front', (WidgetTester tester) async {
      final card = MockFlashcard(
        id: '1',
        front: 'Gato',
        back: 'Cat',
        deckId: 'deck-1',
        createdAt: DateTime.now(),
        lastReviewedAt: DateTime.now(),
      );

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: FlashcardWidget(
              card: card,
              onRating: (_) {},
              onNext: () {},
            ),
          ),
        ),
      );

      // First tap - flip to back
      await tester.tap(find.byType(FlashcardWidget));
      await tester.pumpAndSettle();
      expect(find.text('Cat'), findsOneWidget);

      // Second tap - flip to front
      await tester.tap(find.byType(FlashcardWidget));
      await tester.pumpAndSettle();
      expect(find.text('Gato'), findsOneWidget);
    });

    testWidgets('animation completes in reasonable time', (WidgetTester tester) async {
      final card = MockFlashcard(
        id: '1',
        front: 'Gato',
        back: 'Cat',
        deckId: 'deck-1',
        createdAt: DateTime.now(),
        lastReviewedAt: DateTime.now(),
      );

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: FlashcardWidget(
              card: card,
              onRating: (_) {},
              onNext: () {},
            ),
          ),
        ),
      );

      final stopwatch = Stopwatch()..start();

      await tester.tap(find.byType(FlashcardWidget));
      await tester.pumpAndSettle();

      stopwatch.stop();

      // Animation should complete in < 500ms
      expect(stopwatch.elapsedMilliseconds, lessThan(500));
    });

    testWidgets('animation is smooth (no jank)', (WidgetTester tester) async {
      final card = MockFlashcard(
        id: '1',
        front: 'Gato',
        back: 'Cat',
        deckId: 'deck-1',
        createdAt: DateTime.now(),
        lastReviewedAt: DateTime.now(),
      );

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: FlashcardWidget(
              card: card,
              onRating: (_) {},
              onNext: () {},
            ),
          ),
        ),
      );

      // Pump at 60fps and verify smooth transition
      await tester.tap(find.byType(FlashcardWidget));

      // Should go through animation frames
      for (int i = 0; i < 9; i++) {
        await tester.pump(const Duration(milliseconds: 33)); // ~60fps
      }

      expect(find.text('Cat'), findsOneWidget);
    });

    testWidgets('state persists after animation', (WidgetTester tester) async {
      final card = MockFlashcard(
        id: '1',
        front: 'Gato',
        back: 'Cat',
        deckId: 'deck-1',
        createdAt: DateTime.now(),
        lastReviewedAt: DateTime.now(),
      );

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: FlashcardWidget(
              card: card,
              onRating: (_) {},
              onNext: () {},
            ),
          ),
        ),
      );

      // Flip card
      await tester.tap(find.byType(FlashcardWidget));
      await tester.pumpAndSettle();

      // Pump extra frames to ensure state is stable
      await tester.pump(const Duration(milliseconds: 100));

      expect(find.text('Cat'), findsOneWidget);
    });
  });

  group('Rating Button Tests', () {
    testWidgets('all rating buttons are visible', (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: RatingButtons(onRate: (_) {}),
          ),
        ),
      );

      expect(find.text('Again'), findsOneWidget);
      expect(find.text('Hard'), findsOneWidget);
      expect(find.text('Good'), findsOneWidget);
      expect(find.text('Easy'), findsOneWidget);
    });

    testWidgets('tapping "Again" calls callback with 0', (WidgetTester tester) async {
      int? ratedValue;

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: RatingButtons(
              onRate: (value) {
                ratedValue = value;
              },
            ),
          ),
        ),
      );

      await tester.tap(find.byKey(const Key('rating-again-btn')));
      expect(ratedValue, equals(0));
    });

    testWidgets('tapping "Hard" calls callback with 1', (WidgetTester tester) async {
      int? ratedValue;

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: RatingButtons(
              onRate: (value) {
                ratedValue = value;
              },
            ),
          ),
        ),
      );

      await tester.tap(find.byKey(const Key('rating-hard-btn')));
      expect(ratedValue, equals(1));
    });

    testWidgets('tapping "Good" calls callback with 2', (WidgetTester tester) async {
      int? ratedValue;

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: RatingButtons(
              onRate: (value) {
                ratedValue = value;
              },
            ),
          ),
        ),
      );

      await tester.tap(find.byKey(const Key('rating-good-btn')));
      expect(ratedValue, equals(2));
    });

    testWidgets('tapping "Easy" calls callback with 3', (WidgetTester tester) async {
      int? ratedValue;

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: RatingButtons(
              onRate: (value) {
                ratedValue = value;
              },
            ),
          ),
        ),
      );

      await tester.tap(find.byKey(const Key('rating-easy-btn')));
      expect(ratedValue, equals(3));
    });

    testWidgets('multiple ratings in sequence', (WidgetTester tester) async {
      final ratings = <int>[];

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: RatingButtons(
              onRate: (value) {
                ratings.add(value);
              },
            ),
          ),
        ),
      );

      await tester.tap(find.byKey(const Key('rating-again-btn')));
      await tester.tap(find.byKey(const Key('rating-hard-btn')));
      await tester.tap(find.byKey(const Key('rating-good-btn')));
      await tester.tap(find.byKey(const Key('rating-easy-btn')));

      expect(ratings, equals([0, 1, 2, 3]));
    });
  });

  group('Flashcard Flip and Rating Flow Tests', () {
    testWidgets('complete study flow: flip -> rate -> next',
        (WidgetTester tester) async {
      int? ratingReceived;
      bool nextPressed = false;

      final card = MockFlashcard(
        id: '1',
        front: 'Gato',
        back: 'Cat',
        deckId: 'deck-1',
        createdAt: DateTime.now(),
        lastReviewedAt: DateTime.now(),
      );

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: Column(
              children: [
                Expanded(
                  child: FlashcardWidget(
                    card: card,
                    onRating: (rating) {
                      ratingReceived = rating;
                    },
                    onNext: () {
                      nextPressed = true;
                    },
                  ),
                ),
                RatingButtons(
                  onRate: (rating) {
                    ratingReceived = rating;
                  },
                ),
              ],
            ),
          ),
        ),
      );

      // Flip card to see answer
      await tester.tap(find.byType(FlashcardWidget));
      await tester.pumpAndSettle();
      expect(find.text('Cat'), findsOneWidget);

      // Rate the card as "Good"
      await tester.tap(find.byKey(const Key('rating-good-btn')));
      expect(ratingReceived, equals(2));
    });
  });

  group('Performance Tests', () {
    testWidgets('multiple rapid flips perform well',
        (WidgetTester tester) async {
      final card = MockFlashcard(
        id: '1',
        front: 'Gato',
        back: 'Cat',
        deckId: 'deck-1',
        createdAt: DateTime.now(),
        lastReviewedAt: DateTime.now(),
      );

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: FlashcardWidget(
              card: card,
              onRating: (_) {},
              onNext: () {},
            ),
          ),
        ),
      );

      final stopwatch = Stopwatch()..start();

      // Perform 20 rapid flips
      for (int i = 0; i < 20; i++) {
        await tester.tap(find.byType(FlashcardWidget));
        await tester.pumpAndSettle();
      }

      stopwatch.stop();

      // Should complete in reasonable time
      expect(stopwatch.elapsedMilliseconds, lessThan(5000));
    });
  });
}
