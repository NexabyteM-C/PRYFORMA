import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../../../app/theme/app_colors.dart';

/// Shared presentation helpers for the classes feature (and the home screen,
/// which reuses the same calendar rows). Pure functions, no state.

List<Color> get _boxPalette => [

  AppColors.primary,
  AppColors.secondaryAccent,
  Color(0xFF7C3AED),
  Color(0xFFD97706),
  Color(0xFF059669),
  Color(0xFFDB2777),
];

/// Deterministic, order-independent color for a given organization id, so the
/// same box always gets the same dot across the whole unified calendar.
Color boxColorForId(String? orgId) {
  if (orgId == null || orgId.isEmpty) return AppColors.primary;
  final idx = orgId.codeUnits.fold<int>(0, (a, c) => a + c) % _boxPalette.length;
  return _boxPalette[idx];
}

String _capitalize(String s) =>
    s.isEmpty ? s : s.replaceRange(0, 1, s[0].toUpperCase());

String capitalize(String s) => _capitalize(s);

/// "6:00 p. m." style time from an ISO timestamp (local box time).
String formatSessionTime(String? iso) {
  final dt = DateTime.tryParse(iso ?? '')?.toLocal();
  if (dt == null) return '';
  try {
    return DateFormat('h:mm a', 'es').format(dt);
  } catch (_) {
    return DateFormat('h:mm a').format(dt);
  }
}

/// Difference in whole minutes between two ISO timestamps, or null.
int? durationMinutesBetween(String? startIso, String? endIso) {
  final s = DateTime.tryParse(startIso ?? '');
  final e = DateTime.tryParse(endIso ?? '');
  if (s == null || e == null) return null;
  final m = e.difference(s).inMinutes;
  return m > 0 ? m : null;
}

const blockTypeLabels = {
  'briefing': 'Briefing',
  'warmup': 'Calentamiento',
  'strength': 'Fuerza',
  'skill': 'Técnica',
  'wod': 'WOD',
  'cooldown': 'Enfriamiento',
  'custom': 'Bloque',
};

String blockTypeLabel(String? type) =>
    blockTypeLabels[type] ?? _capitalize(type ?? 'Bloque');

/// Visual identity (name, color, icon) for the default class structure:
/// Calentamiento → Fuerza / Técnica → WOD Principal → Estiramiento.
/// Used by the class detail and record screens so the sections read as a set.
class BlockSection {
  const BlockSection(this.label, this.color, this.icon);
  final String label;
  final Color color;
  final IconData icon;
}

/// Section style for a block. Falls back to the block's own title for custom
/// blocks. [block] uses the defensive `block_type ?? type` / `title ?? name`.
BlockSection blockSectionFor(Map<String, dynamic> block) {
  final type = (block['block_type'] ?? block['type']) as String?;
  final title = (block['title'] ?? block['name']) as String?;
  switch (type) {
    case 'warmup':
      return BlockSection(
          'Calentamiento', Color(0xFFF59E0B), Icons.local_fire_department_rounded);
    case 'strength':
    case 'skill':
      return BlockSection(
          'Fuerza / Técnica', AppColors.primary, Icons.fitness_center_rounded);
    case 'wod':
      return BlockSection('WOD Principal', AppColors.error, Icons.bolt_rounded);
    case 'cooldown':
      return BlockSection(
          'Estiramiento', AppColors.secondaryAccent, Icons.self_improvement_rounded);
    case 'briefing':
      return BlockSection(
          'Briefing', Color(0xFF6B7280), Icons.info_outline_rounded);
    default:
      return BlockSection(
        (title != null && title.isNotEmpty) ? title : blockTypeLabel(type),
        AppColors.textSecondary,
        Icons.tune_rounded,
      );
  }
}

/// Blocks that an athlete records a result for.
bool isScorableBlock(String? blockType, String? scoring) {
  if (scoring != null && scoring != 'none' && scoring.isNotEmpty) return true;
  return blockType == 'wod' || blockType == 'strength';
}

/// Normalizes a block's scoring type, falling back from block_type when the
/// column is absent/none.
String resolveScoring(Map<String, dynamic> block) {
  final raw = (block['scoring_type'] ?? block['scoring']) as String?;
  if (raw != null && raw != 'none' && raw.isNotEmpty) return raw;
  final type = (block['block_type'] ?? block['type']) as String?;
  if (type == 'strength') return 'weight';
  if (type == 'wod') return 'rounds_reps';
  return raw ?? 'none';
}
