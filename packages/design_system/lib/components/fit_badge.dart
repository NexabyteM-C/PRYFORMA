import 'package:flutter/material.dart';
import '../tokens/colors.dart';
import '../tokens/radii.dart';

enum FitBadgeVariant { info, success, warning, neutral, primary, teal }

class FitBadge extends StatelessWidget {
  const FitBadge({
    super.key,
    required this.label,
    this.variant = FitBadgeVariant.neutral,
  });

  final String label;
  final FitBadgeVariant variant;

  @override
  Widget build(BuildContext context) {
    final (Color bg, Color fg) = switch (variant) {
      FitBadgeVariant.info => (FitColors.primaryLight, FitColors.primaryDark),
      FitBadgeVariant.success => (const Color(0xFFDCFCE7), FitColors.success),
      FitBadgeVariant.warning => (FitColors.warningBackground, FitColors.warningText),
      FitBadgeVariant.neutral => (FitColors.badgeBackground, FitColors.textSecondary),
      FitBadgeVariant.primary => (FitColors.primaryDark, FitColors.surface),
      FitBadgeVariant.teal => (FitColors.secondaryLight, FitColors.secondaryDark),
    };

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(FitRadii.xs),
      ),
      child: Text(
        label,
        style: TextStyle(
          fontFamily: 'Inter',
          fontSize: 11,
          fontWeight: FontWeight.w600,
          color: fg,
        ),
      ),
    );
  }
}
