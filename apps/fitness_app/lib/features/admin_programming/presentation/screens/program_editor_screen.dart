import 'package:domain_models/domain_models.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';

import '../../../../app/theme/app_colors.dart';
import '../../../../core/widgets/fit_back_button.dart';
import '../../../organizations/presentation/providers/organization_provider.dart';
import '../providers/programming_provider.dart';
import '../providers/time_slots_provider.dart';
import '../widgets/block_editor.dart';
import '../widgets/exercise_picker.dart';
import '../../../exercises/presentation/providers/exercise_provider.dart';
import '../widgets/publication_scheduler.dart';
import 'program_status_badge.dart';

class _SessionDraft {
  _SessionDraft({
    this.id,
    required this.time,
    this.capacity = 15,
    this.locationId,
  });
  String? id;
  TimeOfDay time;
  int capacity;
  String? locationId;
}

class ProgramEditorScreen extends ConsumerStatefulWidget {
  const ProgramEditorScreen({super.key, this.programId});
  final String? programId;

  @override
  ConsumerState<ProgramEditorScreen> createState() =>
      _ProgramEditorScreenState();
}

class _ProgramEditorScreenState extends ConsumerState<ProgramEditorScreen> {
  final _titleCtrl = TextEditingController();
  final _descCtrl = TextEditingController();
  final _objectiveCtrl = TextEditingController();
  final _coachNotesCtrl = TextEditingController();
  final _focusTagCtrl = TextEditingController();

  String? _programId;
  DateTime _programDate = DateTime.now();
  final List<String> _focusTags = [];
  String? _locationId;
  final List<BlockDraft> _blocks = [];
  final List<_SessionDraft> _sessions = [];
  final List<String> _existingBlockIds = [];
  final List<String> _existingSessionIds = [];

  String _status = 'draft';
  DateTime? _scheduledAt;
  bool _loading = false;
  bool _saving = false;

  /// Bumped to force the configured-slots panel to refetch after changes.
  int _sessionsVersion = 0;

  @override
  void initState() {
    super.initState();
    _programId = widget.programId;
    if (_programId != null) {
      _loading = true;
      WidgetsBinding.instance.addPostFrameCallback((_) => _load());
    } else {
      // Default class structure for a brand-new program (fully editable).
      _blocks.addAll([
        BlockDraft(
          blockType: 'warmup',
          title: 'Calentamiento',
          durationMinutes: 10,
        ),
        BlockDraft(
          blockType: 'strength',
          title: 'Fuerza / Técnica',
          durationMinutes: 20,
        ),
        BlockDraft(
          blockType: 'wod',
          title: 'WOD Principal',
          durationMinutes: 15,
          scoringTypeOverride: 'rounds_reps',
        ),
        BlockDraft(
          blockType: 'cooldown',
          title: 'Estiramiento',
          durationMinutes: 5,
        ),
      ]);
    }
  }

  @override
  void dispose() {
    _titleCtrl.dispose();
    _descCtrl.dispose();
    _objectiveCtrl.dispose();
    _coachNotesCtrl.dispose();
    _focusTagCtrl.dispose();
    for (final b in _blocks) {
      b.dispose();
    }
    super.dispose();
  }

