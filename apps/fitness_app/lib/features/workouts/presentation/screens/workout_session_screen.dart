import 'package:domain_models/domain_models.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import '../../../../app/theme/app_colors.dart';
import '../../../../core/utils/exercise_label.dart';
import '../../../../core/utils/rm_calculator.dart';
import '../../../personal_records/presentation/widgets/exercise_picker_sheet.dart';
import '../providers/workout_provider.dart';

/// Create a new workout session: title, date, notes, exercises, and sets.
/// Set weights are entered in POUNDS (LB) and stored in kilograms.
class WorkoutSessionScreen extends ConsumerStatefulWidget {
  const WorkoutSessionScreen({super.key});

  @override
  ConsumerState<WorkoutSessionScreen> createState() => _WorkoutSessionScreenState();
}

class _WorkoutSessionScreenState extends ConsumerState<WorkoutSessionScreen> {
  final _titleController = TextEditingController();
  final _notesController = TextEditingController();
  DateTime _date = DateTime.now();
  final List<_ExerciseEntry> _exercises = [];
  bool _saving = false;
  String? _error;

  /// When the workout is linked to a programmed class the athlete worked.
  String? _linkedSessionId;
  String? _linkedClassLabel;

  @override
  void dispose() {
    _titleController.dispose();
    _notesController.dispose();
    for (final e in _exercises) {
      e.dispose();
    }
    super.dispose();
  }

  Future<void> _addExercise() async {
    final ex = await showExercisePicker(context);
    if (ex != null) {
      setState(() => _exercises.add(_ExerciseEntry(exercise: ex)));
    }
  }

  /// Pick one of the athlete's recently programmed classes and pre-fill the
  /// workout (title + exercises) from that class, linking it.
  Future<void> _pickClass() async {
    final classes = await showModalBottomSheet<Map<String, dynamic>>(
      context: context,
      backgroundColor: AppColors.surface,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (_) => const _ClassPickerSheet(),
    );
    if (classes == null) return;

    final sessionId = classes['id'] as String;
    try {
      final ds = ref.read(workoutClassDatasourceProvider);
      final session = await ds.getSession(sessionId);
      final program = session['program'] as Map<String, dynamic>?;
      final title = program?['title'] as String? ?? 'Clase';
      final blocks =
          ((program?['blocks'] as List?) ?? const []).cast<Map<String, dynamic>>();
      blocks.sort((a, b) =>
          ((a['sort_order'] as num?) ?? 0).compareTo((b['sort_order'] as num?) ?? 0));

      final entries = <_ExerciseEntry>[];
      for (final b in blocks) {
        final exs = ((b['exercises'] as List?) ?? const [])
            .cast<Map<String, dynamic>>();
        for (final be in exs) {
          final exMap = be['exercise'] as Map<String, dynamic>?;
          if (exMap == null) continue;
          entries.add(_ExerciseEntry(exercise: Exercise.fromJson(exMap)));
        }
      }

      setState(() {
        _linkedSessionId = sessionId;
        _linkedClassLabel = title;
        if (_titleController.text.trim().isEmpty) _titleController.text = title;
        for (final e in _exercises) {
          e.dispose();
        }
        _exercises
          ..clear()
          ..addAll(entries);
      });
    } catch (e) {
      if (mounted) {
        setState(() => _error = 'No se pudo cargar la clase: $e');
      }
    }
  }

  void _clearClass() {
    setState(() {
      _linkedSessionId = null;
      _linkedClassLabel = null;
    });
  }

