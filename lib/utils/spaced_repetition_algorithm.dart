import 'package:language_learning_app/data/models/flashcard_model.dart';

/// SM-2 Spaced Repetition Algorithm
/// 
/// The SuperMemo-2 (SM-2) algorithm is used for optimizing the review schedule
/// of flashcards. It calculates the optimal review interval based on performance.
/// 
/// References: https://www.supermemo.com/en/archives1990-2015/english/ol/sm2copy.htm

/// Quality ratings for the SM-2 algorithm
/// - 0: Again (complete failure, forgot)
/// - 1: Hard (incorrect response, but upon reflection it's clear)
/// - 2: Good (correct response after some hesitation)
/// - 3: Easy (perfect response)
enum Quality { again, hard, good, easy }

extension QualityValue on Quality {
  int get value {
    switch (this) {
      case Quality.again:
        return 0;
      case Quality.hard:
        return 1;
      case Quality.good:
        return 2;
      case Quality.easy:
        return 3;
    }
  }
}

/// Calculates the next review date and updates flashcard parameters using SM-2
/// 
/// The SM-2 algorithm determines:
/// - Next review interval (in days)
/// - Ease factor (difficulty multiplier)
/// - Number of repetitions
/// 
/// Parameters:
///   - card: The flashcard to update
///   - rating: Quality of response (0=again, 1=hard, 2=good, 3=easy)
/// 
/// Returns:
///   Updated FlashcardModel with new review parameters
FlashcardModel calculateNextReview(FlashcardModel card, int rating) {
  if (rating < 0 || rating > 3) {
    throw ArgumentError('Rating must be between 0 and 3, got $rating');
  }

  final quality = Quality.values[rating];
  
  // Map 0-3 scale to SM-2 quality scale (0-5)
  // 0 -> 0 (complete failure)
  // 1 -> 1 (incorrect, but clear upon reflection)
  // 2 -> 4 (perfect response)
  // 3 -> 5 (perfect response with instant recall)
  final sm2Quality = _mapQualityToSM2Scale(quality);

  // Step 1: Calculate ease factor
  // EF' = EF + (0.1 - (5 - q) * (0.08 + (5 - q) * 0.02))
  final easeFactor = _calculateEaseFactor(
    currentEaseFactor: card.easeFactor,
    quality: sm2Quality,
  );

  // Step 2: Determine interval and repetitions
  int interval;
  int repetitions;

  if (quality == Quality.again) {
    // If quality is "again", reset repetitions and set interval to 1 day
    repetitions = 0;
    interval = 1;
  } else {
    // Increment repetitions
    repetitions = card.repetitions + 1;

    // Calculate interval based on repetitions
    if (repetitions == 1) {
      interval = 1; // First repetition: 1 day
    } else if (repetitions == 2) {
      interval = 6; // Second repetition: 6 days
    } else {
      // Subsequent repetitions: interval = previous_interval * ease_factor
      interval = (card.interval * easeFactor).round();
    }
  }

  // Step 3: Calculate next review date
  final nextReviewDate = DateTime.now().add(Duration(days: interval));

  // Return updated card
  return card.copyWith(
    easeFactor: easeFactor,
    interval: interval,
    repetitions: repetitions,
    nextReviewDate: nextReviewDate,
  );
}

/// Maps the 0-3 quality scale to SM-2's 0-5 scale
/// 
/// Quality mapping:
/// - 0 (again) -> 0 (complete failure)
/// - 1 (hard) -> 1 (incorrect, but clear upon reflection)
/// - 2 (good) -> 4 (perfect response)
/// - 3 (easy) -> 5 (perfect response with instant recall)
int _mapQualityToSM2Scale(Quality quality) {
  switch (quality) {
    case Quality.again:
      return 0;
    case Quality.hard:
      return 1;
    case Quality.good:
      return 4;
    case Quality.easy:
      return 5;
  }
}

/// Calculates the new ease factor based on SM-2 formula
/// 
/// Formula: EF' = EF + (0.1 - (5 - q) * (0.08 + (5 - q) * 0.02))
/// 
/// Where:
/// - EF is the current ease factor
/// - q is the quality of response (0-5)
/// - Result is clamped to minimum of 1.3
double _calculateEaseFactor({
  required double currentEaseFactor,
  required int quality,
}) {
  // Clamp quality to 0-5 range
  final q = quality.clamp(0, 5);
  
  // SM-2 ease factor formula
  final newEaseFactor = currentEaseFactor +
      (0.1 - (5 - q) * (0.08 + (5 - q) * 0.02));
  
  // Minimum ease factor is 1.3
  return newEaseFactor.clamp(1.3, double.infinity);
}

