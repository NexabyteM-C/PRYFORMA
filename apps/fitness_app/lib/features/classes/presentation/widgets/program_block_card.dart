import 'package:domain_models/domain_models.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../../app/theme/app_colors.dart';
import '../../../../core/utils/exercise_label.dart';

class ProgramBlockCard extends StatefulWidget {
  const ProgramBlockCard({super.key, required this.block, this.athleteRMs});
  final ClassProgramBlock block;
  final Map<String, double>? athleteRMs;

  @override
  State<ProgramBlockCard> createState() => _ProgramBlockCardState();
}

class _ProgramBlockCardState extends State<ProgramBlockCard> {
  bool _expanded = true;

  @override
  Widget build(BuildContext context) {
    final exercises = widget.block.exercises ?? [];
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: AppColors.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          GestureDetector(
            onTap: () => setState(() => _expanded = !_expanded),
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Row(
                children: [
                  Container(
                    width: 32, height: 32,
                    decoration: BoxDecoration(
                      color: AppColors.primaryDark,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Center(
                      child: Text(
                        widget.block.blockType,
                        style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w700, color: Colors.white),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      widget.block.title,
                      style: GoogleFonts.spaceGrotesk(fontSize: 15, fontWeight: FontWeight.w600, color: AppColors.textPrimary),
                    ),
                  ),
                  Icon(_expanded ? Icons.expand_less_rounded : Icons.expand_more_rounded,
                      color: AppColors.textSecondary, size: 20),
                ],
              ),
            ),
          ),
          if (_expanded) ...[
            const Divider(height: 1),
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 12, 16, 16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  ...exercises.map((ex) => _buildExerciseRow(ex)),
                  if (widget.block.description != null && widget.block.description!.isNotEmpty) ...[
                    const SizedBox(height: 10),
                    Container(
                      padding: const EdgeInsets.all(10),
                      decoration: BoxDecoration(
                        color: AppColors.warningBackground,
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Icon(Icons.lightbulb_outline_rounded, size: 16, color: AppColors.warningText),
                          const SizedBox(width: 6),
                          Expanded(
                            child: Text(widget.block.description!, style: TextStyle(fontSize: 12, color: AppColors.warningText)),
                          ),
                        ],
                      ),
                    ),
                  ],
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildExerciseRow(ClassBlockExercise ex) {
    final rm = widget.athleteRMs?[ex.exerciseId];
    final loadText = ex.weightPrescription != null && rm != null
        ? '${ex.weightPrescription} (RM: ${rm.toStringAsFixed(0)} kg)'
        : ex.weightPrescription;

    final bilingual = exerciseBilingual(ex.exercise?.nameEs, ex.exercise?.name);
    final exerciseName = bilingual.isEmpty ? 'Ejercicio' : bilingual;

    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            flex: 3,
            child: Text(exerciseName,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w500)),
          ),
          Expanded(
            flex: 2,
            child: Text(
              '${ex.sets ?? '-'}×${ex.reps ?? '-'}',
              style: TextStyle(fontSize: 13, color: AppColors.textSecondary),
              textAlign: TextAlign.center,
            ),
          ),
          if (loadText != null)
            Expanded(
              flex: 2,
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                decoration: BoxDecoration(
                  color: AppColors.secondaryLight,
                  borderRadius: BorderRadius.circular(6),
                ),
                child: Text(loadText, style: TextStyle(fontSize: 11, fontWeight: FontWeight.w600, color: AppColors.secondaryAccent), textAlign: TextAlign.center),
              ),
            )
          else
            const Expanded(flex: 2, child: SizedBox()),
        ],
      ),
    );
  }
}
