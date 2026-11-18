import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../data/datasources/programming_remote_datasource.dart';
import 'programming_provider.dart';

/// Formats minutes-from-midnight as a 12-hour "h:mm" string (no period).
String slotTimeNoPeriod(int minutes) {
  var hour = (minutes ~/ 60) % 12;
  if (hour == 0) hour = 12;
  final min = minutes % 60;
  return '$hour:${min.toString().padLeft(2, '0')}';
}

/// 'AM' / 'PM' derived from minutes-from-midnight.
String slotPeriod(int minutes) => (minutes % 1440) < 720 ? 'AM' : 'PM';

/// Auto-derived label like "5:00 - 6:00 AM".
String slotLabel(int startMinutes, int endMinutes) =>
    '${slotTimeNoPeriod(startMinutes)} - ${slotTimeNoPeriod(endMinutes)} '
    '${slotPeriod(startMinutes)}';

/// Reusable weekly time slots a box configures, keyed by organization id.
final timeSlotsProvider =
    FutureProvider.family<List<Map<String, dynamic>>, String>((ref, orgId) {
      final ds = ref.watch(programmingDatasourceProvider);
      return ds.listTimeSlots(orgId);
    });

/// Mutations for [timeSlotsProvider]. Each action refreshes the cached list.
final timeSlotActionsProvider = Provider<TimeSlotActions>(
  (ref) => TimeSlotActions(ref),
);

class TimeSlotActions {
  TimeSlotActions(this._ref);
  final Ref _ref;

  ProgrammingRemoteDatasource get _ds =>
      _ref.read(programmingDatasourceProvider);

  Future<void> create(String orgId, Map<String, dynamic> body) async {
    await _ds.createTimeSlot(orgId, body);
    _ref.invalidate(timeSlotsProvider(orgId));
  }

  Future<void> update(
    String orgId,
    String id,
    Map<String, dynamic> body,
  ) async {
    await _ds.updateTimeSlot(id, body);
    _ref.invalidate(timeSlotsProvider(orgId));
  }

  Future<void> delete(String orgId, String id) async {
    await _ds.deleteTimeSlot(id);
    _ref.invalidate(timeSlotsProvider(orgId));
  }
}
