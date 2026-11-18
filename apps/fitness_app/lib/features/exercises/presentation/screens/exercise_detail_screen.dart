import 'package:domain_models/domain_models.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import '../../../../app/theme/app_colors.dart';
import '../../../../core/utils/exercise_label.dart';
import '../../../../core/utils/rm_calculator.dart';
import '../../../skills/presentation/providers/skill_provider.dart';
import '../../../skills/presentation/screens/skill_progression_screen.dart';
import '../providers/exercise_provider.dart';

const _categoryLabels = {
  'halterofilia': 'Halterofilia',
  'fuerza': 'Fuerza',
  'gimnasia': 'Gimnasia',
  'funcional': 'Funcional',
  'cardio': 'Cardio',
};

class ExerciseDetailScreen extends ConsumerWidget {
  const ExerciseDetailScreen({super.key, required this.exerciseId});
  final String exerciseId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final detail = ref.watch(exerciseDetailProvider(exerciseId));

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.background,
        elevation: 0,
        foregroundColor: AppColors.textPrimary,
      ),
      body: detail.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => Center(
            child: Text('Error: $e',
                style: TextStyle(color: AppColors.textSecondary))),
        data: (exercise) {
          final variants = exercise.variants ?? const [];
          final metrics = exercise.metricDefinitions ?? const [];
          final displayName = exerciseBilingual(exercise.nameEs, exercise.name);
          final categoryLabel =
              _categoryLabels[exercise.category] ?? exercise.category;

          return SingleChildScrollView(
            padding: const EdgeInsets.fromLTRB(20, 0, 20, 32),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  displayName,
                  style: GoogleFonts.spaceGrotesk(
                    fontSize: 24,
                    fontWeight: FontWeight.w700,
                    letterSpacing: -0.48,
                    color: AppColors.textPrimary,
                  ),
                ),
                const SizedBox(height: 10),
                _Chip(label: categoryLabel),
                if (exercise.description?.isNotEmpty == true) ...[
                  const SizedBox(height: 20),
                  Text(
                    exercise.description!,
                    style: TextStyle(
                        fontSize: 14,
                        color: AppColors.textSecondary,
                        height: 1.5),
                  ),
                ],

                // Personal record
                const SizedBox(height: 24),
                _PrSection(exerciseId: exerciseId),

                // Gymnastics progressions
                if (exercise.category == 'gimnasia')
                  _ProgressionsLink(exerciseId: exerciseId),

                // Metrics
                const SizedBox(height: 24),
                _SectionTitle('Métricas'),
                const SizedBox(height: 12),
                if (metrics.isEmpty)
                  const _MutedText('Sin métricas registradas')
                else
                  ...metrics.map((m) => _MetricRow(metric: m)),

                // Variants
                const SizedBox(height: 24),
                _SectionTitle('Variantes'),
                const SizedBox(height: 12),
                if (variants.isEmpty)
                  const _MutedText('Sin variantes registradas')
                else
                  ...variants.map((v) => _VariantRow(variant: v)),
              ],
            ),
          );
        },
      ),
    );
  }
}

class _PrSection extends ConsumerWidget {
  const _PrSection({required this.exerciseId});
  final String exerciseId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final pr = ref.watch(exercisePrProvider(exerciseId));

    return pr.when(
      loading: () => const SizedBox.shrink(),
      error: (_, _) => const SizedBox.shrink(),
      data: (record) {
        final hasPr = record != null;
        String? valueText;
        String? dateText;
        if (hasPr) {
          final kg = (record['value_numeric'] as num?)?.toDouble();
          if (kg != null) {
            valueText = RmCalculator.formatLb(RmCalculator.kgToLb(kg));
          }
          final achievedAt = record['achieved_at'] as String?;
          if (achievedAt != null) {
            dateText = DateFormat('d MMM yyyy', 'es')
                .format(DateTime.parse(achievedAt).toLocal());
          }
        }

        return GestureDetector(
          onTap: () => context.push('/athlete/progress/exercise/$exerciseId'),
          child: Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: AppColors.surface,
              borderRadius: BorderRadius.circular(18),
              border: Border.all(color: AppColors.border),
            ),
            child: Row(
              children: [
                Container(
                  width: 44,
                  height: 44,
                  decoration: BoxDecoration(
                    color: AppColors.primaryLight,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Icon(Icons.emoji_events_rounded,
                      color: AppColors.primary, size: 22),
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('Tu récord personal',
                          style: GoogleFonts.inter(
                              fontSize: 12.5,
                              fontWeight: FontWeight.w500,
                              color: AppColors.textSecondary)),
                      const SizedBox(height: 3),
                      if (hasPr && valueText != null)
                        Text(valueText,
                            style: GoogleFonts.spaceGrotesk(
                                fontSize: 20,
                                fontWeight: FontWeight.w700,
                                color: AppColors.textPrimary))
                      else
                        Text('Sin registro — toca para registrar',
                            style: TextStyle(
                                fontSize: 14,
                                fontWeight: FontWeight.w500,
                                color: AppColors.textPrimary)),
                      if (dateText != null) ...[
                        const SizedBox(height: 2),
                        Text(dateText,
                            style: TextStyle(
                                fontSize: 11.5,
                                color: AppColors.textSecondary)),
                      ],
                    ],
                  ),
                ),
                Icon(Icons.chevron_right_rounded,
                    color: AppColors.textSecondary, size: 20),
              ],
            ),
          ),
        );
      },
    );
  }
}

