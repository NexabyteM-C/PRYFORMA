import 'package:flutter/material.dart';
import '../tokens/colors.dart';
import '../tokens/radii.dart';

class FitChip extends StatelessWidget {
  const FitChip({
    super.key,
    required this.label,
    this.isSelected = false,
    this.onTap,
    this.color,
    this.showDot = false,
  });

  final String label;
  final bool isSelected;
  final VoidCallback? onTap;
  final Color? color;
  final bool showDot;

  @override
  Widget build(BuildContext context) {
    final bg = isSelected ? FitColors.textPrimary : FitColors.surface;
    final fg = isSelected ? FitColors.surface : FitColors.textPrimary;
    final weight = isSelected ? FontWeight.w600 : FontWeight.w500;
    final border = isSelected ? null : Border.all(color: FitColors.border);
    final radius = BorderRadius.circular(FitRadii.pill);

    return Material(
      color: bg,
      borderRadius: radius,
      child: InkWell(
        onTap: onTap,
        borderRadius: radius,
        child: Container(
          height: 36,
          padding: const EdgeInsets.symmetric(horizontal: 14),
          decoration: BoxDecoration(
            borderRadius: radius,
            border: border,
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              if (showDot && color != null) ...[
                Container(
                  width: 8,
                  height: 8,
                  decoration: BoxDecoration(
                    color: color,
                    shape: BoxShape.circle,
                  ),
                ),
                const SizedBox(width: 8),
              ],
              Text(
                label,
                style: TextStyle(
                  fontFamily: 'Inter',
                  fontSize: 13,
                  fontWeight: weight,
                  color: fg,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
