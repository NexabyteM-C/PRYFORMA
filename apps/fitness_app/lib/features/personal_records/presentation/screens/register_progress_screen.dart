import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';

import '../../../../app/theme/app_colors.dart';
import '../../../../core/utils/exercise_label.dart';
import '../../../../core/utils/rm_calculator.dart';
import '../../../classes/presentation/providers/class_format.dart';
import '../../../classes/presentation/providers/class_provider.dart';
import '../../../skills/presentation/providers/skill_provider.dart';
import '../../../workouts/presentation/providers/workout_provider.dart';
import '../providers/pr_provider.dart';

/// Lifting record types selectable per movement when registering progress.
/// Only weight-based types (stored in kg) are offered here.
const _kLiftRecordTypes = <String, String>{
  '1rm': '1RM',
  '2rm': '2RM',
  '3rm': '3RM',
  '5rm': '5RM',
};

bool _isLifting(String? category) =>
    category == 'halterofilia' || category == 'fuerza';
bool _isGymnastics(String? category) => category == 'gimnasia';

/// "Registrar progreso" flow in the athlete's Progreso section.
///
/// Shows a whole class/workout and lets the athlete log their marks movement by
/// movement. Lifting movements feed personal records (PRs); gymnastics movements
/// with skill progressions feed the skills registry. Reached via
/// `Navigator.push(MaterialPageRoute(...))` from [PrListScreen].
class RegisterProgressScreen extends ConsumerStatefulWidget {
  const RegisterProgressScreen({super.key});

  @override
  ConsumerState<RegisterProgressScreen> createState() =>
      _RegisterProgressScreenState();
}