  Future<void> _load() async {
    final ds = ref.read(programmingDatasourceProvider);
    try {
      final data = await ds.getById(_programId!);
      _titleCtrl.text = (data['title'] as String?) ?? '';
      _descCtrl.text = (data['description'] as String?) ?? '';
      _objectiveCtrl.text = (data['objective'] as String?) ?? '';
      _coachNotesCtrl.text = (data['coach_notes'] as String?) ?? '';
      _status = (data['status'] as String?) ?? 'draft';
      _locationId = data['location_id'] as String?;
      final dateStr = data['program_date'] as String?;
      if (dateStr != null) _programDate = DateTime.parse(dateStr);
      final tags = (data['focus_tags'] as List<dynamic>?) ?? const [];
      _focusTags
        ..clear()
        ..addAll(tags.map((e) => e as String));
      final schedStr = data['scheduled_publish_at'] as String?;
      if (schedStr != null) _scheduledAt = DateTime.parse(schedStr).toLocal();

      final blockRows =
          ((data['blocks'] as List<dynamic>?) ?? const [])
              .map((e) => e as Map<String, dynamic>)
              .toList()
            ..sort(
              (a, b) => ((a['sort_order'] as num?) ?? 0).compareTo(
                (b['sort_order'] as num?) ?? 0,
              ),
            );
      for (final b in _blocks) {
        b.dispose();
      }
      _blocks
        ..clear()
        ..addAll(blockRows.map(BlockDraft.fromJson));
      _existingBlockIds
        ..clear()
        ..addAll(blockRows.map((e) => e['id'] as String));
      if (_blocks.isEmpty) _blocks.add(BlockDraft(blockType: 'warmup'));

      final sessionRows =
          ((data['sessions'] as List<dynamic>?) ?? const [])
              .map((e) => e as Map<String, dynamic>)
              .toList()
            ..sort(
              (a, b) => ((a['start_time'] as String?) ?? '').compareTo(
                (b['start_time'] as String?) ?? '',
              ),
            );
      _sessions
        ..clear()
        ..addAll(
          sessionRows.map((e) {
            final start = DateTime.parse(e['start_time'] as String).toLocal();
            return _SessionDraft(
              id: e['id'] as String?,
              time: TimeOfDay(hour: start.hour, minute: start.minute),
              capacity: (e['capacity'] as num?)?.toInt() ?? 15,
              locationId: e['location_id'] as String?,
            );
          }),
        );
      _existingSessionIds
        ..clear()
        ..addAll(sessionRows.map((e) => e['id'] as String));
    } catch (e) {
      if (mounted) _snack('No se pudo cargar: $e', isError: true);
    } finally {
      if (mounted) setState(() => _loading = false);
      // Flutter web sometimes doesn't paint TextFields built during an async
      // load until an interaction; force an extra frame so blocks show.
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted) setState(() {});
      });
    }
  }

  /// Re-reads this program's sessions from the server and rebuilds the
  /// free-form draft list so it stays in sync after slot toggles / saves.
  Future<void> _reloadSessions() async {
    if (_programId == null) return;
    final ds = ref.read(programmingDatasourceProvider);
    try {
      final rows = await ds.sessionsForProgram(_programId!);
      final sorted = [...rows]..sort(
        (a, b) => ((a['start_time'] as String?) ?? '').compareTo(
          (b['start_time'] as String?) ?? '',
        ),
      );
      _sessions
        ..clear()
        ..addAll(
          sorted.map((e) {
            final start = DateTime.parse(e['start_time'] as String).toLocal();
            return _SessionDraft(
              id: e['id'] as String?,
              time: TimeOfDay(hour: start.hour, minute: start.minute),
              capacity: (e['capacity'] as num?)?.toInt() ?? 15,
              locationId: e['location_id'] as String?,
            );
          }),
        );
      _existingSessionIds
        ..clear()
        ..addAll(sorted.map((e) => e['id'] as String));
      if (mounted) setState(() => _sessionsVersion++);
    } catch (e) {
      if (mounted) {
        _snack('No se pudieron recargar las sesiones: $e', isError: true);
      }
    }
  }

  void _snack(String msg, {bool isError = false}) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(msg),
        backgroundColor: isError ? AppColors.error : AppColors.success,
      ),
    );
  }

  List<OrganizationLocation> _locations() {
    final org = ref.read(resolvedAdminOrgProvider);
    return org?.locations ?? const [];
  }

  Future<void> _persist({required bool publish}) async {
    final title = _titleCtrl.text.trim();
    if (title.isEmpty) {
      _snack('El título es obligatorio', isError: true);
      return;
    }
    if (_locationId == null) {
      _snack('Selecciona una ubicación', isError: true);
      return;
    }
    if (publish && _scheduledAt == null && !_immediateSelected) {
      // _scheduledAt null + not immediate => scheduler not completed
      _snack('Completa la fecha y hora de publicación', isError: true);
      return;
    }

    setState(() => _saving = true);
    final ds = ref.read(programmingDatasourceProvider);
    final org = ref.read(resolvedAdminOrgProvider);
    try {
      final header = <String, dynamic>{
        'title': title,
        'program_date': DateFormat('yyyy-MM-dd').format(_programDate),
        'location_id': _locationId,
        'description': _descCtrl.text.trim().isEmpty
            ? null
            : _descCtrl.text.trim(),
        'objective': _objectiveCtrl.text.trim().isEmpty
            ? null
            : _objectiveCtrl.text.trim(),
        'coach_notes': _coachNotesCtrl.text.trim().isEmpty
            ? null
            : _coachNotesCtrl.text.trim(),
        'focus_tags': _focusTags,
      };

      if (_programId == null) {
        final created = await ds.create(org!.id, header);
        _programId = created['id'] as String;
      } else {
        await ds.update(_programId!, header);
      }

      // Replace blocks (cascade removes their exercises). Run the network
      // calls in parallel waves instead of one-by-one so publishing a full
      // program stays fast even with many blocks and movements.

      // Wave 1: delete every existing block (cascade removes its exercises)
      // and, in parallel, create all the new blocks.
      final createResults = await Future.wait([
        ..._existingBlockIds.map(ds.deleteBlock).map((f) => f.then((_) => null)),
        for (var i = 0; i < _blocks.length; i++)
          () {
            final b = _blocks[i];
            final blockTitle = b.titleCtrl.text.trim().isEmpty
                ? blockTypeLabel(b.blockType)
                : b.titleCtrl.text.trim();
            return ds.addBlock({
              'program_id': _programId,
              'block_type': b.blockType,
              'title': blockTitle,
              'description': b.descCtrl.text.trim().isEmpty
                  ? null
                  : b.descCtrl.text.trim(),
              'scoring_type': b.scoringType,
              'coach_notes': b.composedCoachNotes(),
              'duration_minutes': b.durationMinutes,
              'is_surprise': b.isSurprise,
              'sort_order': i,
            }).then((row) => (i, row));
          }(),
      ]);
      _existingBlockIds.clear();

      // Map each created block back to its draft (deletes returned null).
      final exerciseInserts = <Future<void>>[];
      for (final result in createResults) {
        if (result is! (int, Map<String, dynamic>)) continue;
        final (i, blockRow) = result;
        final b = _blocks[i];
        final blockId = blockRow['id'] as String;
        b.id = blockId;
        _existingBlockIds.add(blockId);
        var exOrder = 0;
        for (final ex in b.exercises) {
          if (ex.exerciseId == null) continue;
          final order = exOrder++;
          exerciseInserts.add(ds.addBlockExercise({
            'block_id': blockId,
            'exercise_id': ex.exerciseId,
            'sets': ex.sets,
            'reps': ex.reps.isEmpty ? null : ex.reps,
            'weight_prescription': ex.weightPrescription.isEmpty
                ? null
                : ex.weightPrescription,
            'set_scheme': ex.schemeJson.isEmpty ? null : ex.schemeJson,
            'is_surprise': ex.isSurprise,
            'sort_order': order,
          }).then((_) {}));
        }
      }

      // Wave 2: insert every movement in parallel, and sync the sessions
      // (which preserves existing session ids) at the same time.
      await Future.wait([
        ...exerciseInserts,
        // Sessions are derived automatically from the box's configured
        // schedule: one class_session per active time slot on this date.
        ds.syncSessionsFromSlots(
          orgId: org!.id,
          programId: _programId!,
          date: _programDate,
          fallbackLocationId: _locationId,
        ),
      ]);

      if (publish) {
        await ds.publish(
          _programId!,
          scheduledAt: _immediateSelected ? null : _scheduledAt,
        );
        _status = _immediateSelected ? 'published' : 'scheduled';
      }

      ref.invalidate(programmingListProvider);
      if (_programId != null) {
        ref.invalidate(programmingDetailProvider(_programId!));
      }
      _snack(
        publish
            ? (_immediateSelected
                  ? 'Programación publicada'
                  : 'Publicación programada')
            : 'Borrador guardado',
      );
      if (mounted && publish) context.pop();
    } catch (e) {
      _snack('Error al guardar: $e', isError: true);
    } finally {
      if (mounted) setState(() => _saving = false);
    }
  }

  bool _immediateSelected = true;

  Future<void> _deleteProgram() async {
    if (_programId == null) return;
    final confirm = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('Eliminar programación'),
        content: const Text(
          '¿Seguro que deseas eliminar esta programación? Esta acción no se puede deshacer.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(dialogContext).pop(false),
            child: const Text('Cancelar'),
          ),
          TextButton(
            onPressed: () => Navigator.of(dialogContext).pop(true),
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
      await ref.read(programmingDatasourceProvider).deleteProgram(_programId!);
      ref.invalidate(programmingListProvider);
      _snack('Programación eliminada');
      if (mounted) context.pop();
    } catch (e) {
      _snack('Error al eliminar: $e', isError: true);
    }
  }

  @override
  Widget build(BuildContext context) {
    final locations = _locations();
    if (_locationId == null && locations.isNotEmpty) {
      _locationId = locations
          .firstWhere((l) => l.isPrimary, orElse: () => locations.first)
          .id;
    }

    if (_loading) {
      return Scaffold(
        backgroundColor: AppColors.background,
        body: Center(child: CircularProgressIndicator()),
      );
    }

    return Scaffold(
      backgroundColor: AppColors.background,
      body: LayoutBuilder(
        builder: (context, constraints) {
          final narrow = constraints.maxWidth < 900;
          final side = _buildSidebar(locations);
          if (narrow) {
            // On a phone the publish / save controls go to the top so they are
            // reachable without scrolling past the whole form and every block.
            return SingleChildScrollView(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildHeader(),
                  const SizedBox(height: 18),
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: AppColors.surface,
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(color: AppColors.border),
                    ),
                    child: side,
                  ),
                  const SizedBox(height: 24),
                  _buildFormBody(locations),
                ],
              ),
            );
          }
          final form = _buildForm(locations);
          return Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                flex: 3,
                child: SingleChildScrollView(
                  padding: const EdgeInsets.all(28),
                  child: form,
                ),
              ),
              Container(
                width: 340,
                constraints: BoxConstraints(minHeight: constraints.maxHeight),
                decoration: BoxDecoration(
                  color: AppColors.surface,
                  border: Border(left: BorderSide(color: AppColors.border)),
                ),
                child: SingleChildScrollView(
                  padding: const EdgeInsets.all(24),
                  child: side,
                ),
              ),
            ],
          );
        },
      ),
    );
  }

  Widget _buildForm(List<OrganizationLocation> locations) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildHeader(),
        const SizedBox(height: 20),
        _buildFormBody(locations),
      ],
    );
  }

  Widget _buildHeader() {
    return Row(
      children: [
        const FitBackButton(fallbackLocation: '/admin/programming'),
        const SizedBox(width: 12),
        Expanded(
          child: Text(
            _programId == null ? 'Nueva programación' : 'Editar programación',
            style: GoogleFonts.spaceGrotesk(
              fontSize: 24,
              fontWeight: FontWeight.w700,
              color: AppColors.textPrimary,
            ),
          ),
        ),
        if (_programId != null)
          IconButton(
            tooltip: 'Ver inscritos',
            icon: Icon(Icons.groups_rounded, color: AppColors.primary),
            onPressed: () =>
                context.push('/admin/programming/$_programId/roster'),
          ),
        ProgramStatusBadge(status: _status),
      ],
    );
  }

  Widget _buildFormBody(List<OrganizationLocation> locations) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        TextField(
          controller: _titleCtrl,
          style: GoogleFonts.spaceGrotesk(
            fontSize: 18,
            fontWeight: FontWeight.w600,
          ),
          decoration: const InputDecoration(
            labelText: 'Título',
            hintText: 'Ej: Strength & Skill, Murph, Fran',
          ),
        ),
        const SizedBox(height: 16),
        Row(
          children: [
            Expanded(
              child: _DateField(
                date: _programDate,
                onTap: () async {
                  final picked = await showDatePicker(
                    context: context,
                    initialDate: _programDate,
                    firstDate: DateTime.now().subtract(
                      const Duration(days: 365),
                    ),
                    lastDate: DateTime.now().add(const Duration(days: 365)),
                  );
                  if (picked != null) setState(() => _programDate = picked);
                },
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: InputDecorator(
                decoration: const InputDecoration(labelText: 'Ubicación'),
                child: DropdownButtonHideUnderline(
                  child: DropdownButton<String>(
                    value: _locationId,
                    isExpanded: true,
                    isDense: true,
                    hint: const Text('Selecciona'),
                    items: [
                      for (final l in locations)
                        DropdownMenuItem(value: l.id, child: Text(l.name)),
                    ],
                    onChanged: (v) => setState(() => _locationId = v),
                  ),
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 16),
        TextField(
          controller: _descCtrl,
          maxLines: 2,
          decoration: const InputDecoration(
            labelText: 'Descripción',
            hintText: 'Resumen de la sesión',
          ),
        ),
        const SizedBox(height: 16),
        TextField(
          controller: _objectiveCtrl,
          decoration: const InputDecoration(
            labelText: 'Objetivo',
            hintText: 'Ej: Fuerza máxima en sentadilla',
          ),
        ),
        const SizedBox(height: 16),
        _FocusTagsField(
          tags: _focusTags,
          controller: _focusTagCtrl,
          onAdd: (t) => setState(() => _focusTags.add(t)),
          onRemove: (t) => setState(() => _focusTags.remove(t)),
        ),
        const SizedBox(height: 16),
        TextField(
          controller: _coachNotesCtrl,
          maxLines: 2,
          decoration: const InputDecoration(
            labelText: 'Notas del coach (generales)',
          ),
        ),
        const SizedBox(height: 24),
        Text(
          'Bloques',
          style: GoogleFonts.spaceGrotesk(
            fontSize: 18,
            fontWeight: FontWeight.w600,
            color: AppColors.textPrimary,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          'Ningún tipo de bloque es obligatorio. Arma la sesión libremente.',
          style: TextStyle(fontSize: 12, color: AppColors.textSecondary),
        ),
        const SizedBox(height: 14),
        ...List.generate(_blocks.length, (i) {
          final b = _blocks[i];
          return BlockEditor(
            key: ObjectKey(b),
            data: b,
            index: i,
            metered: ref.watch(exerciseMeteredMapProvider).valueOrNull ??
                const {},
            onPickExercise: () => showExercisePicker(context),
            onChanged: () => setState(() {}),
            onRemove: _blocks.length > 1
                ? () => setState(() {
                    b.dispose();
                    _blocks.removeAt(i);
                  })
                : null,
            onMoveUp: i > 0
                ? () => setState(() {
                    final x = _blocks.removeAt(i);
                    _blocks.insert(i - 1, x);
                  })
                : null,
            onMoveDown: i < _blocks.length - 1
                ? () => setState(() {
                    final x = _blocks.removeAt(i);
                    _blocks.insert(i + 1, x);
                  })
                : null,
          );
        }),
        OutlinedButton.icon(
          onPressed: () => setState(() => _blocks.add(BlockDraft())),
          icon: const Icon(Icons.add_rounded, size: 18),
          label: const Text('Agregar bloque'),
        ),
      ],
    );
  }

  Widget _buildSidebar(List<OrganizationLocation> locations) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Publicación',
          style: GoogleFonts.spaceGrotesk(
            fontSize: 18,
            fontWeight: FontWeight.w600,
            color: AppColors.textPrimary,
          ),
        ),
        const SizedBox(height: 12),
        PublicationScheduler(
          onSchedule: (dt) {
            setState(() {
              _scheduledAt = dt;
              _immediateSelected = dt == null;
            });
          },
        ),
        const SizedBox(height: 16),
        Container(
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            color: AppColors.primaryLight.withValues(alpha: 0.5),
            borderRadius: BorderRadius.circular(14),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Vista previa notificación',
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                  color: AppColors.primary,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                _titleCtrl.text.isEmpty
                    ? 'Nueva clase publicada'
                    : '${_titleCtrl.text} — ${DateFormat('EEEE d MMM', 'es').format(_programDate)}',
                style: TextStyle(
                  fontSize: 13,
                  color: AppColors.textPrimary,
                ),
              ),
              if (_scheduledAt != null) ...[
                const SizedBox(height: 4),
                Text(
                  'Se publicará: ${DateFormat('d MMM y, h:mm a', 'es').format(_scheduledAt!)}',
                  style: TextStyle(
                    fontSize: 11,
                    color: AppColors.textSecondary,
                  ),
                ),
              ],
            ],
          ),
        ),
        const SizedBox(height: 20),
        if (_saving)
          const Center(child: CircularProgressIndicator())
        else ...[
          Row(
            children: [
              Expanded(
                child: OutlinedButton(
                  onPressed: () => _persist(publish: false),
                  child: const Text('Guardar borrador'),
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: ElevatedButton(
                  onPressed: () => _persist(publish: true),
                  child: Text(_immediateSelected ? 'Publicar' : 'Programar'),
                ),
              ),
            ],
          ),
          if (_programId != null) ...[
            const SizedBox(height: 10),
            TextButton.icon(
              onPressed: _deleteProgram,
              icon: Icon(
                Icons.delete_outline_rounded,
                size: 18,
                color: AppColors.error,
              ),
              label: Text(
                'Eliminar programación',
                style: TextStyle(color: AppColors.error),
              ),
            ),
          ],
        ],
      ],
    );
  }
}