class _ProgressionsLink extends ConsumerWidget {
  const _ProgressionsLink({required this.exerciseId});
  final String exerciseId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final progressions = ref.watch(progressionsForExerciseProvider(exerciseId));
    final steps = progressions.valueOrNull ?? const [];
    if (steps.isEmpty) return const SizedBox.shrink();

    return Padding(
      padding: const EdgeInsets.only(top: 24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _SectionTitle('Progresiones'),
          const SizedBox(height: 12),
          GestureDetector(
            onTap: () => Navigator.of(context).push(
              MaterialPageRoute(
                builder: (_) =>
                    SkillProgressionScreen(exerciseId: exerciseId),
              ),
            ),
            child: Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [AppColors.primary, AppColors.primaryDark],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.circular(18),
              ),
              child: Row(
                children: [
                  const Icon(Icons.timeline_rounded,
                      color: Colors.white, size: 24),
                  const SizedBox(width: 14),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('Rastrea tu progresión',
                            style: GoogleFonts.spaceGrotesk(
                                fontSize: 15,
                                fontWeight: FontWeight.w600,
                                color: Colors.white)),
                        const SizedBox(height: 2),
                        Text('${steps.length} pasos hacia la habilidad',
                            style: TextStyle(
                                fontSize: 12.5,
                                color:
                                    Colors.white.withValues(alpha: 0.85))),
                      ],
                    ),
                  ),
                  const Icon(Icons.chevron_right_rounded,
                      color: Colors.white, size: 22),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _MetricRow extends StatelessWidget {
  const _MetricRow({required this.metric});
  final ExerciseMetricDefinition metric;

  @override
  Widget build(BuildContext context) {
    final unit = metric.unit;
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppColors.border),
      ),
      child: Row(
        children: [
          Icon(
            metric.isPrimary
                ? Icons.star_rounded
                : Icons.straighten_rounded,
            color: metric.isPrimary
                ? AppColors.primary
                : AppColors.textSecondary,
            size: 20,
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Text(metric.metricCode,
                style: const TextStyle(
                    fontSize: 14, fontWeight: FontWeight.w500)),
          ),
          Text(
            [
              if (unit != null && unit.isNotEmpty) unit,
              metric.valueType,
            ].join(' · '),
            style: TextStyle(
                fontSize: 12.5, color: AppColors.textSecondary),
          ),
        ],
      ),
    );
  }
}

class _VariantRow extends StatelessWidget {
  const _VariantRow({required this.variant});
  final ExerciseVariant variant;

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppColors.border),
      ),
      child: Row(
        children: [
          Icon(Icons.swap_horiz_rounded,
              color: AppColors.primary, size: 20),
          const SizedBox(width: 10),
          Expanded(
            child: Text(variant.name,
                style: const TextStyle(
                    fontSize: 14, fontWeight: FontWeight.w500)),
          ),
          if (variant.variantType != null)
            Text(variant.variantType!,
                style: TextStyle(
                    fontSize: 12, color: AppColors.textSecondary)),
        ],
      ),
    );
  }
}

class _SectionTitle extends StatelessWidget {
  const _SectionTitle(this.text);
  final String text;

  @override
  Widget build(BuildContext context) {
    return Text(text,
        style: GoogleFonts.spaceGrotesk(
            fontSize: 18,
            fontWeight: FontWeight.w600,
            color: AppColors.textPrimary));
  }
}

class _MutedText extends StatelessWidget {
  const _MutedText(this.text);
  final String text;

  @override
  Widget build(BuildContext context) {
    return Text(text,
        style:
            TextStyle(color: AppColors.textSecondary, fontSize: 14));
  }
}

class _Chip extends StatelessWidget {
  const _Chip({required this.label});
  final String label;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: AppColors.primaryLightest,
        borderRadius: BorderRadius.circular(18),
      ),
      child: Text(label,
          style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w600,
              color: AppColors.primary)),
    );
  }
}
