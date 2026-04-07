import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:connectivity_plus/connectivity_plus.dart';

/// Riverpod provider for connectivity stream
final connectivityStateProvider =
    StreamProvider.autoDispose<ConnectivityResult>((ref) {
  return Connectivity().onConnectivityChanged.map((results) => results.first);
});

/// Simplified provider for checking if online
final isOnlineProvider = Provider<bool>((ref) {
  final state = ref.watch(connectivityStateProvider);
  return state.maybeWhen(
    data: (result) => result != ConnectivityResult.none,
    orElse: () => true,
  );
});

/// Simplified provider for checking if offline
final isOfflineProvider = Provider<bool>((ref) {
  final state = ref.watch(connectivityStateProvider);
  return state.maybeWhen(
    data: (result) => result == ConnectivityResult.none,
    orElse: () => false,
  );
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

/// Provider for offline queue
final offlineQueueProvider = Provider((ref) {
  return <OfflineQueueItem>[];
});