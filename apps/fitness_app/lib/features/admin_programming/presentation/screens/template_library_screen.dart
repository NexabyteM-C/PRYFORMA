import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../../../app/theme/app_colors.dart';
import '../../../../core/utils/exercise_label.dart';
import '../../../../core/widgets/fit_back_button.dart';
import '../providers/template_provider.dart';
import '../widgets/block_editor.dart';

class TemplateLibraryScreen extends ConsumerWidget {
  const TemplateLibraryScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final templates = ref.watch(templateListProvider);

    return Scaffold(
      backgroundColor: AppColors.background,
      floatingActionButton: FloatingActionButton.extended(
        backgroundColor: AppColors.primary,
        foregroundColor: Colors.white,
        onPressed: () => context.push('/admin/programming/new'),
        icon: const Icon(Icons.add_rounded),
        label: const Text('Nueva'),
      ),
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header: back + title stack so it never overflows on phones.
            Padding(
              padding: const EdgeInsets.fromLTRB(8, 12, 20, 4),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const FitBackButton(fallbackLocation: '/admin/programming'),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Plantillas',
                          style: GoogleFonts.spaceGrotesk(
                            fontSize: 24,
                            fontWeight: FontWeight.w700,
                            color: AppColors.textPrimary,
                          ),
                        ),
                        Text(
                          'Reutiliza una estructura para programar el día.',
                          style: TextStyle(
                            fontSize: 13,
                            color: AppColors.textSecondary,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            Expanded(
              child: templates.when(
                data: (list) => list.isEmpty
                    ? _empty()
                    : ListView.separated(
                        padding: const EdgeInsets.fromLTRB(16, 12, 16, 96),
                        itemCount: list.length,
                        separatorBuilder: (_, _) => const SizedBox(height: 12),
                        itemBuilder: (context, i) =>
                            _TemplateCard(template: list[i]),
                      ),
                loading: () => const Center(child: CircularProgressIndicator()),
                error: (e, _) => Center(child: Text('Error: $e')),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _empty() {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            Icons.library_books_rounded,
            size: 56,
            color: Colors.grey.shade300,
          ),
          const SizedBox(height: 12),
          Text(
            'Sin plantillas guardadas',
            style: TextStyle(color: AppColors.textSecondary),
          ),
          const SizedBox(height: 8),
          Text(
            'Las plantillas permiten reutilizar programaciones',
            style: TextStyle(fontSize: 13, color: AppColors.textSecondary),
          ),
        ],
      ),
    );
  }
}

/// A single template rendered as an expandable card. Tapping it reveals the
/// template's 4 sections and the exercises prescribed in each.
class _TemplateCard extends ConsumerWidget {
  const _TemplateCard({required this.template});
  final ProgramTemplate template;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: AppColors.border),
      ),
      clipBehavior: Clip.antiAlias,
      child: Theme(
        data: Theme.of(context).copyWith(dividerColor: Colors.transparent),
        child: ExpansionTile(
          tilePadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
          childrenPadding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
          leading: Container(
            width: 44,
            height: 44,
            decoration: BoxDecoration(
              color: AppColors.primaryLight,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(
              Icons.description_rounded,
              color: AppColors.primary,
            ),
          ),
          title: Text(
            template.name,
            style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w600),
          ),
          subtitle: template.description != null
              ? Padding(
                  padding: const EdgeInsets.only(top: 4),
                  child: Text(
                    template.description!,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      fontSize: 12,
                      color: AppColors.textSecondary,
                    ),
                  ),
                )
              : null,
          children: [
            _TemplatePreview(template: template),
            const SizedBox(height: 14),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed: () => _useTemplate(context, ref),
                icon: const Icon(Icons.playlist_add_check_rounded, size: 18),
                label: const Text('Usar plantilla'),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _useTemplate(BuildContext context, WidgetRef ref) async {
    final now = DateTime.now();
    final date = await showDatePicker(
      context: context,
      initialDate: now,
      firstDate: now.subtract(const Duration(days: 1)),
      lastDate: now.add(const Duration(days: 365)),
      helpText: 'Fecha de la programación',
    );
    if (date == null) return;
    if (!context.mounted) return;

    final messenger = ScaffoldMessenger.of(context);
    try {
      final newId = await ref
          .read(applyTemplateActionProvider)
          .call(template.id, date);
      // Refresh the calendar list so the new draft appears.
      ref.invalidate(templateListProvider);
      if (!context.mounted) return;
      messenger.showSnackBar(
        SnackBar(
          content: Text('Programación creada desde la plantilla'),
          backgroundColor: AppColors.success,
        ),
      );
      context.push('/admin/programming/$newId');
    } catch (e) {
      messenger.showSnackBar(
        SnackBar(
          content: Text('No se pudo aplicar la plantilla: $e'),
          backgroundColor: AppColors.error,
        ),
      );
    }
  }
}

/// Loads and renders the template's blocks (Spanish "momento" labels) with
/// their exercises shown bilingually ("English / Spanish").
class _TemplatePreview extends ConsumerWidget {
  const _TemplatePreview({required this.template});
  final ProgramTemplate template;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final async = ref.watch(templateWithBlocksProvider(template.id));
    return async.when(
      loading: () => const Padding(
        padding: EdgeInsets.symmetric(vertical: 16),
        child: Center(
          child: SizedBox(
            width: 20,
            height: 20,
            child: CircularProgressIndicator(strokeWidth: 2),
          ),
        ),
      ),
      error: (e, _) => Text(
        'No se pudo cargar la estructura.\n$e',
        style: TextStyle(fontSize: 12, color: AppColors.error),
      ),
      data: (data) {
        final blocks = (data['blocks'] as List<dynamic>?) ?? const [];
        if (blocks.isEmpty) {
          return Text(
            'Esta plantilla no tiene bloques.',
            style: TextStyle(fontSize: 12, color: AppColors.textSecondary),
          );
        }
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            for (final raw in blocks)
              _BlockPreview(block: raw as Map<String, dynamic>),
          ],
        );
      },
    );
  }
}

