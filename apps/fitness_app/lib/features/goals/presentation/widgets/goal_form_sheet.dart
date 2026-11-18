import 'package:domain_models/domain_models.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import '../../../../app/theme/app_colors.dart';
import '../../../../core/utils/exercise_label.dart';
import '../../../personal_records/presentation/widgets/exercise_picker_sheet.dart';
import '../goal_formatting.dart';
import '../providers/goal_provider.dart';

/// Bottom sheet to create or edit a goal. Returns true when saved.
///
/// [presetExercise] pre-selects a movement (used when defining a goal straight
/// from that movement's progress screen).
Future<bool?> showGoalFormSheet(
  BuildContext context, {
  Goal? existing,
  Exercise? presetExercise,
}) {
  return showModalBottomSheet<bool>(
    context: context,
    isScrollControlled: true,
    backgroundColor: Colors.transparent,
    builder: (_) =>
        _GoalFormSheet(existing: existing, presetExercise: presetExercise),
  );
}

class _GoalFormSheet extends ConsumerStatefulWidget {
  const _GoalFormSheet({this.existing, this.presetExercise});
  final Goal? existing;
  final Exercise? presetExercise;

  @override
  ConsumerState<_GoalFormSheet> createState() => _GoalFormSheetState();
}

class _GoalFormSheetState extends ConsumerState<_GoalFormSheet> {
  late final TextEditingController _title;
  late final TextEditingController _target;
  late final TextEditingController _current;
  late final TextEditingController _unit;
  String _goalType = 'weight';
  DateTime? _targetDate;
  Exercise? _exercise;
  String? _exerciseId;
  bool _saving = false;
  String? _error;

  bool get _isEdit => widget.existing != null;

  @override
  void initState() {
    super.initState();
    final g = widget.existing;
    // Note: the Goal model does not expose `title`, so it cannot be prefilled on
    // edit. The title field is only shown when creating (DB column is NOT NULL).
    _title = TextEditingController();
    _target = TextEditingController(text: g != null ? formatNumber(g.targetValue) : '');
    _current = TextEditingController(
        text: g?.currentValue != null ? formatNumber(g!.currentValue!) : '');
    _unit = TextEditingController(text: g?.unit ?? '');
    _goalType = g?.goalType ?? 'weight';
    _targetDate = g?.targetDate;
    _exerciseId = g?.exerciseId ?? widget.presetExercise?.id;
    _exercise = g?.exercise ?? widget.presetExercise;
  }

  @override
  void dispose() {
    _title.dispose();
    _target.dispose();
    _current.dispose();
    _unit.dispose();
    super.dispose();
  }

  Future<void> _pickExercise() async {
    final ex = await showExercisePicker(context);
    if (ex != null) {
      setState(() {
        _exercise = ex;
        _exerciseId = ex.id;
      });
    }
  }