/// Lets the coach assign this program to the box's configured time slots.
/// Toggling a slot creates / deletes a real class_session immediately.
class _SlotSessionsPanel extends ConsumerStatefulWidget {
  const _SlotSessionsPanel({
    super.key,
    required this.orgId,
    required this.programId,
    required this.programDate,
    required this.fallbackLocationId,
    required this.onChanged,
  });

  final String? orgId;
  final String? programId;
  final DateTime programDate;
  final String? fallbackLocationId;
  final VoidCallback onChanged;

  @override
  ConsumerState<_SlotSessionsPanel> createState() => _SlotSessionsPanelState();
}

class _SlotSessionsPanelState extends ConsumerState<_SlotSessionsPanel> {
  bool _loading = true;
  String? _error;
  List<Map<String, dynamic>> _slots = const [];

  /// start_minutes -> session id for slots currently active on this program.
  final Map<int, String> _sessionByStart = {};
  final Set<String> _busy = {};

  @override
  void initState() {
    super.initState();
    if (widget.orgId == null || widget.programId == null) {
      _loading = false;
    } else {
      WidgetsBinding.instance.addPostFrameCallback((_) => _fetch());
    }
  }

  Future<void> _fetch() async {
    if (widget.orgId == null || widget.programId == null) {
      if (mounted) setState(() => _loading = false);
      return;
    }
    final ds = ref.read(programmingDatasourceProvider);
    try {
      final slots = await ds.listTimeSlots(widget.orgId!);
      final sessions = await ds.sessionsForProgram(widget.programId!);
      _sessionByStart.clear();
      for (final s in sessions) {
        final start = DateTime.parse(s['start_time'] as String).toLocal();
        _sessionByStart[start.hour * 60 + start.minute] = s['id'] as String;
      }
      if (mounted) {
        setState(() {
          _slots = slots
              .where((s) => (s['is_active'] as bool?) ?? true)
              .toList();
          _loading = false;
          _error = null;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _loading = false;
          _error = '$e';
        });
      }
    }
  }