  Future<void> _pickDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _date,
      firstDate: DateTime(2015),
      lastDate: DateTime.now(),
    );
    if (picked != null) {
      setState(() => _date = DateTime(
            picked.year,
            picked.month,
            picked.day,
            _date.hour,
            _date.minute,
          ));
    }
  }

  Future<void> _save() async {
    setState(() => _error = null);
    if (_titleController.text.trim().isEmpty) {
      setState(() => _error = 'Ingresa un título para el entrenamiento.');
      return;
    }

    setState(() => _saving = true);
    try {
      final remote = ref.read(workoutRemoteProvider);
      final session = await remote.create({
        'title': _titleController.text.trim(),
        'notes': _notesController.text.trim().isEmpty ? null : _notesController.text.trim(),
        'performed_at': _date.toIso8601String(),
        'status': 'completed',
        if (_linkedSessionId != null) 'class_session_id': _linkedSessionId,
      });
      final sessionId = session['id'] as String;

      for (var i = 0; i < _exercises.length; i++) {
        final entry = _exercises[i];
        final we = await remote.addExercise({
          'session_id': sessionId,
          'exercise_id': entry.exercise.id,
          'sort_order': i,
        });
        final weId = we['id'] as String;

        var setNumber = 1;
        for (final s in entry.sets) {
          final lb = double.tryParse(s.weight.text.trim().replaceAll(',', '.'));
          final reps = int.tryParse(s.reps.text.trim());
          if (lb == null && reps == null) continue;
          await remote.addSet({
            'workout_exercise_id': weId,
            'set_number': setNumber,
            'weight_kg': lb == null ? null : RmCalculator.lbToKg(lb),
            'reps': reps,
            'is_warmup': s.isWarmup,
          });
          setNumber++;
        }
      }

      ref.invalidate(workoutListProvider);
      if (mounted) Navigator.of(context).pop(true);
    } catch (e) {
      setState(() {
        _error = 'No se pudo guardar: $e';
        _saving = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.background,
        elevation: 0,
        iconTheme: IconThemeData(color: AppColors.textPrimary),
        title: Text(
          'Registrar entrenamiento',
          style: GoogleFonts.spaceGrotesk(
            fontSize: 18,
            fontWeight: FontWeight.w700,
            color: AppColors.textPrimary,
          ),
        ),
      ),
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.fromLTRB(20, 8, 20, 24),
          children: [
            _label('Clase trabajada (opcional)'),
            const SizedBox(height: 6),
            if (_linkedClassLabel != null)
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                decoration: BoxDecoration(
                  color: AppColors.primaryLight,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: AppColors.primaryLighter),
                ),
                child: Row(
                  children: [
                    Icon(Icons.event_available_rounded,
                        size: 18, color: AppColors.primary),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Text(
                        _linkedClassLabel!,
                        style: GoogleFonts.inter(
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                          color: AppColors.textPrimary,
                        ),
                      ),
                    ),
                    TextButton(
                      onPressed: _clearClass,
                      child: const Text('Quitar'),
                    ),
                  ],
                ),
              )
            else
              Material(
                color: AppColors.surface,
                borderRadius: BorderRadius.circular(10),
                child: InkWell(
                  borderRadius: BorderRadius.circular(10),
                  onTap: _pickClass,
                  child: Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 14, vertical: 15),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(10),
                      border: Border.all(color: AppColors.border),
                    ),
                    child: Row(
                      children: [
                        Icon(Icons.fitness_center_rounded,
                            size: 18, color: AppColors.primary),
                        const SizedBox(width: 10),
                        Expanded(
                          child: Text(
                            'Seleccionar una clase programada',
                            style: GoogleFonts.inter(
                              fontSize: 14,
                              color: AppColors.textSecondary,
                            ),
                          ),
                        ),
                        Icon(Icons.chevron_right_rounded,
                            color: AppColors.textSecondary),
                      ],
                    ),
                  ),
                ),
              ),
            const SizedBox(height: 16),

            _label('Título'),
            const SizedBox(height: 6),
            TextField(
              controller: _titleController,
              style: GoogleFonts.inter(fontSize: 15, color: AppColors.textPrimary),
              decoration: _dec('Ej. WOD del lunes'),
            ),
            const SizedBox(height: 16),

            _label('Fecha'),
            const SizedBox(height: 6),
            Material(
              color: AppColors.surface,
              borderRadius: BorderRadius.circular(10),
              child: InkWell(
                borderRadius: BorderRadius.circular(10),
                onTap: _pickDate,
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 15),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(color: AppColors.border),
                  ),
                  child: Row(
                    children: [
                      Icon(Icons.calendar_today_rounded,
                          size: 18, color: AppColors.primary),
                      const SizedBox(width: 12),
                      Text(
                        DateFormat("d 'de' MMMM, y", 'es').format(_date),
                        style: GoogleFonts.inter(fontSize: 14, color: AppColors.textPrimary),
                      ),
                    ],
                  ),
                ),
              ),
            ),
            const SizedBox(height: 16),

            _label('Notas (opcional)'),
            const SizedBox(height: 6),
            TextField(
              controller: _notesController,
              maxLines: 3,
              style: GoogleFonts.inter(fontSize: 14, color: AppColors.textPrimary),
              decoration: _dec('Sensaciones, escalados, etc.'),
            ),
            const SizedBox(height: 24),

            Row(
              children: [
                Text(
                  'Ejercicios',
                  style: GoogleFonts.spaceGrotesk(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: AppColors.textPrimary,
                  ),
                ),
                const Spacer(),
                Text(
                  '${_exercises.length}',
                  style: GoogleFonts.inter(fontSize: 13, color: AppColors.textSecondary),
                ),
              ],
            ),
            const SizedBox(height: 12),

            ..._exercises.asMap().entries.map((e) => Padding(
                  padding: const EdgeInsets.only(bottom: 12),
                  child: _ExerciseCard(
                    entry: e.value,
                    onRemove: () => setState(() => _exercises.removeAt(e.key)),
                    onChanged: () => setState(() {}),
                  ),
                )),

            OutlinedButton.icon(
              onPressed: _addExercise,
              icon: const Icon(Icons.add_rounded, size: 18),
              label: const Text('Agregar ejercicio'),
              style: OutlinedButton.styleFrom(
                foregroundColor: AppColors.primary,
                side: BorderSide(color: AppColors.primary),
                minimumSize: const Size.fromHeight(48),
                textStyle: GoogleFonts.inter(fontSize: 14, fontWeight: FontWeight.w600),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              ),
            ),

            if (_error != null) ...[
              const SizedBox(height: 16),
              Text(
                _error!,
                style: GoogleFonts.inter(fontSize: 13, color: AppColors.error),
              ),
            ],

            const SizedBox(height: 24),
            SizedBox(
              height: 52,
              child: ElevatedButton(
                onPressed: _saving ? null : _save,
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primary,
                  foregroundColor: Colors.white,
                  elevation: 0,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                ),
                child: _saving
                    ? const SizedBox(
                        width: 22,
                        height: 22,
                        child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
                      )
                    : Text(
                        'Guardar entrenamiento',
                        style: GoogleFonts.inter(fontSize: 15, fontWeight: FontWeight.w600),
                      ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _label(String t) => Text(
        t,
        style: GoogleFonts.inter(
          fontSize: 13,
          fontWeight: FontWeight.w600,
          color: AppColors.textSecondary,
        ),
      );

  InputDecoration _dec(String hint) => InputDecoration(
        hintText: hint,
        filled: true,
        fillColor: AppColors.surface,
        contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
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
          borderSide: BorderSide(color: AppColors.primary, width: 1.5),
        ),
      );
}

