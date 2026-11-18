import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../../app/theme/app_colors.dart';
import '../../../../core/utils/exercise_label.dart';
import '../providers/skill_provider.dart';
import 'skill_progression_screen.dart';

/// Hub listing gymnastics exercises that have progressions, each with the
/// athlete's X/N progress. Reachable from the Progress area; self-contained
/// and pushable via Navigator (route to be wired by the coordinator).
class SkillsHubScreen extends ConsumerWidget {
  const SkillsHubScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final exercises = ref.watch(gymnasticsExercisesProvider);
    final myProgress = ref.watch(mySkillProgressProvider);

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.background,
        elevation: 0,
        foregroundColor: AppColors.textPrimary,
        title: Text('Habilidades',
            style: GoogleFonts.spaceGrotesk(
                fontSize: 18, fontWeight: FontWeight.w600)),
      ),
      body: exercises.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => Center(
            child: Text('Error: $e',
                style: TextStyle(color: AppColors.textSecondary))),
        data: (list) {
          if (list.isEmpty) {
            return Center(
              child: Padding(
                padding: EdgeInsets.all(32),
                child: Text(
                    'Aún no hay progresiones de gimnasia disponibles',
                    textAlign: TextAlign.center,
                    style: TextStyle(color: AppColors.textSecondary)),
              ),
            );
          }
          final progressRows = myProgress.valueOrNull ?? const [];
          final achievedIds = <String>{
            for (final r in progressRows)
              if (r['achieved'] == true) r['progression_id'] as String,
          };

          return RefreshIndicator(
            onRefresh: () async {
              ref.invalidate(gymnasticsExercisesProvider);
              ref.invalidate(mySkillProgressProvider);
            },
            child: ListView(
              padding: const EdgeInsets.fromLTRB(20, 12, 20, 32),
              children: [
                Text(
                    'Domina las progresiones de gimnasia paso a paso',
                    style: GoogleFonts.inter(
                        fontSize: 13.5,
                        color: AppColors.textSecondary,
                        height: 1.4)),
                const SizedBox(height: 16),
                ...list.map((ex) {
                  final progs = (ex['skill_progressions'] as List?) ?? const [];
                  final total = progs.length;
                  final achieved = progs
                      .where((p) =>
                          achievedIds.contains((p as Map)['id'] as String))
                      .length;
                  final name = exerciseBilingualFromMap(ex);
                  return _SkillTile(
                    name: name,
                    achieved: achieved,
                    total: total,
                    onTap: () => Navigator.of(context).push(
                      MaterialPageRoute(
                        builder: (_) => SkillProgressionScreen(
                            exerciseId: ex['id'] as String),
                      ),
                    ),
                  );
                }),
              ],
            ),
          );
        },
      ),
    );
  }
}

class _SkillTile extends StatelessWidget {
  const _SkillTile({
    required this.name,
    required this.achieved,
    required this.total,
    required this.onTap,
  });

  final String name;
  final int achieved;
  final int total;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final complete = total > 0 && achieved == total;
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: GestureDetector(
        onTap: onTap,
        child: Container(
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            color: AppColors.surface,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: AppColors.border),
          ),
          child: Row(
            children: [
              Container(
                width: 44,
                height: 44,
                decoration: BoxDecoration(
                  color: complete
                      ? AppColors.success.withValues(alpha: 0.12)
                      : AppColors.primaryLight,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(
                  complete
                      ? Icons.emoji_events_rounded
                      : Icons.self_improvement_rounded,
                  color: complete ? AppColors.success : AppColors.primary,
                  size: 22,
                ),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(name,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                            fontSize: 15,
                            fontWeight: FontWeight.w600,
                            color: AppColors.textPrimary)),
                    const SizedBox(height: 6),
                    Row(
                      children: [
                        Expanded(
                          child: ClipRRect(
                            borderRadius: BorderRadius.circular(6),
                            child: LinearProgressIndicator(
                              value: total == 0 ? 0 : achieved / total,
                              minHeight: 6,
                              backgroundColor: AppColors.border,
                              valueColor: AlwaysStoppedAnimation(
                                  complete
                                      ? AppColors.success
                                      : AppColors.primary),
                            ),
                          ),
                        ),
                        const SizedBox(width: 10),
                        Text('$achieved / $total',
                            style: TextStyle(
                                fontSize: 12.5,
                                fontWeight: FontWeight.w700,
                                color: AppColors.textSecondary)),
                      ],
                    ),
                  ],
                ),
              ),
              Icon(Icons.chevron_right_rounded,
                  color: AppColors.textSecondary, size: 20),
            ],
          ),
        ),
      ),
    );
  }
}
