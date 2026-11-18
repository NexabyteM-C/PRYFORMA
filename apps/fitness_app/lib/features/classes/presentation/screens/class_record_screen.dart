import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../../app/theme/app_colors.dart';
import '../../../../core/utils/exercise_label.dart';
import '../../../../core/utils/rm_calculator.dart';
import '../../../../core/widgets/barbell_visual.dart';
import '../../../personal_records/presentation/providers/pr_provider.dart';
import '../../../skills/presentation/providers/skill_provider.dart';
import '../../../workouts/presentation/providers/workout_provider.dart';
import '../providers/class_format.dart';
import '../providers/class_provider.dart';

/// Athlete result capture, broken down movement by movement.
///
/// For every block the athlete sees each movement with its prescription and a
/// suggested working load (derived from their 1RM when the prescription is
/// %-based), an input for the actual weight used, an optional "save as 1RM"
/// toggle, gymnastics progression checkboxes, plus a per-block effort scale
/// (RPE), RX/Scaled toggle, score input (for scorable blocks) and notes.
///
/// NOTE: [programId] is a class SESSION id (kept for router compatibility).
class ClassRecordScreen extends ConsumerStatefulWidget {
  const ClassRecordScreen({super.key, required this.programId});
  final String programId;

  @override
  ConsumerState<ClassRecordScreen> createState() => _ClassRecordScreenState();
}

class _ClassRecordScreenState extends ConsumerState<ClassRecordScreen> {
  final Map<String, _BlockInput> _blockInputs = {};
  final Map<String, _MovementInput> _movementInputs = {};

  /// Current checkbox state for gymnastics progressions, keyed by progression id.
  final Map<String, bool> _skillSelections = {};

  /// The achieved state each progression had when loaded (to save only deltas).
  final Map<String, bool> _skillOriginal = {};

  bool _submitting = false;

  String get _sessionId => widget.programId;

  @override
  void dispose() {
    for (final input in _blockInputs.values) {
      input.dispose();
    }
    for (final input in _movementInputs.values) {
      input.dispose();
    }
    super.dispose();
  }

  _BlockInput _blockInputFor(String blockId) =>
      _blockInputs.putIfAbsent(blockId, () => _BlockInput());

  _MovementInput _movementInputFor(String key) =>
      _movementInputs.putIfAbsent(key, () => _MovementInput());

  /// All blocks worth showing (has movements or is scorable), sorted.
  List<Map<String, dynamic>> _displayBlocks(Map<String, dynamic> row) {
    final program = (row['program'] is Map ? row['program'] as Map : row)
        .cast<String, dynamic>();
    final blocks =
        ((program['blocks'] as List?) ?? const []).cast<Map<String, dynamic>>();
    final shown = blocks.where((b) {
      final type = (b['block_type'] ?? b['type']) as String?;
      final scoring = resolveScoring(b);
      final exercises = (b['exercises'] as List?) ?? const [];
      return exercises.isNotEmpty || isScorableBlock(type, scoring);
    }).toList()
      ..sort((a, b) => ((a['sort_order'] as num?) ?? 0)
          .compareTo((b['sort_order'] as num?) ?? 0));
    return shown;
  }

  List<Map<String, dynamic>> _exercisesOf(Map<String, dynamic> block) {
    final list = ((block['exercises'] as List?) ?? const [])
        .cast<Map<String, dynamic>>()
        .toList()
      ..sort((a, b) => ((a['sort_order'] as num?) ?? 0)
          .compareTo((b['sort_order'] as num?) ?? 0));
    return list;
  }

  // ---- Save ----

