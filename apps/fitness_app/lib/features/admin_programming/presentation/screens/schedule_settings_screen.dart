import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../../../app/theme/app_colors.dart';
import '../../../organizations/presentation/providers/organization_provider.dart';
import '../providers/time_slots_provider.dart';

/// Lets a box configure its reusable weekly time slots (schedule).
///
/// Wired to the `/admin/settings` route by the coordinator.
class ScheduleSettingsScreen extends ConsumerWidget {
  const ScheduleSettingsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final org = ref.watch(resolvedAdminOrgProvider);

    return Scaffold(
      backgroundColor: AppColors.background,
      body: org == null
          ? const _EmptyState(
              icon: Icons.business_rounded,
              message: 'Selecciona un box para configurar sus horarios.',
            )
          : _ScheduleBody(orgId: org.id),
      floatingActionButton: org == null
          ? null
          : FloatingActionButton.extended(
              backgroundColor: AppColors.primary,
              foregroundColor: Colors.white,
              onPressed: () => _openSlotDialog(context, ref, org.id),
              icon: const Icon(Icons.add_rounded),
              label: const Text('Agregar horario'),
            ),
    );
  }
}

class _ScheduleBody extends ConsumerWidget {
  const _ScheduleBody({required this.orgId});
  final String orgId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final slotsAsync = ref.watch(timeSlotsProvider(orgId));

    return RefreshIndicator(
      onRefresh: () async => ref.invalidate(timeSlotsProvider(orgId)),
      child: slotsAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => ListView(
          children: [
            const SizedBox(height: 120),
            _EmptyState(
              icon: Icons.error_outline_rounded,
              message: 'No se pudieron cargar los horarios.\n$e',
            ),
          ],
        ),
        data: (slots) {
          int startOf(Map<String, dynamic> s) =>
              (s['start_minutes'] as num?)?.toInt() ?? 0;
          // Earliest slot on top, latest at the bottom, within each period.
          final am = slots
              .where((s) => (s['period'] as String?) == 'AM')
              .toList()
            ..sort((a, b) => startOf(a).compareTo(startOf(b)));
          final pm = slots
              .where((s) => (s['period'] as String?) != 'AM')
              .toList()
            ..sort((a, b) => startOf(a).compareTo(startOf(b)));

          return ListView(
            padding: const EdgeInsets.fromLTRB(20, 24, 20, 96),
            children: [
              Text(
                'Horarios del box',
                style: GoogleFonts.spaceGrotesk(
                  fontSize: 24,
                  fontWeight: FontWeight.w700,
                  color: AppColors.textPrimary,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                'Franjas semanales reutilizables. Se usan para programar las '
                'sesiones de cada clase.',
                style: TextStyle(fontSize: 13, color: AppColors.textSecondary),
              ),
              const SizedBox(height: 24),
              if (slots.isEmpty)
                const _EmptyState(
                  icon: Icons.schedule_rounded,
                  message: 'Aún no hay horarios configurados.',
                )
              else ...[
                _SlotGroup(title: 'Mañana (AM)', orgId: orgId, slots: am),
                if (am.isNotEmpty && pm.isNotEmpty)
                  const SizedBox(height: 24),
                _SlotGroup(title: 'Tarde (PM)', orgId: orgId, slots: pm),
              ],
            ],
          );
        },
      ),
    );
  }
}

class _SlotGroup extends StatelessWidget {
  const _SlotGroup({
    required this.title,
    required this.orgId,
    required this.slots,
  });
  final String title;
  final String orgId;
  final List<Map<String, dynamic>> slots;

  @override
  Widget build(BuildContext context) {
    if (slots.isEmpty) return const SizedBox.shrink();
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: GoogleFonts.spaceGrotesk(
            fontSize: 16,
            fontWeight: FontWeight.w600,
            color: AppColors.primaryDark,
          ),
        ),
        const SizedBox(height: 10),
        ...slots.map((s) => _SlotCard(orgId: orgId, slot: s)),
      ],
    );
  }
}

