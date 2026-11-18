import 'package:domain_models/domain_models.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import '../../../../app/theme/app_colors.dart';
import '../../../../core/utils/exercise_label.dart';
import '../../../../core/utils/rm_calculator.dart';
import '../providers/workout_provider.dart';

class WorkoutListScreen extends ConsumerWidget {
  const WorkoutListScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final asyncWorkouts = ref.watch(workoutListProvider);

    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: RefreshIndicator(
          onRefresh: () async => ref.refresh(workoutListProvider.future),
          child: asyncWorkouts.when(
            loading: () => const Center(child: CircularProgressIndicator()),
            error: (e, _) => _error('$e', () => ref.invalidate(workoutListProvider)),
            data: (sessions) => _buildContent(context, sessions),
          ),
        ),
      ),
    );
  }

  Widget _buildContent(BuildContext context, List<WorkoutSession> sessions) {
    return SingleChildScrollView(
      physics: const AlwaysScrollableScrollPhysics(),
      padding: const EdgeInsets.fromLTRB(20, 16, 20, 96),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Entrenar',
            style: GoogleFonts.spaceGrotesk(
              fontSize: 28,
              fontWeight: FontWeight.w700,
              letterSpacing: -0.56,
              color: AppColors.textPrimary,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            'Tu historial de entrenamientos',
            style: GoogleFonts.inter(fontSize: 14, color: AppColors.textSecondary),
          ),
          const SizedBox(height: 20),
          if (sessions.isEmpty)
            _empty()
          else
            ...sessions.map((s) => Padding(
                  padding: const EdgeInsets.only(bottom: 10),
                  child: _WorkoutCard(
                    session: s,
                    onTap: () => _showDetail(context, s.id),
                  ),
                )),
        ],
      ),
    );
  }

  void _showDetail(BuildContext context, String id) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => _WorkoutDetailSheet(sessionId: id),
    );
  }

  Widget _empty() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(vertical: 40, horizontal: 20),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.border),
      ),
      child: Column(
        children: [
          Icon(Icons.fitness_center_rounded, size: 48, color: AppColors.textSecondary),
          const SizedBox(height: 12),
          Text(
            'Sin entrenamientos',
            style: GoogleFonts.inter(
              fontSize: 15,
              fontWeight: FontWeight.w600,
              color: AppColors.textPrimary,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            'Tus entrenamientos aparecerán aquí cuando registres los '
            'resultados de una clase desde Inicio → "Iniciar clase".',
            textAlign: TextAlign.center,
            style: GoogleFonts.inter(fontSize: 13, color: AppColors.textSecondary),
          ),
        ],
      ),
    );
  }

  Widget _error(String msg, VoidCallback onRetry) {
    return ListView(
      padding: const EdgeInsets.all(24),
      children: [
        const SizedBox(height: 80),
        Icon(Icons.error_outline_rounded, size: 48, color: AppColors.error),
        const SizedBox(height: 12),
        Text(
          'No se pudieron cargar los entrenamientos',
          textAlign: TextAlign.center,
          style: GoogleFonts.inter(
            fontSize: 15,
            fontWeight: FontWeight.w600,
            color: AppColors.textPrimary,
          ),
        ),
        const SizedBox(height: 6),
        Text(
          msg,
          textAlign: TextAlign.center,
          style: GoogleFonts.inter(fontSize: 12, color: AppColors.textSecondary),
        ),
        const SizedBox(height: 16),
        Center(child: OutlinedButton(onPressed: onRetry, child: const Text('Reintentar'))),
      ],
    );
  }
}

class _WorkoutCard extends StatelessWidget {
  const _WorkoutCard({required this.session, required this.onTap});

  final WorkoutSession session;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final count = session.exercises?.length ?? 0;
    final durationMin = session.durationMs != null ? (session.durationMs! / 60000).round() : null;

    return Material(
      color: AppColors.surface,
      borderRadius: BorderRadius.circular(16),
      child: InkWell(
        borderRadius: BorderRadius.circular(16),
        onTap: onTap,
        child: Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: AppColors.border),
          ),
          child: Row(
            children: [
              Container(
                width: 44,
                height: 44,
                decoration: BoxDecoration(
                  color: AppColors.primaryLight,
                  borderRadius: BorderRadius.circular(14),
                ),
                child: Icon(Icons.fitness_center_rounded,
                    color: AppColors.primary, size: 22),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      session.title ?? 'Entrenamiento',
                      style: GoogleFonts.inter(
                        fontSize: 15,
                        fontWeight: FontWeight.w600,
                        color: AppColors.textPrimary,
                      ),
                    ),
                    const SizedBox(height: 3),
                    Text(
                      [
                        DateFormat("d MMM y", 'es').format(session.performedAt),
                        '$count ejercicios',
                        if (durationMin != null) '$durationMin min',
                      ].join(' · '),
                      style: GoogleFonts.inter(fontSize: 12, color: AppColors.textSecondary),
                    ),
                  ],
                ),
              ),
              Icon(Icons.chevron_right_rounded, color: AppColors.textSecondary),
            ],
          ),
        ),
      ),
    );
  }
}