class _RegisterProgressScreenState
    extends ConsumerState<RegisterProgressScreen> {
  /// Selected class session (raw map from recentClassesProvider).
  Map<String, dynamic>? _selectedClass;

  /// Full session (program + blocks + exercises) loaded via getSession.
  Future<Map<String, dynamic>>? _sessionFuture;

  bool _saving = false;

  // --- Per-movement lifting inputs (keyed by exercise id) ---
  final Map<String, TextEditingController> _weightCtrls = {};
  final Map<String, String> _recordTypes = {};

  // --- Per-progression gymnastics toggles (keyed by progression id) ---
  final Map<String, bool> _skillChecks = {};
  final Set<String> _skillTouched = {};

  @override
  void dispose() {
    for (final c in _weightCtrls.values) {
      c.dispose();
    }
    super.dispose();
  }

  TextEditingController _weightCtrlFor(String exerciseId) =>
      _weightCtrls.putIfAbsent(exerciseId, () => TextEditingController());

  void _selectClass(Map<String, dynamic> klass) {
    final sessionId = klass['id'] as String;
    setState(() {
      _selectedClass = klass;
      _sessionFuture =
          ref.read(workoutClassDatasourceProvider).getSession(sessionId);
    });
  }

  void _backToPicker() {
    setState(() {
      _selectedClass = null;
      _sessionFuture = null;
    });
  }

  bool _skillChecked(String progId, bool stored) =>
      _skillTouched.contains(progId) ? (_skillChecks[progId] ?? false) : stored;

  void _setSkillChecked(String progId, bool value) {
    setState(() {
      _skillTouched.add(progId);
      _skillChecks[progId] = value;
    });
  }

  Future<void> _save() async {
    setState(() => _saving = true);
    final pr = ref.read(prRemoteProvider);
    final skillActions = ref.read(skillActionsProvider);
    var saved = 0;
    try {
      // Lifting marks → personal records (lb entered, stored in kg).
      for (final entry in _weightCtrls.entries) {
        final txt = entry.value.text.trim().replaceAll(',', '.');
        final lb = double.tryParse(txt);
        if (lb == null || lb <= 0) continue;
        await pr.create({
          'exercise_id': entry.key,
          'record_type': _recordTypes[entry.key] ?? '1rm',
          'value_numeric': RmCalculator.lbToKg(lb),
          'mark_type': 'real',
          'achieved_at': DateTime.now().toIso8601String(),
        });
        saved++;
      }

      // Gymnastics progressions → skills registry.
      for (final progId in _skillTouched) {
        await skillActions.toggle(progId, _skillChecks[progId] ?? false);
        saved++;
      }

      ref.invalidate(prListProvider);
      ref.invalidate(mySkillProgressProvider);
      // Refresh the per-exercise 1RM map so class suggested loads recalc.
      ref.invalidate(athleteRmMapProvider);

      if (!mounted) return;
      if (saved == 0) {
        setState(() => _saving = false);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('No ingresaste ninguna marca para guardar.'),
          ),
        );
        return;
      }
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          backgroundColor: AppColors.success,
          content: Text(
            saved == 1
                ? 'Progreso guardado (1 registro).'
                : 'Progreso guardado ($saved registros).',
          ),
        ),
      );
      Navigator.of(context).pop(true);
    } catch (e) {
      if (!mounted) return;
      setState(() => _saving = false);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          backgroundColor: AppColors.error,
          content: Text('No se pudo guardar: $e'),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final onPicker = _selectedClass == null;
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.background,
        elevation: 0,
        leading: onPicker
            ? null
            : IconButton(
                icon: const Icon(Icons.arrow_back_rounded),
                onPressed: _saving ? null : _backToPicker,
              ),
        title: Text(
          'Registrar progreso',
          style: GoogleFonts.spaceGrotesk(
            fontSize: 20,
            fontWeight: FontWeight.w700,
            color: AppColors.textPrimary,
          ),
        ),
        iconTheme: IconThemeData(color: AppColors.textPrimary),
      ),
      body: SafeArea(
        child: onPicker ? _buildPicker() : _buildMovements(),
      ),
    );
  }

  // --- Step 1: pick a class ---

  Widget _buildPicker() {
    final asyncClasses = ref.watch(recentClassesProvider);
    return asyncClasses.when(
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (e, _) => _ErrorView(
        message: '$e',
        onRetry: () => ref.invalidate(recentClassesProvider),
      ),
      data: (classes) {
        if (classes.isEmpty) {
          return _EmptyClasses(onRetry: () => ref.invalidate(recentClassesProvider));
        }
        return ListView(
          padding: const EdgeInsets.fromLTRB(20, 8, 20, 24),
          children: [
            Text(
              'Elige la clase que entrenaste',
              style: GoogleFonts.spaceGrotesk(
                fontSize: 18,
                fontWeight: FontWeight.w600,
                color: AppColors.textPrimary,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              'Verás todos sus movimientos para registrar tus marcas.',
              style: GoogleFonts.inter(
                fontSize: 13,
                color: AppColors.textSecondary,
              ),
            ),
            const SizedBox(height: 16),
            ...classes.map(
              (c) => Padding(
                padding: const EdgeInsets.only(bottom: 10),
                child: _ClassCard(klass: c, onTap: () => _selectClass(c)),
              ),
            ),
          ],
        );
      },
    );
  }

  // --- Step 2: log movements ---

  Widget _buildMovements() {
    return FutureBuilder<Map<String, dynamic>>(
      future: _sessionFuture,
      builder: (context, snap) {
        if (snap.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }
        if (snap.hasError) {
          return _ErrorView(
            message: '${snap.error}',
            onRetry: _backToPicker,
          );
        }
        final session = snap.data!;
        final program = session['program'] as Map<String, dynamic>?;
        final blocks = (program?['blocks'] as List?) ?? const [];
        final sorted = [...blocks]
          ..sort((a, b) => ((a['sort_order'] ?? 0) as num)
              .compareTo((b['sort_order'] ?? 0) as num));

        final storedProgress = _storedSkillMap();

        return Column(
          children: [
            Expanded(
              child: ListView(
                padding: const EdgeInsets.fromLTRB(20, 8, 20, 24),
                children: [
                  _ClassHeader(klass: _selectedClass!),
                  const SizedBox(height: 16),
                  if (sorted.isEmpty)
                    _InfoCard(
                      text:
                          'Esta clase no tiene movimientos registrados en su programación.',
                    )
                  else
                    ...sorted.map((block) => _buildBlock(
                          block as Map<String, dynamic>,
                          storedProgress,
                        )),
                ],
              ),
            ),
            _SaveBar(saving: _saving, onSave: _saving ? null : _save),
          ],
        );
      },
    );
  }

  /// Map progression_id -> achieved from the athlete's stored skill progress.
  Map<String, bool> _storedSkillMap() {
    final rows = ref.watch(mySkillProgressProvider).valueOrNull ?? const [];
    return {
      for (final r in rows)
        (r['progression_id'] as String): (r['achieved'] as bool? ?? false),
    };
  }

  Widget _buildBlock(
    Map<String, dynamic> block,
    Map<String, bool> storedProgress,
  ) {
    final section = blockSectionFor(block);
    final exercises = (block['exercises'] as List?) ?? const [];

    // Distinct exercises within the block, keeping first appearance order.
    final seen = <String>{};
    final distinct = <Map<String, dynamic>>[];
    for (final e in exercises) {
      final ex = (e as Map<String, dynamic>)['exercise'] as Map<String, dynamic>?;
      final id = ex?['id'] as String?;
      if (ex == null || id == null) continue;
      if (seen.add(id)) distinct.add(ex);
    }
    if (distinct.isEmpty) return const SizedBox.shrink();

    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: AppColors.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 14, 16, 8),
            child: Row(
              children: [
                Container(
                  width: 30,
                  height: 30,
                  decoration: BoxDecoration(
                    color: section.color.withValues(alpha: 0.12),
                    borderRadius: BorderRadius.circular(9),
                  ),
                  child: Icon(section.icon, size: 17, color: section.color),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: Text(
                    section.label,
                    style: GoogleFonts.spaceGrotesk(
                      fontSize: 15,
                      fontWeight: FontWeight.w700,
                      color: AppColors.textPrimary,
                    ),
                  ),
                ),
              ],
            ),
          ),
          for (final ex in distinct) _buildMovement(ex, storedProgress),
          const SizedBox(height: 6),
        ],
      ),
    );
  }

  Widget _buildMovement(
    Map<String, dynamic> exercise,
    Map<String, bool> storedProgress,
  ) {
    final exerciseId = exercise['id'] as String;
    final category = exercise['category'] as String?;
    final label = exerciseBilingualFromMap(exercise);

    Widget inner;
    if (_isLifting(category)) {
      inner = _LiftingInput(
        controller: _weightCtrlFor(exerciseId),
        recordType: _recordTypes[exerciseId] ?? '1rm',
        onRecordTypeChanged: (t) => setState(() => _recordTypes[exerciseId] = t),
      );
    } else if (_isGymnastics(category)) {
      inner = _SkillInput(
        exerciseId: exerciseId,
        stored: storedProgress,
        checked: _skillChecked,
        onToggle: _setSkillChecked,
      );
    } else {
      inner = const SizedBox.shrink();
    }

    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 8, 16, 8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label.isEmpty ? 'Movimiento' : label,
            style: GoogleFonts.inter(
              fontSize: 14,
              fontWeight: FontWeight.w600,
              color: AppColors.textPrimary,
            ),
          ),
          inner,
          const SizedBox(height: 4),
          Divider(height: 1, color: AppColors.border),
        ],
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// Lifting input: weight (lb) + record-type selector.
// ---------------------------------------------------------------------------

