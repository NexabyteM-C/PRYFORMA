import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../../app/theme/app_colors.dart';
import '../providers/profile_provider.dart';

const _experienceOptions = {
  'beginner': 'Principiante',
  'intermediate': 'Intermedio',
  'advanced': 'Avanzado',
  'elite': 'Élite',
};

class EditProfileScreen extends ConsumerStatefulWidget {
  const EditProfileScreen({super.key});

  @override
  ConsumerState<EditProfileScreen> createState() => _EditProfileScreenState();
}

class _EditProfileScreenState extends ConsumerState<EditProfileScreen> {
  final _nameController = TextEditingController();
  final _sportController = TextEditingController();
  final _heightController = TextEditingController();
  final _weightController = TextEditingController();
  String _experience = 'beginner';
  String _unit = 'kg';
  bool _seeded = false;
  bool _saving = false;

  @override
  void dispose() {
    _nameController.dispose();
    _sportController.dispose();
    _heightController.dispose();
    _weightController.dispose();
    super.dispose();
  }

  void _seed(Map<String, dynamic> raw) {
    _nameController.text = (raw['display_name'] as String?) ?? '';
    final athlete = athleteProfileFrom(raw);
    _sportController.text = (athlete?['primary_sport'] as String?) ?? '';
    final h = (athlete?['height_cm'] as num?)?.toDouble();
    final w = (athlete?['weight_kg'] as num?)?.toDouble();
    _heightController.text = h != null ? h.toStringAsFixed(0) : '';
    _weightController.text = w != null ? w.toStringAsFixed(1) : '';
    _experience = (athlete?['experience_level'] as String?) ?? 'beginner';
    _unit = (athlete?['preferred_unit'] as String?) ?? 'kg';
    _seeded = true;
  }

  Future<void> _save() async {
    setState(() => _saving = true);
    try {
      await ref.read(profileActionsProvider).save(
            displayName: _nameController.text.trim(),
            experienceLevel: _experience,
            preferredUnit: _unit,
            primarySport: _sportController.text.trim().isEmpty
                ? null
                : _sportController.text.trim(),
            heightCm: double.tryParse(_heightController.text.trim()),
            weightKg: double.tryParse(_weightController.text.trim()),
          );
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Perfil actualizado')),
        );
        Navigator.of(context).pop();
      }
    } catch (e) {
      if (mounted) {
        setState(() => _saving = false);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error al guardar: $e')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final raw = ref.watch(profileRawProvider);

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.background,
        elevation: 0,
        foregroundColor: AppColors.textPrimary,
        title: Text('Editar perfil',
            style: GoogleFonts.spaceGrotesk(
                fontSize: 18, fontWeight: FontWeight.w600)),
        actions: [
          TextButton(
            onPressed: _saving ? null : _save,
            child: _saving
                ? const SizedBox(
                    width: 18,
                    height: 18,
                    child: CircularProgressIndicator(strokeWidth: 2))
                : Text('Guardar',
                    style: TextStyle(
                        fontWeight: FontWeight.w700,
                        color: AppColors.primary)),
          ),
        ],
      ),
      body: raw.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => Center(
            child: Text('Error: $e',
                style: TextStyle(color: AppColors.textSecondary))),
        data: (data) {
          if (!_seeded) _seed(data);
          return SingleChildScrollView(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _Label('Nombre'),
                const SizedBox(height: 6),
                TextField(
                  controller: _nameController,
                  textCapitalization: TextCapitalization.words,
                  decoration: const InputDecoration(hintText: 'Tu nombre'),
                ),
                const SizedBox(height: 20),
                _Label('Deporte principal'),
                const SizedBox(height: 6),
                TextField(
                  controller: _sportController,
                  textCapitalization: TextCapitalization.words,
                  decoration:
                      const InputDecoration(hintText: 'Ej. CrossFit'),
                ),
                const SizedBox(height: 20),
                _Label('Nivel de experiencia'),
                const SizedBox(height: 8),
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: _experienceOptions.entries.map((e) {
                    final selected = e.key == _experience;
                    return GestureDetector(
                      onTap: () => setState(() => _experience = e.key),
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 16, vertical: 9),
                        decoration: BoxDecoration(
                          color: selected
                              ? AppColors.primary
                              : AppColors.surface,
                          borderRadius: BorderRadius.circular(18),
                          border: Border.all(
                              color: selected
                                  ? AppColors.primary
                                  : AppColors.border),
                        ),
                        child: Text(e.value,
                            style: TextStyle(
                                fontSize: 13,
                                fontWeight: FontWeight.w600,
                                color: selected
                                    ? Colors.white
                                    : AppColors.textSecondary)),
                      ),
                    );
                  }).toList(),
                ),
                const SizedBox(height: 20),
                _Label('Unidad de peso'),
                const SizedBox(height: 8),
                Row(
                  children: [
                    _UnitOption(
                        label: 'Kilogramos (kg)',
                        value: 'kg',
                        groupValue: _unit,
                        onChanged: (v) => setState(() => _unit = v)),
                    const SizedBox(width: 10),
                    _UnitOption(
                        label: 'Libras (lb)',
                        value: 'lb',
                        groupValue: _unit,
                        onChanged: (v) => setState(() => _unit = v)),
                  ],
                ),
                const SizedBox(height: 20),
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          _Label('Altura (cm)'),
                          const SizedBox(height: 6),
                          TextField(
                            controller: _heightController,
                            keyboardType: TextInputType.number,
                            decoration:
                                const InputDecoration(hintText: 'Ej. 175'),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          _Label('Peso (kg)'),
                          const SizedBox(height: 6),
                          TextField(
                            controller: _weightController,
                            keyboardType: const TextInputType.numberWithOptions(
                                decimal: true),
                            decoration:
                                const InputDecoration(hintText: 'Ej. 72.5'),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}

class _Label extends StatelessWidget {
  const _Label(this.text);
  final String text;

  @override
  Widget build(BuildContext context) {
    return Text(text,
        style: TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.w600,
            color: AppColors.textSecondary));
  }
}

class _UnitOption extends StatelessWidget {
  const _UnitOption(
      {required this.label,
      required this.value,
      required this.groupValue,
      required this.onChanged});
  final String label;
  final String value;
  final String groupValue;
  final ValueChanged<String> onChanged;

  @override
  Widget build(BuildContext context) {
    final selected = value == groupValue;
    return Expanded(
      child: GestureDetector(
        onTap: () => onChanged(value),
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 12),
          decoration: BoxDecoration(
            color: selected ? AppColors.primaryLight : AppColors.surface,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
                color: selected ? AppColors.primary : AppColors.border),
          ),
          child: Center(
            child: Text(label,
                style: TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                    color: selected
                        ? AppColors.primary
                        : AppColors.textPrimary)),
          ),
        ),
      ),
    );
  }
}
