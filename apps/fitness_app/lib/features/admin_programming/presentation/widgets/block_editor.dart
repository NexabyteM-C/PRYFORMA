import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../../../app/theme/app_colors.dart';

/// Canonical block types (value stored in DB, label shown in UI).
const kBlockTypes = <(String, String)>[
  ('briefing', 'Briefing'),
  ('warmup', 'Warm-up'),
  ('skill', 'Skill'),
  ('strength', 'Strength'),
  ('wod', 'WOD'),
  ('cooldown', 'Cool-down'),
  ('custom', 'Custom'),
];

/// Selectable WOD formats (spec §4). Each maps to a DB scoring_type.
const kWodTypes = <String>[
  'For Time',
  'AMRAP',
  'EMOM',
  'Tabata',
  'Chipper',
  'Benchmark',
  'Intervals',
];

String scoringTypeForWod(String? wod) {
  switch (wod) {
    case 'For Time':
    case 'Chipper':
    case 'Benchmark':
    case 'Intervals':
      return 'time';
    case 'AMRAP':
    case 'EMOM':
      return 'rounds_reps';
    case 'Tabata':
      return 'reps';
    default:
      return 'none';
  }
}

String blockTypeLabel(String value) {
  for (final t in kBlockTypes) {
    if (t.$1 == value) return t.$2;
  }
  return value;
}

/// Visual identity (color, icon, section label) per block type, used to render
/// the 4 default sections as clearly distinct groups in the editor.
({Color color, IconData icon, String label}) blockTypeStyle(String type) {
  switch (type) {
    case 'warmup':
      return (
        color: const Color(0xFFF59E0B),
        icon: Icons.local_fire_department_rounded,
        label: 'Calentamiento',
      );
    case 'strength':
    case 'skill':
      return (
        color: AppColors.primary,
        icon: Icons.fitness_center_rounded,
        label: 'Fuerza / Técnica',
      );
    case 'wod':
      return (
        color: const Color(0xFFDC2626),
        icon: Icons.bolt_rounded,
        label: 'WOD Principal',
      );
    case 'cooldown':
      return (
        color: AppColors.secondaryAccent,
        icon: Icons.self_improvement_rounded,
        label: 'Estiramiento',
      );
    case 'briefing':
      return (
        color: Colors.grey,
        icon: Icons.info_outline_rounded,
        label: 'Briefing',
      );
    default:
      return (
        color: AppColors.textSecondary,
        icon: Icons.tune_rounded,
        label: 'Personalizado',
      );
  }
}

const _wodMarker = 'Tipo WOD: ';

/// Accent used across the editor + athlete views for "sorpresa" items.
const kSurpriseColor = Color(0xFF7C3AED);

/// A single prescribed exercise inside a block.
/// One line of a percentage ramp: "{percent}% {sets}x{reps}", e.g. 70% 5x5.
class SchemeLine {
  SchemeLine({int? percent, int? sets, String reps = ''})
      : percentCtrl = TextEditingController(text: percent?.toString() ?? ''),
        setsCtrl = TextEditingController(text: sets?.toString() ?? ''),
        repsCtrl = TextEditingController(text: reps);

  final TextEditingController percentCtrl;
  final TextEditingController setsCtrl;
  final TextEditingController repsCtrl;

  int? get percent => int.tryParse(percentCtrl.text.trim());
  int? get sets => int.tryParse(setsCtrl.text.trim());
  String get reps => repsCtrl.text.trim();

  /// JSON for the `set_scheme` column, or null when the percent is missing.
  Map<String, dynamic>? toJson() {
    final p = percent;
    if (p == null) return null;
    return {
      'percent': p,
      'sets': sets,
      'reps': reps.isEmpty ? null : reps,
    };
  }

  void dispose() {
    percentCtrl.dispose();
    setsCtrl.dispose();
    repsCtrl.dispose();
  }
}