class _LiftingInput extends StatelessWidget {
  const _LiftingInput({
    required this.controller,
    required this.recordType,
    required this.onRecordTypeChanged,
  });

  final TextEditingController controller;
  final String recordType;
  final ValueChanged<String> onRecordTypeChanged;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SizedBox(height: 8),
        Row(
          children: [
            SizedBox(
              width: 120,
              child: TextField(
                controller: controller,
                keyboardType:
                    const TextInputType.numberWithOptions(decimal: true),
                inputFormatters: [
                  FilteringTextInputFormatter.allow(RegExp(r'[0-9.,]')),
                ],
                style: GoogleFonts.spaceGrotesk(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: AppColors.textPrimary,
                ),
                decoration: InputDecoration(
                  isDense: true,
                  hintText: 'Peso',
                  suffixText: 'lb',
                  filled: true,
                  fillColor: AppColors.inputBackground,
                  contentPadding:
                      const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10),
                    borderSide: BorderSide(color: AppColors.border),
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10),
                    borderSide: BorderSide(color: AppColors.border),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10),
                    borderSide:
                        BorderSide(color: AppColors.primary, width: 1.5),
                  ),
                ),
              ),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: Wrap(
                spacing: 6,
                runSpacing: 6,
                children: _kLiftRecordTypes.entries.map((e) {
                  final selected = e.key == recordType;
                  return GestureDetector(
                    onTap: () => onRecordTypeChanged(e.key),
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 12, vertical: 7),
                      decoration: BoxDecoration(
                        color:
                            selected ? AppColors.primary : AppColors.surface,
                        borderRadius: BorderRadius.circular(10),
                        border: Border.all(
                          color: selected ? AppColors.primary : AppColors.border,
                        ),
                      ),
                      child: Text(
                        e.value,
                        style: GoogleFonts.inter(
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                          color:
                              selected ? Colors.white : AppColors.textSecondary,
                        ),
                      ),
                    ),
                  );
                }).toList(),
              ),
            ),
          ],
        ),
        const SizedBox(height: 4),
        Text(
          'Solo si lo hiciste más pesado. Déjalo vacío para omitir.',
          style: GoogleFonts.inter(fontSize: 11, color: AppColors.textSecondary),
        ),
      ],
    );
  }
}

