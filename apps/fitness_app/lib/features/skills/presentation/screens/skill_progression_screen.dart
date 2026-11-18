import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../../app/theme/app_colors.dart';
import '../../../../core/utils/exercise_label.dart';
import '../../../exercises/presentation/providers/exercise_provider.dart';
import '../providers/skill_provider.dart';

/// Gymnastics progression tracker for a single exercise (spec §3.2).
///
/// Pushed via Navigator.push from ExerciseDetailScreen and SkillsHubScreen.
class SkillProgressionScreen extends ConsumerWidget {
  const SkillProgressionScreen({super.key, required this.exerciseId});
  final String exerciseId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final exercise = ref.watch(exerciseDetailProvider(exerciseId));
    final progressions = ref.watch(progressionsForExerciseProvider(exerciseId));
    final myProgress = ref.watch(mySkillProgressProvider);

    final ex = exercise.valueOrNull;
    final bilingual = exerciseBilingual(ex?.nameEs, ex?.name);
    final title = bilingual.isEmpty ? 'Progresión' : bilingual;

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.background,
        elevation: 0,
        foregroundColor: AppColors.textPrimary,
        title: Text(title,
            style: GoogleFonts.spaceGrotesk(
                fontSize: 18, fontWeight: FontWeight.w600)),
      ),
      body: progressions.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => Center(
            child: Text('Error al cargar progresiones: $e',
                style: TextStyle(color: AppColors.textSecondary))),
        data: (steps) {
          if (steps.isEmpty) {
            return const _EmptyState();
          }
          final progressRows = myProgress.valueOrNull ?? const [];
          final byProgression = <String, Map<String, dynamic>>{
            for (final r in progressRows)
              (r['progression_id'] as String): r,
          };
          final achievedCount = steps.where((s) {
            final r = byProgression[s['id'] as String];
            return r != null && r['achieved'] == true;
          }).length;

          return RefreshIndicator(
            onRefresh: () async {
              ref.invalidate(progressionsForExerciseProvider(exerciseId));
              ref.invalidate(mySkillProgressProvider);
            },
            child: ListView(
              padding: const EdgeInsets.fromLTRB(20, 12, 20, 32),
              children: [
                _CounterCard(achieved: achievedCount, total: steps.length),
                const SizedBox(height: 20),
                Text('Pasos de la progresión',
                    style: GoogleFonts.spaceGrotesk(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        color: AppColors.textPrimary)),
                const SizedBox(height: 12),
                ...List.generate(steps.length, (i) {
                  final step = steps[i];
                  final row = byProgression[step['id'] as String];
                  final achieved = row != null && row['achieved'] == true;
                  return _StepCard(
                    index: i + 1,
                    step: step,
                    progress: row,
                    achieved: achieved,
                    onTap: () => _openStepSheet(context, ref, step, row, achieved),
                  );
                }),
              ],
            ),
          );
        },
      ),
    );
  }

  Future<void> _openStepSheet(
    BuildContext context,
    WidgetRef ref,
    Map<String, dynamic> step,
    Map<String, dynamic>? progress,
    bool achieved,
  ) async {
    await showModalBottomSheet<void>(
      context: context,
      backgroundColor: AppColors.surface,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (ctx) => _StepSheet(
        step: step,
        progress: progress,
        achieved: achieved,
        onSave: (isAchieved, reps, durationMs, notes) async {
          await ref.read(skillActionsProvider).toggle(
                step['id'] as String,
                isAchieved,
                reps: reps,
                durationMs: durationMs,
                notes: notes,
              );
          if (ctx.mounted) Navigator.of(ctx).pop();
        },
      ),
    );
  }
}

class _CounterCard extends StatelessWidget {
  const _CounterCard({required this.achieved, required this.total});
  final int achieved;
  final int total;

  @override
  Widget build(BuildContext context) {
    final fraction = total == 0 ? 0.0 : achieved / total;
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [AppColors.primary, AppColors.primaryDark],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(18),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Habilidades registradas',
              style: GoogleFonts.inter(
                  fontSize: 13,
                  fontWeight: FontWeight.w500,
                  color: Colors.white.withValues(alpha: 0.85))),
          const SizedBox(height: 6),
          Text('$achieved / $total',
              style: GoogleFonts.spaceGrotesk(
                  fontSize: 30,
                  fontWeight: FontWeight.w700,
                  color: Colors.white)),
          const SizedBox(height: 14),
          ClipRRect(
            borderRadius: BorderRadius.circular(8),
            child: LinearProgressIndicator(
              value: fraction,
              minHeight: 8,
              backgroundColor: Colors.white.withValues(alpha: 0.25),
              valueColor: const AlwaysStoppedAnimation(Colors.white),
            ),
          ),
        ],
      ),
    );
  }
}

class _StepCard extends StatelessWidget {
  const _StepCard({
    required this.index,
    required this.step,
    required this.progress,
    required this.achieved,
    required this.onTap,
  });

