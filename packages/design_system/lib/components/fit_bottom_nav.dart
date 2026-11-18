import 'package:flutter/material.dart';
import '../tokens/colors.dart';

class FitBottomNavItem {
  const FitBottomNavItem({required this.icon, required this.label});

  final Widget icon;
  final String label;
}

class FitBottomNav extends StatelessWidget {
  const FitBottomNav({
    super.key,
    required this.currentIndex,
    required this.onTap,
    required this.items,
  });

  final int currentIndex;
  final ValueChanged<int> onTap;
  final List<FitBottomNavItem> items;

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 78,
      padding: const EdgeInsets.only(left: 12, right: 12, top: 8, bottom: 14),
      decoration: BoxDecoration(
        color: FitColors.surface,
        border: Border(top: BorderSide(color: FitColors.border)),
      ),
      child: Row(
        children: List.generate(items.length, (i) {
          final active = i == currentIndex;
          final color = active ? FitColors.primary : FitColors.textSecondary;
          final weight = active ? FontWeight.w700 : FontWeight.w500;

          return Expanded(
            child: GestureDetector(
              behavior: HitTestBehavior.opaque,
              onTap: () => onTap(i),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  IconTheme(
                    data: IconThemeData(color: color, size: 22),
                    child: items[i].icon,
                  ),
                  const SizedBox(height: 4),
                  Text(
                    items[i].label,
                    style: TextStyle(
                      fontFamily: 'Inter',
                      fontSize: 11,
                      fontWeight: weight,
                      color: color,
                    ),
                  ),
                ],
              ),
            ),
          );
        }),
      ),
    );
  }
}