class _BlockPreview extends StatelessWidget {
  const _BlockPreview({required this.block});
  final Map<String, dynamic> block;

  @override
  Widget build(BuildContext context) {
    final blockType = (block['block_type'] as String?) ?? 'custom';
    final style = blockTypeStyle(blockType);
    final blockTitle = (block['title'] as String?)?.trim() ?? '';
    final duration = (block['duration_minutes'] as num?)?.toInt();
    final exercises = (block['exercises'] as List<dynamic>?) ?? const [];

    return Container(
      margin: const EdgeInsets.only(top: 12),
      decoration: BoxDecoration(
        color: AppColors.inputBackground,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: style.color.withValues(alpha: 0.4)),
      ),
      padding: const EdgeInsets.fromLTRB(12, 10, 12, 10),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(style.icon, size: 16, color: style.color),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  // Spanish "momento" label.
                  style.label,
                  style: GoogleFonts.spaceGrotesk(
                    fontSize: 13,
                    fontWeight: FontWeight.w700,
                    color: style.color,
                  ),
                ),
              ),
              if (duration != null)
                Text(
                  '$duration min',
                  style: TextStyle(
                    fontSize: 11,
                    color: AppColors.textSecondary,
                  ),
                ),
            ],
          ),
          if (blockTitle.isNotEmpty && blockTitle != style.label) ...[
            const SizedBox(height: 2),
            Text(
              blockTitle,
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w600,
                color: AppColors.textPrimary,
              ),
            ),
          ],
          if (exercises.isNotEmpty) ...[
            const SizedBox(height: 8),
            for (final rawEx in exercises)
              _ExerciseLine(exercise: rawEx as Map<String, dynamic>),
          ],
        ],
      ),
    );
  }
}

class _ExerciseLine extends StatelessWidget {
  const _ExerciseLine({required this.exercise});
  final Map<String, dynamic> exercise;

  @override
  Widget build(BuildContext context) {
    final label = exerciseBilingualFromMap(
      exercise['exercise'] as Map<String, dynamic>?,
    );
    final sets = (exercise['sets'] as num?)?.toInt();
    final reps = (exercise['reps'] as String?)?.trim() ?? '';
    final weight = (exercise['weight_prescription'] as String?)?.trim() ?? '';

    final prescription = <String>[
      if (sets != null && sets > 0 && reps.isNotEmpty)
        '$sets x $reps'
      else if (sets != null && sets > 0)
        '$sets sets'
      else if (reps.isNotEmpty)
        reps,
      if (weight.isNotEmpty) weight,
    ].join(' · ');

    return Padding(
      padding: const EdgeInsets.only(top: 4),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: EdgeInsets.only(top: 5),
            child: Icon(
              Icons.fiber_manual_record,
              size: 6,
              color: AppColors.textSecondary,
            ),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label.isEmpty ? 'Ejercicio' : label,
                  style: TextStyle(
                    fontSize: 13,
                    color: AppColors.textPrimary,
                  ),
                ),
                if (prescription.isNotEmpty)
                  Text(
                    prescription,
                    style: TextStyle(
                      fontSize: 11,
                      color: AppColors.textSecondary,
                    ),
                  ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
