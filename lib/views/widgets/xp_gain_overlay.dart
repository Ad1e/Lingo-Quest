import 'package:flutter/material.dart';
import 'package:lottie/lottie.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../utils/gamification_models.dart';

/// Enum for animation types
enum XpAnimationType {
  xpGain,
  levelUp,
  achievementUnlock,
}

/// Widget to show XP gain animation overlay
class XpGainOverlay extends ConsumerStatefulWidget {
  final int xpAmount;
  final XpAnimationType type;
  final String? title;
  final String? subtitle;
  final VoidCallback? onAnimationComplete;

  const XpGainOverlay({
    Key? key,
    required this.xpAmount,
    this.type = XpAnimationType.xpGain,
    this.title,
    this.subtitle,
    this.onAnimationComplete,
  }) : super(key: key);

  @override
  ConsumerState<XpGainOverlay> createState() => _XpGainOverlayState();
}

class _XpGainOverlayState extends ConsumerState<XpGainOverlay>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<Offset> _slideAnimation;
  late Animation<double> _fadeAnimation;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 2500),
      vsync: this,
    );

    _slideAnimation = Tween<Offset>(
      begin: const Offset(0, 1),
      end: const Offset(0, -2),
    ).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeOut),
    );

    _fadeAnimation = Tween<double>(begin: 1, end: 0).animate(
      CurvedAnimation(
        parent: _animationController,
        curve: const Interval(0.7, 1.0),
      ),
    );

    _animationController.forward().then((_) {
      widget.onAnimationComplete?.call();
    });
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return SlideTransition(
      position: _slideAnimation,
      child: FadeTransition(
        opacity: _fadeAnimation,
        child: Align(
          alignment: Alignment.topCenter,
          child: Padding(
            padding: const EdgeInsets.only(top: 100.0),
            child: _buildContent(context),
          ),
        ),
      ),
    );
  }

  Widget _buildContent(BuildContext context) {
    switch (widget.type) {
      case XpAnimationType.xpGain:
        return _buildXpGainWidget(context);
      case XpAnimationType.levelUp:
        return _buildLevelUpWidget(context);
      case XpAnimationType.achievementUnlock:
        return _buildAchievementWidget(context);
    }
  }

  Widget _buildXpGainWidget(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            Colors.amber.shade600,
            Colors.orange.shade600,
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.amber.withOpacity(0.5),
            blurRadius: 20,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            '+${widget.xpAmount}',
            style: Theme.of(context).textTheme.displayMedium?.copyWith(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                  letterSpacing: 2,
                ),
          ),
          const SizedBox(height: 4),
          Text(
            'XP',
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  color: Colors.white70,
                  fontWeight: FontWeight.w600,
                ),
          ),
        ],
      ),
    );
  }

  Widget _buildLevelUpWidget(BuildContext context) {
    return SizedBox(
      height: 300,
      width: 300,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          SizedBox(
            height: 200,
            width: 200,
            child: Lottie.asset(
              'assets/lottie/level_up.json',
              fit: BoxFit.contain,
              repeat: false,
            ),
          ),
          const SizedBox(height: 16),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  Colors.purple.shade600,
                  Colors.indigo.shade600,
                ],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(16),
              boxShadow: [
                BoxShadow(
                  color: Colors.purple.withOpacity(0.5),
                  blurRadius: 20,
                  offset: const Offset(0, 10),
                ),
              ],
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  'Level Up!',
                  style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                      ),
                ),
                if (widget.title != null) ...[
                  const SizedBox(height: 8),
                  Text(
                    widget.title!,
                    style: TextStyle(
                      color: Colors.white70,
                      fontSize: 16,
                    ),
                  ),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAchievementWidget(BuildContext context) {
    return SizedBox(
      height: 350,
      width: 320,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          SizedBox(
            height: 200,
            width: 200,
            child: Lottie.asset(
              'assets/lottie/achievement_unlock.json',
              fit: BoxFit.contain,
              repeat: false,
            ),
          ),
          const SizedBox(height: 16),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  Colors.amber.shade600,
                  Colors.orange.shade600,
                ],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(16),
              boxShadow: [
                BoxShadow(
                  color: Colors.amber.withOpacity(0.5),
                  blurRadius: 20,
                  offset: const Offset(0, 10),
                ),
              ],
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  'Achievement Unlocked!',
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                      ),
                  textAlign: TextAlign.center,
                ),
                if (widget.title != null) ...[
                  const SizedBox(height: 8),
                  Text(
                    widget.title!,
                    style: Theme.of(context).textTheme.titleLarge?.copyWith(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                        ),
                    textAlign: TextAlign.center,
                  ),
                ],
                if (widget.subtitle != null) ...[
                  const SizedBox(height: 4),
                  Text(
                    widget.subtitle!,
                    style: TextStyle(
                      color: Colors.white70,
                      fontSize: 14,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }
}

/// Overlay widget to show notifications stack
class XpNotificationOverlay extends ConsumerStatefulWidget {
  final Widget child;

  const XpNotificationOverlay({
    Key? key,
    required this.child,
  }) : super(key: key);

  @override
  ConsumerState<XpNotificationOverlay> createState() =>
      _XpNotificationOverlayState();
}

class _XpNotificationOverlayState extends ConsumerState<XpNotificationOverlay> {
  final List<_NotificationItem> _notifications = [];
  OverlayEntry? _overlayEntry;

  @override
  void initState() {
    super.initState();
    _setupOverlay();
  }

  void _setupOverlay() {
    _overlayEntry = OverlayEntry(
      builder: (context) => Stack(
        children: _notifications.map((notif) => notif.widget).toList(),
      ),
    );

    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) {
        Overlay.of(context).insert(_overlayEntry!);
      }
    });
  }

  void showXpGain(int amount) {
    final notification = _NotificationItem(
      id: DateTime.now().millisecondsSinceEpoch,
      widget: XpGainOverlay(
        xpAmount: amount,
        type: XpAnimationType.xpGain,
        onAnimationComplete: () {
          _removeNotification(
            DateTime.now().millisecondsSinceEpoch,
          );
        },
      ),
    );

    setState(() {
      _notifications.add(notification);
    });
  }

  void showLevelUp(int newLevel) {
    final notification = _NotificationItem(
      id: DateTime.now().millisecondsSinceEpoch,
      widget: XpGainOverlay(
        xpAmount: 0,
        type: XpAnimationType.levelUp,
        title: 'Level $newLevel',
        onAnimationComplete: () {
          _removeNotification(
            DateTime.now().millisecondsSinceEpoch,
          );
        },
      ),
    );

    setState(() {
      _notifications.add(notification);
    });
  }

  void showAchievementUnlock(AchievementUnlock achievement) {
    final notification = _NotificationItem(
      id: DateTime.now().millisecondsSinceEpoch,
      widget: XpGainOverlay(
        xpAmount: 0,
        type: XpAnimationType.achievementUnlock,
        title: achievement.title,
        subtitle: achievement.description,
        onAnimationComplete: () {
          _removeNotification(
            DateTime.now().millisecondsSinceEpoch,
          );
        },
      ),
    );

    setState(() {
      _notifications.add(notification);
    });
  }

  void _removeNotification(int id) {
    setState(() {
      _notifications.removeWhere((notif) => notif.id == id);
    });
  }

  @override
  void dispose() {
    _overlayEntry?.remove();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return widget.child;
  }
}

class _NotificationItem {
  final int id;
  final Widget widget;

  _NotificationItem({
    required this.id,
    required this.widget,
  });
}
