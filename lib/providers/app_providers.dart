// lib/providers/app_providers.dart
//
// Single source of truth for all Riverpod providers.
// Datasources → Repositories → UseCases, all lazily instantiated.

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:language_learning_app/data/datasources/local/flashcard_local_ds.dart';
import 'package:language_learning_app/data/datasources/local/progress_local_ds.dart';
import 'package:language_learning_app/data/datasources/remote/cloud_functions_ds.dart';
import 'package:language_learning_app/data/datasources/remote/flashcard_remote_ds.dart';
import 'package:language_learning_app/data/datasources/remote/lesson_remote_ds.dart';
import 'package:language_learning_app/data/repositories/auth_repository_impl.dart';
import 'package:language_learning_app/data/repositories/flashcard_repository_impl.dart';
import 'package:language_learning_app/data/repositories/lesson_repository_impl.dart';
import 'package:language_learning_app/data/repositories/progress_repository_impl.dart';
import 'package:language_learning_app/domain/repositories/auth_repository.dart';
import 'package:language_learning_app/domain/repositories/flashcard_repository.dart';
import 'package:language_learning_app/domain/repositories/lesson_repository.dart';
import 'package:language_learning_app/domain/repositories/progress_repository.dart';
import 'package:language_learning_app/data/datasources/local/database_helper.dart';
import 'package:language_learning_app/domain/usecases/get_flashcards_usecase.dart';
import 'package:language_learning_app/domain/usecases/get_user_stats_usecase.dart';
import 'package:language_learning_app/domain/usecases/study_flashcard_usecase.dart';

// ─────────────────────────────────────────────
// Firebase singletons
// ─────────────────────────────────────────────

final firebaseAuthProvider = Provider<FirebaseAuth>(
  (ref) => FirebaseAuth.instance,
);

final firestoreProvider = Provider<FirebaseFirestore>(
  (ref) => FirebaseFirestore.instance,
);

// ─────────────────────────────────────────────
// Local datasources
// ─────────────────────────────────────────────

final flashcardLocalDsProvider = Provider<FlashcardLocalDataSource>(
  (ref) => FlashcardLocalDataSourceImpl(),
);

final progressLocalDsProvider = Provider<ProgressLocalDataSource>(
  (ref) => ProgressLocalDataSourceImpl(),
);

// ─────────────────────────────────────────────
// Remote datasources
// ─────────────────────────────────────────────

final flashcardRemoteDsProvider = Provider<FlashcardRemoteDataSource>(
  (ref) => FlashcardRemoteDataSourceImpl(
    ref.watch(firestoreProvider),
  ),
);

final lessonRemoteDsProvider = Provider<LessonRemoteDataSource>(
  (ref) => LessonRemoteDataSourceImpl(
    ref.watch(firestoreProvider),
  ),
);

final cloudFunctionsDsProvider = Provider<CloudFunctionsDataSource>(
  (ref) => CloudFunctionsDataSourceImpl(),
);

// ─────────────────────────────────────────────
// Local DB helper (Drift)
// ─────────────────────────────────────────────

final databaseHelperProvider = Provider<DatabaseHelper>(
  (ref) => DatabaseHelper(),
);

// ─────────────────────────────────────────────
// Repositories
// ─────────────────────────────────────────────

final authRepositoryProvider = Provider<AuthRepository>(
  (ref) => AuthRepositoryImpl(ref.watch(firebaseAuthProvider)),
);

final flashcardRepositoryProvider = Provider<FlashcardRepository>(
  (ref) => FlashcardRepositoryImpl(
    ref.watch(flashcardLocalDsProvider),
    ref.watch(flashcardRemoteDsProvider),
    ref.watch(databaseHelperProvider),
  ),
);

final lessonRepositoryProvider = Provider<LessonRepository>(
  (ref) => LessonRepositoryImpl(
    ref.watch(databaseHelperProvider),
    ref.watch(lessonRemoteDsProvider),
  ),
);

final progressRepositoryProvider = Provider<ProgressRepository>(
  (ref) => ProgressRepositoryImpl(
    ref.watch(progressLocalDsProvider),
    ref.watch(cloudFunctionsDsProvider),
    ref.watch(databaseHelperProvider),
  ),
);

// ─────────────────────────────────────────────
// Use cases
// ─────────────────────────────────────────────

final studyFlashcardUseCaseProvider = Provider<StudyFlashcardUseCase>(
  (ref) => StudyFlashcardUseCaseImpl(
    ref.watch(flashcardRepositoryProvider),
    ref.watch(progressRepositoryProvider),
  ),
);

final getFlashcardsUseCaseProvider = Provider<GetFlashcardsUseCase>(
  (ref) => GetFlashcardsUseCaseImpl(
    ref.watch(flashcardRepositoryProvider),
  ),
);

final getUserStatsUseCaseProvider = Provider<GetUserStatsUseCase>(
  (ref) => GetUserStatsUseCaseImpl(
    ref.watch(progressRepositoryProvider),
  ),
);