class _ExerciseCard extends StatelessWidget {
  const _ExerciseCard({
    required this.entry,
    required this.onRemove,
    required this.onChanged,
  });

  final _ExerciseEntry entry;
  final VoidCallback onRemove;
  final VoidCallback onChanged;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  exerciseBilingual(
                      entry.exercise.nameEs, entry.exercise.name),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: GoogleFonts.inter(
                    fontSize: 15,
                    fontWeight: FontWeight.w600,
                    color: AppColors.textPrimary,
                  ),
                ),
              ),
              IconButton(
                icon: const Icon(Icons.delete_outline_rounded, size: 20),
                color: AppColors.error,
                onPressed: onRemove,
              ),
            ],
          ),
          const SizedBox(height: 4),
          Row(
            children: [
              SizedBox(
                width: 28,
                child: Text(
                  'Set',
                  style: GoogleFonts.inter(fontSize: 11, color: AppColors.textSecondary),
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  'Peso (lb)',
                  style: GoogleFonts.inter(fontSize: 11, color: AppColors.textSecondary),
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  'Reps',
                  style: GoogleFonts.inter(fontSize: 11, color: AppColors.textSecondary),
                ),
              ),
              const SizedBox(width: 40),
            ],
          ),
          const SizedBox(height: 4),
          ...entry.sets.asMap().entries.map((e) {
            final i = e.key;
            final s = e.value;
            return Padding(
              padding: const EdgeInsets.only(bottom: 8),
              child: Row(
                children: [
                  SizedBox(
                    width: 28,
                    child: Text(
                      '${i + 1}',
                      style: GoogleFonts.spaceGrotesk(
                        fontSize: 14,
                        fontWeight: FontWeight.w700,
                        color: AppColors.textPrimary,
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(child: _numField(s.weight, '0')),
                  const SizedBox(width: 8),
                  Expanded(child: _numField(s.reps, '0', decimal: false)),
                  SizedBox(
                    width: 40,
                    child: IconButton(
                      icon: const Icon(Icons.close_rounded, size: 18),
                      color: AppColors.textSecondary,
                      onPressed: () {
                        entry.removeSet(i);
                        onChanged();
                      },
                    ),
                  ),
                ],
              ),
            );
          }),
          TextButton.icon(
            onPressed: () {
              entry.addSet();
              onChanged();
            },
            icon: const Icon(Icons.add_rounded, size: 16),
            label: const Text('Agregar set'),
            style: TextButton.styleFrom(
              foregroundColor: AppColors.primary,
              textStyle: GoogleFonts.inter(fontSize: 13, fontWeight: FontWeight.w600),
            ),
          ),
        ],
      ),
    );
  }

  Widget _numField(TextEditingController c, String hint, {bool decimal = true}) {
    return TextField(
      controller: c,
      keyboardType: TextInputType.numberWithOptions(decimal: decimal),
      inputFormatters: [
        FilteringTextInputFormatter.allow(RegExp(decimal ? r'[0-9.,]' : r'[0-9]')),
      ],
      style: GoogleFonts.inter(fontSize: 14, color: AppColors.textPrimary),
      decoration: InputDecoration(
        hintText: hint,
        isDense: true,
        filled: true,
        fillColor: AppColors.inputBackground,
        contentPadding: const EdgeInsets.symmetric(horizontal: 10, vertical: 10),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: BorderSide(color: AppColors.border),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: BorderSide(color: AppColors.border),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: BorderSide(color: AppColors.primary, width: 1.5),
        ),
      ),
    );
  }
}