class ExerciseDraft {
  ExerciseDraft({
    this.id,
    this.exerciseId,
    this.exerciseName = '',
    int sets = 3,
    String reps = '',
    String weightPrescription = '',
    List<dynamic>? setScheme,
    this.isSurprise = false,
  }) : setsCtrl = TextEditingController(text: sets > 0 ? '$sets' : ''),
       repsCtrl = TextEditingController(text: reps),
       weightCtrl = TextEditingController() {
    // Detect the prescription mode from a persisted value:
    // "20 cal" / "500 m" → metered (machines/mono); "80% 1RM" → percent of 1RM;
    // anything else → free text (kg/notes).
    final metered =
        RegExp(r'^\s*(\d+(?:\.\d+)?)\s*(cal|m)\b', caseSensitive: false)
            .firstMatch(weightPrescription);
    final m = RegExp(r'^\s*(\d+)\s*%').firstMatch(weightPrescription);
    if (metered != null) {
      meteredUnit = metered.group(2)!.toLowerCase();
      isPercent = false;
      weightCtrl.text = metered.group(1)!;
    } else if (m != null) {
      isPercent = true;
      weightCtrl.text = m.group(1)!;
    } else {
      isPercent = false;
      weightCtrl.text = weightPrescription;
    }
    // Load a persisted percentage ramp, if any.
    final hasPersistedScheme = setScheme is List && setScheme.isNotEmpty;
    if (hasPersistedScheme) {
      for (final raw in setScheme) {
        if (raw is Map) {
          scheme.add(SchemeLine(
            percent: (raw['percent'] as num?)?.toInt(),
            sets: (raw['sets'] as num?)?.toInt(),
            reps: (raw['reps'] as String?) ?? '',
          ));
        }
      }
      // Legacy rows persisted the per-series summary (e.g. "80% 3x5 · 90% 2x1")
      // into weight_prescription. The ramp is the source of truth, so don't let
      // that summary leak back into the base "Carga" field as a phantom value.
      if (weightPrescription.contains('·') ||
          weightPrescription.contains('x')) {
        weightCtrl.text = '';
        isPercent = true;
      }
    }
  }

  String? id;
  String? exerciseId;
  String exerciseName;

  /// When true, this movement is hidden from the athlete (shown as "Movimiento
  /// sorpresa") until the class is started from the player.
  bool isSurprise;

  /// Non-null for a "metered" movement (machine/monostructural): 'cal' or 'm'.
  /// When set, the prescription is an amount in that unit, not sets×reps×load.
  String? meteredUnit;

  /// true = percentage of the athlete's 1RM (digits only); false = free text.
  bool isPercent = false;
  final TextEditingController setsCtrl;
  final TextEditingController repsCtrl;
  final TextEditingController weightCtrl;

  /// Optional multi-line percentage ramp (70% 5x5, 80% 3x3, …). When present it
  /// drives the athlete's per-set suggested loads.
  final List<SchemeLine> scheme = [];

  int? get sets => int.tryParse(setsCtrl.text.trim());
  String get reps => repsCtrl.text.trim();

  /// Canonical base-load string: "{n}% 1RM" in percent mode (so the athlete
  /// view computes their personal load), `<n> cal/m` for metered movements, or
  /// the free text as typed. The per-series ramp is persisted separately in
  /// `set_scheme` (see [schemeJson]); it is NOT folded in here, so the base
  /// "Carga" field round-trips cleanly instead of re-importing the ramp summary.
  String get weightPrescription {
    // Metered movements (machines/mono): "<n> cal" or "<n> m".
    if (meteredUnit != null) {
      final d = weightCtrl.text.replaceAll(RegExp(r'[^0-9.]'), '');
      return d.isEmpty ? '' : '$d $meteredUnit';
    }
    final v = weightCtrl.text.trim();
    if (v.isEmpty) return '';
    if (isPercent) {
      final d = v.replaceAll(RegExp(r'[^0-9]'), '');
      return d.isEmpty ? '' : '$d% 1RM';
    }
    return v;
  }

  /// The percentage ramp as JSON rows (skips lines without a percent).
  List<Map<String, dynamic>> get schemeJson => scheme
      .map((l) => l.toJson())
      .whereType<Map<String, dynamic>>()
      .toList();

  void dispose() {
    setsCtrl.dispose();
    repsCtrl.dispose();
    weightCtrl.dispose();
    for (final l in scheme) {
      l.dispose();
    }
  }
}

/// A programming block (warm-up, strength, WOD, …) with its exercises.
class BlockDraft {
  BlockDraft({
    this.id,
    this.blockType = 'warmup',
    String title = '',
    String description = '',
    String coachNotes = '',
    int? durationMinutes,
    this.wodType,
    this.scoringTypeOverride,
    this.isSurprise = false,
    List<ExerciseDraft>? exercises,
  }) : titleCtrl = TextEditingController(text: title),
       descCtrl = TextEditingController(text: description),
       coachNotesCtrl = TextEditingController(text: coachNotes),
       durationCtrl = TextEditingController(
         text: durationMinutes != null ? '$durationMinutes' : '',
       ),
       exercises = exercises ?? [];

  String? id;
  String blockType;
  String? wodType;

  /// When true, the whole block is hidden from the athlete (shown as a sealed
  /// "sorpresa" card) until the class is started from the player.
  bool isSurprise;

  /// Explicit scoring_type when no WOD format is chosen (e.g. default WOD block).
  String? scoringTypeOverride;
  final TextEditingController titleCtrl;
  final TextEditingController descCtrl;
  final TextEditingController coachNotesCtrl;
  final TextEditingController durationCtrl;
  final List<ExerciseDraft> exercises;

