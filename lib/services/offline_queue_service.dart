import 'dart:developer' as developer;
import 'package:flutter/material.dart';

/// Enum for offline operation types
enum OfflineOperationType {
  addXp,
  recordFlashcardStudy,
  updateStreak,
  unlockAchievement,
  updateUserProfile,
}

/// Model for offline operation queue
class OfflineOperation {
  final String id;
  final OfflineOperationType type;
  final Map<String, dynamic> data;
  final DateTime createdAt;
  bool isProcessing;
  String? error;

  OfflineOperation({
    required this.id,
    required this.type,
    required this.data,
    required this.createdAt,
    this.isProcessing = false,
    this.error,
  });

  /// Convert to JSON for storage
  Map<String, dynamic> toJson() => {
    'id': id,
    'type': type.name,
    'data': data,
    'createdAt': createdAt.toIso8601String(),
    'isProcessing': isProcessing,
    'error': error,
  };

  /// Create from JSON
  factory OfflineOperation.fromJson(Map<String, dynamic> json) {
    return OfflineOperation(
      id: json['id'] as String,
      type: OfflineOperationType.values.byName(json['type'] as String),
      data: json['data'] as Map<String, dynamic>,
      createdAt: DateTime.parse(json['createdAt'] as String),
      isProcessing: json['isProcessing'] as bool? ?? false,
      error: json['error'] as String?,
    );
  }
}

/// Offline queue service
/// Manages queuing of Firestore writes while offline
class OfflineQueueService {
  static final OfflineQueueService _instance =
      OfflineQueueService._internal();

  final List<OfflineOperation> _operations = [];
  final List<void Function(List<OfflineOperation>)> _listeners = [];

  factory OfflineQueueService() {
    return _instance;
  }

  OfflineQueueService._internal();

  /// Initialize and load persisted operations from local storage
  Future<void> initialize() async {
    try {
      // TODO: Load persisted operations from Drift DB
      // This will be implemented when Drift DB is set up
      developer.log('Offline queue service initialized');
    } catch (e) {
      developer.log('Error initializing offline queue: $e',
          error: e, stackTrace: StackTrace.current);
    }
  }

  /// Add operation to queue
  Future<void> addOperation(
    OfflineOperationType type,
    Map<String, dynamic> data,
  ) async {
    try {
      final operation = OfflineOperation(
        id: '${DateTime.now().millisecondsSinceEpoch}_${_operations.length}',
        type: type,
        data: data,
        createdAt: DateTime.now(),
      );

      _operations.add(operation);
      developer.log('Operation queued: ${operation.id}');

      // TODO: Persist to Drift DB
      _notifyListeners();
    } catch (e) {
      developer.log('Error adding operation to queue: $e', error: e);
      rethrow;
    }
  }

  /// Process all queued operations
  Future<void> processQueue({
    required Future<bool> Function(OfflineOperation) processor,
  }) async {
    if (_operations.isEmpty) {
      developer.log('Offline queue is empty');
      return;
    }

    developer.log('Processing ${_operations.length} queued operations');

    for (int i = 0; i < _operations.length; i++) {
      final operation = _operations[i];

      try {
        operation.isProcessing = true;
        _notifyListeners();

        final success = await processor(operation);

        if (success) {
          _operations.removeAt(i);
          i--;
          developer.log('Operation processed successfully: ${operation.id}');
        } else {
          operation.error = 'Processing failed';
          operation.isProcessing = false;
          developer.log('Operation processing failed: ${operation.id}');
        }
      } catch (e) {
        operation.error = e.toString();
        operation.isProcessing = false;
        developer.log('Error processing operation: $e', error: e);
      }

      _notifyListeners();
    }

    // TODO: Remove processed operations from Drift DB
    developer.log('Queue processing complete. Remaining: ${_operations.length}');
  }

  /// Get all pending operations
  List<OfflineOperation> getPendingOperations() {
    return List.unmodifiable(_operations);
  }

  /// Get number of pending operations
  int get operationCount => _operations.length;

  /// Check if queue has operations
  bool get hasOperations => _operations.isNotEmpty;

  /// Clear queue (use with caution)
  Future<void> clearQueue() async {
    try {
      _operations.clear();
      developer.log('Offline queue cleared');
      // TODO: Clear from Drift DB
      _notifyListeners();
    } catch (e) {
      developer.log('Error clearing queue: $e', error: e);
      rethrow;
    }
  }

  /// Add listener for queue changes
  void addListener(void Function(List<OfflineOperation>) listener) {
    _listeners.add(listener);
  }

  /// Remove listener
  void removeListener(void Function(List<OfflineOperation>) listener) {
    _listeners.remove(listener);
  }

  /// Notify listeners of queue changes
  void _notifyListeners() {
    for (final listener in _listeners) {
      listener(List.unmodifiable(_operations));
    }
  }

  /// Get operation by ID
  OfflineOperation? getOperation(String id) {
    try {
      return _operations.firstWhere((op) => op.id == id);
    } catch (e) {
      return null;
    }
  }

  /// Retry specific operation
  Future<void> retryOperation(
    String operationId, {
    required Future<bool> Function(OfflineOperation) processor,
  }) async {
    try {
      final operation = getOperation(operationId);
      if (operation == null) {
        throw Exception('Operation not found: $operationId');
      }

      operation.isProcessing = true;
      operation.error = null;
      _notifyListeners();

      final success = await processor(operation);

      if (success) {
        _operations.removeWhere((op) => op.id == operationId);
        developer.log('Operation retried successfully: $operationId');
      } else {
        operation.error = 'Retry failed';
        developer.log('Operation retry failed: $operationId');
      }

      operation.isProcessing = false;
      _notifyListeners();
    } catch (e) {
      developer.log('Error retrying operation: $e', error: e);
      rethrow;
    }
  }
}
