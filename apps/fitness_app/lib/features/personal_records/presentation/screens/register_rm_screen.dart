import 'package:domain_models/domain_models.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import '../../../../app/theme/app_colors.dart';
import '../../../../core/utils/exercise_label.dart';
import '../../../../core/utils/rm_calculator.dart';
import '../../../classes/presentation/providers/class_provider.dart';
import '../pr_formatting.dart';
import '../providers/pr_provider.dart';
import '../widgets/exercise_picker_sheet.dart';

/// Screen to register a new RM / personal record.
///
/// Per spec: values are always entered by the athlete (never auto-filled).
/// Weights are entered in POUNDS (LB) and converted to kilograms on save.
class RegisterRmScreen extends ConsumerStatefulWidget {
  const RegisterRmScreen({super.key, this.initialExercise});

  final Exercise? initialExercise;

  @override
  ConsumerState<RegisterRmScreen> createState() => _RegisterRmScreenState();
}

class _RegisterRmScreenState extends ConsumerState<RegisterRmScreen> {
  final _valueController = TextEditingController();
  Exercise? _exercise;
  String _recordType = '1rm';
  String _markType = 'real';
  DateTime _date = DateTime.now();
  bool _saving = false;
  String? _error;

  @override
  void initState() {
    super.initState();
    _exercise = widget.initialExercise;
  }

  @override
  void dispose() {
    _valueController.dispose();
    super.dispose();
  }

  bool get _isWeight => isWeightRecord(_recordType);

  Future<void> _pickExercise() async {
    final picked = await showExercisePicker(context);
    if (picked != null) setState(() => _exercise = picked);
  }