  int? get durationMinutes => int.tryParse(durationCtrl.text.trim());

  String get scoringType {
    if (wodType != null && wodType!.isNotEmpty) {
      return scoringTypeForWod(wodType);
    }
    return scoringTypeOverride ?? scoringTypeForWod(wodType);
  }

  /// Serialises the WOD type as a tagged first line of coach_notes so the
  /// selection survives a round-trip without a dedicated column.
  String? composedCoachNotes() {
    final notes = coachNotesCtrl.text.trim();
    if (wodType != null && wodType!.isNotEmpty) {
      return notes.isEmpty
          ? '$_wodMarker$wodType'
          : '$_wodMarker$wodType\n$notes';
    }
    return notes.isEmpty ? null : notes;
  }

  /// Builds a draft from a persisted row map (keys in snake_case).
  factory BlockDraft.fromJson(Map<String, dynamic> json) {
    var notes = (json['coach_notes'] as String?) ?? '';
    String? wod;
    if (notes.startsWith(_wodMarker)) {
      final nl = notes.indexOf('\n');
      if (nl == -1) {
        wod = notes.substring(_wodMarker.length).trim();
        notes = '';
      } else {
        wod = notes.substring(_wodMarker.length, nl).trim();
        notes = notes.substring(nl + 1);
      }
    }
    final exRows = (json['exercises'] as List<dynamic>?) ?? const [];
    final exercises = exRows.map((e) => e as Map<String, dynamic>).map((e) {
      final ex = e['exercise'] as Map<String, dynamic>?;
      final name = ex?['name_es'] ?? ex?['name'] ?? '';
      return ExerciseDraft(
        id: e['id'] as String?,
        exerciseId: e['exercise_id'] as String?,
        exerciseName: name as String,
        sets: (e['sets'] as num?)?.toInt() ?? 0,
        reps: (e['reps'] as String?) ?? '',
        weightPrescription: (e['weight_prescription'] as String?) ?? '',
        setScheme: e['set_scheme'] as List<dynamic>?,
        isSurprise: (e['is_surprise'] as bool?) ?? false,
      );
    }).toList();
    return BlockDraft(
      id: json['id'] as String?,
      blockType: (json['block_type'] as String?) ?? 'custom',
      title: (json['title'] as String?) ?? '',
      description: (json['description'] as String?) ?? '',
      coachNotes: notes,
      durationMinutes: (json['duration_minutes'] as num?)?.toInt(),
      wodType: wod,
      isSurprise: (json['is_surprise'] as bool?) ?? false,
      exercises: exercises,
    );
  }

  void dispose() {
    titleCtrl.dispose();
    descCtrl.dispose();
    coachNotesCtrl.dispose();
    durationCtrl.dispose();
    for (final e in exercises) {
      e.dispose();
    }
  }
}

class BlockEditor extends StatefulWidget {
  const BlockEditor({
    super.key,
    required this.data,
    required this.index,
    required this.onPickExercise,
    this.onRemove,
    this.onChanged,
    this.onMoveUp,
    this.onMoveDown,
    this.metered = const {},
  });

  final BlockDraft data;
  final int index;

  /// exerciseId → (units, primaryUnit) for machine/mono movements prescribed in
  /// calories or meters. An exercise present here shows a cal/m "Objetivo" field
  /// instead of sets×reps×load.
  final Map<String, ({List<String> units, String primaryUnit})> metered;

  /// Opens the catalog picker; returns (exerciseId, name) or null.
  final Future<(String, String)?> Function() onPickExercise;
  final VoidCallback? onRemove;
  final VoidCallback? onChanged;
  final VoidCallback? onMoveUp;
  final VoidCallback? onMoveDown;

  @override
  State<BlockEditor> createState() => _BlockEditorState();
}

