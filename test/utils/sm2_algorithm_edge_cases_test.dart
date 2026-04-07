/// Widget tests for SM-2 spaced repetition algorithm edge cases
/// 
/// Tests cover:
/// - Ease factor calculations
/// - Interval calculations
/// - Quality rating mappings
/// - Extreme ratings
/// - Large repetition counts
/// - Quality transitions

import 'package:flutter_test/flutter_test.dart';
import 'package:language_learning_app/data/models/flashcard_model.dart';
import 'package:language_learning_app/utils/spaced_repetition_algorithm.dart';

void main() {
  group('SM-2 Algorithm Tests', () {
    /// Sample flashcard for testing
    late FlashcardModel testCard;

    setUp(() {
      testCard = FlashcardModel(
        id: 'test-card',
        word: 'Gato',
        translation: 'Cat',
        language: 'es',
        easeFactor: 2.5,
        interval: 1,
        repetitions: 0,
        nextReviewDate: DateTime.now(),
      );
    });

    group('Ease Factor Calculations', () {
      test('ease factor decreases with poor quality (rating 0)', () {
        final updated = calculateNextReview(testCard, 0);
        expect(updated.easeFactor, lessThan(testCard.easeFactor));
      });

      test('ease factor increases with perfect quality (rating 3)', () {
        final updated = calculateNextReview(testCard, 3);
        expect(updated.easeFactor, greaterThan(testCard.easeFactor));
      });

      test('ease factor stays moderate with good quality (rating 2)', () {
        final updated = calculateNextReview(testCard, 2);
        expect(updated.easeFactor, lessThan(testCard.easeFactor + 0.2));
        expect(updated.easeFactor, greaterThan(testCard.easeFactor - 0.1));
      });

      test('ease factor never drops below 1.3 (SM-2 constraint)', () {
        var card = testCard;
        // Apply multiple poor ratings
        for (int i = 0; i < 10; i++) {
          card = calculateNextReview(card, 0);
        }
        expect(card.easeFactor, greaterThanOrEqualTo(1.3));
      });

      test('ease factor responds correctly to mixed ratings', () {
        var card = testCard;
        
        // Good rating
        card = calculateNextReview(card, 2);
        final afterGood = card.easeFactor;
        
        // Poor rating
        card = calculateNextReview(card, 0);
        final afterPoor = card.easeFactor;
        
        expect(afterPoor, lessThan(afterGood));
      });
    });

    group('Interval Calculations', () {
      test('first repetition has 1-day interval', () {
        final firstCard = testCard.copyWith(repetitions: 0);
        final updated = calculateNextReview(firstCard, 2);
        expect(updated.interval, equals(1));
        expect(updated.repetitions, equals(1));
      });

      test('second repetition has 6-day interval', () {
        final secondCard = testCard.copyWith(repetitions: 1);
        final updated = calculateNextReview(secondCard, 2);
        expect(updated.interval, equals(6));
        expect(updated.repetitions, equals(2));
      });

      test('third+ repetition multiplies by ease factor', () {
        var card = testCard.copyWith(
          repetitions: 2,
          interval: 6,
          easeFactor: 2.0,
        );
        final updated = calculateNextReview(card, 2);
        // Expected: 6 * 2.0 = 12
        expect(updated.interval, equals(12));
        expect(updated.repetitions, equals(3));
      });

      test('poor rating resets interval to 1 day', () {
        final card = testCard.copyWith(
          repetitions: 5,
          interval: 30,
        );
        final updated = calculateNextReview(card, 0);
        expect(updated.interval, equals(1));
        expect(updated.repetitions, equals(0));
      });

      test('high ease factor produces large intervals', () {
        var card = testCard.copyWith(easeFactor: 3.5);
        card = calculateNextReview(card, 2);
        card = calculateNextReview(card, 3); // Good rating
        card = calculateNextReview(card, 3); // Good rating
        
        final updated = calculateNextReview(card, 3);
        expect(updated.interval, greaterThan(50));
      });

      test('low ease factor produces small intervals', () {
        var card = testCard.copyWith(easeFactor: 1.3);
        card = calculateNextReview(card, 0); // Poor rating
        card = calculateNextReview(card, 0); // Poor rating
        
        final updated = calculateNextReview(card, 2);
        expect(updated.interval, lessThan(10));
      });
    });

    group('Quality Rating Validation', () {
      test('throws error on invalid low rating (-1)', () {
        expect(
          () => calculateNextReview(testCard, -1),
          throwsArgumentError,
        );
      });

      test('throws error on invalid high rating (4)', () {
        expect(
          () => calculateNextReview(testCard, 4),
          throwsArgumentError,
        );
      });

      test('accepts valid ratings 0-3', () {
        for (int rating = 0; rating <= 3; rating++) {
          expect(
            () => calculateNextReview(testCard, rating),
            returnsNormally,
          );
        }
      });
    });

    group('Next Review Date Calculations', () {
      test('next review date is in the future', () {
        final now = DateTime.now();
        final updated = calculateNextReview(testCard, 2);
        
        expect(
          updated.nextReviewDate.isAfter(now),
          true,
          reason: 'Next review date should be in the future',
        );
      });

      test('next review date increases with interval', () {
        final basicCard = testCard.copyWith(repetitions: 1, interval: 1);
        final advancedCard = testCard.copyWith(
          repetitions: 5,
          interval: 30,
          easeFactor: 2.5,
        );
        
        final basicUpdated = calculateNextReview(basicCard, 2);
        final advancedUpdated = calculateNextReview(advancedCard, 2);
        
        expect(
          advancedUpdated.nextReviewDate.isAfter(basicUpdated.nextReviewDate),
          true,
        );
      });

      test('next review date respects interval in days', () {
        final updated = calculateNextReview(testCard, 2);
        final expectedDays = updated.interval;
        
        final difference = updated.nextReviewDate.difference(DateTime.now()).inDays;
        // Allow 1 day tolerance for timing variations
        expect(difference, inInclusiveRange(expectedDays - 1, expectedDays + 1));
      });
    });

    group('Repetition Count Tracking', () {
      test('repetition count increments on correct response', () {
        var card = testCard;
        for (int i = 0; i < 5; i++) {
          final before = card.repetitions;
          card = calculateNextReview(card, 2); // Good rating
          expect(card.repetitions, equals(before + 1));
        }
      });

      test('repetition count resets to 0 on poor rating', () {
        var card = testCard.copyWith(repetitions: 10);
        final updated = calculateNextReview(card, 0);
        expect(updated.repetitions, equals(0));
      });

      test('repetition count handles large numbers (100+)', () {
        var card = testCard.copyWith(
          repetitions: 100,
          interval: 365,
          easeFactor: 3.0,
        );
        
        final updated = calculateNextReview(card, 2);
        expect(updated.repetitions, equals(101));
        expect(updated.interval, greaterThan(365));
      });
    });

    group('Algorithm Consistency', () {
      test('same input produces same output', () {
        final result1 = calculateNextReview(testCard, 2);
        final result2 = calculateNextReview(testCard, 2);
        
        expect(result1.easeFactor, equals(result2.easeFactor));
        expect(result1.interval, equals(result2.interval));
        expect(result1.repetitions, equals(result2.repetitions));
      });

      test('algorithm handles card state correctly', () {
        var card = testCard;
        
        // Simulate a study session
        card = calculateNextReview(card, 2); // Day 1: Good
        card = calculateNextReview(card, 3); // Day 7: Perfect
        card = calculateNextReview(card, 1); // Day 13: Hard
        
        expect(card.repetitions, equals(3));
        expect(card.easeFactor, greaterThanOrEqualTo(1.3));
        expect(card.interval, greaterThan(0));
      });

      test('poor ratings gradually increase interval again after reset', () {
        var card = testCard;
        
        // Poor rating resets
        card = calculateNextReview(card, 0);
        expect(card.interval, equals(1));
        
        // Gradually build back up
        card = calculateNextReview(card, 2);
        final afterFirst = card.interval;
        
        card = calculateNextReview(card, 2);
        final afterSecond = card.interval;
        
        expect(afterSecond, greaterThan(afterFirst));
      });
    });

    group('Quality Enum Mappings', () {
      test('Quality enum has correct values', () {
        expect(Quality.again.value, equals(0));
        expect(Quality.hard.value, equals(1));
        expect(Quality.good.value, equals(2));
        expect(Quality.easy.value, equals(3));
      });

      test('all Quality values are accessible', () {
        final qualities = Quality.values;
        expect(qualities.length, equals(4));
        expect(qualities, contains(Quality.again));
        expect(qualities, contains(Quality.hard));
        expect(qualities, contains(Quality.good));
        expect(qualities, contains(Quality.easy));
      });
    });
  });

  group('SM-2 Performance Tests', () {
    test('algorithm processes 1000 cards efficiently', () {
      final stopwatch = Stopwatch()..start();
      
      var card = FlashcardModel(
        id: 'test',
        word: 'test',
        translation: 'test',
        language: 'en',
        easeFactor: 2.5,
        interval: 1,
        repetitions: 0,
        nextReviewDate: DateTime.now(),
      );
      
      for (int i = 0; i < 1000; i++) {
        card = calculateNextReview(card, i % 4); // Cycle through ratings
      }
      
      stopwatch.stop();
      
      // Should complete in less than 100ms
      expect(stopwatch.elapsedMilliseconds, lessThan(100));
    });
  });
}
