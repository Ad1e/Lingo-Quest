import 'package:flutter/material.dart';
import 'package:language_learning_app/config/theme.dart';

enum AppButtonVariant { primary, secondary, text }

class AppButton extends StatefulWidget {
  final String label;
  final VoidCallback? onPressed;
  final AppButtonVariant variant;
  final bool isLoading;
  final IconData? trailingIcon;
  final double? height;
  final bool fullWidth;

  const AppButton({
    super.key,
    required this.label,
    this.onPressed,
    this.variant = AppButtonVariant.primary,
    this.isLoading = false,
    this.trailingIcon,
    this.height,
    this.fullWidth = true,
  });

  @override
  State<AppButton> createState() => _AppButtonState();
}

class _AppButtonState extends State<AppButton> with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _scale;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(vsync: this, duration: const Duration(milliseconds: 100));
    _scale = Tween<double>(begin: 1.0, end: 0.96).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeOut),
    );
  }

  @override
  void dispose() { _controller.dispose(); super.dispose(); }

  void _onTapDown(_) => _controller.forward();
  void _onTapUp(_) => _controller.reverse();
  void _onTapCancel() => _controller.reverse();

  @override
  Widget build(BuildContext context) {
    final disabled = widget.onPressed == null && !widget.isLoading;

    Widget child;
    if (widget.isLoading) {
      child = SizedBox(
        width: 20, height: 20,
        child: CircularProgressIndicator(
          strokeWidth: 2,
          color: widget.variant == AppButtonVariant.primary
              ? Colors.white : AppColors.primary,
        ),
      );
    } else {
      final row = <Widget>[
        Text(widget.label, style: AppTextStyles.buttonText(
          color: widget.variant == AppButtonVariant.primary ? Colors.white : AppColors.primary,
        )),
        if (widget.trailingIcon != null) ...[
          const SizedBox(width: 8),
          Icon(widget.trailingIcon,
            size: 18,
            color: widget.variant == AppButtonVariant.primary ? Colors.white : AppColors.primary,
          ),
        ],
      ];
      child = Row(mainAxisSize: MainAxisSize.min, mainAxisAlignment: MainAxisAlignment.center, children: row);
    }

    Widget button;
    switch (widget.variant) {
      case AppButtonVariant.primary:
        button = Container(
          height: widget.height ?? 52,
          width: widget.fullWidth ? double.infinity : null,
          decoration: BoxDecoration(
            color: disabled ? AppColors.primary.withValues(alpha: 0.5) : AppColors.primary,
            borderRadius: BorderRadius.circular(AppRadius.button),
          ),
          child: Center(child: child),
        );
      case AppButtonVariant.secondary:
        button = Container(
          height: widget.height ?? 52,
          width: widget.fullWidth ? double.infinity : null,
          decoration: BoxDecoration(
            color: Colors.transparent,
            borderRadius: BorderRadius.circular(AppRadius.button),
            border: Border.all(
              color: disabled ? AppColors.primary.withValues(alpha: 0.5) : AppColors.primary,
              width: 1.5,
            ),
          ),
          child: Center(child: child),
        );
      case AppButtonVariant.text:
        return GestureDetector(
          onTap: disabled ? null : widget.onPressed,
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 2),
            child: Text(widget.label, style: AppTextStyles.buttonText(color: AppColors.primary).copyWith(fontSize: 14, fontWeight: FontWeight.w500)),
          ),
        );
    }

    return ScaleTransition(
      scale: _scale,
      child: GestureDetector(
        onTapDown: disabled ? null : _onTapDown,
        onTapUp: disabled ? null : _onTapUp,
        onTapCancel: _onTapCancel,
        onTap: disabled || widget.isLoading ? null : widget.onPressed,
        child: button,
      ),
    );
  }
}