class _BlockEditorState extends State<BlockEditor> {
  @override
  Widget build(BuildContext context) {
    final d = widget.data;
    final isWod = d.blockType == 'wod';
    final style = blockTypeStyle(d.blockType);

    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      clipBehavior: Clip.antiAlias,
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(18),
        // Uniform border only — a non-uniform Border (different left width)
        // combined with borderRadius throws a paint error on web and leaves
        // the card content invisible. The colored accent is an inner strip.
        border: Border.all(color: AppColors.border),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF0A1A3F).withValues(alpha: 0.06),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: IntrinsicHeight(
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Container(width: 5, color: style.color),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
          // Colored, labeled section header so the blocks read as distinct.
          Container(
            decoration: BoxDecoration(
              color: style.color.withValues(alpha: 0.16),
              borderRadius: const BorderRadius.only(
                topRight: Radius.circular(14),
              ),
            ),
            padding: const EdgeInsets.fromLTRB(14, 10, 6, 10),
            child: Row(
              children: [
                Container(
                  width: 32,
                  height: 32,
                  decoration: BoxDecoration(
                    color: style.color,
                    borderRadius: BorderRadius.circular(9),
                  ),
                  child: Icon(style.icon, size: 18, color: Colors.white),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: Row(
                    children: [
                      Flexible(
                        child: Text(
                          '${widget.index + 1}. ${style.label}',
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: GoogleFonts.spaceGrotesk(
                            fontSize: 15,
                            fontWeight: FontWeight.w700,
                            color: style.color,
                          ),
                        ),
                      ),
                      if (d.isSurprise) ...[
                        const SizedBox(width: 8),
                        _surpriseBadge(),
                      ],
                    ],
                  ),
                ),
                // Toggle: hide this whole block from the athlete until start.
                IconButton(
                  icon: Icon(
                    d.isSurprise
                        ? Icons.visibility_off_rounded
                        : Icons.auto_awesome_outlined,
                    size: 18,
                    color: d.isSurprise
                        ? kSurpriseColor
                        : AppColors.textSecondary,
                  ),
                  tooltip: d.isSurprise
                      ? 'Bloque sorpresa: se revela al iniciar la clase'
                      : 'Marcar bloque como sorpresa',
                  onPressed: () {
                    setState(() => d.isSurprise = !d.isSurprise);
                    widget.onChanged?.call();
                  },
                ),
                IconButton(
                  icon: const Icon(Icons.arrow_upward_rounded, size: 18),
                  color: AppColors.textSecondary,
                  tooltip: 'Subir',
                  onPressed: widget.onMoveUp,
                ),
                IconButton(
                  icon: const Icon(Icons.arrow_downward_rounded, size: 18),
                  color: AppColors.textSecondary,
                  tooltip: 'Bajar',
                  onPressed: widget.onMoveDown,
                ),
                if (widget.onRemove != null)
                  IconButton(
                    icon: Icon(
                      Icons.delete_outline_rounded,
                      size: 18,
                      color: AppColors.error,
                    ),
                    tooltip: 'Eliminar bloque',
                    onPressed: widget.onRemove,
                  ),
              ],
            ),
          ),
          // Row 1: block type + title side by side (compact).
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 10, 16, 0),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _fieldLabel('Tipo'),
                    SizedBox(
                      width: 140,
                      child: _BlockTypeDropdown(
                        value: d.blockType,
                        onChanged: (v) {
                          setState(() => d.blockType = v);
                          widget.onChanged?.call();
                        },
                      ),
                    ),
                  ],
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _fieldLabel('Título del bloque'),
                      TextField(
                        controller: d.titleCtrl,
                        onChanged: (_) => widget.onChanged?.call(),
                        style: GoogleFonts.spaceGrotesk(
                          fontSize: 15,
                          fontWeight: FontWeight.w600,
                        ),
                        decoration: const InputDecoration(isDense: true),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          // Row 2: minutes + description side by side (compact).
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 10, 16, 0),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                SizedBox(
                  width: 90,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _fieldLabel('Minutos'),
                      TextField(
                        controller: d.durationCtrl,
                        keyboardType: TextInputType.number,
                        style: const TextStyle(fontSize: 13),
                        decoration: const InputDecoration(isDense: true),
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _fieldLabel('Descripción (la ve el atleta)'),
                      TextField(
                        controller: d.descCtrl,
                        onChanged: (_) => widget.onChanged?.call(),
                        minLines: 1,
                        maxLines: 2,
                        style: const TextStyle(fontSize: 13),
                        decoration: const InputDecoration(isDense: true),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          // Row 3 (WOD blocks only): the scoring format.
          if (isWod)
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 10, 16, 0),
              child: _WodTypeDropdown(
                value: d.wodType,
                onChanged: (v) {
                  setState(() => d.wodType = v);
                  widget.onChanged?.call();
                },
              ),
            ),
          const SizedBox(height: 8),
          const Divider(height: 1),
          // Column headers only make sense in the single-row (wide) layout; on
          // phones each field carries its own label on the second line.
          if (MediaQuery.sizeOf(context).width >= 600)
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 8, 16, 2),
            child: Row(
              children: [
                Expanded(
                  flex: 4,
                  child: Text(
                    'Ejercicio',
                    style: TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.w600,
                      color: AppColors.textSecondary,
                    ),
                  ),
                ),
                SizedBox(
                  width: 48,
                  child: Text(
                    'Sets',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.w600,
                      color: AppColors.textSecondary,
                    ),
                  ),
                ),
                SizedBox(
                  width: 70,
                  child: Text(
                    'Reps',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.w600,
                      color: AppColors.textSecondary,
                    ),
                  ),
                ),
                SizedBox(
                  width: 96,
                  child: Text(
                    'Carga',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.w600,
                      color: AppColors.textSecondary,
                    ),
                  ),
                ),
                SizedBox(width: 28),
              ],
            ),
          ),
          ...List.generate(d.exercises.length, (i) {
            final ex = d.exercises[i];
            // Machine/mono movements are prescribed in cal/m, not sets×reps×load.
            final metInfo = widget.metered[ex.exerciseId];
            if (metInfo != null && ex.meteredUnit == null) {
              ex.meteredUnit = metInfo.primaryUnit;
            }
            return Padding(
              padding: const EdgeInsets.fromLTRB(16, 2, 8, 2),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildExerciseRow(d, ex, i, metInfo),
                  if (metInfo == null) _buildScheme(ex),
                ],
              ),
            );
          }),
          Padding(
            padding: const EdgeInsets.fromLTRB(12, 2, 16, 2),
            child: TextButton.icon(
              onPressed: () {
                setState(() => d.exercises.add(ExerciseDraft()));
                widget.onChanged?.call();
              },
              icon: const Icon(Icons.add_rounded, size: 16),
              label: const Text(
                'Agregar ejercicio',
                style: TextStyle(fontSize: 13),
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 0, 16, 14),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _fieldLabel('Notas del coach'),
                TextField(
                  controller: d.coachNotesCtrl,
                  maxLines: 2,
                  style: const TextStyle(fontSize: 13),
                  decoration: const InputDecoration(
                    isDense: true,
                    contentPadding: EdgeInsets.all(10),
                  ),
                ),
              ],
            ),
          ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  // Column widths for the per-series ramp editor, reused by the header and each
  // row so everything lines up vertically ("uno debajo del otro").
  static const double _schemeIdxW = 30;
  static const double _schemeSetsW = 50;
  static const double _schemeRepsW = 58;
  static const double _schemePctW = 66;

  /// One exercise row. On phones the movement name takes the full first line
  /// (so long names are readable, not truncated to "Fon…") and the Sets · Reps ·
  /// Carga controls drop to a second line; on wider screens it's one row.
  Widget _buildExerciseRow(
    BlockDraft d,
    ExerciseDraft ex,
    int i,
    ({List<String> units, String primaryUnit})? metInfo,
  ) {
    final narrow = MediaQuery.sizeOf(context).width < 600;

    final surprise = GestureDetector(
      onTap: () {
        setState(() => ex.isSurprise = !ex.isSurprise);
        widget.onChanged?.call();
      },
      child: Tooltip(
        message: ex.isSurprise
            ? 'Movimiento sorpresa: se revela al iniciar'
            : 'Marcar movimiento como sorpresa',
        child: Container(
          width: 26,
          height: 36,
          alignment: Alignment.center,
          child: Icon(
            ex.isSurprise
                ? Icons.visibility_off_rounded
                : Icons.auto_awesome_outlined,
            size: 16,
            color: ex.isSurprise ? kSurpriseColor : AppColors.textSecondary,
          ),
        ),
      ),
    );

    final nameField = InkWell(
      borderRadius: BorderRadius.circular(8),
      onTap: () async {
        final pick = await widget.onPickExercise();
        if (pick != null) {
          setState(() {
            ex.exerciseId = pick.$1;
            ex.exerciseName = pick.$2;
            final info = widget.metered[pick.$1];
            if (info != null) {
              ex.meteredUnit = info.primaryUnit;
              ex.setsCtrl.clear();
              ex.repsCtrl.clear();
              ex.weightCtrl.clear();
              for (final l in ex.scheme) {
                l.dispose();
              }
              ex.scheme.clear();
            } else {
              ex.meteredUnit = null;
            }
          });
          widget.onChanged?.call();
        }
      },
      child: Container(
        height: 36,
        padding: const EdgeInsets.symmetric(horizontal: 10),
        alignment: Alignment.centerLeft,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: AppColors.border),
          color: AppColors.inputBackground,
        ),
        child: Row(
          children: [
            Expanded(
              child: Text(
                ex.exerciseName.isEmpty
                    ? 'Elegir del catálogo…'
                    : ex.exerciseName,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                  fontSize: 13,
                  color: ex.exerciseName.isEmpty
                      ? AppColors.textSecondary
                      : AppColors.textPrimary,
                ),
              ),
            ),
            Icon(Icons.search_rounded,
                size: 15, color: AppColors.textSecondary),
          ],
        ),
      ),
    );

    final delete = SizedBox(
      width: 28,
      child: IconButton(
        icon: Icon(Icons.remove_circle_outline_rounded,
            size: 16, color: AppColors.error),
        padding: EdgeInsets.zero,
        onPressed: () {
          setState(() {
            ex.dispose();
            d.exercises.removeAt(i);
          });
          widget.onChanged?.call();
        },
      ),
    );

    Widget labeled(String label, Widget field) {
      if (!narrow) return field;
      return Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label,
              style: TextStyle(
                  fontSize: 9.5,
                  fontWeight: FontWeight.w700,
                  color: AppColors.textSecondary)),
          const SizedBox(height: 2),
          field,
        ],
      );
    }

    final setsField = SizedBox(
      width: 48,
      height: 36,
      child: TextField(
        controller: ex.setsCtrl,
        keyboardType: TextInputType.number,
        textAlign: TextAlign.center,
        style: const TextStyle(fontSize: 13),
        decoration: const InputDecoration(
          isDense: true,
          contentPadding: EdgeInsets.symmetric(horizontal: 4, vertical: 8),
        ),
      ),
    );
    final repsField = SizedBox(
      width: narrow ? 72 : 66,
      height: 36,
      child: TextField(
        controller: ex.repsCtrl,
        textAlign: TextAlign.center,
        style: const TextStyle(fontSize: 13),
        decoration: const InputDecoration(
          isDense: true,
          contentPadding: EdgeInsets.symmetric(horizontal: 4, vertical: 8),
        ),
      ),
    );
    final cargaField = SizedBox(
      width: 120,
      height: 36,
      child: Row(
        children: [
          GestureDetector(
            onTap: () {
              setState(() {
                ex.isPercent = !ex.isPercent;
                ex.weightCtrl.clear();
              });
              widget.onChanged?.call();
            },
            child: Container(
              width: 32,
              height: 36,
              alignment: Alignment.center,
              decoration: BoxDecoration(
                color: ex.isPercent
                    ? AppColors.primary
                    : AppColors.inputBackground,
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: AppColors.border),
              ),
              child: Text(
                ex.isPercent ? '%' : 'kg',
                style: TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.w700,
                  color: ex.isPercent ? Colors.white : AppColors.textSecondary,
                ),
              ),
            ),
          ),
          const SizedBox(width: 4),
          Expanded(
            child: TextField(
              controller: ex.weightCtrl,
              keyboardType: ex.isPercent
                  ? TextInputType.number
                  : TextInputType.text,
              inputFormatters: ex.isPercent
                  ? [FilteringTextInputFormatter.digitsOnly]
                  : null,
              textAlign: TextAlign.center,
              style: const TextStyle(fontSize: 13),
              onChanged: (_) => widget.onChanged?.call(),
              decoration: InputDecoration(
                suffixText: ex.isPercent ? '%' : null,
                suffixStyle: const TextStyle(fontSize: 11),
                isDense: true,
                contentPadding:
                    const EdgeInsets.symmetric(horizontal: 4, vertical: 8),
              ),
            ),
          ),
        ],
      ),
    );

    final List<Widget> metrics = metInfo == null
        ? [
            labeled('Sets', setsField),
            const SizedBox(width: 8),
            labeled('Reps', repsField),
            const SizedBox(width: 8),
            labeled('Carga', cargaField),
          ]
        : [
            labeled(
              'Objetivo',
              SizedBox(
                width: 92,
                height: 36,
                child: TextField(
                  controller: ex.weightCtrl,
                  keyboardType: TextInputType.number,
                  textAlign: TextAlign.center,
                  style: const TextStyle(fontSize: 13),
                  onChanged: (_) => widget.onChanged?.call(),
                  decoration: InputDecoration(
                    hintText: 'Objetivo',
                    hintStyle: const TextStyle(fontSize: 11),
                    suffixText: ex.meteredUnit,
                    suffixStyle: const TextStyle(fontSize: 11),
                    isDense: true,
                    contentPadding:
                        const EdgeInsets.symmetric(horizontal: 6, vertical: 8),
                  ),
                ),
              ),
            ),
            const SizedBox(width: 8),
            labeled(
              'Unidad',
              _MeteredUnitToggle(
                units: metInfo.units,
                unit: ex.meteredUnit ?? metInfo.primaryUnit,
                onChanged: (u) {
                  setState(() => ex.meteredUnit = u);
                  widget.onChanged?.call();
                },
              ),
            ),
          ];

    if (narrow) {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              surprise,
              const SizedBox(width: 2),
              Expanded(child: nameField),
              delete,
            ],
          ),
          const SizedBox(height: 8),
          Padding(
            padding: const EdgeInsets.only(left: 28, bottom: 2),
            child: Row(
                crossAxisAlignment: CrossAxisAlignment.end, children: metrics),
          ),
        ],
      );
    }

    return Row(
      children: [
        surprise,
        const SizedBox(width: 2),
        Expanded(flex: 4, child: nameField),
        const SizedBox(width: 4),
        ...metrics,
        const SizedBox(width: 4),
        delete,
      ],
    );
  }

  /// Per-exercise series ramp editor. Each line is ONE prescription step with
  /// its own Sets · Reps · % of 1RM, laid out in labeled, vertically-aligned
  /// columns (same order as the main exercise row) so there's no ambiguity
  /// about which number is which.
  Widget _buildScheme(ExerciseDraft ex) {
    final hasRows = ex.scheme.isNotEmpty;
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 2, 8, 4),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (hasRows)
            Container(
              padding: const EdgeInsets.fromLTRB(10, 8, 6, 8),
              decoration: BoxDecoration(
                color: AppColors.inputBackground,
                borderRadius: BorderRadius.circular(10),
                border: Border.all(color: AppColors.border),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Padding(
                    padding: const EdgeInsets.only(bottom: 6),
                    child: Text(
                      'Esquema por series · cada línea es una serie',
                      style: TextStyle(
                        fontSize: 10.5,
                        fontWeight: FontWeight.w700,
                        color: AppColors.textSecondary,
                        letterSpacing: 0.2,
                      ),
                    ),
                  ),
                  // Column headers, aligned with the inputs below.
                  Padding(
                    padding: const EdgeInsets.only(bottom: 4),
                    child: Row(
                      children: [
                        const SizedBox(width: _schemeIdxW),
                        _schemeColLabel('Sets', _schemeSetsW),
                        const SizedBox(width: 18),
                        _schemeColLabel('Reps', _schemeRepsW),
                        const SizedBox(width: 10),
                        _schemeColLabel('% 1RM', _schemePctW),
                        const SizedBox(width: 26),
                      ],
                    ),
                  ),
                  ...List.generate(ex.scheme.length, (j) {
                    final line = ex.scheme[j];
                    return Padding(
                      padding: const EdgeInsets.only(bottom: 5),
                      child: Row(
                        children: [
                          // Series index chip (S1, S2…).
                          SizedBox(
                            width: _schemeIdxW,
                            child: Text(
                              'S${j + 1}',
                              style: TextStyle(
                                fontSize: 11.5,
                                fontWeight: FontWeight.w700,
                                color: AppColors.primary,
                              ),
                            ),
                          ),
                          _miniField(line.setsCtrl, _schemeSetsW, digits: true),
                          Padding(
                            padding: EdgeInsets.symmetric(horizontal: 5),
                            child: Text('×',
                                style: TextStyle(
                                    fontSize: 13,
                                    color: AppColors.textSecondary)),
                          ),
                          _miniField(line.repsCtrl, _schemeRepsW),
                          const SizedBox(width: 10),
                          _miniField(line.percentCtrl, _schemePctW,
                              suffix: '%', digits: true),
                          SizedBox(
                            width: 26,
                            child: IconButton(
                              icon: Icon(
                                  Icons.remove_circle_outline_rounded,
                                  size: 15,
                                  color: AppColors.error),
                              padding: EdgeInsets.zero,
                              onPressed: () {
                                setState(() {
                                  line.dispose();
                                  ex.scheme.removeAt(j);
                                });
                                widget.onChanged?.call();
                              },
                            ),
                          ),
                        ],
                      ),
                    );
                  }),
                  Align(
                    alignment: Alignment.centerLeft,
                    child: TextButton.icon(
                      style: TextButton.styleFrom(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 4, vertical: 0),
                        minimumSize: const Size(0, 28),
                        tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                      ),
                      onPressed: () {
                        setState(() => ex.scheme.add(SchemeLine()));
                        widget.onChanged?.call();
                      },
                      icon: const Icon(Icons.add_rounded, size: 14),
                      label: const Text('Agregar serie',
                          style: TextStyle(fontSize: 12)),
                    ),
                  ),
                ],
              ),
            )
          else
            Align(
              alignment: Alignment.centerLeft,
              child: TextButton.icon(
                style: TextButton.styleFrom(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 6, vertical: 0),
                  minimumSize: const Size(0, 28),
                  tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                ),
                onPressed: () {
                  setState(() => ex.scheme.add(SchemeLine()));
                  widget.onChanged?.call();
                },
                icon: const Icon(Icons.add_rounded, size: 14),
                label: const Text('Esquema por series (3×7 75%, 3×5 80%…)',
                    style: TextStyle(fontSize: 12)),
              ),
            ),
        ],
      ),
    );
  }

  /// A column header for the series ramp table, sized to match its input.
  Widget _schemeColLabel(String text, double width) {
    return SizedBox(
      width: width,
      child: Text(
        text,
        textAlign: TextAlign.center,
        style: TextStyle(
          fontSize: 10,
          fontWeight: FontWeight.w700,
          color: AppColors.textSecondary,
        ),
      ),
    );
  }

  Widget _miniField(
    TextEditingController ctrl,
    double width, {
    String? suffix,
    bool digits = false,
  }) {
    return SizedBox(
      width: width,
      height: 32,
      child: TextField(
        controller: ctrl,
        keyboardType: digits ? TextInputType.number : TextInputType.text,
        inputFormatters:
            digits ? [FilteringTextInputFormatter.digitsOnly] : null,
        textAlign: TextAlign.center,
        style: const TextStyle(fontSize: 12.5),
        onChanged: (_) => widget.onChanged?.call(),
        decoration: InputDecoration(
          suffixText: suffix,
          suffixStyle: const TextStyle(fontSize: 10),
          isDense: true,
          contentPadding:
              const EdgeInsets.symmetric(horizontal: 4, vertical: 6),
        ),
      ),
    );
  }

  /// Small purple "SORPRESA" pill shown on a block marked as surprise.
  Widget _surpriseBadge() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 2),
      decoration: BoxDecoration(
        color: kSurpriseColor.withValues(alpha: 0.14),
        borderRadius: BorderRadius.circular(6),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(Icons.auto_awesome_rounded, size: 11, color: kSurpriseColor),
          const SizedBox(width: 3),
          Text(
            'SORPRESA',
            style: GoogleFonts.inter(
              fontSize: 9.5,
              fontWeight: FontWeight.w800,
              letterSpacing: 0.4,
              color: kSurpriseColor,
            ),
          ),
        ],
      ),
    );
  }

  /// A small persistent field title shown above an input (no placeholders).
  Widget _fieldLabel(String text) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 4, left: 2),
      child: Text(
        text,
        style: TextStyle(
          fontSize: 11,
          fontWeight: FontWeight.w600,
          color: AppColors.textSecondary,
        ),
      ),
    );
  }
}

