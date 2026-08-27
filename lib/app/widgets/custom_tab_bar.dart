import 'package:doyel_live/app/theme/app_colors.dart';
import 'package:doyel_live/app/theme/app_neumorphic_styles.dart';
import 'package:flutter_neumorphic_plus/flutter_neumorphic.dart';

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
    final unselectedColor = AppColors.textSecondary;

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
                        i == selectedIndex
                            ? Neumorphic(
                                padding: const EdgeInsets.all(6),
                                style: AppNeumorphicStyles.raised(
                                  color: AppColors.secondary,
                                  depth: 2,
                                  radius: 12,
                                ),
                                child: Icon(
                                  item.activeIcon,
                                  color: selectedColor,
                                  size: 21,
                                ),
                              )
                            : Padding(
                                padding: const EdgeInsets.all(6),
                                child: Icon(
                                  item.inactiveIcon,
                                  color: unselectedColor,
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
