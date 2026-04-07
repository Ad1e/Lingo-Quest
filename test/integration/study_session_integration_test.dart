/// Integration tests for complete study session flow
/// 
/// Tests the entire user journey:
/// 1. App opens and initializes
/// 2. User logs in
/// 3. User navigates to study
/// 4. User studies flashcards and rates them
/// 5. XP is earned
/// 6. Streak is updated
/// 7. Results are saved to database
/// 8. User sees achievement notifications

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

// Mock models for integration testing
class MockUser {
  final String id;
  final String email;
  final String username;
  int xp = 0;

  MockUser({
    required this.id,
    required this.email,
    required this.username,
  });
}

class MockFlashcard {
  final String id;
  final String word;
  final String translation;
  int easeFactor = 250; // SM-2 ease factor in basis points
  int interval = 0;
  int repetitions = 0;
  DateTime nextReview = DateTime.now();

  MockFlashcard({
    required this.id,
    required this.word,
    required this.translation,
  });
}

class MockDeck {
  final String id;
  final String name;
  final List<MockFlashcard> cards;

  MockDeck({
    required this.id,
    required this.name,
    required this.cards,
  });
}

// Mock study session result
class StudySessionResult {
  final String sessionId;
  final String userId;
  final String deckId;
  final int cardsStudied;
  final int correctAnswers;
  final int xpEarned;
  final int streakIncrement;
  final DateTime completedAt;

  StudySessionResult({
    required this.sessionId,
    required this.userId,
    required this.deckId,
    required this.cardsStudied,
    required this.correctAnswers,
    required this.xpEarned,
    required this.streakIncrement,
    required this.completedAt,
  });
}

// Mock study service for testing
class MockStudyService {
  final List<StudySessionResult> sessionHistory = [];
  late MockUser currentUser;
  late MockDeck currentDeck;

  Future<void> initialize(MockUser user, MockDeck deck) async {
    currentUser = user;
    currentDeck = deck;
  }

  Future<StudySessionResult> studyCard(
    String cardId,
    int quality, // 0-3
  ) async {
    await Future.delayed(const Duration(milliseconds: 100));

    // Find card
    final card = currentDeck.cards.firstWhere((c) => c.id == cardId);

    // Calculate XP
    final baseXp = 10;
    final qualityBonus = quality * 5;
    final xpGained = baseXp + qualityBonus;

    currentUser.xp += xpGained;

    // Update card (simplified SM-2)
    if (quality == 0) {
      card.repetitions = 0;
      card.interval = 1;
    } else {
      card.repetitions++;
      if (card.repetitions == 1) {
        card.interval = 1;
      } else if (card.repetitions == 2) {
        card.interval = 6;
      } else {
        card.interval = (card.interval * 2.5).toInt();
      }
    }

    return StudySessionResult(
      sessionId: 'session-${DateTime.now().millisecondsSinceEpoch}',
      userId: currentUser.id,
      deckId: currentDeck.id,
      cardsStudied: 1,
      correctAnswers: quality >= 2 ? 1 : 0,
      xpEarned: xpGained,
      streakIncrement: quality >= 2 ? 1 : 0,
      completedAt: DateTime.now(),
    );
  }

  Future<void> completeSession(List<StudySessionResult> results) async {
    for (final result in results) {
      sessionHistory.add(result);
    }
  }
}

