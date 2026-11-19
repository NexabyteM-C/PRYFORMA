import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'class_provider.dart';

/// All time-slot sessions of a program (with location, coaches, enrolled_count
/// and capacity). Used to let the athlete pick a schedule to enroll in.
final programSessionsProvider =
    FutureProvider.family<List<Map<String, dynamic>>, String>(
        (ref, programId) async {
  final ds = ref.watch(classRemoteDatasourceProvider);
  return ds.sessionsForProgram(programId);
});

/// Roster of a session (athletes currently enrolled, with their profile) —
/// used by the admin/coach "Inscritos" view. autoDispose so the list refetches
/// each time the screen is opened.
final sessionRosterProvider = FutureProvider.autoDispose
    .family<List<Map<String, dynamic>>, String>((ref, sessionId) async {
  final ds = ref.watch(classRemoteDatasourceProvider);
  return ds.sessionRoster(sessionId);
});

/// The current athlete's enrollment row for a single session, or null.
final myEnrollmentProvider =
    FutureProvider.family<Map<String, dynamic>?, String>((ref, sessionId) async {
  final ds = ref.watch(classRemoteDatasourceProvider);
  return ds.myEnrollmentForSession(sessionId);
});

/// Set of session ids the athlete is actively enrolled in — used to surface an
/// "Inscrito" badge on calendar cards and to reflect per-slot enrollment state.
final myEnrolledSessionIdsProvider = FutureProvider<Set<String>>((ref) async {
  final ds = ref.watch(classRemoteDatasourceProvider);
  final rows = await ds.myEnrollments();
  return rows
      .map((r) => r['class_session_id'] as String?)
      .whereType<String>()
      .toSet();
});

/// Enroll / cancel operations that refresh the affected providers afterwards so
/// slot counts and badges update without a manual reload.
class EnrollmentActions {
  EnrollmentActions(this._ref);
  final Ref _ref;

  Future<void> enroll(String sessionId, {String? programId}) async {
    final ds = _ref.read(classRemoteDatasourceProvider);
    await ds.enroll(sessionId);
    _refresh(sessionId, programId);
  }

  Future<void> cancel(String sessionId, {String? programId}) async {
    final ds = _ref.read(classRemoteDatasourceProvider);
    await ds.cancelEnrollment(sessionId);
    _refresh(sessionId, programId);
  }

  void _refresh(String sessionId, String? programId) {
    _ref.invalidate(myEnrollmentProvider(sessionId));
    _ref.invalidate(myEnrolledSessionIdsProvider);
    if (programId != null) {
      _ref.invalidate(programSessionsProvider(programId));
    }
  }
}

final enrollmentActionsProvider =
    Provider<EnrollmentActions>((ref) => EnrollmentActions(ref));
