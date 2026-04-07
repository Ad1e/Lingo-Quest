import 'package:flutter/material.dart';
import 'package:language_learning_app/config/theme.dart';

/// Base card with consistent shadow, border radius, and padding.
class AppCard extends StatelessWidget {
  final Widget child;
  final EdgeInsetsGeometry? padding;
  final Color? color;
  final double? borderRadius;
  final VoidCallback? onTap;
  final bool useDarkBorder;

  const AppCard({
    super.key,
    required this.child,
    this.padding,
    this.color,
    this.borderRadius,
    this.onTap,
    this.useDarkBorder = false,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final bg = color ?? (isDark ? AppColors.surfaceDark : AppColors.bgLight);
    final radius = borderRadius ?? AppRadius.card;

    return Container(
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(radius),
        boxShadow: isDark
            ? [BoxShadow(color: AppColors.borderDark.withValues(alpha: 0.08), blurRadius: 0, spreadRadius: 1)]
            : AppShadows.card,
        border: isDark ? Border.all(color: AppColors.borderDark, width: 1) : null,
      ),
      child: Material(
        color: Colors.transparent,
        borderRadius: BorderRadius.circular(radius),
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(radius),
          splashColor: AppColors.primary.withValues(alpha: 0.05),
          highlightColor: AppColors.primary.withValues(alpha: 0.03),
          child: Padding(
            padding: padding ?? const EdgeInsets.symmetric(
              vertical: AppSpacing.cardV,
              horizontal: AppSpacing.cardH,
            ),
            child: child,
          ),
        ),
      ),
    );
  }
}