  final int index;
  final Map<String, dynamic> step;
  final Map<String, dynamic>? progress;
  final bool achieved;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final reps = progress?['reps'] as int?;
    final durationMs = progress?['duration_ms'] as int?;
    final meta = <String>[
      if (reps != null) '$reps reps',
      if (durationMs != null) '${(durationMs / 1000).toStringAsFixed(0)} s',
    ].join(' · ');

    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: GestureDetector(
        onTap: onTap,
        child: Container(
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            color: AppColors.surface,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
                color: achieved ? AppColors.success : AppColors.border,
                width: achieved ? 1.4 : 1),
          ),
          child: Row(
            children: [
              Container(
                width: 34,
                height: 34,
                decoration: BoxDecoration(
                  color: achieved
                      ? AppColors.success
                      : AppColors.primaryLight,
                  shape: BoxShape.circle,
                ),
                child: Center(
                  child: achieved
                      ? const Icon(Icons.check_rounded,
                          color: Colors.white, size: 20)
                      : Text('$index',
                          style: TextStyle(
                              fontWeight: FontWeight.w700,
                              color: AppColors.primary)),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text((step['name'] ?? '') as String,
                        style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w600,
                            color: AppColors.textPrimary)),
                    if (step['description'] != null) ...[
                      const SizedBox(height: 3),
                      Text(step['description'] as String,
                          style: TextStyle(
                              fontSize: 12.5,
                              color: AppColors.textSecondary,
                              height: 1.35)),
                    ],
                    if (meta.isNotEmpty) ...[
                      const SizedBox(height: 5),
                      Text(meta,
                          style: TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.w600,
                              color: AppColors.success)),
                    ],
                  ],
                ),
              ),
              Icon(
                achieved
                    ? Icons.check_circle_rounded
                    : Icons.radio_button_unchecked_rounded,
                color: achieved ? AppColors.success : AppColors.border,
                size: 24,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _StepSheet extends StatefulWidget {
  const _StepSheet({
    required this.step,
    required this.progress,
    required this.achieved,
    required this.onSave,
  });

  final Map<String, dynamic> step;
  final Map<String, dynamic>? progress;
  final bool achieved;
  final Future<void> Function(
      bool achieved, int? reps, int? durationMs, String? notes) onSave;

  @override
  State<_StepSheet> createState() => _StepSheetState();
}

class _StepSheetState extends State<_StepSheet> {
  late final TextEditingController _repsController;
  late final TextEditingController _secondsController;
  late final TextEditingController _notesController;
  bool _saving = false;

  @override
  void initState() {
    super.initState();
    final p = widget.progress;
    _repsController =
        TextEditingController(text: (p?['reps'] as int?)?.toString() ?? '');
    final durMs = p?['duration_ms'] as int?;
    _secondsController = TextEditingController(
        text: durMs != null ? (durMs / 1000).round().toString() : '');
    _notesController =
        TextEditingController(text: (p?['notes'] as String?) ?? '');
  }

  @override
  void dispose() {
    _repsController.dispose();
    _secondsController.dispose();
    _notesController.dispose();
    super.dispose();
  }

  Future<void> _save(bool achieved) async {
    setState(() => _saving = true);
    final reps = int.tryParse(_repsController.text.trim());
    final seconds = int.tryParse(_secondsController.text.trim());
    final notes = _notesController.text.trim();
    await widget.onSave(
      achieved,
      achieved ? reps : null,
      achieved && seconds != null ? seconds * 1000 : null,
      achieved && notes.isNotEmpty ? notes : null,
    );
    if (mounted) setState(() => _saving = false);
  }

  @override
  Widget build(BuildContext context) {
    final bottomInset = MediaQuery.of(context).viewInsets.bottom;
    return Padding(
      padding: EdgeInsets.fromLTRB(20, 18, 20, 20 + bottomInset),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Center(
            child: Container(
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: AppColors.border,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
          ),
          const SizedBox(height: 16),
          Text((widget.step['name'] ?? '') as String,
              style: GoogleFonts.spaceGrotesk(
                  fontSize: 18,
                  fontWeight: FontWeight.w700,
                  color: AppColors.textPrimary)),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: _Field(
                  label: 'Repeticiones',
                  controller: _repsController,
                  hint: 'Ej. 5',
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _Field(
                  label: 'Duración (s)',
                  controller: _secondsController,
                  hint: 'Ej. 30',
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),
          _Field(
            label: 'Notas',
            controller: _notesController,
            hint: 'Opcional',
            keyboard: TextInputType.text,
          ),
          const SizedBox(height: 20),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: _saving ? null : () => _save(true),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.success,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 14),
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12)),
              ),
              child: _saving
                  ? const SizedBox(
                      width: 18,
                      height: 18,
                      child: CircularProgressIndicator(
                          strokeWidth: 2, color: Colors.white))
                  : Text(widget.achieved
                      ? 'Actualizar logro'
                      : 'Marcar como lograda'),
            ),
          ),
          if (widget.achieved) ...[
            const SizedBox(height: 10),
            SizedBox(
              width: double.infinity,
              child: OutlinedButton(
                onPressed: _saving ? null : () => _save(false),
                style: OutlinedButton.styleFrom(
                  foregroundColor: AppColors.error,
                  side: BorderSide(color: AppColors.error),
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12)),
                ),
                child: const Text('Quitar logro'),
              ),
            ),
          ],
        ],
      ),
    );
  }
}

class _Field extends StatelessWidget {
  const _Field({
    required this.label,
    required this.controller,
    required this.hint,
    this.keyboard = TextInputType.number,
  });

  final String label;
  final TextEditingController controller;
  final String hint;
  final TextInputType keyboard;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label,
            style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w600,
                color: AppColors.textSecondary)),
        const SizedBox(height: 6),
        TextField(
          controller: controller,
          keyboardType: keyboard,
          inputFormatters: keyboard == TextInputType.number
              ? [FilteringTextInputFormatter.digitsOnly]
              : null,
          decoration: InputDecoration(hintText: hint),
        ),
      ],
    );
  }
}

class _EmptyState extends StatelessWidget {
  const _EmptyState();

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: EdgeInsets.all(32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.timeline_rounded,
                size: 48, color: AppColors.textSecondary),
            SizedBox(height: 12),
            Text('Este ejercicio aún no tiene progresiones',
                textAlign: TextAlign.center,
                style: TextStyle(color: AppColors.textSecondary)),
          ],
        ),
      ),
    );
  }
}
