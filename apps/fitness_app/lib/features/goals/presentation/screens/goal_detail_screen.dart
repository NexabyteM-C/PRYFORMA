import 'package:domain_models/domain_models.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import '../../../../app/theme/app_colors.dart';
import '../../../../core/utils/exercise_label.dart';
import '../goal_formatting.dart';
import '../providers/goal_provider.dart';
import '../widgets/goal_form_sheet.dart';

class GoalDetailScreen extends ConsumerWidget {
  const GoalDetailScreen({super.key, required this.goalId});

  final String goalId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final asyncGoal = ref.watch(goalDetailProvider(goalId));

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.background,
        elevation: 0,
        iconTheme: IconThemeData(color: AppColors.textPrimary),
        title: Text(
          'Objetivo',
          style: GoogleFonts.spaceGrotesk(
            fontSize: 20,
            fontWeight: FontWeight.w700,
            color: AppColors.textPrimary,
          ),
        ),
        actions: [
          asyncGoal.maybeWhen(
            data: (goal) => PopupMenuButton<String>(
              icon: Icon(Icons.more_vert_rounded, color: AppColors.textPrimary),
              onSelected: (v) => _onMenu(context, ref, goal, v),
              itemBuilder: (_) => [
                const PopupMenuItem(value: 'edit', child: Text('Editar')),
                if (goal.status != 'achieved')
                  const PopupMenuItem(value: 'achieve', child: Text('Marcar como logrado')),
                PopupMenuItem(
                  value: 'delete',
                  child: Text('Eliminar', style: TextStyle(color: AppColors.error)),
                ),
              ],
            ),
            orElse: () => const SizedBox.shrink(),
          ),
        ],
      ),
      body: SafeArea(
        child: asyncGoal.when(
          loading: () => const Center(child: CircularProgressIndicator()),
          error: (e, _) => Center(
            child: Padding(
              padding: const EdgeInsets.all(24),
              child: Text(
                'No se pudo cargar el objetivo.\n$e',
                textAlign: TextAlign.center,
                style: GoogleFonts.inter(fontSize: 13, color: AppColors.textSecondary),
              ),
            ),
          ),
          data: (goal) => _buildContent(context, ref, goal),
        ),
      ),
    );
  }

  Future<void> _onMenu(
      BuildContext context, WidgetRef ref, Goal goal, String action) async {
    switch (action) {
      case 'edit':
        final saved = await showGoalFormSheet(context, existing: goal);
        if (saved == true) {
          ref.invalidate(goalDetailProvider(goalId));
          ref.invalidate(goalListProvider);
        }
        break;
      case 'achieve':
        await ref.read(goalRemoteProvider).update(goal.id, {
          'status': 'achieved',
          'achieved_at': DateTime.now().toIso8601String(),
          'current_value': goal.targetValue,
        });
        ref.invalidate(goalDetailProvider(goalId));
        ref.invalidate(goalListProvider);
        break;
      case 'delete':
        final confirm = await showDialog<bool>(
          context: context,
          builder: (dialogCtx) => AlertDialog(
            title: const Text('Eliminar objetivo'),
            content: const Text('¿Seguro que deseas eliminar este objetivo?'),
            actions: [
              TextButton(
                onPressed: () => Navigator.of(dialogCtx).pop(false),
                child: const Text('Cancelar'),
              ),
              TextButton(
                onPressed: () => Navigator.of(dialogCtx).pop(true),
                child: Text('Eliminar', style: TextStyle(color: AppColors.error)),
              ),
            ],
          ),
        );
        if (confirm == true) {
          await ref.read(goalRemoteProvider).delete(goal.id);
          ref.invalidate(goalListProvider);
          if (context.mounted) Navigator.of(context).pop();
        }
        break;
    }
  }

  Widget _buildContent(BuildContext context, WidgetRef ref, Goal goal) {
    final current = goal.currentValue ?? goal.initialValue ?? 0.0;
    final progress =
        goal.targetValue > 0 ? (current / goal.targetValue).clamp(0.0, 1.0) : 0.0;
    final unit = goal.unit ?? '';
    final achieved = goal.status == 'achieved';
    final milestones = goal.milestones ?? [];

    return ListView(
      padding: const EdgeInsets.fromLTRB(20, 12, 20, 32),
      children: [
        Text(
          goal.exercise != null
              ? exerciseBilingual(goal.exercise!.nameEs, goal.exercise!.name)
              : goalTypeLabel(goal.goalType),
          style: GoogleFonts.spaceGrotesk(
            fontSize: 24,
            fontWeight: FontWeight.w700,
            color: AppColors.textPrimary,
          ),
        ),
        const SizedBox(height: 6),
        Row(
          children: [
            _StatusPill(status: goal.status),
            const SizedBox(width: 8),
            Text(
              goalTypeLabel(goal.goalType),
              style: GoogleFonts.inter(fontSize: 13, color: AppColors.textSecondary),
            ),
            if (goal.exercise != null) ...[
              const SizedBox(width: 4),
              Flexible(
                child: Text(
                  '· ${exerciseBilingual(goal.exercise!.nameEs, goal.exercise!.name)}',
                  overflow: TextOverflow.ellipsis,
                  style: GoogleFonts.inter(fontSize: 13, color: AppColors.textSecondary),
                ),
              ),
            ],
          ],
        ),
        const SizedBox(height: 20),

        Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: AppColors.surface,
            borderRadius: BorderRadius.circular(18),
            border: Border.all(color: AppColors.border),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text(
                    '${formatNumber(current)}${unit.isEmpty ? '' : ' $unit'}',
                    style: GoogleFonts.spaceGrotesk(
                      fontSize: 28,
                      fontWeight: FontWeight.w700,
                      color: AppColors.textPrimary,
                    ),
                  ),
                  const SizedBox(width: 6),
                  Padding(
                    padding: const EdgeInsets.only(bottom: 4),
                    child: Text(
                      'de ${formatNumber(goal.targetValue)}${unit.isEmpty ? '' : ' $unit'}',
                      style: GoogleFonts.inter(fontSize: 14, color: AppColors.textSecondary),
                    ),
                  ),
                  const Spacer(),
                  Text(
                    '${(progress * 100).toInt()}%',
                    style: GoogleFonts.spaceGrotesk(
                      fontSize: 22,
                      fontWeight: FontWeight.w700,
                      color: achieved ? AppColors.success : AppColors.primary,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 14),
              ClipRRect(
                borderRadius: BorderRadius.circular(6),
                child: LinearProgressIndicator(
                  value: progress,
                  minHeight: 10,
                  backgroundColor: AppColors.primaryLightest,
                  color: achieved ? AppColors.success : AppColors.primary,
                ),
              ),
              if (goal.targetDate != null) ...[
                const SizedBox(height: 14),
                Row(
                  children: [
                    Icon(Icons.calendar_today_rounded,
                        size: 15, color: AppColors.textSecondary),
                    const SizedBox(width: 6),
                    Text(
                      'Meta: ${DateFormat("d 'de' MMMM, y", 'es').format(goal.targetDate!)}',
                      style: GoogleFonts.inter(fontSize: 13, color: AppColors.textSecondary),
                    ),
                  ],
                ),
              ],
              if (goal.achievedAt != null) ...[
                const SizedBox(height: 8),
                Row(
                  children: [
                    Icon(Icons.check_circle_rounded, size: 15, color: AppColors.success),
                    const SizedBox(width: 6),
                    Text(
                      'Logrado: ${DateFormat("d 'de' MMMM, y", 'es').format(goal.achievedAt!)}',
                      style: GoogleFonts.inter(fontSize: 13, color: AppColors.success),
                    ),
                  ],
                ),
              ],
            ],
          ),
        ),

        const SizedBox(height: 24),
        Text(
          'Hitos',
          style: GoogleFonts.spaceGrotesk(
            fontSize: 16,
            fontWeight: FontWeight.w600,
            color: AppColors.textPrimary,
          ),
        ),
        const SizedBox(height: 12),
        if (milestones.isEmpty)
          Text(
            'Aún no hay hitos registrados.',
            style: GoogleFonts.inter(fontSize: 13, color: AppColors.textSecondary),
          )
        else
          ...(milestones.toList()
                ..sort((a, b) => a.achievedAt.compareTo(b.achievedAt)))
              .map((m) => Padding(
                    padding: const EdgeInsets.only(bottom: 10),
                    child: _MilestoneRow(milestone: m, unit: unit),
                  )),

        const SizedBox(height: 24),
        if (!achieved)
          SizedBox(
            width: double.infinity,
            height: 50,
            child: ElevatedButton.icon(
              onPressed: () => _onMenu(context, ref, goal, 'achieve'),
              icon: const Icon(Icons.check_rounded),
              label: const Text('Marcar como logrado'),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.success,
                foregroundColor: Colors.white,
                elevation: 0,
                textStyle: GoogleFonts.inter(fontSize: 15, fontWeight: FontWeight.w600),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              ),
            ),
          ),
        const SizedBox(height: 10),
        SizedBox(
          width: double.infinity,
          height: 50,
          child: OutlinedButton.icon(
            onPressed: () => _onMenu(context, ref, goal, 'edit'),
            icon: const Icon(Icons.edit_outlined),
            label: const Text('Editar objetivo'),
            style: OutlinedButton.styleFrom(
              foregroundColor: AppColors.primary,
              side: BorderSide(color: AppColors.primary),
              textStyle: GoogleFonts.inter(fontSize: 15, fontWeight: FontWeight.w600),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            ),
          ),
        ),
      ],
    );
  }
}

