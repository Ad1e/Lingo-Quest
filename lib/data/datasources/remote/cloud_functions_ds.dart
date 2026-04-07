import 'package:http/http.dart' as http;
import 'package:injectable/injectable.dart';
import 'dart:convert';
import 'package:firebase_auth/firebase_auth.dart';

/// Abstract interface for Cloud Functions data source
abstract class CloudFunctionsDataSource {
  /// Generate lesson content using AI
  Future<GeneratedLessonContent> generateLessonContent({
    required String topic,
    required String level,
    required String language,
  });

  /// Generate vocabulary from text
  Future<List<VocabularyItem>> generateVocabularyFromText({
    required String text,
    required String language,
  });

  /// Get leaderboard data
  Future<LeaderboardData> getLeaderboard({
    required String timeframe,
    required String region,
    int limit = 100,
  });

  /// Get user rank
  Future<UserRankData> getUserRank({
    required String userId,
    required String timeframe,
  });

  /// Analyze pronunciation
  Future<PronunciationAnalysis> analyzePronunciation({
    required String audioUrl,
    required String word,
    required String language,
  });

  /// Check streak milestone
  Future<StreakMilestoneResult> checkStreakMilestone({
    required String userId,
    required int currentStreak,
  });
}

/// Generated lesson content model
class GeneratedLessonContent {
  final String id;
  final String title;
  final String grammarExplanation;
  final List<VocabularyItem> vocabulary;
  final List<Exercise> exercises;

  GeneratedLessonContent({
    required this.id,
    required this.title,
    required this.grammarExplanation,
    required this.vocabulary,
    required this.exercises,
  });

  factory GeneratedLessonContent.fromJson(Map<String, dynamic> json) =>
      GeneratedLessonContent(
        id: json['id'] as String,
        title: json['title'] as String,
        grammarExplanation: json['grammarExplanation'] as String,
        vocabulary: (json['vocabulary'] as List?)
                ?.map((v) => VocabularyItem.fromJson(v))
                .toList() ??
            [],
        exercises: (json['exercises'] as List?)
                ?.map((e) => Exercise.fromJson(e))
                .toList() ??
            [],
      );
}

/// Vocabulary item model
class VocabularyItem {
  final String word;
  final String translation;
  final String partOfSpeech;
  final String exampleSentence;
  final String audioUrl;

  VocabularyItem({
    required this.word,
    required this.translation,
    required this.partOfSpeech,
    required this.exampleSentence,
    required this.audioUrl,
  });

  factory VocabularyItem.fromJson(Map<String, dynamic> json) =>
      VocabularyItem(
        word: json['word'] as String,
        translation: json['translation'] as String,
        partOfSpeech: json['partOfSpeech'] as String,
        exampleSentence: json['exampleSentence'] as String,
        audioUrl: json['audioUrl'] as String,
      );
}

/// Exercise model
class Exercise {
  final String id;
  final String type;
  final String question;
  final List<String> options;
  final String correctAnswer;

  Exercise({
    required this.id,
    required this.type,
    required this.question,
    required this.options,
    required this.correctAnswer,
  });

  factory Exercise.fromJson(Map<String, dynamic> json) => Exercise(
    id: json['id'] as String,
    type: json['type'] as String,
    question: json['question'] as String,
    options: List<String>.from(json['options'] as List? ?? []),
    correctAnswer: json['correctAnswer'] as String,
  );
}

/// Leaderboard data model
class LeaderboardData {
  final List<LeaderboardEntry> entries;
  final DateTime generatedAt;

  LeaderboardData({
    required this.entries,
    required this.generatedAt,
  });

  factory LeaderboardData.fromJson(Map<String, dynamic> json) =>
      LeaderboardData(
        entries: (json['entries'] as List?)
                ?.map((e) => LeaderboardEntry.fromJson(e))
                .toList() ??
            [],
        generatedAt: DateTime.parse(json['generatedAt'] as String),
      );
}

/// Leaderboard entry model
class LeaderboardEntry {
  final int rank;
  final String userId;
  final String username;
  final int xp;
  final int level;
  final String? avatarUrl;

  LeaderboardEntry({
    required this.rank,
    required this.userId,
    required this.username,
    required this.xp,
    required this.level,
    this.avatarUrl,
  });

  factory LeaderboardEntry.fromJson(Map<String, dynamic> json) =>
      LeaderboardEntry(
        rank: json['rank'] as int,
        userId: json['userId'] as String,
        username: json['username'] as String,
        xp: json['xp'] as int,
        level: json['level'] as int,
        avatarUrl: json['avatarUrl'] as String?,
      );
}

/// User rank data model
class UserRankData {
  final int rank;
  final int totalUsers;
  final int xp;
  final int level;

