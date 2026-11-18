import 'package:domain_models/domain_models.dart';
import 'package:flutter/material.dart';
import '../../../../app/theme/app_colors.dart';

class ClassCard extends StatelessWidget {
  const ClassCard({super.key, required this.session, this.onTap, this.boxColor});
  final ClassSession session;
  final VoidCallback? onTap;
  final Color? boxColor;

  @override
  Widget build(BuildContext context) {
    final color = boxColor ?? AppColors.primary;
    final coachName = session.coaches?.isNotEmpty == true ? session.coaches!.first.displayName : null;
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(18),
          border: Border.all(color: AppColors.border),
        ),
        child: Row(
          children: [
            Container(
              width: 4,
              height: 48,
              decoration: BoxDecoration(color: color, borderRadius: BorderRadius.circular(2)),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    session.startTime,
                    style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: AppColors.textPrimary),
                  ),
                  const SizedBox(height: 4),
                  Row(
                    children: [
                      Icon(Icons.access_time_rounded, size: 14, color: AppColors.textSecondary),
                      const SizedBox(width: 4),
                      Text(
                        session.startTime,
                        style: TextStyle(fontSize: 12, color: AppColors.textSecondary),
                      ),
                      if (coachName != null) ...[
                        const SizedBox(width: 12),
                        Icon(Icons.person_outline_rounded, size: 14, color: AppColors.textSecondary),
                        const SizedBox(width: 4),
                        Text(coachName, style: TextStyle(fontSize: 12, color: AppColors.textSecondary)),
                      ],
                    ],
                  ),
                ],
              ),
            ),
            Icon(Icons.chevron_right_rounded, color: AppColors.textSecondary, size: 20),
          ],
        ),
      ),
    );
  }
}
