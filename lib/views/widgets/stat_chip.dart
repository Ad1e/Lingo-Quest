import 'package:flutter/material.dart';
import 'package:language_learning_app/config/theme.dart';

/// 2x2 metric card: large number + label below.
class StatCard extends StatelessWidget {
  final String value;
  final String label;
  final Color? valueColor;

  const StatCard({
    super.key,
    required this.value,
    required this.label,
    this.valueColor,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 12),
      decoration: BoxDecoration(
        color: isDark ? AppColors.surfaceDark : AppColors.bgLight,
        borderRadius: BorderRadius.circular(AppRadius.card),
        boxShadow: isDark ? null : AppShadows.card,
        border: isDark ? Border.all(color: AppColors.borderDark, width: 1) : null,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(value,
            style: AppTextStyles.display(color: valueColor ?? AppColors.primary),
          ),
          const SizedBox(height: 4),
          Text(label, style: AppTextStyles.label()),
        ],
      ),
    );
  }
}

/// Badge/chip with color variants.
enum AppChipVariant { blue, amber, gray }

class AppChip extends StatelessWidget {
  final String label;
  final AppChipVariant variant;

  const AppChip({super.key, required this.label, this.variant = AppChipVariant.blue});

  @override
  Widget build(BuildContext context) {
    Color bg, textColor;
    switch (variant) {
      case AppChipVariant.blue:  bg = AppColors.primaryMid; textColor = AppColors.primary; break;
      case AppChipVariant.amber: bg = AppColors.amberMid;   textColor = AppColors.amberText; break;
      case AppChipVariant.gray:  bg = AppColors.neutralLight; textColor = AppColors.neutralMid; break;
    }
    return Container(
      height: 24,
      padding: const EdgeInsets.symmetric(horizontal: 10),
      decoration: BoxDecoration(color: bg, borderRadius: BorderRadius.circular(AppRadius.chip)),
      alignment: Alignment.center,
      child: Text(label, style: AppTextStyles.label(color: textColor)),
    );
  }
}
