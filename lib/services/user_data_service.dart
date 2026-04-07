import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

/// Lightweight service for reading and writing user progress to Firestore.
/// All methods are safe – they return defaults on any error.
class UserDataService {
  static final _db   = FirebaseFirestore.instance;
  static final _auth = FirebaseAuth.instance;

  static String? get _uid => _auth.currentUser?.uid;

  // ── User document ──────────────────────────────────────────
  static DocumentReference? get _userDoc =>
      _uid != null ? _db.collection('users').doc(_uid) : null;

  /// Fetch user stats. Returns defaults for brand-new users.
  static Future<Map<String, dynamic>> getUserStats() async {
    try {
      if (_userDoc == null) return _defaultStats();
      final snap = await _userDoc!.get();
      if (!snap.exists) {
        // First login – initialise document
        await _userDoc!.set(_defaultStats());
        return _defaultStats();
      }
      final data = snap.data() as Map<String, dynamic>;
      return _defaultStats()..addAll(data); // merge so missing fields use defaults
    } catch (_) {
      return _defaultStats();
    }
  }

  static Map<String, dynamic> _defaultStats() => {
    'streakDays':     0,
    'totalXp':        0,
    'totalCards':     0,
    'lessonsCompleted': 0,
    'currentLevel':   1,
    'accuracy':       0,
    'selectedLanguage': null,
    'dailyGoalMin':   10,
    'level':          'Beginner',
  };

  /// Persist any field(s) to the user document (merge = true).
  static Future<void> updateStats(Map<String, dynamic> fields) async {
    try {
      await _userDoc?.set(fields, SetOptions(merge: true));
    } catch (_) {}
  }

  // ── Lessons ────────────────────────────────────────────────
  static Future<List<Map<String, dynamic>>> getLessons() async {
    try {
      final snap = await _db
          .collection('lessons')
          .orderBy('order')
          .get();
      if (snap.docs.isEmpty) return _defaultLessons();
      return snap.docs.map((d) => {'id': d.id, ...d.data()}).toList();
    } catch (_) {
      return _defaultLessons();
    }
  }

  /// Get this user's progress for a specific lesson.
  static Future<double> getLessonProgress(String lessonId) async {
    try {
      if (_uid == null) return 0;
      final doc = await _db
          .collection('users')
          .doc(_uid)
          .collection('lessonProgress')
          .doc(lessonId)
          .get();
      return (doc.data()?['progress'] as num?)?.toDouble() ?? 0;
    } catch (_) {
      return 0;
    }
  }

  // ── Flashcard decks ────────────────────────────────────────
  static Future<List<Map<String, dynamic>>> getFlashcardDecks() async {
    try {
      if (_uid == null) return [];
      final snap = await _db
          .collection('users')
          .doc(_uid)
          .collection('flashcardDecks')
          .get();
      return snap.docs.map((d) => {'id': d.id, ...d.data()}).toList();
    } catch (_) {
      return [];
    }
  }

  // ── Onboarding save ────────────────────────────────────────
  static Future<void> saveOnboarding({
    required String language,
    required int dailyGoalMin,
    required String level,
  }) async {
    await updateStats({
      'selectedLanguage': language,
      'dailyGoalMin':     dailyGoalMin,
      'level':            level,
    });
  }

  // ── Static fallback lessons ────────────────────────────────
  static List<Map<String, dynamic>> _defaultLessons() => [
    {'id': 'l1', 'order': 1, 'title': 'Greetings & Numbers',  'tag': 'Beginner',     'locked': false},
    {'id': 'l2', 'order': 2, 'title': 'Colors & Shapes',      'tag': 'Beginner',     'locked': false},
    {'id': 'l3', 'order': 3, 'title': 'Food & Drinks',        'tag': 'Beginner',     'locked': false},
    {'id': 'l4', 'order': 4, 'title': 'Family & Friends',     'tag': 'Intermediate', 'locked': true},
    {'id': 'l5', 'order': 5, 'title': 'Travel Phrases',       'tag': 'Intermediate', 'locked': true},
    {'id': 'l6', 'order': 6, 'title': 'At the Hotel',         'tag': 'Intermediate', 'locked': true},
    {'id': 'l7', 'order': 7, 'title': 'Shopping',             'tag': 'Advanced',     'locked': true},
    {'id': 'l8', 'order': 8, 'title': 'Directions',           'tag': 'Advanced',     'locked': true},
  ];
}