  Future<void> _pickDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _targetDate ?? DateTime.now().add(const Duration(days: 30)),
      firstDate: DateTime.now().subtract(const Duration(days: 1)),
      lastDate: DateTime(2035),
    );
    if (picked != null) setState(() => _targetDate = picked);
  }

  Future<void> _save() async {
    setState(() => _error = null);
    final title = _title.text.trim();
    final target = double.tryParse(_target.text.trim().replaceAll(',', '.'));
    if (!_isEdit && title.isEmpty) {
      setState(() => _error = 'Ingresa un título.');
      return;
    }
    if (target == null || target <= 0) {
      setState(() => _error = 'Ingresa un valor objetivo válido.');
      return;
    }
    final current = _current.text.trim().isEmpty
        ? (widget.existing?.currentValue ?? 0.0)
        : double.tryParse(_current.text.trim().replaceAll(',', '.')) ?? 0.0;

    final body = <String, dynamic>{
      'goal_type': _goalType,
      'exercise_id': _exerciseId,
      'target_value': target,
      'current_value': current,
      'unit': _unit.text.trim().isEmpty ? null : _unit.text.trim(),
      'target_date': _targetDate?.toIso8601String(),
    };

    setState(() => _saving = true);
    try {
      final remote = ref.read(goalRemoteProvider);
      if (_isEdit) {
        await remote.update(widget.existing!.id, body);
        ref.invalidate(goalDetailProvider(widget.existing!.id));
      } else {
        body['title'] = title;
        body['initial_value'] = current;
        body['status'] = 'active';
        await remote.create(body);
      }
      ref.invalidate(goalListProvider);
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
    final bottomInset = MediaQuery.of(context).viewInsets.bottom;
    return Padding(
      padding: EdgeInsets.only(bottom: bottomInset),
      child: Container(
        decoration: BoxDecoration(
          color: AppColors.background,
          borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
        ),
        child: SafeArea(
          top: false,
          child: SingleChildScrollView(
            padding: const EdgeInsets.fromLTRB(20, 14, 20, 20),
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
                Text(
                  _isEdit ? 'Editar objetivo' : 'Nuevo objetivo',
                  style: GoogleFonts.spaceGrotesk(
                    fontSize: 20,
                    fontWeight: FontWeight.w700,
                    color: AppColors.textPrimary,
                  ),
                ),
                const SizedBox(height: 18),

                if (!_isEdit) ...[
                  _label('Título'),
                  const SizedBox(height: 6),
                  _input(_title, hint: 'Ej. Back Squat 140 kg'),
                  const SizedBox(height: 16),
                ],

                _label('Tipo de objetivo'),
                const SizedBox(height: 8),
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: kGoalTypeLabels.entries.map((e) {
                    final selected = e.key == _goalType;
                    return GestureDetector(
                      onTap: () => setState(() => _goalType = e.key),
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 9),
                        decoration: BoxDecoration(
                          color: selected ? AppColors.primary : AppColors.surface,
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(
                            color: selected ? AppColors.primary : AppColors.border,
                          ),
                        ),
                        child: Text(
                          e.value,
                          style: GoogleFonts.inter(
                            fontSize: 13,
                            fontWeight: FontWeight.w600,
                            color: selected ? Colors.white : AppColors.textSecondary,
                          ),
                        ),
                      ),
                    );
                  }).toList(),
                ),
                const SizedBox(height: 16),

                _label('Ejercicio (opcional)'),
                const SizedBox(height: 6),
                _fieldButton(
                  _exercise == null
                      ? 'Sin ejercicio'
                      : exerciseBilingual(_exercise!.nameEs, _exercise!.name),
                  _exercise == null,
                  _pickExercise,
                  trailing: _exercise != null
                      ? IconButton(
                          icon: const Icon(Icons.close_rounded, size: 18),
                          color: AppColors.textSecondary,
                          onPressed: () => setState(() {
                            _exercise = null;
                            _exerciseId = null;
                          }),
                        )
                      : null,
                ),
                const SizedBox(height: 16),

                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          _label('Valor actual'),
                          const SizedBox(height: 6),
                          _input(_current, hint: '0', number: true),
                        ],
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          _label('Objetivo'),
                          const SizedBox(height: 6),
                          _input(_target, hint: '140', number: true),
                        ],
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          _label('Unidad'),
                          const SizedBox(height: 6),
                          _input(_unit, hint: 'kg'),
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),

                _label('Fecha objetivo (opcional)'),
                const SizedBox(height: 6),
                _fieldButton(
                  _targetDate == null
                      ? 'Sin fecha'
                      : DateFormat("d 'de' MMMM, y", 'es').format(_targetDate!),
                  _targetDate == null,
                  _pickDate,
                  trailing: _targetDate != null
                      ? IconButton(
                          icon: const Icon(Icons.close_rounded, size: 18),
                          color: AppColors.textSecondary,
                          onPressed: () => setState(() => _targetDate = null),
                        )
                      : null,
                ),

                if (_error != null) ...[
                  const SizedBox(height: 14),
                  Text(
                    _error!,
                    style: GoogleFonts.inter(fontSize: 13, color: AppColors.error),
                  ),
                ],

                const SizedBox(height: 24),
                SizedBox(
                  height: 52,
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: _saving ? null : _save,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.primary,
                      foregroundColor: Colors.white,
                      elevation: 0,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    child: _saving
                        ? const SizedBox(
                            width: 22,
                            height: 22,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              color: Colors.white,
                            ),
                          )
                        : Text(
                            _isEdit ? 'Guardar cambios' : 'Crear objetivo',
                            style: GoogleFonts.inter(
                              fontSize: 15,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                  ),
                ),
              ],
            ),
          ),
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

  Widget _input(TextEditingController c, {required String hint, bool number = false}) {
    return TextField(
      controller: c,
      keyboardType:
          number ? const TextInputType.numberWithOptions(decimal: true) : TextInputType.text,
      style: GoogleFonts.inter(fontSize: 14, color: AppColors.textPrimary),
      decoration: InputDecoration(
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
      ),
    );
  }

  Widget _fieldButton(String text, bool placeholder, VoidCallback onTap,
      {Widget? trailing}) {
    return Material(
      color: AppColors.surface,
      borderRadius: BorderRadius.circular(10),
      child: InkWell(
        borderRadius: BorderRadius.circular(10),
        onTap: onTap,
        child: Container(
          padding: EdgeInsets.fromLTRB(14, 14, trailing != null ? 4 : 14, 14),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(10),
            border: Border.all(color: AppColors.border),
          ),
          child: Row(
            children: [
              Expanded(
                child: Text(
                  text,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: GoogleFonts.inter(
                    fontSize: 14,
                    color: placeholder ? AppColors.textSecondary : AppColors.textPrimary,
                  ),
                ),
              ),
              trailing ?? Icon(Icons.chevron_right_rounded, color: AppColors.textSecondary),
            ],
          ),
        ),
      ),
    );
  }
}
