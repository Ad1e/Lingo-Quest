import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:language_learning_app/services/connectivity_service.dart';

/// Riverpod provider for connectivity service
final connectivityServiceProvider = Provider((ref) {
  return ConnectivityService();
});

/// Riverpod provider for connectivity state
final connectivityStateProvider =
    StreamProvider.autoDispose<ConnectivityState>((ref) async* {
  final service = ref.watch(connectivityServiceProvider);

  // Emit initial state
  yield service.currentState;

  // Listen to connectivity changes
  void listener(ConnectivityState state) async* {
    yield state;
  }

  service.addListener(listener);
  ref.onDispose(() => service.removeListener(listener));

  // Keep the stream alive
  await Future.delayed(const Duration(days: 365));
});

/// Simplified provider for checking if online
final isOnlineProvider = Provider<bool>((ref) {
  final state = ref.watch(connectivityStateProvider);

  return state.maybeWhen(
    data: (connectivityState) => connectivityState == ConnectivityState.online,
    orElse: () => true, // Default to online if unknown
  );
});

/// Simplified provider for checking if offline
final isOfflineProvider = Provider<bool>((ref) {
  final state = ref.watch(connectivityStateProvider);

  return state.maybeWhen(
    data: (connectivityState) =>
        connectivityState == ConnectivityState.offline,
    orElse: () => false,
  );
});

/// Provider for offline queue
final offlineQueueProvider = Provider((ref) {
  // This will be connected to the actual offline queue service
  // For now, it returns a placeholder
  return <OfflineQueueItem>[];
});

/// Placeholder model for offline queue items
class OfflineQueueItem {
  final String id;
  final String type;
  final DateTime timestamp;

  OfflineQueueItem({
    required this.id,
    required this.type,
    required this.timestamp,
  });
}