  Future<void> _submit(
    List<Map<String, dynamic>> blocks,
    Map<String, double> rmMap,
  ) async {
    FocusScope.of(context).unfocus();
    final classDs = ref.read(classRemoteDatasourceProvider);
    final prDs = ref.read(prRemoteProvider);
    final skillActions = ref.read(skillActionsProvider);

    // Collect everything first so we can validate "nothing entered".
    final blockBodies = <Map<String, dynamic>>[];
    final movementSaves = <Map<String, dynamic>>[];
    final prSaves = <Map<String, dynamic>>[];

    for (final block in blocks) {
      final blockId = block['id'] as String;
      final scoring = resolveScoring(block);
      final body = _blockInputFor(blockId).toBody(scoring);
      if (body != null) {
        body['block_id'] = blockId;
        blockBodies.add(body);
      }

      for (final mv in _exercisesOf(block)) {
        final key = (mv['id'] ?? '${blockId}_${mv['exercise_id']}') as String;
        final input = _movementInputFor(key);
        final lb = double.tryParse(input.weight.text.trim());
        if (lb == null || lb <= 0) continue;
        final exId =
            (mv['exercise_id'] ?? (mv['exercise'] as Map?)?['id']) as String?;
        if (exId == null) continue;
        final kg = RmCalculator.lbToKg(lb);
        movementSaves.add({
          'class_session_id': _sessionId,
          'exercise_id': exId,
          'block_id': blockId,
          'weight_kg': kg,
        });
        if (input.saveAsRm) {
          prSaves.add({
            'exercise_id': exId,
            'record_type': '1rm',
            'value_numeric': kg,
            'mark_type': 'real',
            'achieved_at': DateTime.now().toIso8601String(),
          });
        }
      }
    }

    // Gymnastics progressions the athlete changed (checked or unchecked).
    final skillToggles = <MapEntry<String, bool>>[];
    for (final entry in _skillSelections.entries) {
      final original = _skillOriginal[entry.key] ?? false;
      if (entry.value != original) {
        skillToggles.add(MapEntry(entry.key, entry.value));
      }
    }

    if (blockBodies.isEmpty &&
        movementSaves.isEmpty &&
        skillToggles.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Ingresa al menos un resultado.')),
      );
      return;
    }

