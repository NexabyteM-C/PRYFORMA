import 'package:flutter/material.dart';
import '../tokens/colors.dart';
import '../tokens/radii.dart';

class FitCard extends StatelessWidget {
  const FitCard({
    super.key,
    required this.child,
    this.padding = const EdgeInsets.all(16),
    this.borderRadius,
    this.borderColor,
    this.hasBorder = true,
    this.elevation = 0,
    this.onTap,
  });

  final Widget child;
  final EdgeInsetsGeometry padding;
  final BorderRadius? borderRadius;
  final Color? borderColor;
  final bool hasBorder;
  final double elevation;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final radius = borderRadius ?? FitRadii.cardBorder;

    final decoration = BoxDecoration(
      color: FitColors.surface,
      borderRadius: radius,
      border: hasBorder ? Border.all(color: borderColor ?? FitColors.border) : null,
      boxShadow: elevation > 0
          ? [
              BoxShadow(
                color: FitColors.primaryDark.withValues(alpha: 0.1),
                blurRadius: elevation * 4,
                offset: Offset(0, elevation),
              ),
            ]
          : null,
    );

    if (onTap != null) {
      return Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          borderRadius: radius,
          child: Ink(
            decoration: decoration,
            child: Padding(padding: padding, child: child),
          ),
        ),
      );
    }

    return DecoratedBox(
      decoration: decoration,
      child: Padding(padding: padding, child: child),
    );
  }
}
