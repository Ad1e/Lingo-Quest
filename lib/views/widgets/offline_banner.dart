import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:language_learning_app/providers/connectivity_provider.dart';
import 'package:language_learning_app/services/connectivity_service.dart';

/// Widget to display offline banner
class OfflineBanner extends ConsumerWidget {
  final Duration animationDuration;
  final Duration displayDuration;

  const OfflineBanner({
    Key? key,
    this.animationDuration = const Duration(milliseconds: 300),
    this.displayDuration = const Duration(milliseconds: 3000),
  }) : super(key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final connectivityState = ref.watch(connectivityStateProvider);

    return connectivityState.when(
      data: (state) {
        if (state == ConnectivityState.online) {
          return const SizedBox.shrink();
        }

        return _buildOfflineBanner(state);
      },
      loading: () => const SizedBox.shrink(),
      error: (_, __) => const SizedBox.shrink(),
    );
  }

  Widget _buildOfflineBanner(ConnectivityState state) {
    return Material(
      color: Colors.transparent,
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        decoration: BoxDecoration(
          color: Colors.red.shade600,
          boxShadow: [
            BoxShadow(
              color: Colors.red.withOpacity(0.3),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Row(
          children: [
            const Icon(
              Icons.cloud_off_rounded,
              color: Colors.white,
              size: 20,
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Text(
                    'Offline Mode',
                    style: TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                      fontSize: 14,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    'Your changes will sync when online',
                    style: TextStyle(
                      color: Colors.white.withOpacity(0.9),
                      fontSize: 12,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 12),
            Container(
              width: 8,
              height: 8,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: Colors.red.shade200,
              ),
              child: const _PulsingDot(),
            ),
          ],
        ),
      ),
    );
  }
}

/// Pulsing indicator dot
class _PulsingDot extends StatefulWidget {
  const _PulsingDot({Key? key}) : super(key: key);

  @override
  State<_PulsingDot> createState() => _PulsingDotState();
}

class _PulsingDotState extends State<_PulsingDot>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _animation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 1500),
      vsync: this,
    )..repeat();

    _animation = Tween<double>(begin: 0.5, end: 1.0).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return ScaleTransition(
      scale: _animation,
      child: Container(
        width: 8,
        height: 8,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: Colors.white.withOpacity(0.7),
        ),
      ),
    );
  }
}

/// Widget to show offline queue status
class OfflineQueueStatus extends ConsumerStatefulWidget {
  final VoidCallback? onRetry;

  const OfflineQueueStatus({
    Key? key,
    this.onRetry,
  }) : super(key: key);

  @override
  ConsumerState<OfflineQueueStatus> createState() => _OfflineQueueStatusState();
}

class _OfflineQueueStatusState extends ConsumerState<OfflineQueueStatus>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(seconds: 2),
      vsync: this,
    )..repeat();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final offlineQueue = ref.watch(offlineQueueProvider);

    if (offlineQueue.isEmpty) {
      return const SizedBox.shrink();
    }

    return Positioned(
      bottom: 16,
      right: 16,
      child: ScaleTransition(
        scale: Tween<double>(begin: 1.0, end: 1.1)
            .animate(CurvedAnimation(parent: _controller, curve: Curves.ease)),
        child: Material(
          borderRadius: BorderRadius.circular(16),
          color: Colors.amber.shade700,
          child: InkWell(
            onTap: widget.onRetry,
            borderRadius: BorderRadius.circular(16),
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(
                    Icons.sync_disabled,
                    color: Colors.white,
                    size: 18,
                  ),
                  const SizedBox(width: 8),
                  Text(
                    '${offlineQueue.length} pending',
                    style: const TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                      fontSize: 14,
                    ),
                  ),
                  const SizedBox(width: 8),
                  Container(
                    padding: const EdgeInsets.all(4),
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.3),
                      borderRadius: BorderRadius.circular(6),
                    ),
                    child: const Icon(
                      Icons.refresh,
                      color: Colors.white,
                      size: 14,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

/// Inline offline indicator widget
class OfflineIndicator extends ConsumerWidget {
  final bool showLabel;
  final double size;

  const OfflineIndicator({
    Key? key,
    this.showLabel = true,
    this.size = 16,
  }) : super(key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isOffline = ref.watch(isOfflineProvider);

    if (!isOffline) {
      return const SizedBox.shrink();
    }

    return Tooltip(
      message: 'You are offline. Changes will sync when online.',
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            Icons.cloud_off_rounded,
            color: Colors.red.shade600,
            size: size,
          ),
          if (showLabel) ...[
            const SizedBox(width: 4),
            Text(
              'Offline',
              style: TextStyle(
                color: Colors.red.shade600,
                fontSize: size - 2,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ],
      ),
    );
}
