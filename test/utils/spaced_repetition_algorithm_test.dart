import 'package:flutter_test/flutter_test.dart';
import 'package:language_learning_app/data/models/flashcard_model.dart';
import 'package:language_learning_app/utils/spaced_repetition_algorithm.dart';

void main() {
  group('SM-2 Spaced Repetition Algorithm', () {
    late FlashcardModel baseCard;

    setUp(() {
      // Create a base flashcard for testing
      baseCard = FlashcardModel(
        id: 'test-card-1',
        front: 'What is the capital of France?',
        back: 'Paris',
        audioUrl: null,
        exampleSentence: null,
        deckId: 'test-deck',
        nextReviewDate: DateTime.now(),
        easeFactor: 2.5,
        interval: 0,
        repetitions: 0,
        createdAt: DateTime.now(),
        lastReviewedAt: DateTime.now(),
      );
    });

    group('First repetition (repetitions = 0)', () {
      test('Rating 0 (again) - resets and sets 1 day interval', () {
        final updated = calculateNextReview(baseCard, 0);

        expect(updated.repetitions, 0);
        expect(updated.interval, 1);
        expect(updated.easeFactor, lessThan(baseCard.easeFactor));
        expect(updated.nextReviewDate.isAfter(DateTime.now()), true);
      });

      test('Rating 1 (hard) - first repetition with 1 day interval', () {
        final updated = calculateNextReview(baseCard, 1);

        expect(updated.repetitions, 1);
        expect(updated.interval, 1);
        expect(updated.easeFactor, lessThan(baseCard.easeFactor));
      });

      test('Rating 2 (good) - first repetition with 1 day interval', () {
        final updated = calculateNextReview(baseCard, 2);

        expect(updated.repetitions, 1);
        expect(updated.interval, 1);
        // Ease factor should stay similar or increase slightly
        expect(updated.easeFactor, greaterThanOrEqualTo(1.3));
      });

      test('Rating 3 (easy) - first repetition with 1 day interval', () {
        final updated = calculateNextReview(baseCard, 3);

        expect(updated.repetitions, 1);
        expect(updated.interval, 1);
        // Ease factor should increase for easy response
        expect(updated.easeFactor, greaterThanOrEqualTo(baseCard.easeFactor));
      });
    });

    group('Second repetition (repetitions = 1)', () {
      late FlashcardModel secondCard;

      setUp(() {
        secondCard = baseCard.copyWith(repetitions: 1, interval: 1);
      });

      test('Rating 0 (again) - resets to first repeat', () {
        final updated = calculateNextReview(secondCard, 0);

        expect(updated.repetitions, 0);
        expect(updated.interval, 1);
        expect(updated.easeFactor, lessThan(2.5));
      });

      test('Rating 1 (hard) - 6 day interval', () {
        final updated = calculateNextReview(secondCard, 1);

        expect(updated.repetitions, 2);
        expect(updated.interval, 6);
      });

      test('Rating 2 (good) - 6 day interval', () {
        final updated = calculateNextReview(secondCard, 2);

        expect(updated.repetitions, 2);
        expect(updated.interval, 6);
      });

      test('Rating 3 (easy) - 6 day interval', () {
        final updated = calculateNextReview(secondCard, 3);

        expect(updated.repetitions, 2);
        expect(updated.interval, 6);
      });
    });

    group('Subsequent repetitions (repetitions >= 2)', () {
      late FlashcardModel thirdCard;

      setUp(() {
        thirdCard = baseCard.copyWith(
          repetitions: 2,
          interval: 6,
          easeFactor: 2.5,
        );
      });

      test('Rating 0 (again) - resets to start', () {
        final updated = calculateNextReview(thirdCard, 0);

        expect(updated.repetitions, 0);
        expect(updated.interval, 1);
      });

      test('Rating 1 (hard) - interval * easeFactor', () {
        final updated = calculateNextReview(thirdCard, 1);

        expect(updated.repetitions, 3);
        final expectedInterval = (6 * 1.96).round();
        expect(updated.interval, expectedInterval);
      });

      test('Rating 2 (good) - interval multiplied by adjusted easeFactor', () {
        final updated = calculateNextReview(thirdCard, 2);

        expect(updated.repetitions, 3);
        final expectedInterval = (6 * updated.easeFactor).round();
        expect(updated.interval, expectedInterval);
      });

      test('Rating 3 (easy) - interval multiplied by increased easeFactor', () {
        final updated = calculateNextReview(thirdCard, 3);

        expect(updated.repetitions, 3);
        expect(updated.easeFactor, greaterThan(2.5));
        final expectedInterval = (6 * updated.easeFactor).round();
        expect(updated.interval, expectedInterval);
      });
    });

    group('Ease factor calculation', () {
      late FlashcardModel cardWithHighEF;
      late FlashcardModel cardWithLowEF;

      setUp(() {
        cardWithHighEF = baseCard.copyWith(easeFactor: 3.0);
        cardWithLowEF = baseCard.copyWith(easeFactor: 1.3);
      });

      test('Easy response increases ease factor', () {
        final updated = calculateNextReview(baseCard, 3);
        expect(updated.easeFactor, greaterThan(baseCard.easeFactor));
      });

      test('Again response decreases ease factor', () {
        final updated = calculateNextReview(baseCard, 0);
        expect(updated.easeFactor, lessThan(baseCard.easeFactor));
      });

      test('Hard response decreases ease factor', () {
        final updated = calculateNextReview(baseCard, 1);
        expect(updated.easeFactor, lessThan(baseCard.easeFactor));
      });

      test('Good response maintains or slightly increases ease factor', () {
        final updated = calculateNextReview(baseCard, 2);
        expect(updated.easeFactor, greaterThanOrEqualTo(1.3));
      });

      test('Ease factor has minimum of 1.3', () {
        final cardWithVeryLowEF = baseCard.copyWith(easeFactor: 1.3);
        final updated = calculateNextReview(cardWithVeryLowEF, 0);
        expect(updated.easeFactor, greaterThanOrEqualTo(1.3));
      });

      test('Multiple failures gradually decrease ease factor', () {
        var card = baseCard;
        for (int i = 0; i < 5; i++) {
          card = calculateNextReview(card, 0);
        }
        expect(card.easeFactor, greaterThanOrEqualTo(1.3));
      });
    });

    group('Review date calculation', () {
      test('Next review date is in the future', () {
        final now = DateTime.now();
        final updated = calculateNextReview(baseCard, 2);
        expect(updated.nextReviewDate.isAfter(now), true);
      });

      test('Next review date reflects the interval', () {
        final now = DateTime.now();
        final updated = calculateNextReview(baseCard, 2);
        final differenceInDays = updated.nextReviewDate.difference(now).inDays;
        expect(differenceInDays, 1); // First repetition is 1 day
      });

      test('Second repetition review date is 6 days away', () {
        final card = baseCard.copyWith(repetitions: 1, interval: 1);
        final now = DateTime.now();
        final updated = calculateNextReview(card, 2);
        final differenceInDays = updated.nextReviewDate.difference(now).inDays;
        expect(differenceInDays, 6);
      });

      test('Review date after reset is 1 day away', () {
        final card = FlashcardModel(
          id: 'test',
          front: 'test',
          back: 'test',
          audioUrl: null,
          exampleSentence: null,
          deckId: 'deck',
          nextReviewDate: DateTime.now().add(Duration(days: 30)),
          easeFactor: 3.0,
          interval: 30,
          repetitions: 10,
          createdAt: DateTime.now(),
          lastReviewedAt: DateTime.now(),
        );
        final now = DateTime.now();
        final updated = calculateNextReview(card, 0); // Reset
        final differenceInDays = updated.nextReviewDate.difference(now).inDays;
        expect(differenceInDays, 1);
      });
    });

    group('Edge cases and validation', () {
      test('Invalid rating throws ArgumentError', () {
        expect(
          () => calculateNextReview(baseCard, -1),
          throwsArgumentError,
        );
        expect(
          () => calculateNextReview(baseCard, 4),
          throwsArgumentError,
        );
      });

      test('Card with many repetitions uses exponential growth', () {
        var card = baseCard;
        var previousInterval = 0;

        for (int i = 0; i < 10; i++) {
          card = calculateNextReview(card, 3); // Always easy
          expect(card.interval, greaterThan(previousInterval));
          previousInterval = card.interval;
        }
      });

      test('Alternating good and hard maintains reasonable intervals', () {
        var card = baseCard;

        for (int i = 0; i < 5; i++) {
          card = calculateNextReview(card, 2); // Good
          card = calculateNextReview(card, 1); // Hard
        }

        expect(card.easeFactor, greaterThanOrEqualTo(1.3));
        expect(card.repetitions, greaterThan(0));
      });

      test('Card immutability - original card not modified', () {
        final original = baseCard;
        calculateNextReview(original, 3);

        expect(original.repetitions, 0);
        expect(original.interval, 0);
        expect(original.easeFactor, 2.5);
      });
    });

    group('Statistics helper', () {
      test('Card stats calculates days until next review', () {
        final card = baseCard.copyWith(
          nextReviewDate: DateTime.now().add(Duration(days: 5)),
          repetitions: 3,
          easeFactor: 2.8,
          interval: 6,
        );

        final stats = getCardStats(card);

        expect(stats.totalRepetitions, 3);
        expect(stats.currentEaseFactor, 2.8);
        expect(stats.currentInterval, 6);
        expect(stats.daysUntilNextReview, 5);
      });

      test('Card stats string representation', () {
        final card = baseCard.copyWith(repetitions: 2);
        final stats = getCardStats(card);
        final statsString = stats.toString();

        expect(statsString.contains('CardStats'), true);
        expect(statsString.contains('Total Repetitions: 2'), true);
      });
    });

    group('Integration tests - learning progression', () {
      test('Typical learning progression - new card', () {
        var card = baseCard;

        // Day 1: First review - mark as good
        card = calculateNextReview(card, 2);
        expect(card.repetitions, 1);
        expect(card.interval, 1);

        // Day 2: Second review - mark as good
        card = calculateNextReview(card, 2);
        expect(card.repetitions, 2);
        expect(card.interval, 6);

        // Day 8: Third review - mark as easy
        card = calculateNextReview(card, 3);
        expect(card.repetitions, 3);
        expect(card.interval, greaterThan(6));
        expect(card.easeFactor, greaterThan(2.5));
      });

      test('Difficult card - keeps resetting', () {
        var card = baseCard;
        var resetCount = 0;

        for (int i = 0; i < 3; i++) {
          card = calculateNextReview(card, 0); // Always again
          if (card.repetitions == 0) resetCount++;
        }

        expect(resetCount, 3);
        expect(card.easeFactor, lessThan(baseCard.easeFactor));
        expect(card.interval, 1);
      });

      test('Easy card - exponential interval growth', () {
        var card = baseCard;
        var intervals = <int>[];

        for (int i = 0; i < 8; i++) {
          card = calculateNextReview(card, 3); // Always easy
          intervals.add(card.interval);
        }

        // Intervals should be: 1, 6, 15+, ...
        expect(intervals[0], 1);
        expect(intervals[1], 6);
        expect(intervals[2], greaterThan(10));

        // Each interval should be roughly multiplying by easeFactor
        for (int i = 2; i < intervals.length; i++) {
          expect(
            intervals[i],
            greaterThan(intervals[i - 1]),
          );
        }
      });
    });

    group('Quality enum and extensions', () {
      test('Quality.again has value 0', () {
        expect(Quality.again.value, 0);
      });

      test('Quality.hard has value 1', () {
        expect(Quality.hard.value, 1);
      });

      test('Quality.good has value 2', () {
        expect(Quality.good.value, 2);
      });

      test('Quality.easy has value 3', () {
        expect(Quality.easy.value, 3);
      });
    });
  });
}
