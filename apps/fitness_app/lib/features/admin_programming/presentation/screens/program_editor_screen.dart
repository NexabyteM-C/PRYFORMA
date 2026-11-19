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

  // ── Time-slot selection ("¿a qué franjas aplica esta programación?") ──
  // The box's active slots and the subset this program applies to. All slots
  // are selected by default; unchecking some marks the program "personalizada".
  List<Map<String, dynamic>> _availableSlots = const [];
  final Set<int> _selectedSlotStarts = {}; // chosen slot start_minutes
  bool _slotsLoaded = false;

  int _slotStart(Map<String, dynamic> s) =>
      (s['start_minutes'] as num?)?.toInt() ?? 0;

  /// Loads the box's active slots. For a new program every slot starts checked;
  /// for an existing one the checked set mirrors the sessions it already has.
  Future<void> _loadSlots({Set<int>? preset}) async {
    final org = ref.read(resolvedAdminOrgProvider);
    if (org == null) return;
    try {
      final ds = ref.read(programmingDatasourceProvider);
      final slots = (await ds.listTimeSlots(org.id))
          .where((s) => s['is_active'] != false)
          .toList();
      if (!mounted) return;
      setState(() {
        _availableSlots = slots;
        _selectedSlotStarts.clear();
        if (preset != null) {
          _selectedSlotStarts.addAll(preset);
        } else {
          // Default: applies to every configured slot.
          _selectedSlotStarts.addAll(slots.map(_slotStart));
        }
        _slotsLoaded = true;
      });
    } catch (_) {
      if (mounted) setState(() => _slotsLoaded = true);
    }
  }

  /// Whether the program applies to all active slots (vs a custom subset).
  bool get _appliesToAll =>
      _availableSlots.isNotEmpty &&
      _availableSlots.every((s) => _selectedSlotStarts.contains(_slotStart(s)));

  @override
  void initState() {
    super.initState();
    _programId = widget.programId;
    if (_programId != null) {
      _loading = true;
      WidgetsBinding.instance.addPostFrameCallback((_) => _load());
    } else {
      // New program: load the box slots so all are pre-checked by default.
      WidgetsBinding.instance.addPostFrameCallback((_) => _loadSlots());
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

      // Pre-check the slots this program already occupies (its session times).
      final sessionStarts = <int>{
        for (final e in sessionRows)
          () {
            final st = DateTime.parse(e['start_time'] as String).toLocal();
            return st.hour * 60 + st.minute;
          }(),
      };
      await _loadSlots(preset: sessionStarts);
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
    if (_slotsLoaded &&
        _availableSlots.isNotEmpty &&
        _selectedSlotStarts.isEmpty) {
      _snack('Selecciona al menos una franja horaria para la clase',
          isError: true);
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
        // One class_session per SELECTED box time slot on this date. By default
        // every slot is selected; a "personalizada" program syncs only to the
        // franjas the coach kept checked.
        ds.syncSessionsFromSlots(
          orgId: org!.id,
          programId: _programId!,
          date: _programDate,
          fallbackLocationId: _locationId,
          onlyStartMinutes: (_slotsLoaded && _availableSlots.isNotEmpty)
              ? _selectedSlotStarts.toSet()
              : null,
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
        _buildSlotSelector(),
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

  /// Lets the coach pick which configured box slots this program applies to.
  /// All slots are checked by default ("Todas las franjas"); unchecking any
  /// marks it "Personalizada" so a second program can take a single slot.
  Widget _buildSlotSelector() {
    final custom = _slotsLoaded && _availableSlots.isNotEmpty && !_appliesToAll;
    return Container(
      padding: const EdgeInsets.fromLTRB(16, 14, 16, 14),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: custom ? AppColors.secondaryAccent : AppColors.border,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.schedule_rounded, size: 20, color: AppColors.primary),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  'Horarios de esta programación',
                  style: GoogleFonts.spaceGrotesk(
                    fontSize: 16,
                    fontWeight: FontWeight.w700,
                    color: AppColors.textPrimary,
                  ),
                ),
              ),
              if (_slotsLoaded && _availableSlots.isNotEmpty)
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(
                    color: (custom
                            ? AppColors.secondaryAccent
                            : AppColors.primary)
                        .withValues(alpha: 0.12),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        custom
                            ? Icons.tune_rounded
                            : Icons.done_all_rounded,
                        size: 13,
                        color: custom
                            ? AppColors.secondaryAccent
                            : AppColors.primary,
                      ),
                      const SizedBox(width: 5),
                      Text(
                        custom ? 'Personalizada' : 'Todas las franjas',
                        style: GoogleFonts.inter(
                          fontSize: 11.5,
                          fontWeight: FontWeight.w700,
                          color: custom
                              ? AppColors.secondaryAccent
                              : AppColors.primary,
                        ),
                      ),
                    ],
                  ),
                ),
            ],
          ),
          const SizedBox(height: 4),
          Text(
            'Por defecto aplica a todas las franjas del box. Desmarca las que '
            'no quieras para dejarla en horarios específicos.',
            style: TextStyle(fontSize: 12, color: AppColors.textSecondary),
          ),
          const SizedBox(height: 12),
          if (!_slotsLoaded)
            const Padding(
              padding: EdgeInsets.symmetric(vertical: 10),
              child: Center(
                child: SizedBox(
                  width: 20,
                  height: 20,
                  child: CircularProgressIndicator(strokeWidth: 2),
                ),
              ),
            )
          else if (_availableSlots.isEmpty)
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: AppColors.warningBackground,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Text(
                'El box no tiene franjas horarias configuradas. Agrégalas en '
                'Configuración para asignar esta clase a un horario.',
                style: TextStyle(fontSize: 12, color: AppColors.warningText),
              ),
            )
          else ...[
            Row(
              children: [
                _slotQuickAction('Todas', Icons.done_all_rounded, () {
                  setState(() {
                    _selectedSlotStarts
                      ..clear()
                      ..addAll(_availableSlots.map(_slotStart));
                  });
                }),
                const SizedBox(width: 8),
                _slotQuickAction('Ninguna', Icons.remove_done_rounded, () {
                  setState(_selectedSlotStarts.clear);
                }),
              ],
            ),
            const SizedBox(height: 10),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: [
                for (final slot in _availableSlots)
                  _slotChip(slot),
              ],
            ),
            if (_selectedSlotStarts.isEmpty) ...[
              const SizedBox(height: 10),
              Text(
                'Selecciona al menos una franja para que la clase aparezca a '
                'los atletas.',
                style: TextStyle(fontSize: 11.5, color: AppColors.error),
              ),
            ],
          ],
        ],
      ),
    );
  }

  Widget _slotQuickAction(String label, IconData icon, VoidCallback onTap) {
    return InkWell(
      borderRadius: BorderRadius.circular(8),
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 4),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: 15, color: AppColors.primary),
            const SizedBox(width: 4),
            Text(label,
                style: GoogleFonts.inter(
                    fontSize: 12.5,
                    fontWeight: FontWeight.w600,
                    color: AppColors.primary)),
          ],
        ),
      ),
    );
  }

  Widget _slotChip(Map<String, dynamic> slot) {
    final start = _slotStart(slot);
    final end = (slot['end_minutes'] as num?)?.toInt() ?? start;
    final label = (slot['label'] as String?) ?? slotLabel(start, end);
    final selected = _selectedSlotStarts.contains(start);
    return InkWell(
      borderRadius: BorderRadius.circular(12),
      onTap: () => setState(() {
        if (selected) {
          _selectedSlotStarts.remove(start);
        } else {
          _selectedSlotStarts.add(start);
        }
      }),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 9),
        decoration: BoxDecoration(
          color: selected ? AppColors.primaryLight : AppColors.inputBackground,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: selected ? AppColors.primary : AppColors.border,
            width: selected ? 1.4 : 1,
          ),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              selected
                  ? Icons.check_box_rounded
                  : Icons.check_box_outline_blank_rounded,
              size: 18,
              color: selected ? AppColors.primary : AppColors.textSecondary,
            ),
            const SizedBox(width: 7),
            Text(
              label,
              style: GoogleFonts.inter(
                fontSize: 13,
                fontWeight: FontWeight.w600,
                color:
                    selected ? AppColors.primaryDark : AppColors.textSecondary,
              ),
            ),
          ],
        ),
      ),
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

