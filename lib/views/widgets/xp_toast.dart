import 'package:flutter/material.dart';
import 'package:language_learning_app/config/theme.dart';

/// Animated "+N XP" toast that slides up and auto-dismisses.
class XpToast extends StatefulWidget {
  final int xp;
  final VoidCallback? onDismissed;

  const XpToast({super.key, required this.xp, this.onDismissed});

  @override
  State<XpToast> createState() => _XpToastState();
}

class _XpToastState extends State<XpToast> with SingleTickerProviderStateMixin {
  late AnimationController _ctrl;
  late Animation<Offset> _slide;
  late Animation<double> _fade;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(vsync: this, duration: const Duration(milliseconds: 400));
    _slide = Tween<Offset>(begin: const Offset(0, 1), end: Offset.zero)
        .animate(CurvedAnimation(parent: _ctrl, curve: Curves.easeOutCubic));
    _fade = CurvedAnimation(parent: _ctrl, curve: Curves.easeOut);
    _ctrl.forward();
    Future.delayed(const Duration(milliseconds: 1200), _dismiss);
  }

  void _dismiss() async {
    await _ctrl.reverse();
    widget.onDismissed?.call();
  }

  @override
  void dispose() { _ctrl.dispose(); super.dispose(); }

  @override
  Widget build(BuildContext context) {
    return SlideTransition(
      position: _slide,
      child: FadeTransition(
        opacity: _fade,
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
          decoration: BoxDecoration(
            color: AppColors.amberMid,
            borderRadius: BorderRadius.circular(AppRadius.chip),
            border: Border.all(color: AppColors.amber.withValues(alpha: 0.4)),
            boxShadow: AppShadows.card,
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(Icons.bolt_rounded, color: AppColors.amber, size: 18),
              const SizedBox(width: 6),
              Text('+${widget.xp} XP',
                style: AppTextStyles.bodySemiBold(color: AppColors.amberText)),
            ],
          ),
        ),
      ),
    );
  }
}

/// Shows an XP toast overlay on a given context.
void showXpToast(BuildContext context, int xp) {
  late OverlayEntry entry;
  entry = OverlayEntry(
    builder: (_) => Positioned(
      bottom: 100,
      left: 0, right: 0,
      child: Center(
        child: XpToast(
          xp: xp,
          onDismissed: () => entry.remove(),
        ),
      ),
    ),
  );
  Overlay.of(context).insert(entry);
}