class _BlockTypeDropdown extends StatelessWidget {
  const _BlockTypeDropdown({required this.value, required this.onChanged});
  final String value;
  final ValueChanged<String> onChanged;

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 34,
      padding: const EdgeInsets.symmetric(horizontal: 10),
      decoration: BoxDecoration(
        color: AppColors.primaryLight,
        borderRadius: BorderRadius.circular(8),
      ),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<String>(
          value: value,
          isDense: true,
          icon: Icon(
            Icons.expand_more_rounded,
            size: 16,
            color: AppColors.primary,
          ),
          style: TextStyle(
            fontSize: 13,
            fontWeight: FontWeight.w600,
            color: AppColors.primary,
          ),
          items: [
            for (final t in kBlockTypes)
              DropdownMenuItem(value: t.$1, child: Text(t.$2)),
          ],
          onChanged: (v) => v == null ? null : onChanged(v),
        ),
      ),
    );
  }
}

/// Compact cal/m unit selector for a metered movement. When the movement
/// supports both units it toggles on tap; otherwise it's a static label.
class _MeteredUnitToggle extends StatelessWidget {
  const _MeteredUnitToggle({
    required this.units,
    required this.unit,
    required this.onChanged,
  });

  final List<String> units;
  final String unit;
  final ValueChanged<String> onChanged;