    setState(() => _submitting = true);
    try {
      for (final body in blockBodies) {
        await classDs.submitResults(_sessionId, body);
      }
      for (final body in movementSaves) {
        await classDs.saveMovementResult(body);
      }
      for (final body in prSaves) {
        await prDs.create(body);
      }
      for (final entry in skillToggles) {
        await skillActions.toggle(entry.key, entry.value);
      }

      // Record the training in the athlete's workout history, linked to the
      // class. This is now the only path that creates workout records.
      final workoutDs = ref.read(workoutRemoteProvider);
      final detail = ref.read(classDetailProvider(widget.programId)).valueOrNull;
      final program = detail?['program'] as Map<String, dynamic>?;
      final workout = await workoutDs.create({
        'title': program?['title'] as String? ?? 'Clase',
        'performed_at': DateTime.now().toIso8601String(),
        'status': 'completed',
        'class_session_id': _sessionId,
      });
      final workoutId = workout['id'] as String;
      var order = 0;
      for (final mv in movementSaves) {
        final we = await workoutDs.addExercise({
          'session_id': workoutId,
          'exercise_id': mv['exercise_id'],
          'sort_order': order++,
        });
        await workoutDs.addSet({
          'workout_exercise_id': we['id'],
          'set_number': 1,
          'weight_kg': mv['weight_kg'],
        });
      }

      ref.invalidate(prListProvider);
      ref.invalidate(athleteRmMapProvider);
      ref.invalidate(mySkillProgressProvider);
      ref.invalidate(workoutListProvider);

      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Resultados guardados'),
          backgroundColor: AppColors.success,
        ),
      );
      context.pop();
    } catch (_) {
      if (!mounted) return;
      setState(() => _submitting = false);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('No se pudieron guardar los resultados.'),
          backgroundColor: AppColors.error,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final detail = ref.watch(classDetailProvider(_sessionId));
    final rmMap = ref.watch(athleteRmMapProvider).valueOrNull ?? const {};

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.background,
        elevation: 0,
        foregroundColor: AppColors.textPrimary,
        title: Text(
          'Registrar resultados',
          style: GoogleFonts.spaceGrotesk(
              fontSize: 18, fontWeight: FontWeight.w600),
        ),
      ),
      body: detail.when(
        loading: () =>
            const Center(child: CircularProgressIndicator(strokeWidth: 2)),
        error: (e, _) => Center(
          child: Text('No pudimos cargar la clase.',
              style: GoogleFonts.inter(
                  fontSize: 14, color: AppColors.textSecondary)),
        ),
        data: (row) {
          final blocks = _displayBlocks(row);
          if (blocks.isEmpty) {
            return Center(
              child: Padding(
                padding: const EdgeInsets.all(32),
                child: Text(
                  'Esta clase no tiene movimientos para registrar.',
                  textAlign: TextAlign.center,
                  style: GoogleFonts.inter(
                      fontSize: 14, color: AppColors.textSecondary),
                ),
              ),
            );
          }
          return Column(
            children: [
              Expanded(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.fromLTRB(16, 8, 16, 24),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      for (final block in blocks) _buildBlock(block, rmMap),
                    ],
                  ),
                ),
              ),
              _buildSubmitBar(blocks, rmMap),
            ],
          );
        },
      ),
    );
  }

  // ---- Block card ----

  Widget _buildBlock(Map<String, dynamic> block, Map<String, double> rmMap) {
    final blockId = block['id'] as String;
    final input = _blockInputFor(blockId);
    final title = (block['title'] ?? block['name']) as String?;
    final scoring = resolveScoring(block);
    final type = (block['block_type'] ?? block['type']) as String?;
    final section = blockSectionFor(block);
    final exercises = _exercisesOf(block);
    final showTitle = title != null &&
        title.isNotEmpty &&
        title.toLowerCase() != section.label.toLowerCase();
    final scorable = isScorableBlock(type, scoring);

    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      clipBehavior: Clip.antiAlias,
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: section.color.withValues(alpha: 0.35)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Colored section header (shared with the class detail screen).
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 11),
            decoration: BoxDecoration(
              color: section.color.withValues(alpha: 0.12),
              border: Border(
                left: BorderSide(color: section.color, width: 4),
              ),
            ),
            child: Row(
              children: [
                Icon(section.icon, size: 20, color: section.color),
                const SizedBox(width: 10),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        section.label.toUpperCase(),
                        style: GoogleFonts.spaceGrotesk(
                          fontSize: 13,
                          fontWeight: FontWeight.w700,
                          letterSpacing: 0.3,
                          color: section.color,
                        ),
                      ),
                      if (showTitle)
                        Text(
                          title,
                          style: GoogleFonts.inter(
                              fontSize: 12.5,
                              fontWeight: FontWeight.w600,
                              color: AppColors.textPrimary),
                        ),
                    ],
                  ),
                ),
                if (scorable) _ScoringBadge(scoring),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Per-movement breakdown.
                for (var i = 0; i < exercises.length; i++) ...[
                  if (i > 0)
                    Divider(height: 24, color: AppColors.border),
                  _buildMovement(blockId, exercises[i], rmMap),
                ],
                if (exercises.isNotEmpty) const SizedBox(height: 18),

                // Scorable blocks keep an aggregate score input.
                if (scorable) ...[
                  _sectionLabel('Resultado del bloque'),
                  const SizedBox(height: 8),
                  _buildScoreInput(scoring, input),
                  const SizedBox(height: 16),
                ],

                // Effort scale (RPE), Apple-Watch style.
                _sectionLabel('Esfuerzo'),
                const SizedBox(height: 8),
                _EffortScale(
                  value: input.effort,
                  onChanged: (v) => setState(() => input.effort = v),
                ),
                const SizedBox(height: 16),

                // RX / Scaled.
                _buildRxToggle(input),
                const SizedBox(height: 12),

                // Notes.
                TextField(
                  controller: input.notes,
                  minLines: 1,
                  maxLines: 3,
                  style: GoogleFonts.inter(fontSize: 13),
                  decoration: _decoration('Notas (opcional)'),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // ---- Movement row ----

  Widget _buildMovement(
    String blockId,
    Map<String, dynamic> mv,
    Map<String, double> rmMap,
  ) {
    final key = (mv['id'] ?? '${blockId}_${mv['exercise_id']}') as String;
    final input = _movementInputFor(key);
    final exercise = (mv['exercise'] as Map?)?.cast<String, dynamic>();
    final exId =
        (mv['exercise_id'] ?? exercise?['id']) as String?;
    final name = exerciseBilingualFromMap(exercise);
    final prescription = _prescription(mv);
    final category = exercise?['category'] as String?;

    // Suggested working load from the athlete's 1RM (only if %-based).
    final prescriptionStr = mv['weight_prescription'] as String?;
    final percent = RmCalculator.percentFromPrescription(prescriptionStr);
    String? suggestedLabel;
    String? suggestedHint;
    double? suggestedLb;
    if (percent != null) {
      final rmKg = exId == null ? null : rmMap[exId];
      final working = RmCalculator.workingWeight(
        rmKg == null ? null : RmCalculator.kgToLb(rmKg),
        percent,
      );
      if (working != null) {
        final lb = RmCalculator.roundToPlate(working);
        suggestedLb = lb;
        suggestedLabel = 'Sugerido: ${RmCalculator.formatLb(lb)}';
        suggestedHint = RmCalculator.formatLb(lb);
      } else {
        suggestedLabel = 'Registra tu RM';
      }
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          name.isEmpty ? 'Movimiento' : name,
          style: GoogleFonts.spaceGrotesk(
              fontSize: 14.5,
              fontWeight: FontWeight.w600,
              color: AppColors.textPrimary),
        ),
        if (prescription.isNotEmpty) ...[
          const SizedBox(height: 2),
          Text(
            prescription,
            style: GoogleFonts.inter(
                fontSize: 12.5, color: AppColors.textSecondary),
          ),
        ],
        if (suggestedLabel != null) ...[
          const SizedBox(height: 6),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
            decoration: BoxDecoration(
              color: AppColors.primaryLight,
              borderRadius: BorderRadius.circular(8),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(Icons.recommend_rounded,
                    size: 14, color: AppColors.primary),
                const SizedBox(width: 4),
                Text(
                  suggestedLabel,
                  style: GoogleFonts.inter(
                      fontSize: 11.5,
                      fontWeight: FontWeight.w600,
                      color: AppColors.primary),
                ),
              ],
            ),
          ),
        ],
        if (suggestedLb != null) ...[
          const SizedBox(height: 8),
          Container(
            width: double.infinity,
            padding: const EdgeInsets.fromLTRB(12, 10, 12, 10),
            decoration: BoxDecoration(
              color: AppColors.inputBackground,
              borderRadius: BorderRadius.circular(10),
              border: Border.all(color: AppColors.border),
            ),
            child: BarbellLoad(totalLb: suggestedLb, dense: true),
          ),
        ],
        const SizedBox(height: 10),
        // Actual weight used.
        SizedBox(
          height: 44,
          child: TextField(
            controller: input.weight,
            keyboardType: const TextInputType.numberWithOptions(decimal: true),
            inputFormatters: [
              FilteringTextInputFormatter.allow(RegExp(r'[0-9.]')),
            ],
            style: GoogleFonts.spaceGrotesk(
                fontSize: 16, fontWeight: FontWeight.w600),
            decoration: _decoration(
              suggestedHint != null
                  ? 'Peso usado (lb) · sug. $suggestedHint'
                  : 'Peso usado (lb)',
            ),
          ),
        ),
        const SizedBox(height: 8),
        // Save as 1RM.
        _CheckRow(
          label: 'Guardar como RM',
          value: input.saveAsRm,
          onChanged: (v) => setState(() => input.saveAsRm = v),
        ),
        // Gymnastics progressions.
        if (category == 'gimnasia' && exId != null) ...[
          const SizedBox(height: 8),
          _MovementProgressions(
            exerciseId: exId,
            selections: _skillSelections,
            original: _skillOriginal,
            onChanged: () => setState(() {}),
          ),
        ],
      ],
    );
  }

  String _prescription(Map<String, dynamic> mv) {
    final sets = mv['sets'];
    final reps = mv['reps'];
    final wp = mv['weight_prescription'];
    final parts = <String>[];
    if (sets != null && reps != null) {
      parts.add('$sets series × $reps');
    } else if (reps != null) {
      parts.add('$reps reps');
    } else if (sets != null) {
      parts.add('$sets series');
    }
    if (wp is String && wp.trim().isNotEmpty) parts.add(wp.trim());
    return parts.join(' · ');
  }

  Widget _sectionLabel(String text) => Text(
        text,
        style: GoogleFonts.inter(
            fontSize: 12,
            fontWeight: FontWeight.w700,
            color: AppColors.textSecondary),
      );

  // ---- Score input (scorable blocks) ----

  Widget _buildScoreInput(String scoring, _BlockInput input) {
    switch (scoring) {
      case 'time':
        return Row(
          children: [
            Expanded(
              child: _field(input.primary, 'min',
                  formatter: FilteringTextInputFormatter.digitsOnly),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 8),
              child: Text(':',
                  style: GoogleFonts.spaceGrotesk(
                      fontSize: 20, fontWeight: FontWeight.w700)),
            ),
            Expanded(
              child: _field(input.secondary, 'seg',
                  formatter: FilteringTextInputFormatter.digitsOnly),
            ),
          ],
        );
      case 'rounds_reps':
        return Row(
          children: [
            Expanded(child: _labeledField(input.primary, 'Rondas')),
            const SizedBox(width: 10),
            Expanded(child: _labeledField(input.secondary, 'Reps')),
          ],
        );
      case 'weight':
        return _labeledField(input.primary, 'Peso (lb)', decimal: true);
      case 'reps':
        return _labeledField(input.primary, 'Repeticiones');
      case 'pass_fail':
        return _labeledField(input.primary, 'Resultado (1 = logrado)');
      default:
        return _labeledField(input.primary, 'Resultado');
    }
  }

  Widget _labeledField(TextEditingController c, String label,
      {bool decimal = false}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label,
            style: GoogleFonts.inter(
                fontSize: 12,
                fontWeight: FontWeight.w600,
                color: AppColors.textSecondary)),
        const SizedBox(height: 6),
        _field(c, label,
            formatter: decimal
                ? FilteringTextInputFormatter.allow(RegExp(r'[0-9.]'))
                : FilteringTextInputFormatter.digitsOnly,
            decimal: decimal),
      ],
    );
  }

  Widget _field(TextEditingController c, String hint,
      {TextInputFormatter? formatter, bool decimal = false}) {
    return SizedBox(
      height: 44,
      child: TextField(
        controller: c,
        keyboardType: TextInputType.numberWithOptions(decimal: decimal),
        inputFormatters: formatter == null ? null : [formatter],
        textAlign: TextAlign.center,
        style: GoogleFonts.spaceGrotesk(
            fontSize: 16, fontWeight: FontWeight.w600),
        decoration: _decoration(hint),
      ),
    );
  }

  Widget _buildRxToggle(_BlockInput input) {
    return Row(
      children: [
        _rxChip('RX', input.rx, () => setState(() => input.rx = true)),
        const SizedBox(width: 8),
        _rxChip('Scaled', !input.rx, () => setState(() => input.rx = false)),
      ],
    );
  }

  Widget _rxChip(String label, bool active, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 8),
        decoration: BoxDecoration(
          color: active ? AppColors.primary : AppColors.surface,
          borderRadius: BorderRadius.circular(10),
          border:
              Border.all(color: active ? AppColors.primary : AppColors.border),
        ),
        child: Text(
          label,
          style: GoogleFonts.inter(
            fontSize: 13,
            fontWeight: FontWeight.w600,
            color: active ? Colors.white : AppColors.textSecondary,
          ),
        ),
      ),
    );
  }

  InputDecoration _decoration(String hint) => InputDecoration(
        hintText: hint,
        hintStyle:
            GoogleFonts.inter(fontSize: 13, color: AppColors.textSecondary),
        isDense: true,
        contentPadding:
            const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
        filled: true,
        fillColor: AppColors.inputBackground,
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: BorderSide(color: AppColors.border),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: BorderSide(color: AppColors.primary, width: 1.5),
        ),
      );

  Widget _buildSubmitBar(
      List<Map<String, dynamic>> blocks, Map<String, double> rmMap) {
    return Container(
      padding: const EdgeInsets.fromLTRB(20, 12, 20, 12),
      decoration: BoxDecoration(
        color: AppColors.surface,
        border: Border(
            top: BorderSide(color: AppColors.border.withValues(alpha: 0.5))),
      ),
      child: SafeArea(
        top: false,
        child: SizedBox(
          height: 48,
          child: ElevatedButton(
            onPressed: _submitting ? null : () => _submit(blocks, rmMap),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primary,
              foregroundColor: Colors.white,
              shape:
                  RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              elevation: 0,
            ),
            child: _submitting
                ? const SizedBox(
                    width: 22,
                    height: 22,
                    child: CircularProgressIndicator(
                        strokeWidth: 2, color: Colors.white),
                  )
                : Text('Guardar resultados',
                    style: GoogleFonts.inter(
                        fontSize: 15, fontWeight: FontWeight.w700)),
          ),
        ),
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// Effort scale (RPE 1–10) — Apple-Watch-like green → yellow → red gradient.
// ---------------------------------------------------------------------------

class _EffortScale extends StatelessWidget {
  const _EffortScale({required this.value, required this.onChanged});
  final int? value;
  final ValueChanged<int?> onChanged;

  static Color colorFor(int v) {
    final t = (v - 1) / 9.0; // 0..1
    if (t <= 0.5) {
      return Color.lerp(
          const Color(0xFF16A34A), const Color(0xFFF59E0B), t * 2)!;
    }
    return Color.lerp(
        const Color(0xFFF59E0B), const Color(0xFFDC2626), (t - 0.5) * 2)!;
  }

  static String _descriptor(int v) {
    if (v <= 2) return 'Muy suave';
    if (v <= 4) return 'Ligero';
    if (v <= 6) return 'Moderado';
    if (v <= 8) return 'Duro';
    return 'Máximo';
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            for (var v = 1; v <= 10; v++)
              Expanded(
                child: Padding(
                  padding: EdgeInsets.only(right: v == 10 ? 0 : 3),
                  child: _segment(v),
                ),
              ),
          ],
        ),
        const SizedBox(height: 6),
        Text(
          value == null
              ? 'Toca para calificar tu esfuerzo (RPE)'
              : 'Esfuerzo $value/10 · ${_descriptor(value!)}',
          style: GoogleFonts.inter(
            fontSize: 11.5,
            fontWeight: FontWeight.w600,
            color: value == null ? AppColors.textSecondary : colorFor(value!),
          ),
        ),
      ],
    );
  }

  Widget _segment(int v) {
    final selected = value == v;
    final color = colorFor(v);
    return GestureDetector(
      onTap: () => onChanged(selected ? null : v),
      behavior: HitTestBehavior.opaque,
      child: Container(
        height: 38,
        alignment: Alignment.center,
        decoration: BoxDecoration(
          color: selected ? color : color.withValues(alpha: 0.14),
          borderRadius: BorderRadius.circular(9),
          border: Border.all(
            color: selected ? color : color.withValues(alpha: 0.35),
            width: selected ? 2 : 1,
          ),
        ),
        child: Text(
          '$v',
          style: GoogleFonts.spaceGrotesk(
            fontSize: 13,
            fontWeight: FontWeight.w700,
            color: selected ? Colors.white : color,
          ),
        ),
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// Gymnastics progression checkboxes for one movement.
// ---------------------------------------------------------------------------

class _MovementProgressions extends ConsumerWidget {
  const _MovementProgressions({
    required this.exerciseId,
    required this.selections,
    required this.original,
    required this.onChanged,
  });

  final String exerciseId;
  final Map<String, bool> selections;
  final Map<String, bool> original;
  final VoidCallback onChanged;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final progressions =
        ref.watch(progressionsForExerciseProvider(exerciseId));
    final progress = ref.watch(mySkillProgressProvider);

    return progressions.maybeWhen(
      orElse: () => const SizedBox.shrink(),
      data: (steps) {
        if (steps.isEmpty) return const SizedBox.shrink();

        // Achieved progression ids for this athlete.
        final achieved = <String>{};
        final progressRows = progress.valueOrNull ?? const [];
        for (final r in progressRows) {
          if (r['achieved'] == true) {
            final pid = r['progression_id'] as String?;
            if (pid != null) achieved.add(pid);
          }
        }

        // Seed local state once per progression id.
        for (final step in steps) {
          final pid = step['id'] as String;
          if (!original.containsKey(pid)) {
            final was = achieved.contains(pid);
            original[pid] = was;
            selections[pid] = was;
          }
        }

        return Container(
          padding: const EdgeInsets.fromLTRB(10, 8, 10, 4),
          decoration: BoxDecoration(
            color: AppColors.secondaryLight,
            borderRadius: BorderRadius.circular(10),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Progresiones desbloqueadas',
                style: GoogleFonts.inter(
                    fontSize: 11.5,
                    fontWeight: FontWeight.w700,
                    color: AppColors.secondaryDark),
              ),
              const SizedBox(height: 2),
              for (final step in steps)
                _CheckRow(
                  label: (step['name'] as String?) ?? 'Progresión',
                  value: selections[step['id'] as String] ?? false,
                  activeColor: AppColors.secondaryAccent,
                  onChanged: (v) {
                    selections[step['id'] as String] = v;
                    onChanged();
                  },
                ),
            ],
          ),
        );
      },
    );
  }
}

