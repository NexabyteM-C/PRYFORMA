import 'package:flutter/material.dart';

import '../../../../app/theme/app_colors.dart';

/// Colored badge for a class_programs.status value.
class ProgramStatusBadge extends StatelessWidget {
  const ProgramStatusBadge({super.key, required this.status});
  final String status;

  @override
  Widget build(BuildContext context) {
    final (Color bg, Color fg, String label) = switch (status) {
      'published' => (const Color(0xFFDCFCE7), AppColors.success, 'Publicada'),
      'scheduled' => (
        AppColors.warningBackground,
        AppColors.warningText,
        'Programada',
      ),
      'cancelled' => (const Color(0xFFFEE2E2), AppColors.error, 'Cancelada'),
      'draft' => (
        AppColors.badgeBackground,
        AppColors.textSecondary,
        'Borrador',
      ),
      _ => (AppColors.badgeBackground, AppColors.textSecondary, status),
    };
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(18),
      ),
      child: Text(
        label,
        style: TextStyle(fontSize: 11, fontWeight: FontWeight.w600, color: fg),
      ),
    );
  }
}