class _SlotCard extends ConsumerWidget {
  const _SlotCard({required this.orgId, required this.slot});
  final String orgId;
  final Map<String, dynamic> slot;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final active = (slot['is_active'] as bool?) ?? true;
    final capacity = (slot['capacity'] as num?)?.toInt() ?? 0;
    final start = (slot['start_minutes'] as num?)?.toInt() ?? 0;
    final end = (slot['end_minutes'] as num?)?.toInt() ?? 0;
    final label = (slot['label'] as String?) ?? slotLabel(start, end);

    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.fromLTRB(16, 12, 8, 12),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: AppColors.border),
      ),
      child: Row(
        children: [
          Container(
            width: 42,
            height: 42,
            decoration: BoxDecoration(
              color: active
                  ? AppColors.primaryLight
                  : AppColors.badgeBackground,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(
              Icons.schedule_rounded,
              size: 20,
              color: active ? AppColors.primary : AppColors.textSecondary,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: GoogleFonts.spaceGrotesk(
                    fontSize: 15,
                    fontWeight: FontWeight.w600,
                    color: AppColors.textPrimary,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  'Cupo: $capacity',
                  style: TextStyle(
                    fontSize: 12,
                    color: AppColors.textSecondary,
                  ),
                ),
              ],
            ),
          ),
          Switch(
            value: active,
            activeThumbColor: AppColors.primary,
            onChanged: (v) async {
              try {
                await ref
                    .read(timeSlotActionsProvider)
                    .update(orgId, slot['id'] as String, {'is_active': v});
              } catch (e) {
                if (context.mounted) {
                  _snack(context, 'No se pudo actualizar: $e', isError: true);
                }
              }
            },
          ),
          IconButton(
            icon: Icon(
              Icons.edit_outlined,
              size: 18,
              color: AppColors.textSecondary,
            ),
            tooltip: 'Editar',
            onPressed: () => _openSlotDialog(context, ref, orgId, slot: slot),
          ),
          IconButton(
            icon: Icon(
              Icons.delete_outline_rounded,
              size: 18,
              color: AppColors.error,
            ),
            tooltip: 'Eliminar',
            onPressed: () async {
              final confirm = await showDialog<bool>(
                context: context,
                builder: (dialogCtx) => AlertDialog(
                  title: const Text('Eliminar horario'),
                  content: Text('¿Eliminar la franja "$label"?'),
                  actions: [
                    TextButton(
                      onPressed: () => Navigator.of(dialogCtx).pop(false),
                      child: const Text('Cancelar'),
                    ),
                    TextButton(
                      onPressed: () => Navigator.of(dialogCtx).pop(true),
                      child: Text(
                        'Eliminar',
                        style: TextStyle(color: AppColors.error),
                      ),
                    ),
                  ],
                ),
              );
              if (confirm != true) return;
              try {
                await ref
                    .read(timeSlotActionsProvider)
                    .delete(orgId, slot['id'] as String);
              } catch (e) {
                if (context.mounted) {
                  _snack(context, 'No se pudo eliminar: $e', isError: true);
                }
              }
            },
          ),
        ],
      ),
    );
  }
}

