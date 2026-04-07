import 'package:connectivity_plus/connectivity_plus.dart';
import 'dart:async';
import 'dart:developer' as developer;

/// Connectivity state enum
enum ConnectivityState {
  online,
  offline,
  unknown,
}

/// Connectivity service for managing online/offline state
class ConnectivityService {
  static final ConnectivityService _instance =
      ConnectivityService._internal();

  final Connectivity _connectivity = Connectivity();
  late StreamSubscription<ConnectivityResult> _subscription;
  
  ConnectivityState _currentState = ConnectivityState.online;
  final List<void Function(ConnectivityState)> _listeners = [];

  factory ConnectivityService() {
    return _instance;
  }

  ConnectivityService._internal();

  /// Initialize connectivity service
  Future<void> initialize() async {
    try {
      // Get initial connectivity status
      final result = await _connectivity.checkConnectivity();
      _updateState(result);

      // Listen for connectivity changes
      _subscription = _connectivity.onConnectivityChanged.listen(
        _updateState,
        onError: (e) {
          developer.log('Connectivity error: $e', error: e);
          _currentState = ConnectivityState.unknown;
          _notifyListeners();
        },
      );

      developer.log('Connectivity service initialized');
    } catch (e) {
      developer.log('Error initializing connectivity service: $e',
          error: e, stackTrace: StackTrace.current);
    }
  }

  /// Update connectivity state
  void _updateState(ConnectivityResult result) {
    final newState = _resultToState(result);
    if (newState != _currentState) {
      _currentState = newState;
      developer.log('Connectivity changed to: $_currentState');
      _notifyListeners();
    }
  }

  /// Convert ConnectivityResult to ConnectivityState
  ConnectivityState _resultToState(ConnectivityResult result) {
    return switch (result) {
      ConnectivityResult.mobile => ConnectivityState.online,
      ConnectivityResult.wifi => ConnectivityState.online,
      ConnectivityResult.ethernet => ConnectivityState.online,
      ConnectivityResult.bluetooth => ConnectivityState.online,
      ConnectivityResult.none => ConnectivityState.offline,
      ConnectivityResult.other => ConnectivityState.online,
      ConnectivityResult.vpn => ConnectivityState.online,
    };
  }

  /// Add listener for connectivity changes
  void addListener(void Function(ConnectivityState) listener) {
    _listeners.add(listener);
  }

  /// Remove listener for connectivity changes
  void removeListener(void Function(ConnectivityState) listener) {
    _listeners.remove(listener);
  }

  /// Notify all listeners of connectivity change
  void _notifyListeners() {
    for (final listener in _listeners) {
      listener(_currentState);
    }
  }

  /// Get current connectivity state
  ConnectivityState get currentState => _currentState;

  /// Check if online
  bool get isOnline => _currentState == ConnectivityState.online;

  /// Check if offline
  bool get isOffline => _currentState == ConnectivityState.offline;

  /// Dispose service
  void dispose() {
    _subscription.cancel();
    _listeners.clear();
  }

  /// Force check connectivity (useful for app resuming)
  Future<void> checkConnectivity() async {
    try {
      final result = await _connectivity.checkConnectivity();
      _updateState(result);
    } catch (e) {
      developer.log('Error checking connectivity: $e', error: e);
    }
  }
}