  UserRankData({
    required this.rank,
    required this.totalUsers,
    required this.xp,
    required this.level,
  });

  factory UserRankData.fromJson(Map<String, dynamic> json) => UserRankData(
    rank: json['rank'] as int,
    totalUsers: json['totalUsers'] as int,
    xp: json['xp'] as int,
    level: json['level'] as int,
  );
}

/// Pronunciation analysis model
class PronunciationAnalysis {
  final double confidence;
  final double accuracy;
  final String feedback;
  final List<String> suggestions;

  PronunciationAnalysis({
    required this.confidence,
    required this.accuracy,
    required this.feedback,
    required this.suggestions,
  });

  factory PronunciationAnalysis.fromJson(Map<String, dynamic> json) =>
      PronunciationAnalysis(
        confidence: (json['confidence'] as num).toDouble(),
        accuracy: (json['accuracy'] as num).toDouble(),
        feedback: json['feedback'] as String,
        suggestions: List<String>.from(json['suggestions'] as List? ?? []),
      );
}

/// Streak milestone result model
class StreakMilestoneResult {
  final bool isMilestone;
  final String? milestone;
  final int xpReward;
  final String? achievementUnlocked;

  StreakMilestoneResult({
    required this.isMilestone,
    this.milestone,
    required this.xpReward,
    this.achievementUnlocked,
  });

  factory StreakMilestoneResult.fromJson(Map<String, dynamic> json) =>
      StreakMilestoneResult(
        isMilestone: json['isMilestone'] as bool,
        milestone: json['milestone'] as String?,
        xpReward: json['xpReward'] as int? ?? 0,
        achievementUnlocked: json['achievementUnlocked'] as String?,
      );
}

/// Implementation of CloudFunctionsDataSource using HTTP
@Singleton(as: CloudFunctionsDataSource)
class CloudFunctionsDataSourceImpl implements CloudFunctionsDataSource {
  static const String _projectId = 'YOUR_FIREBASE_PROJECT_ID';
  static const String _region = 'us-central1';
  final String _baseUrl = 'https://$_region-$_projectId.cloudfunctions.net';

  Future<String> _getAuthToken() async {
    final user = FirebaseAuth.instance.currentUser;
    return user?.getIdToken() ?? '';
  }

  Future<T> _callFunction<T>(
    String functionName,
    Map<String, dynamic> payload,
    T Function(dynamic) parser,
  ) async {
    try {
      final token = await _getAuthToken();
      final response = await http.post(
        Uri.parse('$_baseUrl/$functionName'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
        body: jsonEncode(payload),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        return parser(data);
      } else {
        throw Exception(
          'Function call failed: ${response.statusCode} - ${response.body}',
        );
      }
    } catch (e) {
      throw Exception('Cloud function error: $e');
    }
  }

  @override
  Future<GeneratedLessonContent> generateLessonContent({
    required String topic,
    required String level,
    required String language,
  }) =>
      _callFunction(
        'generateLessonContent',
        {'topic': topic, 'level': level, 'language': language},
        (data) => GeneratedLessonContent.fromJson(data),
      );

  @override
  Future<List<VocabularyItem>> generateVocabularyFromText({
    required String text,
    required String language,
  }) =>
      _callFunction(
        'generateVocabularyFromText',
        {'text': text, 'language': language},
        (data) =>
            (data as List).map((v) => VocabularyItem.fromJson(v)).toList(),
      );

  @override
  Future<LeaderboardData> getLeaderboard({
    required String timeframe,
    required String region,
    int limit = 100,
  }) =>
      _callFunction(
        'getLeaderboard',
        {'timeframe': timeframe, 'region': region, 'limit': limit},
        (data) => LeaderboardData.fromJson(data),
      );

  @override
  Future<UserRankData> getUserRank({
    required String userId,
    required String timeframe,
  }) =>
      _callFunction(
        'getUserRank',
        {'userId': userId, 'timeframe': timeframe},
        (data) => UserRankData.fromJson(data),
      );

  @override
  Future<PronunciationAnalysis> analyzePronunciation({
    required String audioUrl,
    required String word,
    required String language,
  }) =>
      _callFunction(
        'analyzePronunciation',
        {'audioUrl': audioUrl, 'word': word, 'language': language},
        (data) => PronunciationAnalysis.fromJson(data),
      );

  @override
  Future<StreakMilestoneResult> checkStreakMilestone({
    required String userId,
    required int currentStreak,
  }) =>
      _callFunction(
        'checkStreakMilestone',
        {'userId': userId, 'currentStreak': currentStreak},
        (data) => StreakMilestoneResult.fromJson(data),
      );
}