class _ExerciseEntry {
  _ExerciseEntry({required this.exercise}) {
    addSet();
  }

  final Exercise exercise;
  final List<_SetEntry> sets = [];

  void addSet() => sets.add(_SetEntry());

  void removeSet(int index) {
    sets[index].dispose();
    sets.removeAt(index);
  }

  void dispose() {
    for (final s in sets) {
      s.dispose();
    }
  }
}

class _SetEntry {
  final TextEditingController weight = TextEditingController();
  final TextEditingController reps = TextEditingController();
  bool isWarmup = false;

  void dispose() {
    weight.dispose();
    reps.dispose();
  }
}

/// Bottom sheet listing the athlete's recent programmed classes to link.
class _ClassPickerSheet extends ConsumerWidget {
  const _ClassPickerSheet();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final async = ref.watch(recentClassesProvider);
    return SafeArea(
      child: ConstrainedBox(
        constraints: BoxConstraints(
          maxHeight: MediaQuery.sizeOf(context).height * 0.7,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const SizedBox(height: 12),
            Container(
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: AppColors.border,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 14, 20, 8),
              child: Row(
                children: [
                  Text(
                    'Elige una clase',
                    style: GoogleFonts.spaceGrotesk(
                      fontSize: 18,
                      fontWeight: FontWeight.w700,
                      color: AppColors.textPrimary,
                    ),
                  ),
                ],
              ),
            ),
            Flexible(
              child: async.when(
                loading: () => const Padding(
                  padding: EdgeInsets.all(28),
                  child: Center(child: CircularProgressIndicator()),
                ),
                error: (e, _) => Padding(
                  padding: const EdgeInsets.all(24),
                  child: Text(
                    'No se pudieron cargar las clases.',
                    style: GoogleFonts.inter(
                        fontSize: 13, color: AppColors.textSecondary),
                  ),
                ),
                data: (classes) {
                  if (classes.isEmpty) {
                    return Padding(
                      padding: const EdgeInsets.all(24),
                      child: Text(
                        'No tienes clases programadas recientes en tus boxes.',
                        style: GoogleFonts.inter(
                            fontSize: 13, color: AppColors.textSecondary),
                      ),
                    );
                  }
                  return ListView.separated(
                    shrinkWrap: true,
                    padding: const EdgeInsets.fromLTRB(12, 0, 12, 16),
                    itemCount: classes.length,
                    separatorBuilder: (_, _) =>
                        Divider(height: 1, color: AppColors.border),
                    itemBuilder: (context, i) {
                      final c = classes[i];
                      final program = c['program'] as Map<String, dynamic>?;
                      final title = program?['title'] as String? ?? 'Clase';
                      final box = (program?['organization']
                          as Map<String, dynamic>?)?['name'] as String?;
                      final dt = DateTime.tryParse(c['start_time'] as String? ?? '')
                          ?.toLocal();
                      final when = dt != null
                          ? DateFormat("EEEE d 'de' MMM · h:mm a", 'es').format(dt)
                          : '';
                      return ListTile(
                        title: Text(
                          title,
                          style: GoogleFonts.inter(
                            fontSize: 15,
                            fontWeight: FontWeight.w600,
                            color: AppColors.textPrimary,
                          ),
                        ),
                        subtitle: Text(
                          [?box, when]
                              .where((e) => e.isNotEmpty)
                              .join(' · '),
                          style: GoogleFonts.inter(
                              fontSize: 12, color: AppColors.textSecondary),
                        ),
                        trailing: Icon(Icons.chevron_right_rounded,
                            color: AppColors.textSecondary),
                        onTap: () => Navigator.of(context).pop(c),
                      );
                    },
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
