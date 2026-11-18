import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../app/theme/app_colors.dart';

/// Circular "volver atrás" button used at the top-left of pushed sub-screens
/// that don't use a Material [AppBar] (which supplies its own back arrow).
///
/// It pops the current route; if there is nothing to pop (e.g. the screen was
/// reached by a deep link or a hard browser refresh), it falls back to
/// [fallbackLocation] so the user is never stranded.
class FitBackButton extends StatelessWidget {
  const FitBackButton({
    super.key,
    this.fallbackLocation,
    this.tooltip = 'Volver',
  });

  /// Where to go when the navigation stack can't pop. Defaults to the athlete
  /// home when not provided.
  final String? fallbackLocation;
  final String tooltip;

  void _onTap(BuildContext context) {
    if (context.canPop()) {
      context.pop();
    } else {
      context.go(fallbackLocation ?? '/athlete/home');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Semantics(
      button: true,
      label: tooltip,
      child: Tooltip(
        message: tooltip,
        child: GestureDetector(
          onTap: () => _onTap(context),
          child: Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: AppColors.surface,
              shape: BoxShape.circle,
              border: Border.all(color: AppColors.border, width: 1.5),
            ),
            child: Icon(
              Icons.chevron_left_rounded,
              color: AppColors.textPrimary,
              size: 24,
            ),
          ),
        ),
      ),
    );
  }
}