class _EmptyState extends StatelessWidget {
  const _EmptyState({required this.icon, required this.message});
  final IconData icon;
  final String message;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: 48, color: AppColors.textSecondary),
            const SizedBox(height: 12),
            Text(
              message,
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 14,
                color: AppColors.textSecondary,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

void _snack(BuildContext context, String msg, {bool isError = false}) {
  if (!context.mounted) return;
  ScaffoldMessenger.of(context).showSnackBar(
    SnackBar(
      content: Text(msg),
      backgroundColor: isError ? AppColors.error : AppColors.success,
    ),
  );
}

/// Opens the add/edit dialog for a slot. When [slot] is null, creates a new one.
Future<void> _openSlotDialog(
  BuildContext context,
  WidgetRef ref,
  String orgId, {
  Map<String, dynamic>? slot,
}) async {
  final result = await showDialog<_SlotFormResult>(
    context: context,
    builder: (_) => _SlotFormDialog(slot: slot),
  );
  if (result == null) return;

  final body = <String, dynamic>{
    'label': slotLabel(result.startMinutes, result.endMinutes),
    'start_minutes': result.startMinutes,
    'end_minutes': result.endMinutes,
    'period': slotPeriod(result.startMinutes),
    'capacity': result.capacity,
    'sort_order': result.startMinutes,
  };

  try {
    final actions = ref.read(timeSlotActionsProvider);
    if (slot == null) {
      await actions.create(orgId, body);
    } else {
      await actions.update(orgId, slot['id'] as String, body);
    }
    if (context.mounted) {
      _snack(context, slot == null ? 'Horario agregado' : 'Horario actualizado');
    }
  } catch (e) {
    if (context.mounted) _snack(context, 'Error: $e', isError: true);
  }
}

class _SlotFormResult {
  _SlotFormResult(this.startMinutes, this.endMinutes, this.capacity);
  final int startMinutes;
  final int endMinutes;
  final int capacity;
}

class _SlotFormDialog extends StatefulWidget {
  const _SlotFormDialog({this.slot});
  final Map<String, dynamic>? slot;

  @override
  State<_SlotFormDialog> createState() => _SlotFormDialogState();
}

class _SlotFormDialogState extends State<_SlotFormDialog> {
  late TimeOfDay _start;
  late TimeOfDay _end;
  late final TextEditingController _capacityCtrl;
  String? _error;

  @override
  void initState() {
    super.initState();
    final s = widget.slot;
    final startM = (s?['start_minutes'] as num?)?.toInt() ?? 300; // 5:00
    final endM = (s?['end_minutes'] as num?)?.toInt() ?? 360; // 6:00
    _start = TimeOfDay(hour: startM ~/ 60, minute: startM % 60);
    _end = TimeOfDay(hour: endM ~/ 60, minute: endM % 60);
    _capacityCtrl = TextEditingController(
      text: '${(s?['capacity'] as num?)?.toInt() ?? 15}',
    );
  }

  @override
  void dispose() {
    _capacityCtrl.dispose();
    super.dispose();
  }

  int get _startMinutes => _start.hour * 60 + _start.minute;
  int get _endMinutes => _end.hour * 60 + _end.minute;

  Future<void> _pickStart() async {
    final t = await showTimePicker(context: context, initialTime: _start);
    if (t != null) setState(() => _start = t);
  }

  Future<void> _pickEnd() async {
    final t = await showTimePicker(context: context, initialTime: _end);
    if (t != null) setState(() => _end = t);
  }

  void _submit() {
    if (_endMinutes <= _startMinutes) {
      setState(() => _error = 'La hora de fin debe ser posterior al inicio.');
      return;
    }
    final capacity = int.tryParse(_capacityCtrl.text.trim());
    if (capacity == null || capacity <= 0) {
      setState(() => _error = 'Ingresa un cupo válido.');
      return;
    }
    Navigator.of(
      context,
    ).pop(_SlotFormResult(_startMinutes, _endMinutes, capacity));
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text(widget.slot == null ? 'Nuevo horario' : 'Editar horario'),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: _TimeField(
                  label: 'Inicio',
                  time: _start,
                  onTap: _pickStart,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _TimeField(label: 'Fin', time: _end, onTap: _pickEnd),
              ),
            ],
          ),
          const SizedBox(height: 16),
          TextField(
            controller: _capacityCtrl,
            keyboardType: TextInputType.number,
            decoration: const InputDecoration(labelText: 'Cupo'),
          ),
          const SizedBox(height: 12),
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: AppColors.primaryLight.withValues(alpha: 0.5),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Row(
              children: [
                Icon(
                  Icons.label_outline_rounded,
                  size: 16,
                  color: AppColors.primary,
                ),
                const SizedBox(width: 8),
                Text(
                  slotLabel(_startMinutes, _endMinutes),
                  style: TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                    color: AppColors.primaryDark,
                  ),
                ),
              ],
            ),
          ),
          if (_error != null) ...[
            const SizedBox(height: 10),
            Text(
              _error!,
              style: TextStyle(fontSize: 12, color: AppColors.error),
            ),
          ],
        ],
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text('Cancelar'),
        ),
        ElevatedButton(onPressed: _submit, child: const Text('Guardar')),
      ],
    );
  }
}

class _TimeField extends StatelessWidget {
  const _TimeField({
    required this.label,
    required this.time,
    required this.onTap,
  });
  final String label;
  final TimeOfDay time;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      child: InputDecorator(
        decoration: InputDecoration(
          labelText: label,
          suffixIcon: const Icon(Icons.schedule_rounded, size: 16),
        ),
        child: Text(time.format(context), style: const TextStyle(fontSize: 14)),
      ),
    );
  }
}