  Future<void> _toggle(Map<String, dynamic> slot) async {
    final slotId = slot['id'] as String;
    final startMinutes = (slot['start_minutes'] as num?)?.toInt() ?? 0;
    final endMinutes = (slot['end_minutes'] as num?)?.toInt() ?? startMinutes;
    final existing = _sessionByStart[startMinutes];
    final ds = ref.read(programmingDatasourceProvider);

    setState(() => _busy.add(slotId));
    try {
      if (existing != null) {
        await ds.deleteSession(existing);
      } else {
        final base = DateTime(
          widget.programDate.year,
          widget.programDate.month,
          widget.programDate.day,
        );
        final start = base.add(Duration(minutes: startMinutes));
        final end = base.add(Duration(minutes: endMinutes));
        await ds.addSession({
          'program_id': widget.programId,
          'location_id': slot['location_id'] ?? widget.fallbackLocationId,
          'start_time': start.toIso8601String(),
          'end_time': end.toIso8601String(),
          'capacity': (slot['capacity'] as num?)?.toInt() ?? 15,
        });
      }
      await _fetch();
      widget.onChanged();
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('No se pudo actualizar la sesión: $e'),
            backgroundColor: AppColors.error,
          ),
        );
      }
    } finally {
      if (mounted) setState(() => _busy.remove(slotId));
    }
  }

  @override
  Widget build(BuildContext context) {
    final header = Text(
      'DESDE HORARIOS CONFIGURADOS',
      style: TextStyle(
        fontSize: 11,
        fontWeight: FontWeight.w700,
        letterSpacing: 0.4,
        color: AppColors.textSecondary,
      ),
    );

    if (widget.programId == null) {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          header,
          const SizedBox(height: 8),
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: AppColors.warningBackground,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Text(
              'Guarda la programación para asignarla a los horarios '
              'configurados del box.',
              style: TextStyle(fontSize: 12, color: AppColors.warningText),
            ),
          ),
        ],
      );
    }

    if (_loading) {
      return const Padding(
        padding: EdgeInsets.symmetric(vertical: 12),
        child: Center(
          child: SizedBox(
            width: 20,
            height: 20,
            child: CircularProgressIndicator(strokeWidth: 2),
          ),
        ),
      );
    }

    if (_error != null) {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          header,
          const SizedBox(height: 8),
          Text(
            'No se pudieron cargar los horarios.\n$_error',
            style: TextStyle(fontSize: 12, color: AppColors.error),
          ),
        ],
      );
    }

    if (_slots.isEmpty) {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          header,
          const SizedBox(height: 8),
          Text(
            'El box no tiene horarios configurados. Agrégalos en '
            'Configuración.',
            style: TextStyle(fontSize: 12, color: AppColors.textSecondary),
          ),
        ],
      );
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        header,
        const SizedBox(height: 8),
        ..._slots.map((slot) {
          final slotId = slot['id'] as String;
          final start = (slot['start_minutes'] as num?)?.toInt() ?? 0;
          final end = (slot['end_minutes'] as num?)?.toInt() ?? start;
          final active = _sessionByStart.containsKey(start);
          final busy = _busy.contains(slotId);
          final label = (slot['label'] as String?) ?? slotLabel(start, end);
          final capacity = (slot['capacity'] as num?)?.toInt() ?? 0;

          return Container(
            margin: const EdgeInsets.only(bottom: 8),
            padding: const EdgeInsets.fromLTRB(12, 6, 6, 6),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: active ? AppColors.primary : AppColors.border,
              ),
              color: active ? AppColors.primaryLight : AppColors.inputBackground,
            ),
            child: Row(
              children: [
                Icon(
                  Icons.schedule_rounded,
                  size: 16,
                  color: active ? AppColors.primary : AppColors.textSecondary,
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        label,
                        style: TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.w600,
                          color: active
                              ? AppColors.primaryDark
                              : AppColors.textPrimary,
                        ),
                      ),
                      Text(
                        'Cupo: $capacity',
                        style: TextStyle(
                          fontSize: 11,
                          color: AppColors.textSecondary,
                        ),
                      ),
                    ],
                  ),
                ),
                if (busy)
                  const SizedBox(
                    width: 36,
                    height: 36,
                    child: Center(
                      child: SizedBox(
                        width: 16,
                        height: 16,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      ),
                    ),
                  )
                else
                  Checkbox(
                    value: active,
                    activeColor: AppColors.primary,
                    onChanged: (_) => _toggle(slot),
                  ),
              ],
            ),
          );
        }),
      ],
    );
  }
}