  @override
  Widget build(BuildContext context) {
    final canToggle = units.length > 1;
    return GestureDetector(
      onTap: canToggle
          ? () {
              final idx = units.indexOf(unit);
              onChanged(units[(idx + 1) % units.length]);
            }
          : null,
      child: Container(
        width: 54,
        height: 36,
        alignment: Alignment.center,
        decoration: BoxDecoration(
          color: AppColors.primaryLight,
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: AppColors.border),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              unit,
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w700,
                color: AppColors.primary,
              ),
            ),
            if (canToggle) ...[
              const SizedBox(width: 2),
              Icon(Icons.swap_horiz_rounded,
                  size: 13, color: AppColors.primary),
            ],
          ],
        ),
      ),
    );
  }
}

class _WodTypeDropdown extends StatelessWidget {
  const _WodTypeDropdown({required this.value, required this.onChanged});
  final String? value;
  final ValueChanged<String?> onChanged;

  @override
  Widget build(BuildContext context) {
    return InputDecorator(
      decoration: const InputDecoration(
        labelText: 'Formato WOD',
        isDense: true,
      ),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<String?>(
          value: value,
          isDense: true,
          isExpanded: true,
          hint: const Text('Seleccionar', style: TextStyle(fontSize: 13)),
          items: [
            const DropdownMenuItem(value: null, child: Text('Sin formato')),
            for (final w in kWodTypes)
              DropdownMenuItem(value: w, child: Text(w)),
          ],
          onChanged: onChanged,
        ),
      ),
    );
  }
}
