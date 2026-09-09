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
  const CustomTabBar({
    super.key,
    required this.items,
    required this.selectedIndex,
    required this.onTap,
    this.isBottomIndicator = false,
  });
  final List<CustomTabItem> items;
  final int selectedIndex;
  final ValueChanged<int> onTap;
  final bool isBottomIndicator;

  @override
  Widget build(BuildContext context) => Padding(
    padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 8),
    child: Row(
      children: List.generate(items.length, (index) {
        final item = items[index];
        final selected = index == selectedIndex;
        return Expanded(
          child: Semantics(
            selected: selected,
            button: true,
            child: InkWell(
              borderRadius: BorderRadius.circular(16),
              onTap: () => onTap(index),
              child: Padding(
                padding: const EdgeInsets.symmetric(vertical: 4),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Neumorphic(
                      duration: MediaQuery.disableAnimationsOf(context)
                          ? Duration.zero
                          : AppNeumorphicStyles.duration,
                      style: AppNeumorphicStyles.raised(
                        color: selected
                            ? AppColors.primarySoft
                            : AppColors.surface,
                        depth: selected ? AppNeumorphicStyles.insetDepth : 0,
                        radius: 14,
                      ),
                      padding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 7,
                      ),
                      child: Icon(
                        selected ? item.activeIcon : item.inactiveIcon,
                        color: selected
                            ? AppColors.primary
                            : AppColors.textSecondary,
                        size: 22,
                      ),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      item.label,
                      textAlign: TextAlign.center,
                      style: Theme.of(context).textTheme.labelSmall?.copyWith(
                        color: selected
                            ? AppColors.primary
                            : AppColors.textSecondary,
                        fontWeight: selected
                            ? FontWeight.w700
                            : FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        );
      }),
    ),
  );
}
