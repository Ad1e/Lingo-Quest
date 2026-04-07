import 'package:injectable/injectable.dart';
import 'package:get_it/get_it.dart';

/// Dependency Injection Module Configuration
/// This file contains the setup for all injectable modules

/// Local Storage Module
@module
abstract class LocalStorageModule {
  // TODO: Add local storage singletons here
  // @singleton
  // Future<Database> getDatabase() async {
  //   // Initialize Local Database
  // }
  
  // @singleton
  // Future<HiveService> getHiveService() async {
  //   // Initialize Hive
  // }
}

/// Firebase Module
@module
abstract class FirebaseModule {
  // TODO: Add Firebase singletons here
  // @singleton
  // Future<FirebaseAuth> getFirebaseAuth() async {
  //   // Initialize Firebase Auth
  // }
  
  // @singleton
  // Future<FirebaseFirestore> getFirebaseFirestore() async {
  //   // Initialize Firestore
  // }
  
  // @singleton
  // Future<FirebaseStorage> getFirebaseStorage() async {
  //   // Initialize Storage
  // }
}

/// API and Network Module
@module
abstract class NetworkModule {
  // TODO: Add network singletons here
  // @singleton
  // HttpClient getHttpClient() {
  //   return HttpClient();
  // }
  
  // @singleton
  // ApiService getApiService(HttpClient httpClient) {
  //   return ApiService(httpClient);
  // }
}

/// Audio and Media Module
@module
abstract class AudioModule {
  // TODO: Add audio singletons here
  // @singleton
  // AudioService getAudioService() {
  //   return AudioService();
  // }
  
  // @singleton
  // RecordService getRecordService() {
  //   return RecordService();
  // }
}

/// ML and Language Module
@module
abstract class MLModule {
  // TODO: Add ML singletons here
  // @singleton
  // LanguageIdentifierService getLanguageIdentifier() {
  //   return LanguageIdentifierService();
  // }
}

// Repository Registration
Future<void> registerRepositories(GetIt getIt) {
  // TODO: Register all repositories as singletons
  // getIt.registerSingleton<FlashcardRepository>(
  //   FlashcardRepositoryImpl(
  //     localDataSource: getIt(),
  //     remoteDataSource: getIt(),
  //   ),
  // );
  
  // getIt.registerSingleton<LessonRepository>(
  //   LessonRepositoryImpl(
  //     localDataSource: getIt(),
  //     remoteDataSource: getIt(),
  //   ),
  // );
  
  // getIt.registerSingleton<ProgressRepository>(
  //   ProgressRepositoryImpl(
  //     localDataSource: getIt(),
  //     remoteDataSource: getIt(),
  //   ),
  // );
  
  // getIt.registerSingleton<AuthRepository>(
  //   AuthRepositoryImpl(
  //     remoteDataSource: getIt(),
  //   ),
  // );
  
  // getIt.registerSingleton<SocialRepository>(
  //   SocialRepositoryImpl(
  //     remoteDataSource: getIt(),
  //   ),
  // );

  return Future.value();
}

// DataSource Registration
Future<void> registerDataSources(GetIt getIt) {
  // TODO: Register all datasources as singletons
  // Local DataSources
  // getIt.registerSingleton<FlashcardLocalDataSource>(
  //   FlashcardLocalDataSourceImpl(database: getIt()),
  // );
  
  // getIt.registerSingleton<ProgressLocalDataSource>(
  //   ProgressLocalDataSourceImpl(database: getIt()),
  // );
  
  // Remote DataSources
  // getIt.registerSingleton<FlashcardRemoteDataSource>(
  //   FlashcardRemoteDataSourceImpl(apiService: getIt()),
  // );
  
  // getIt.registerSingleton<LessonRemoteDataSource>(
  //   LessonRemoteDataSourceImpl(apiService: getIt()),
  // );
  
  // getIt.registerSingleton<AuthRemoteDataSource>(
  //   AuthRemoteDataSourceImpl(firebaseAuth: getIt()),
  // );

  return Future.value();
}