class _DateField extends StatelessWidget {
  const _DateField({required this.date, required this.onTap});
  final DateTime date;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      child: InputDecorator(
        decoration: const InputDecoration(
          labelText: 'Fecha',
          suffixIcon: Icon(Icons.calendar_today_rounded, size: 16),
        ),
        child: Text(
          DateFormat('EEEE d MMM y', 'es').format(date),
          style: const TextStyle(fontSize: 14),
        ),
      ),
    );
  }
}

class _FocusTagsField extends StatelessWidget {
  const _FocusTagsField({
    required this.tags,
    required this.controller,
    required this.onAdd,
    required this.onRemove,
  });
  final List<String> tags;
  final TextEditingController controller;
  final ValueChanged<String> onAdd;
  final ValueChanged<String> onRemove;

  @override
  Widget build(BuildContext context) {
    void submit() {
      final t = controller.text.trim();
      if (t.isNotEmpty && !tags.contains(t)) {
        onAdd(t);
        controller.clear();
      }
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Expanded(
              child: TextField(
                controller: controller,
                onSubmitted: (_) => submit(),
                decoration: const InputDecoration(
                  labelText: 'Enfoque (tags)',
                  hintText: 'Ej: fuerza, gimnasia, cardio',
                ),
              ),
            ),
            const SizedBox(width: 8),
            IconButton(onPressed: submit, icon: const Icon(Icons.add_rounded)),
          ],
        ),
        if (tags.isNotEmpty) ...[
          const SizedBox(height: 8),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              for (final t in tags)
                Chip(
                  label: Text(t, style: const TextStyle(fontSize: 12)),
                  backgroundColor: AppColors.primaryLight,
                  labelStyle: TextStyle(color: AppColors.primaryDark),
                  onDeleted: () => onRemove(t),
                  deleteIconColor: AppColors.primaryDark,
                ),
            ],
          ),
        ],
      ],
    );
  }
}