// ---------------------------------------------------------------------------
// Gymnastics input: progression steps as checkboxes.
// ---------------------------------------------------------------------------

class _SkillInput extends ConsumerWidget {
  const _SkillInput({
    required this.exerciseId,
    required this.stored,
    required this.checked,
    required this.onToggle,
  });

  final String exerciseId;
  final Map<String, bool> stored;
  final bool Function(String progId, bool stored) checked;
  final void Function(String progId, bool value) onToggle;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final async = ref.watch(progressionsForExerciseProvider(exerciseId));
    return async.when(
      loading: () => const Padding(
        padding: EdgeInsets.symmetric(vertical: 10),
        child: SizedBox(
          height: 16,
          width: 16,
          child: CircularProgressIndicator(strokeWidth: 2),
        ),
      ),
      error: (_, _) => const SizedBox.shrink(),
      data: (steps) {
        if (steps.isEmpty) return const SizedBox.shrink();
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 4),
            Text(
              'Marca las progresiones que ya dominas:',
              style: GoogleFonts.inter(
                fontSize: 11,
                color: AppColors.textSecondary,
              ),
            ),
            ...steps.map((step) {
              final progId = step['id'] as String;
              final value = checked(progId, stored[progId] ?? false);
              return InkWell(
                onTap: () => onToggle(progId, !value),
                borderRadius: BorderRadius.circular(8),
                child: Padding(
                  padding: const EdgeInsets.symmetric(vertical: 4),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      SizedBox(
                        width: 24,
                        height: 24,
                        child: Checkbox(
                          value: value,
                          onChanged: (v) => onToggle(progId, v ?? false),
                          activeColor: AppColors.success,
                          materialTapTargetSize:
                              MaterialTapTargetSize.shrinkWrap,
                          visualDensity: VisualDensity.compact,
                        ),
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          (step['name'] as String?) ?? 'Progresión',
                          style: GoogleFonts.inter(
                            fontSize: 13,
                            fontWeight: FontWeight.w500,
                            color: AppColors.textPrimary,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              );
            }),
          ],
        );
      },
    );
  }
}

// ---------------------------------------------------------------------------
// Supporting widgets
// ---------------------------------------------------------------------------

String _classTitle(Map<String, dynamic> klass) {
  final program = klass['program'] as Map<String, dynamic>?;
  final title = program?['title'] as String?;
  return (title == null || title.isEmpty) ? 'Clase' : title;
}

String _classBox(Map<String, dynamic> klass) {
  final program = klass['program'] as Map<String, dynamic>?;
  final org = program?['organization'] as Map<String, dynamic>?;
  return (org?['name'] as String?) ?? '';
}

String _classDate(Map<String, dynamic> klass) {
  final dt = DateTime.tryParse(klass['start_time'] as String? ?? '')?.toLocal();
  if (dt == null) return '';
  try {
    return DateFormat("EEE d 'de' MMM", 'es').format(dt);
  } catch (_) {
    return DateFormat('EEE d MMM').format(dt);
  }
}

class _ClassCard extends StatelessWidget {
  const _ClassCard({required this.klass, required this.onTap});
  final Map<String, dynamic> klass;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final box = _classBox(klass);
    final date = _classDate(klass);
    final subtitle = [box, date].where((s) => s.isNotEmpty).join(' · ');
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
                child: Icon(Icons.event_note_rounded,
                    color: AppColors.primary, size: 22),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      _classTitle(klass),
                      overflow: TextOverflow.ellipsis,
                      style: GoogleFonts.inter(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                        color: AppColors.textPrimary,
                      ),
                    ),
                    if (subtitle.isNotEmpty) ...[
                      const SizedBox(height: 3),
                      Text(
                        subtitle,
                        style: GoogleFonts.inter(
                          fontSize: 12,
                          color: AppColors.textSecondary,
                        ),
                      ),
                    ],
                  ],
                ),
              ),
              Icon(Icons.chevron_right_rounded,
                  color: AppColors.textSecondary),
            ],
          ),
        ),
      ),
    );
  }
}

