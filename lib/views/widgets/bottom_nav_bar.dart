import 'package:flutter/material.dart';
import 'package:iconsax/iconsax.dart';
import 'package:language_learning_app/config/theme.dart';

class BottomNavBar extends StatelessWidget {
  final int selectedIndex;
  final ValueChanged<int> onTap;

  const BottomNavBar({
    super.key,
    required this.selectedIndex,
    required this.onTap,
  });

  static const _items = [
    _NavItem(icon: Iconsax.home_2,   activeIcon: Iconsax.home_15,  label: 'Home'),
    _NavItem(icon: Iconsax.book_1,   activeIcon: Iconsax.book,     label: 'Lessons'),
    _NavItem(icon: Iconsax.cards,    activeIcon: Iconsax.cards,    label: 'Practice'),
    _NavItem(icon: Iconsax.people,   activeIcon: Iconsax.people5,  label: 'Social'),
    _NavItem(icon: Iconsax.user,     activeIcon: Iconsax.user_tick, label: 'Profile'),
  ];

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 0, 16, 12),
      child: Container(
        height: 64,
        decoration: BoxDecoration(
          color: isDark ? AppColors.surfaceDark : AppColors.bgLight,
          borderRadius: BorderRadius.circular(20),
          boxShadow: AppShadows.floating,
          border: isDark ? Border.all(color: AppColors.borderDark, width: 1) : null,
        ),
        child: Row(
          children: List.generate(_items.length, (i) {
            final active = i == selectedIndex;
            return Expanded(
              child: GestureDetector(
                behavior: HitTestBehavior.opaque,
                onTap: () => onTap(i),
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 220),
                  curve: Curves.easeInOutCubic,
                  margin: const EdgeInsets.symmetric(horizontal: 4, vertical: 8),
                  decoration: BoxDecoration(
                    color: active ? AppColors.primaryMid : Colors.transparent,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        active ? _items[i].activeIcon : _items[i].icon,
                        size: 22,
                        color: active ? AppColors.primary : AppColors.neutralMid,
                      ),
                      const SizedBox(height: 3),
                      AnimatedDefaultTextStyle(
                        duration: const Duration(milliseconds: 220),
                        style: AppTextStyles.label(
                          color: active ? AppColors.primary : Colors.transparent,
                        ),
                        child: Text(_items[i].label),
                      ),
                    ],
                  ),
                ),
              ),
            );
          }),
        ),
      ),
    );
  }
}

class _NavItem {
  final IconData icon;
  final IconData activeIcon;
  final String label;
  const _NavItem({required this.icon, required this.activeIcon, required this.label});
}
