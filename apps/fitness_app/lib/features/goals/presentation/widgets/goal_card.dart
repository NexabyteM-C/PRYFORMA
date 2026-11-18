import 'package:domain_models/domain_models.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../../app/theme/app_colors.dart';
import '../../../../core/utils/exercise_label.dart';
import '../goal_formatting.dart';

class GoalCard extends StatelessWidget {
  const GoalCard({super.key, required this.goal, this.onTap});
  final Goal goal;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final current = goal.currentValue ?? goal.initialValue ?? 0.0;
    final progress =
        goal.targetValue > 0 ? (current / goal.targetValue).clamp(0.0, 1.0) : 0.0;
    final unit = goal.unit ?? '';
    final achieved = goal.status == 'achieved';

    return Material(
      color: AppColors.surface,
      borderRadius: BorderRadius.circular(18),
      child: InkWell(
        borderRadius: BorderRadius.circular(18),
        onTap: onTap,
        child: Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(18),
            border: Border.all(color: AppColors.border),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Expanded(
                    child: Text(
                      goal.exercise != null
                          ? exerciseBilingual(
                              goal.exercise!.nameEs, goal.exercise!.name)
                          : goalTypeLabel(goal.goalType),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: GoogleFonts.inter(
                        fontSize: 15,
                        fontWeight: FontWeight.w600,
                        color: AppColors.textPrimary,
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Text(
                    '${(progress * 100).toInt()}%',
                    style: GoogleFonts.spaceGrotesk(
                      fontSize: 18,
                      fontWeight: FontWeight.w700,
                      color: achieved ? AppColors.success : AppColors.primary,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 4),
              Text(
                goalTypeLabel(goal.goalType),
                style: GoogleFonts.inter(fontSize: 12, color: AppColors.textSecondary),
              ),
              const SizedBox(height: 12),
              ClipRRect(
                borderRadius: BorderRadius.circular(6),
                child: LinearProgressIndicator(
                  value: progress,
                  minHeight: 8,
                  backgroundColor: AppColors.primaryLightest,
                  color: achieved ? AppColors.success : AppColors.primary,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                '${formatNumber(current)} / ${formatNumber(goal.targetValue)}${unit.isEmpty ? '' : ' $unit'}',
                style: GoogleFonts.inter(fontSize: 12, color: AppColors.textSecondary),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
