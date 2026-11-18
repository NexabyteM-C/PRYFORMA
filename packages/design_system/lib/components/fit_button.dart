import 'package:flutter/material.dart';
import '../tokens/colors.dart';
import '../tokens/radii.dart';

enum FitButtonVariant { primary, secondary, outline, ghost }

class FitButton extends StatelessWidget {
  const FitButton({
    super.key,
    required this.label,
    this.onPressed,
    this.variant = FitButtonVariant.primary,
    this.isExpanded = false,
    this.height = 44,
    this.icon,
  });

  final String label;
  final VoidCallback? onPressed;
  final FitButtonVariant variant;
  final bool isExpanded;
  final double height;
  final Widget? icon;

  @override
  Widget build(BuildContext context) {
    final disabled = onPressed == null;

    Color bg;
    Color fg;
    FontWeight weight;
    BoxBorder? border;

    switch (variant) {
      case FitButtonVariant.primary:
        bg = FitColors.primary;
        fg = FitColors.surface;
        weight = FontWeight.w700;
      case FitButtonVariant.secondary:
        bg = FitColors.primaryLight;
        fg = FitColors.primaryDark;
        weight = FontWeight.w600;
      case FitButtonVariant.outline:
        bg = FitColors.surface;
        fg = FitColors.textPrimary;
        weight = FontWeight.w600;
        border = Border.all(color: FitColors.border);
      case FitButtonVariant.ghost:
        bg = Colors.transparent;
        fg = FitColors.textSecondary;
        weight = FontWeight.w500;
    }

    final radius = BorderRadius.circular(FitRadii.button);

    Widget child = Row(
      mainAxisSize: isExpanded ? MainAxisSize.max : MainAxisSize.min,
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        if (icon != null) ...[
          IconTheme(data: IconThemeData(color: fg, size: 18), child: icon!),
          const SizedBox(width: 8),
        ],
        Text(
          label,
          style: TextStyle(
            fontFamily: 'Inter',
            fontSize: 14,
            fontWeight: weight,
            color: fg,
          ),
        ),
      ],
    );

    return Opacity(
      opacity: disabled ? 0.5 : 1.0,
      child: Material(
        color: bg,
        borderRadius: radius,
        child: InkWell(
          onTap: onPressed,
          borderRadius: radius,
          child: Container(
            height: height,
            padding: const EdgeInsets.symmetric(horizontal: 16),
            decoration: BoxDecoration(
              borderRadius: radius,
              border: border,
            ),
            alignment: Alignment.center,
            child: child,
          ),
        ),
      ),
    );
  }
}