class _SessionTile extends StatelessWidget {
  const _SessionTile({
    required this.draft,
    required this.locations,
    required this.onPickTime,
    required this.onCapacity,
    required this.onLocation,
    required this.onRemove,
  });
  final _SessionDraft draft;
  final List<OrganizationLocation> locations;
  final VoidCallback onPickTime;
  final ValueChanged<int> onCapacity;
  final ValueChanged<String?> onLocation;
  final VoidCallback onRemove;

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppColors.border),
        color: AppColors.inputBackground,
      ),
      child: Column(
        children: [
          Row(
            children: [
              Expanded(
                child: InkWell(
                  onTap: onPickTime,
                  child: Row(
                    children: [
                      Icon(
                        Icons.schedule_rounded,
                        size: 16,
                        color: AppColors.primary,
                      ),
                      const SizedBox(width: 6),
                      Text(
                        draft.time.format(context),
                        style: const TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              SizedBox(
                width: 70,
                child: TextField(
                  controller: TextEditingController(text: '${draft.capacity}'),
                  keyboardType: TextInputType.number,
                  textAlign: TextAlign.center,
                  style: const TextStyle(fontSize: 13),
                  decoration: const InputDecoration(
                    labelText: 'Cupo',
                    isDense: true,
                  ),
                  onChanged: (v) =>
                      onCapacity(int.tryParse(v) ?? draft.capacity),
                ),
              ),
              IconButton(
                icon: Icon(
                  Icons.close_rounded,
                  size: 18,
                  color: AppColors.textSecondary,
                ),
                onPressed: onRemove,
              ),
            ],
          ),
          if (locations.length > 1)
            DropdownButtonHideUnderline(
              child: DropdownButton<String>(
                value:
                    draft.locationId ??
                    (locations.isNotEmpty ? locations.first.id : null),
                isExpanded: true,
                isDense: true,
                items: [
                  for (final l in locations)
                    DropdownMenuItem(
                      value: l.id,
                      child: Text(l.name, style: const TextStyle(fontSize: 12)),
                    ),
                ],
                onChanged: onLocation,
              ),
            ),
        ],
      ),
    );
  }
}
