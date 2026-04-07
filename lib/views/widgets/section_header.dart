import 'package:flutter/material.dart';
import 'package:language_learning_app/config/theme.dart';

/// Section heading row with optional "See all" button.
class SectionHeader extends StatelessWidget {
  final String title;
  final VoidCallback? onSeeAll;

  const SectionHeader({super.key, required this.title, this.onSeeAll});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: Text(title, style: AppTextStyles.sectionHeading()),
        ),
        if (onSeeAll != null)
          GestureDetector(
            onTap: onSeeAll,
            child: Text('See all', style: AppTextStyles.caption(color: AppColors.primary).copyWith(fontSize: 14, fontWeight: FontWeight.w500)),
          ),
      ],
    );
  }
}
