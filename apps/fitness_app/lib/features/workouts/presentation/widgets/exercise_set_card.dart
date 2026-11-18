import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../../app/theme/app_colors.dart';

class ExerciseSetCard extends StatelessWidget {
  const ExerciseSetCard({
    super.key,
    required this.exerciseName,
    required this.sets,
  });

  final String exerciseName;
  final List<Widget> sets;

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: AppColors.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            exerciseName,
            style: GoogleFonts.spaceGrotesk(
              fontSize: 16,
              fontWeight: FontWeight.w600,
              color: AppColors.textPrimary,
            ),
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              SizedBox(width: 32, child: Text('Set', textAlign: TextAlign.center, style: TextStyle(fontSize: 11, fontWeight: FontWeight.w600, color: AppColors.textSecondary))),
              SizedBox(width: 8),
              Expanded(child: Text('Peso', textAlign: TextAlign.center, style: TextStyle(fontSize: 11, fontWeight: FontWeight.w600, color: AppColors.textSecondary))),
              SizedBox(width: 8),
              Expanded(child: Text('Reps', textAlign: TextAlign.center, style: TextStyle(fontSize: 11, fontWeight: FontWeight.w600, color: AppColors.textSecondary))),
              SizedBox(width: 44),
            ],
          ),
          const SizedBox(height: 8),
          ...sets,
        ],
      ),
    );
  }
}
