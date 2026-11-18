import 'package:flutter/material.dart';
import '../tokens/colors.dart';
import '../components/fit_bottom_nav.dart';

class AthleteShell extends StatelessWidget {
  const AthleteShell({
    super.key,
    required this.child,
    required this.currentIndex,
    required this.onNavigate,
    required this.items,
  });

  final Widget child;
  final int currentIndex;
  final ValueChanged<int> onNavigate;
  final List<FitBottomNavItem> items;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: FitColors.background,
      child: Column(
        children: [
          Expanded(child: child),
          FitBottomNav(
            currentIndex: currentIndex,
            onTap: onNavigate,
            items: items,
          ),
        ],
      ),
    );
  }
}