class _StatusPill extends StatelessWidget {
  const _StatusPill({required this.status});
  final String status;

  @override
  Widget build(BuildContext context) {
    final color = switch (status) {
      'achieved' => AppColors.success,
      'abandoned' => AppColors.error,
      'paused' => AppColors.warningText,
      _ => AppColors.primary,
    };
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 3),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Text(
        goalStatusLabel(status),
        style: GoogleFonts.inter(fontSize: 12, fontWeight: FontWeight.w700, color: color),
      ),
    );
  }
}

class _MilestoneRow extends StatelessWidget {
  const _MilestoneRow({required this.milestone, required this.unit});
  final GoalMilestone milestone;
  final String unit;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppColors.border),
      ),
      child: Row(
        children: [
          Icon(Icons.flag_rounded, size: 18, color: AppColors.primary),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  '${formatNumber(milestone.value)}${unit.isEmpty ? '' : ' $unit'}',
                  style: GoogleFonts.inter(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: AppColors.textPrimary,
                  ),
                ),
                if (milestone.note != null && milestone.note!.isNotEmpty)
                  Text(
                    milestone.note!,
                    style: GoogleFonts.inter(fontSize: 12, color: AppColors.textSecondary),
                  ),
              ],
            ),
          ),
          Text(
            DateFormat('d MMM y', 'es').format(milestone.achievedAt),
            style: GoogleFonts.inter(fontSize: 12, color: AppColors.textSecondary),
          ),
        ],
      ),
    );
  }
}