// ---------------------------------------------------------------------------
// Reusable compact checkbox row.
// ---------------------------------------------------------------------------

class _CheckRow extends StatelessWidget {
  const _CheckRow({
    required this.label,
    required this.value,
    required this.onChanged,
    this.activeColor,
  });

  final String label;
  final bool value;
  final ValueChanged<bool> onChanged;
  final Color? activeColor;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: () => onChanged(!value),
      borderRadius: BorderRadius.circular(8),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 4),
        child: Row(
          children: [
            Container(
              width: 20,
              height: 20,
              decoration: BoxDecoration(
                color: value ? (activeColor ?? AppColors.primary) : Colors.transparent,
                borderRadius: BorderRadius.circular(6),
                border: Border.all(
                  color: value ? (activeColor ?? AppColors.primary) : AppColors.border,
                  width: 1.5,
                ),
              ),
              child: value
                  ? const Icon(Icons.check_rounded,
                      size: 14, color: Colors.white)
                  : null,
            ),
            const SizedBox(width: 8),
            Expanded(
              child: Text(
                label,
                style: GoogleFonts.inter(
                    fontSize: 12.5,
                    fontWeight: FontWeight.w500,
                    color: AppColors.textPrimary),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _ScoringBadge extends StatelessWidget {
  const _ScoringBadge(this.scoring);
  final String scoring;
  @override
  Widget build(BuildContext context) {
    const labels = {
      'time': 'Tiempo',
      'rounds_reps': 'Rondas + reps',
      'weight': 'Carga',
      'reps': 'Reps',
      'pass_fail': 'Logrado',
    };
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(
        color: AppColors.primaryLight,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Text(
        labels[scoring] ?? scoring,
        style: GoogleFonts.inter(
            fontSize: 11,
            fontWeight: FontWeight.w600,
            color: AppColors.primary),
      ),
    );
  }
}

/// Holds the controllers + RX + effort state for one block and turns them into
/// an `athlete_class_results` body based on the block's scoring type.
class _BlockInput {
  final TextEditingController primary = TextEditingController();
  final TextEditingController secondary = TextEditingController();
  final TextEditingController notes = TextEditingController();
  bool rx = true;
  int? effort; // RPE 1-10

  void dispose() {
    primary.dispose();
    secondary.dispose();
    notes.dispose();
  }

  Map<String, dynamic>? toBody(String scoring) {
    final p = primary.text.trim();
    final s = secondary.text.trim();
    final notesText = notes.text.trim();

    double? value;
    String? unit;
    String? extraNote;

    switch (scoring) {
      case 'time':
        if (p.isNotEmpty || s.isNotEmpty) {
          final mins = int.tryParse(p) ?? 0;
          final secs = int.tryParse(s) ?? 0;
          value = (mins * 60 + secs).toDouble();
          unit = 'seg';
        }
        break;
      case 'rounds_reps':
        if (p.isNotEmpty || s.isNotEmpty) {
          value = double.tryParse(p) ?? 0;
          unit = 'rondas';
          if (s.isNotEmpty && (int.tryParse(s) ?? 0) > 0) {
            extraNote = '+$s reps';
          }
        }
        break;
      case 'weight':
        if (p.isNotEmpty) {
          value = double.tryParse(p);
          unit = 'lb';
        }
        break;
      case 'reps':
        if (p.isNotEmpty) {
          value = double.tryParse(p);
          unit = 'reps';
        }
        break;
      case 'pass_fail':
        if (p.isNotEmpty) {
          value = double.tryParse(p);
          unit = 'pass_fail';
        }
        break;
      default:
        if (p.isNotEmpty) {
          value = double.tryParse(p);
          unit = scoring;
        }
    }

    final combinedNotes = [
      ?extraNote,
      if (notesText.isNotEmpty) notesText,
    ].join(' · ');

    final hasScore = value != null;
    final hasEffort = effort != null;
    final hasNotes = combinedNotes.isNotEmpty;

    // Nothing worth persisting for this block.
    if (!hasScore && !hasEffort && !hasNotes) return null;

    return {
      if (hasScore) 'score_value': value,
      if (hasScore) 'score_unit': unit,
      'rx': rx,
      if (hasEffort) 'effort': effort,
      if (hasNotes) 'notes': combinedNotes,
    };
  }
}

/// Per-movement input: actual weight used + "save as 1RM" flag.
class _MovementInput {
  final TextEditingController weight = TextEditingController();
  bool saveAsRm = false;

  void dispose() {
    weight.dispose();
  }
}
