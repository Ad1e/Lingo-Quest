import 'package:get_it/get_it.dart';

/// Extension on GetIt for easier access to common services
extension GetItExtension on GetIt {
  /// Register a repository as a singleton
  void registerRepositorySingleton<T extends Object>(
    T instance, {
    String? instanceName,
  }) {
    registerSingleton<T>(instance, instanceName: instanceName);
  }

  /// Register a datasource as a singleton
  void registerDataSourceSingleton<T extends Object>(
    T instance, {
    String? instanceName,
  }) {
    registerSingleton<T>(instance, instanceName: instanceName);
  }

  /// Register a provider factory
  void registerProviderFactory<T extends Object>(
    T Function() factoryFunc, {
    String? instanceName,
  }) {
    registerSingleton<T>(factoryFunc(), instanceName: instanceName);
  }

  /// Check if a service is registered
  bool isRegistered<T extends Object>({String? instanceName}) {
    return hasRegistration<T>(instanceName: instanceName);
  }

  /// Safe get with fallback
  T? getSafe<T extends Object>({
    String? instanceName,
    T? defaultValue,
  }) {
    try {
      return get<T>(instanceName: instanceName);
    } catch (e) {
      return defaultValue;
    }
  }
}

/// Service locator utility for accessing GetIt instance globally
class ServiceLocator {
  static final GetIt _instance = GetIt.instance;

  /// Get the GetIt instance
  static GetIt get instance => _instance;

  /// Get a registered service
  static T get<T extends Object>({String? instanceName}) {
    return _instance.get<T>(instanceName: instanceName);
  }

  /// Get a registered service safely
  static T? getSafe<T extends Object>({
    String? instanceName,
    T? defaultValue,
  }) {
    return _instance.getSafe<T>(
      instanceName: instanceName,
      defaultValue: defaultValue,
    );
  }

  /// Check if service is registered
  static bool isRegistered<T extends Object>({String? instanceName}) {
    return _instance.isRegistered<T>(instanceName: instanceName);
  }

  /// Register a singleton
  static void registerSingleton<T extends Object>(
    T instance, {
    String? instanceName,
  }) {
    if (!_instance.isRegistered<T>(instanceName: instanceName)) {
      _instance.registerSingleton<T>(instance, instanceName: instanceName);
    }
  }

  /// Register a lazy singleton
  static void registerLazySingleton<T extends Object>(
    T Function() factory, {
    String? instanceName,
  }) {
    if (!_instance.isRegistered<T>(instanceName: instanceName)) {
      _instance.registerLazySingleton<T>(factory, instanceName: instanceName);
    }
  }

  /// Register a factory
  static void registerFactory<T extends Object>(
    T Function() factory, {
    String? instanceName,
  }) {
    _instance.registerFactory<T>(factory, instanceName: instanceName);
  }

  /// Unregister a service
  static Future<void> unregister<T extends Object>({
    String? instanceName,
    bool closeInstance = true,
  }) {
    return _instance.unregister<T>(
      instanceName: instanceName,
      closeInstance: closeInstance,
    );
  }

  /// Reset all services
  static Future<void> reset() {
    return _instance.reset();
  }
}