  Future<void> _pickDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _date,
      firstDate: DateTime(2015),
      lastDate: DateTime.now(),
    );
    if (picked != null) setState(() => _date = picked);
  }

  Future<void> _save() async {
    setState(() => _error = null);
    if (_exercise == null) {
      setState(() => _error = 'Selecciona un ejercicio.');
      return;
    }
    final entered = double.tryParse(_valueController.text.trim().replaceAll(',', '.'));
    if (entered == null || entered <= 0) {
      setState(() => _error = 'Ingresa un valor válido.');
      return;
    }

    // Weight marks: entered in lb, stored in kg. Reps: stored as-is.
    final double storedValue = _isWeight ? RmCalculator.lbToKg(entered) : entered;

    setState(() => _saving = true);
    try {
      await ref.read(prRemoteProvider).create({
        'exercise_id': _exercise!.id,
        'record_type': _recordType,
        'value_numeric': storedValue,
        'mark_type': _markType,
        'achieved_at': _date.toIso8601String(),
      });
      ref.invalidate(prListProvider);
      ref.invalidate(prByExerciseProvider(_exercise!.id));
      // Refresh the per-exercise 1RM map so class suggested loads recalc.
      ref.invalidate(athleteRmMapProvider);
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
    final unitHint = _isWeight ? 'Valor (lb)' : 'Repeticiones';

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.background,
        elevation: 0,
        title: Text(
          'Registrar RM',
          style: GoogleFonts.spaceGrotesk(
            fontSize: 20,
            fontWeight: FontWeight.w700,
            color: AppColors.textPrimary,
          ),
        ),
        iconTheme: IconThemeData(color: AppColors.textPrimary),
      ),
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.fromLTRB(20, 8, 20, 24),
          children: [
            _label('Ejercicio'),
            const SizedBox(height: 8),
            _FieldButton(
              icon: Icons.fitness_center_rounded,
              text: _exercise == null
                  ? 'Seleccionar ejercicio'
                  : exerciseBilingual(_exercise!.nameEs, _exercise!.name),
              placeholder: _exercise == null,
              onTap: _pickExercise,
            ),
            const SizedBox(height: 20),

            _label('Tipo de récord'),
            const SizedBox(height: 8),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: kSelectableRecordTypes.entries.map((e) {
                final selected = e.key == _recordType;
                return _Chip(
                  label: e.value,
                  selected: selected,
                  onTap: () => setState(() => _recordType = e.key),
                );
              }).toList(),
            ),
            const SizedBox(height: 20),

            _label(unitHint),
            const SizedBox(height: 8),
            TextField(
              controller: _valueController,
              keyboardType: const TextInputType.numberWithOptions(decimal: true),
              inputFormatters: [
                FilteringTextInputFormatter.allow(RegExp(r'[0-9.,]')),
              ],
              style: GoogleFonts.spaceGrotesk(
                fontSize: 18,
                fontWeight: FontWeight.w600,
                color: AppColors.textPrimary,
              ),
              decoration: _inputDecoration(
                hint: _isWeight ? 'Ej. 225' : 'Ej. 15',
                suffix: _isWeight ? 'lb' : 'reps',
              ),
            ),
            if (_isWeight)
              Padding(
                padding: const EdgeInsets.only(top: 6, left: 4),
                child: Text(
                  'Las marcas de fuerza se registran en libras (lb).',
                  style: GoogleFonts.inter(
                    fontSize: 12,
                    color: AppColors.textSecondary,
                  ),
                ),
              ),
            const SizedBox(height: 20),

            _label('Tipo de marca'),
            const SizedBox(height: 8),
            Row(
              children: [
                _Chip(
                  label: markTypeLabel('real'),
                  selected: _markType == 'real',
                  onTap: () => setState(() => _markType = 'real'),
                ),
                const SizedBox(width: 8),
                _Chip(
                  label: markTypeLabel('estimated'),
                  selected: _markType == 'estimated',
                  onTap: () => setState(() => _markType = 'estimated'),
                ),
              ],
            ),
            const SizedBox(height: 20),

            _label('Fecha'),
            const SizedBox(height: 8),
            _FieldButton(
              icon: Icons.calendar_today_rounded,
              text: DateFormat("d 'de' MMMM, y", 'es').format(_date),
              placeholder: false,
              onTap: _pickDate,
            ),

            if (_error != null) ...[
              const SizedBox(height: 16),
              Text(
                _error!,
                style: GoogleFonts.inter(fontSize: 13, color: AppColors.error),
              ),
            ],

            const SizedBox(height: 28),
            SizedBox(
              height: 52,
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
                        'Guardar récord',
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
    );
  }

  Widget _label(String text) => Text(
        text,
        style: GoogleFonts.inter(
          fontSize: 13,
          fontWeight: FontWeight.w600,
          color: AppColors.textSecondary,
        ),
      );

  InputDecoration _inputDecoration({required String hint, String? suffix}) {
    return InputDecoration(
      hintText: hint,
      suffixText: suffix,
      filled: true,
      fillColor: AppColors.surface,
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
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
}

class _FieldButton extends StatelessWidget {
  const _FieldButton({
    required this.icon,
    required this.text,
    required this.placeholder,
    required this.onTap,
  });

  final IconData icon;
  final String text;
  final bool placeholder;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: AppColors.surface,
      borderRadius: BorderRadius.circular(10),
      child: InkWell(
        borderRadius: BorderRadius.circular(10),
        onTap: onTap,
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(10),
            border: Border.all(color: AppColors.border),
          ),
          child: Row(
            children: [
              Icon(icon, size: 20, color: AppColors.primary),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  text,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: GoogleFonts.inter(
                    fontSize: 15,
                    fontWeight: FontWeight.w500,
                    color: placeholder
                        ? AppColors.textSecondary
                        : AppColors.textPrimary,
                  ),
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

class _Chip extends StatelessWidget {
  const _Chip({
    required this.label,
    required this.selected,
    required this.onTap,
  });

  final String label;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
        decoration: BoxDecoration(
          color: selected ? AppColors.primary : AppColors.surface,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: selected ? AppColors.primary : AppColors.border),
        ),
        child: Text(
          label,
          style: GoogleFonts.inter(
            fontSize: 13,
            fontWeight: FontWeight.w600,
            color: selected ? Colors.white : AppColors.textSecondary,
          ),
        ),
      ),
    );
  }
}