/// Calculates the optimal review interval for a card without updating it
/// 
/// Useful for previewing what the interval would be
int calculateInterval({
  required int repetitions,
  required double easeFactor,
  required int currentInterval,
}) {
  if (repetitions == 0) {
    return 1;
  } else if (repetitions == 1) {
    return 1;
  } else if (repetitions == 2) {
    return 6;
  } else {
    return (currentInterval * easeFactor).round();
  }
}

/// Generates a summary of the SM-2 update
String summarizeUpdate({
  required int oldRepetitions,
  required int newRepetitions,
  required double oldEaseFactor,
  required double newEaseFactor,
  required int oldInterval,
  required int newInterval,
}) {
  return '''
SM-2 Update Summary:
  Repetitions: $oldRepetitions → $newRepetitions
  Ease Factor: ${oldEaseFactor.toStringAsFixed(2)} → ${newEaseFactor.toStringAsFixed(2)}
  Interval: $oldInterval days → $newInterval days
  ''';
}

/// Statistics about a card's learning progress
class CardStats {
  final int totalReviews;
  final int totalRepetitions;
  final double currentEaseFactor;
  final int currentInterval;
  final int daysUntilNextReview;
  final DateTime? lastReviewDate;

  CardStats({
    required this.totalReviews,
    required this.totalRepetitions,
    required this.currentEaseFactor,
    required this.currentInterval,
    required this.daysUntilNextReview,
    this.lastReviewDate,
  });

  @override
  String toString() {
    return '''
CardStats:
  Total Reviews: $totalReviews
  Total Repetitions: $totalRepetitions
  Ease Factor: ${currentEaseFactor.toStringAsFixed(2)}
  Current Interval: $currentInterval days
  Days Until Next: $daysUntilNextReview
  Last Review: ${lastReviewDate?.toLocal()}
    ''';
  }
}

/// Gets statistics about a card's progress
CardStats getCardStats(FlashcardModel card) {
  final now = DateTime.now();
  final daysUntilNextReview =
      card.nextReviewDate.difference(now).inDays;

  return CardStats(
    totalReviews: card.repetitions,
    totalRepetitions: card.repetitions,
    currentEaseFactor: card.easeFactor,
    currentInterval: card.interval,
    daysUntilNextReview: daysUntilNextReview,
    lastReviewDate: card.lastReviewedAt,
  );
}

/// Legacy class for backward compatibility - wraps new implementation
class SpacedRepetitionAlgorithm {
  /// SM-2 Algorithm for spaced repetition (legacy wrapper)
  /// 
  /// Deprecated: Use `calculateNextReview(card, rating)` instead
  static Map<String, dynamic> calculateNextReview({
    required int quality,
    required int interval,
    required double easeFactor,
    required int repetitions,
  }) {
    // Ensure quality is between 0 and 5
    quality = quality.clamp(0, 5);

    double newEaseFactor = easeFactor +
        (0.1 - (5 - quality) * (0.08 + (5 - quality) * 0.02));

    // Ensure ease factor doesn't go below 1.3
    newEaseFactor = newEaseFactor < 1.3 ? 1.3 : newEaseFactor;

    int newInterval;
    int newRepetitions = repetitions;

    if (quality < 3) {
      // Failed - restart learning
      newInterval = 1;
      newRepetitions = 0;
    } else if (repetitions == 0) {
      newInterval = 1;
      newRepetitions = 1;
    } else if (repetitions == 1) {
      newInterval = 6; // Updated to 6 days per SM-2 spec
      newRepetitions = 2;
    } else {
      newInterval = (interval * newEaseFactor).ceil();
      newRepetitions = repetitions + 1;
    }

    return {
      'interval': newInterval,
      'easeFactor': newEaseFactor,
      'repetitions': newRepetitions,
      'nextReviewDate':
          DateTime.now().add(Duration(days: newInterval)),
      'isGraduated': newRepetitions > 10,
    };
  }

  /// Get cards due for review today
  static List<FlashcardModel> getCardsDueToday(
    List<FlashcardModel> cards,
  ) {
    final now = DateTime.now();
    return cards
        .where((card) =>
            card.nextReviewDate.isBefore(now) ||
            card.nextReviewDate.day == now.day)
        .toList();
  }

  /// Predict next review time
  static String formatNextReview(int days) {
    if (days == 0) return 'Today';
    if (days == 1) return 'Tomorrow';
    if (days < 7) return '$days days';
    if (days < 30) return '${(days / 7).floor()} weeks';
    if (days < 365) return '${(days / 30).floor()} months';
    return '${(days / 365).floor()} years';
  }
}