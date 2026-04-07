class SpacedRepetitionAlgorithm {
  /// SM-2 Algorithm for spaced repetition
  /// Quality: 0=complete blackout, 1=incorrect, 2=correct with difficulty
  ///          3=correct with some difficulty, 4=perfect response
  
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
      newInterval = 3;
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