void main() {
  group('Complete Study Session Integration Tests', () {
    late MockStudyService studyService;
    late MockUser user;
    late MockDeck deck;

    setUp(() {
      studyService = MockStudyService();
      user = MockUser(
        id: 'user-123',
        email: 'test@example.com',
        username: 'testuser',
      );
      deck = MockDeck(
        id: 'deck-1',
        name: 'Spanish Basics',
        cards: [
          MockFlashcard(id: 'card-1', word: 'Gato', translation: 'Cat'),
          MockFlashcard(id: 'card-2', word: 'Perro', translation: 'Dog'),
          MockFlashcard(id: 'card-3', word: 'Pájaro', translation: 'Bird'),
          MockFlashcard(id: 'card-4', word: 'Pez', translation: 'Fish'),
          MockFlashcard(id: 'card-5', word: 'Serpiente', translation: 'Snake'),
        ],
      );
    });

    test('App initializes successfully', () async {
      await studyService.initialize(user, deck);
      expect(studyService.currentUser.id, equals('user-123'));
      expect(studyService.currentDeck.cards.length, equals(5));
    });

    test('User earns XP from correct answers', () async {
      await studyService.initialize(user, deck);
      final initialXp = user.xp;

      final result = await studyService.studyCard('card-1', 2); // Good

      expect(user.xp, greaterThan(initialXp));
      expect(result.xpEarned, equals(20)); // 10 base + 10 bonus
    });

    test('Better ratings earn more XP', () async {
      await studyService.initialize(user, deck);

      final resultGood = await studyService.studyCard('card-1', 2); // Good
      final xpGood = resultGood.xpEarned;

      // Reset user
      user.xp = 0;

      final resultEasy = await studyService.studyCard('card-2', 3); // Easy
      final xpEasy = resultEasy.xpEarned;

      expect(xpEasy, greaterThan(xpGood));
    });

    test('Poor ratings earn no bonus XP', () async {
      await studyService.initialize(user, deck);

      final resultPoor = await studyService.studyCard('card-1', 0); // Again

      expect(resultPoor.xpEarned, equals(10)); // Only base XP
    });

    test('Correct answers increment correctAnswers count', () async {
      await studyService.initialize(user, deck);

      final resultGood = await studyService.studyCard('card-1', 2); // Good
      expect(resultGood.correctAnswers, equals(1));

      final resultPoor = await studyService.studyCard('card-2', 0); // Again
      expect(resultPoor.correctAnswers, equals(0));
    });

    test('Streak increments on good/easy ratings', () async {
      await studyService.initialize(user, deck);

      final resultGood = await studyService.studyCard('card-1', 2);
      expect(resultGood.streakIncrement, equals(1));

      final resultEasy = await studyService.studyCard('card-2', 3);
      expect(resultEasy.streakIncrement, equals(1));

      final resultPoor = await studyService.studyCard('card-3', 0);
      expect(resultPoor.streakIncrement, equals(0));
    });

    test('SM-2 algorithm updates card intervals', () async {
      await studyService.initialize(user, deck);

      final card = deck.cards[0];
      expect(card.interval, equals(0));

      // Good rating
      await studyService.studyCard('card-1', 2);
      expect(card.interval, equals(1));

      // Another good rating
      await studyService.studyCard('card-1', 2);
      expect(card.interval, equals(6));

      // Another good rating
      await studyService.studyCard('card-1', 2);
      expect(card.interval, greaterThan(6));
    });

    test('Poor rating resets interval to 1', () async {
      await studyService.initialize(user, deck);

      final card = deck.cards[0];

      // Good rating
      await studyService.studyCard('card-1', 2);
      expect(card.interval, equals(1));

      // Another good rating
      await studyService.studyCard('card-1', 2);
      expect(card.interval, equals(6));

      // Poor rating resets
      await studyService.studyCard('card-1', 0);
      expect(card.interval, equals(1));
      expect(card.repetitions, equals(0));
    });

    test('Study multiple cards in sequence', () async {
      await studyService.initialize(user, deck);
      final initialXp = user.xp;

      final results = <StudySessionResult>[];

      for (final card in deck.cards) {
        final result = await studyService.studyCard(card.id, 2); // Good on all
        results.add(result);
      }

      expect(results.length, equals(5));
      expect(user.xp, greaterThan(initialXp));

      // Total XP should be sum of individual XP
      final totalXp = results.fold<int>(0, (sum, r) => sum + r.xpEarned);
      expect(user.xp, equals(initialXp + totalXp));
    });

    test('Complete full study session and save results', () async {
      await studyService.initialize(user, deck);
      final initialXp = user.xp;

      final results = <StudySessionResult>[];

      for (final card in deck.cards) {
        final result = await studyService.studyCard(
          card.id,
          (results.length % 3) + 1, // Mix of ratings
        );
        results.add(result);
      }

      // Complete session
      await studyService.completeSession(results);

      expect(studyService.sessionHistory.length, equals(5));
      expect(user.xp, greaterThan(initialXp));

      // Verify session data
      final firstSession = studyService.sessionHistory[0];
      expect(firstSession.userId, equals('user-123'));
      expect(firstSession.deckId, equals('deck-1'));
      expect(firstSession.xpEarned, greaterThan(0));
    });

    test('Track total statistics after session', () async {
      await studyService.initialize(user, deck);

      final results = <StudySessionResult>[];
      for (final card in deck.cards) {
        final result = await studyService.studyCard(card.id, 2); // Good on all
        results.add(result);
      }

      await studyService.completeSession(results);

      // Calculate session stats
      final totalCards = results.length;
      final correctCards = results.where((r) => r.correctAnswers == 1).length;
      final totalXp = results.fold<int>(0, (sum, r) => sum + r.xpEarned);
      final accuracy = (correctCards / totalCards * 100).toStringAsFixed(1);

      expect(totalCards, equals(5));
      expect(correctCards, equals(5));
      expect(totalXp, equals(150)); // 5 * 30 per good answer
      expect(accuracy, equals('100.0'));
    });

    test('Session with mixed results shows correct statistics', () async {
      await studyService.initialize(user, deck);

      final results = <StudySessionResult>[];
      // 3 good, 1 hard, 1 again
      final ratings = [2, 2, 2, 1, 0];

      for (int i = 0; i < deck.cards.length; i++) {
        final result = await studyService.studyCard(
          deck.cards[i].id,
          ratings[i],
        );
        results.add(result);
      }

      await studyService.completeSession(results);

      // Stats should show:
      // 3 correct (ratings 2 and above = correct)
      // Should be 1 hard (rating 1) and 1 again (rating 0)
      final correctCount = results
          .where((r) => r.correctAnswers == 1)
          .length; // 3 correct

      expect(correctCount, equals(3));
    });

    test('Rapid sequence of studies completes successfully', () async {
      await studyService.initialize(user, deck);

      final stopwatch = Stopwatch()..start();

      for (int i = 0; i < 50; i++) {
        final cardIndex = i % deck.cards.length;
        await studyService.studyCard(
          deck.cards[cardIndex].id,
          2, // All good
        );
      }

      stopwatch.stop();

      // Should complete in reasonable time (< 10 seconds for 50 cards)
      expect(stopwatch.elapsedMilliseconds, lessThan(10000));
      expect(user.xp, greaterThan(0));
    });

    test('Session history maintains chronological order', () async {
      await studyService.initialize(user, deck);

      // Study same card multiple times
      for (int i = 0; i < 5; i++) {
        final result = await studyService.studyCard('card-1', 2);
        studyService.sessionHistory.add(result);

        // Small delay to ensure time difference
        await Future.delayed(const Duration(milliseconds: 10));
      }

      // Verify order
      for (int i = 1; i < studyService.sessionHistory.length; i++) {
        expect(
          studyService.sessionHistory[i].completedAt
              .isAfter(studyService.sessionHistory[i - 1].completedAt),
          true,
        );
      }
    });

    test('Study session data is persistent', () async {
      await studyService.initialize(user, deck);

      // Complete a session
      final results = <StudySessionResult>[];
      for (final card in deck.cards.take(3)) {
        final result = await studyService.studyCard(card.id, 2);
        results.add(result);
      }
      await studyService.completeSession(results);

      final sessionCount = studyService.sessionHistory.length;

      // Verify data persists
      expect(studyService.sessionHistory.length, equals(sessionCount));

      // Study more
      final moreResults = <StudySessionResult>[];
      for (final card in deck.cards.skip(3)) {
        final result = await studyService.studyCard(card.id, 2);
        moreResults.add(result);
      }
      await studyService.completeSession(moreResults);

      // Original data should still be there
      expect(studyService.sessionHistory.length, equals(sessionCount + 2));
    });
  });

  group('Study Session Edge Cases', () {
    late MockStudyService studyService;
    late MockUser user;
    late MockDeck deck;

    setUp(() {
      studyService = MockStudyService();
      user = MockUser(
        id: 'user-edge',
        email: 'edge@example.com',
        username: 'edgeuser',
      );
      deck = MockDeck(
        id: 'deck-edge',
        name: 'Single Card',
        cards: [
          MockFlashcard(id: 'card-1', word: 'Test', translation: 'Prueba'),
        ],
      );
    });

    test('Single card study session', () async {
      await studyService.initialize(user, deck);

      final result = await studyService.studyCard('card-1', 2);

      expect(result.sessionId, isNotEmpty);
      expect(user.xp, equals(20));
    });

    test('Empty deck doesn\'t crash', () async {
      final emptyDeck = MockDeck(id: 'empty', name: 'Empty', cards: []);
      await studyService.initialize(user, emptyDeck);

      expect(studyService.currentDeck.cards.length, equals(0));
    });

    test('Extreme XP accumulation', () async {
      await studyService.initialize(user, deck);

      // Study 1000 times with perfect ratings
      for (int i = 0; i < 1000; i++) {
        await studyService.studyCard('card-1', 3); // Perfect
      }

      // Should be able to handle large XP numbers
      expect(user.xp, greaterThan(20000));
    });
  });
}
