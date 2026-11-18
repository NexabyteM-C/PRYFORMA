import 'package:domain_models/domain_models.dart';
import '../../../core/utils/rm_calculator.dart';

/// Display helpers for personal records. Weights are stored in KG but the spec
/// requires lifting marks to be shown in pounds (LB).

/// record_type values accepted by the backend.
const kWeightRecordTypes = {'1rm', '2rm', '3rm', '5rm', 'max_weight'};

/// Record types selectable when registering an RM, mapped to their display label.
const kSelectableRecordTypes = <String, String>{
  '1rm': '1RM',
  '2rm': '2RM',
  '3rm': '3RM',
  '5rm': '5RM',
  'max_reps': 'Máx. reps',
};

String recordTypeLabel(String recordType) {
  switch (recordType) {
    case '1rm':
      return '1RM';
    case '2rm':
      return '2RM';
    case '3rm':
      return '3RM';
    case '5rm':
      return '5RM';
    case 'max_reps':
      return 'Máx. reps';
    case 'max_duration':
      return 'Máx. duración';
    case 'min_time':
      return 'Mejor tiempo';
    case 'max_distance':
      return 'Máx. distancia';
    default:
      return recordType.toUpperCase();
  }
}

bool isWeightRecord(String recordType) => kWeightRecordTypes.contains(recordType);

String _formatDuration(int ms) {
  final totalSeconds = (ms / 1000).round();
  final m = totalSeconds ~/ 60;
  final s = totalSeconds % 60;
  return '$m:${s.toString().padLeft(2, '0')}';
}

/// Formats a stored record value for display, picking units by record type.
String formatRecordValue(PersonalRecord pr) {
  final v = pr.valueNumeric;
  switch (pr.recordType) {
    case 'max_reps':
      return '${v.round()} reps';
    case 'max_duration':
    case 'min_time':
      return _formatDuration(v.round());
    case 'max_distance':
      return '${v % 1 == 0 ? v.toInt() : v.toStringAsFixed(1)} m';
    default:
      // Weight-based marks: stored in kg, shown in lb.
      return RmCalculator.formatLb(RmCalculator.kgToLb(v));
  }
}

/// Numeric value in lb for charting weight records.
double recordValueInLb(PersonalRecord pr) => RmCalculator.kgToLb(pr.valueNumeric);

const kCategoryLabels = <String, String>{
  'halterofilia': 'Halterofilia',
  'fuerza': 'Fuerza',
  'gimnasia': 'Gimnasia',
  'funcional': 'Funcional',
  'cardio': 'Cardio',
};

String categoryLabel(String? category) =>
    category == null ? '' : (kCategoryLabels[category] ?? category);

String markTypeLabel(String markType) {
  switch (markType) {
    case 'real':
      return 'Real';
    case 'estimated':
      return 'Estimado';
    case 'weighted':
      return 'Con lastre';
    case 'assisted':
      return 'Asistido';
    default:
      return markType;
  }
}