class _WorkoutDetailSheet extends ConsumerWidget {
  const _WorkoutDetailSheet({required this.sessionId});
  final String sessionId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final asyncSession = ref.watch(workoutDetailProvider(sessionId));

    return DraggableScrollableSheet(
      initialChildSize: 0.7,
      minChildSize: 0.4,
      maxChildSize: 0.92,
      expand: false,
      builder: (context, controller) => Container(
        decoration: BoxDecoration(
          color: AppColors.background,
          borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
        ),
        child: asyncSession.when(
          loading: () => const Center(child: CircularProgressIndicator()),
          error: (e, _) => Center(
            child: Padding(
              padding: const EdgeInsets.all(24),
              child: Text(
                'No se pudo cargar el detalle.\n$e',
                textAlign: TextAlign.center,
                style: GoogleFonts.inter(fontSize: 13, color: AppColors.textSecondary),
              ),
            ),
          ),
          data: (session) => _content(controller, session),
        ),
      ),
    );
  }

  Widget _content(ScrollController controller, WorkoutSession session) {
    final exercises = session.exercises ?? [];
    return ListView(
      controller: controller,
      padding: const EdgeInsets.fromLTRB(20, 12, 20, 24),
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
        Text(
          session.title ?? 'Entrenamiento',
          style: GoogleFonts.spaceGrotesk(
            fontSize: 22,
            fontWeight: FontWeight.w700,
            color: AppColors.textPrimary,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          DateFormat("EEEE d 'de' MMMM, y", 'es').format(session.performedAt),
          style: GoogleFonts.inter(fontSize: 13, color: AppColors.textSecondary),
        ),
        if (session.notes != null && session.notes!.trim().isNotEmpty) ...[
          const SizedBox(height: 12),
          Text(
            session.notes!,
            style: GoogleFonts.inter(fontSize: 14, height: 1.5, color: AppColors.textSecondary),
          ),
        ],
        const SizedBox(height: 20),
        if (exercises.isEmpty)
          Text(
            'Este entrenamiento no tiene ejercicios registrados.',
            style: GoogleFonts.inter(fontSize: 13, color: AppColors.textSecondary),
          )
        else
          ...exercises.map(_exerciseBlock),
      ],
    );
  }

  Widget _exerciseBlock(WorkoutExercise we) {
    final sets = (we.sets ?? []).toList()
      ..sort((a, b) => a.setNumber.compareTo(b.setNumber));
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            () {
              final b = exerciseBilingual(we.exercise?.nameEs, we.exercise?.name);
              return b.isEmpty ? 'Ejercicio' : b;
            }(),
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
            style: GoogleFonts.inter(
              fontSize: 15,
              fontWeight: FontWeight.w600,
              color: AppColors.textPrimary,
            ),
          ),
          const SizedBox(height: 8),
          if (sets.isEmpty)
            Text(
              'Sin series',
              style: GoogleFonts.inter(fontSize: 12, color: AppColors.textSecondary),
            )
          else
            ...sets.map((s) {
              final parts = <String>[];
              if (s.weightKg != null) {
                parts.add(RmCalculator.formatLb(RmCalculator.kgToLb(s.weightKg!)));
              }
              if (s.reps != null) parts.add('${s.reps} reps');
              if (s.durationMs != null) {
                parts.add('${(s.durationMs! / 1000).round()} s');
              }
              return Padding(
                padding: const EdgeInsets.only(bottom: 4),
                child: Row(
                  children: [
                    SizedBox(
                      width: 48,
                      child: Text(
                        'Set ${s.setNumber}',
                        style: GoogleFonts.inter(fontSize: 12, color: AppColors.textSecondary),
                      ),
                    ),
                    Expanded(
                      child: Text(
                        parts.isEmpty ? '—' : parts.join(' · '),
                        style: GoogleFonts.inter(
                          fontSize: 13,
                          fontWeight: FontWeight.w500,
                          color: AppColors.textPrimary,
                        ),
                      ),
                    ),
                    if (s.isWarmup)
                      Text(
                        'Calent.',
                        style: GoogleFonts.inter(fontSize: 11, color: AppColors.secondaryAccent),
                      ),
                  ],
                ),
              );
            }),
        ],
      ),
    );
  }
}