class _ClassHeader extends StatelessWidget {
  const _ClassHeader({required this.klass});
  final Map<String, dynamic> klass;

  @override
  Widget build(BuildContext context) {
    final box = _classBox(klass);
    final date = _classDate(klass);
    final subtitle = [box, date].where((s) => s.isNotEmpty).join(' · ');
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          _classTitle(klass),
          style: GoogleFonts.spaceGrotesk(
            fontSize: 22,
            fontWeight: FontWeight.w700,
            letterSpacing: -0.44,
            color: AppColors.textPrimary,
          ),
        ),
        if (subtitle.isNotEmpty) ...[
          const SizedBox(height: 4),
          Text(
            subtitle,
            style: GoogleFonts.inter(fontSize: 13, color: AppColors.textSecondary),
          ),
        ],
      ],
    );
  }
}

class _SaveBar extends StatelessWidget {
  const _SaveBar({required this.saving, required this.onSave});
  final bool saving;
  final VoidCallback? onSave;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.fromLTRB(20, 12, 20, 16),
      decoration: BoxDecoration(
        color: AppColors.surface,
        border: Border(top: BorderSide(color: AppColors.border)),
      ),
      child: SizedBox(
        height: 52,
        width: double.infinity,
        child: ElevatedButton(
          onPressed: onSave,
          style: ElevatedButton.styleFrom(
            backgroundColor: AppColors.primary,
            foregroundColor: Colors.white,
            elevation: 0,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
          ),
          child: saving
              ? const SizedBox(
                  width: 22,
                  height: 22,
                  child: CircularProgressIndicator(
                    strokeWidth: 2,
                    color: Colors.white,
                  ),
                )
              : Text(
                  'Guardar progreso',
                  style: GoogleFonts.inter(
                    fontSize: 15,
                    fontWeight: FontWeight.w600,
                  ),
                ),
        ),
      ),
    );
  }
}

class _InfoCard extends StatelessWidget {
  const _InfoCard({required this.text});
  final String text;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.border),
      ),
      child: Text(
        text,
        style: GoogleFonts.inter(fontSize: 13, color: AppColors.textSecondary),
      ),
    );
  }
}

class _EmptyClasses extends StatelessWidget {
  const _EmptyClasses({required this.onRetry});
  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.all(24),
      children: [
        const SizedBox(height: 60),
        Icon(Icons.event_busy_rounded,
            size: 48, color: AppColors.textSecondary),
        const SizedBox(height: 12),
        Text(
          'No hay clases recientes',
          textAlign: TextAlign.center,
          style: GoogleFonts.inter(
            fontSize: 15,
            fontWeight: FontWeight.w600,
            color: AppColors.textPrimary,
          ),
        ),
        const SizedBox(height: 6),
        Text(
          'Cuando entrenes una clase programada en tu box, aparecerá aquí para '
          'registrar tu progreso. También puedes registrar una RM directamente.',
          textAlign: TextAlign.center,
          style: GoogleFonts.inter(fontSize: 13, color: AppColors.textSecondary),
        ),
        const SizedBox(height: 16),
        Center(
          child: OutlinedButton(
            onPressed: onRetry,
            child: const Text('Reintentar'),
          ),
        ),
      ],
    );
  }
}

class _ErrorView extends StatelessWidget {
  const _ErrorView({required this.message, required this.onRetry});
  final String message;
  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.all(24),
      children: [
        const SizedBox(height: 80),
        Icon(Icons.error_outline_rounded, size: 48, color: AppColors.error),
        const SizedBox(height: 12),
        Text(
          'No se pudo cargar la información',
          textAlign: TextAlign.center,
          style: GoogleFonts.inter(
            fontSize: 15,
            fontWeight: FontWeight.w600,
            color: AppColors.textPrimary,
          ),
        ),
        const SizedBox(height: 6),
        Text(
          message,
          textAlign: TextAlign.center,
          style: GoogleFonts.inter(fontSize: 12, color: AppColors.textSecondary),
        ),
        const SizedBox(height: 16),
        Center(
          child: OutlinedButton(onPressed: onRetry, child: const Text('Reintentar')),
        ),
      ],
    );
  }
}
