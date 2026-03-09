import 'package:doyel_live/app/theme/app_colors.dart';
import 'package:flutter/material.dart';

class CustomTabItem {
  const CustomTabItem({
    required this.label,
    required this.activeIcon,
    required this.inactiveIcon,
  });

  final String label;
  final IconData activeIcon;
  final IconData inactiveIcon;
}

class CustomTabBar extends StatelessWidget {
  final List<CustomTabItem> items;
  final int selectedIndex;
  final Function(int) onTap;
  final bool isBottomIndicator;

  const CustomTabBar({
    super.key,
    required this.items,
    required this.selectedIndex,
    required this.onTap,
    this.isBottomIndicator = false,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final selectedColor = theme.colorScheme.primary;
    final unselectedColor = AppColors.black45;

    return SizedBox(
      height: 72,
      child: TabBar(
        indicatorPadding: EdgeInsets.zero,
        indicator: const BoxDecoration(
          border: Border(
            bottom: BorderSide(color: Colors.transparent, width: 0.0),
          ),
        ),
        padding: EdgeInsets.zero,
        labelPadding: EdgeInsets.zero,
        tabs: items
            .asMap()
            .map(
              (i, item) => MapEntry(
                i,
                Tab(
                  height: 72,
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 220),
                    curve: Curves.easeOutCubic,
                    padding: const EdgeInsets.symmetric(vertical: 4),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        AnimatedContainer(
                          duration: const Duration(milliseconds: 220),
                          curve: Curves.easeOutCubic,
                          padding: const EdgeInsets.all(6),
                          decoration: BoxDecoration(
                            gradient: i == selectedIndex
                                ? LinearGradient(
                                    begin: Alignment.topLeft,
                                    end: Alignment.bottomRight,
                                    colors: [
                                      selectedColor.withValues(alpha: 0.26),
                                      theme.colorScheme.secondary.withValues(
                                        alpha: 0.16,
                                      ),
                                    ],
                                  )
                                : null,
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(
                              color: i == selectedIndex
                                  ? selectedColor.withValues(alpha: 0.35)
                                  : Colors.transparent,
                              width: 1,
                            ),
                            boxShadow: i == selectedIndex
                                ? [
                                    BoxShadow(
                                      color: selectedColor.withValues(
                                        alpha: 0.22,
                                      ),
                                      blurRadius: 14,
                                      offset: const Offset(0, 5),
                                    ),
                                  ]
                                : const [],
                          ),
                          child: Icon(
                            i == selectedIndex
                                ? item.activeIcon
                                : item.inactiveIcon,
                            color: i == selectedIndex
                                ? selectedColor
                                : unselectedColor,
                            size: 21,
                          ),
                        ),
                        const SizedBox(height: 3),
                        Text(
                          item.label,
                          style: theme.textTheme.labelSmall?.copyWith(
                            color: i == selectedIndex
                                ? selectedColor
                                : unselectedColor,
                            fontWeight: i == selectedIndex
                                ? FontWeight.w700
                                : FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            )
            .values
            .toList(),
        onTap: onTap,
      ),
    );
  }
}
