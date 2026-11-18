import 'package:uuid/uuid.dart';
import '../db/database.dart';
import '../db/queries/class_session_queries.dart' as q;
import '../db/queries/personal_record_queries.dart' as prq;

class ClassSessionService {
  final Database _db;
  final _uuid = const Uuid();

  ClassSessionService(this._db);

  Future<Map<String, dynamic>> createSession({
    required String programId,
    required String organizationId,
    required String locationId,
    required DateTime startsAt,
    required DateTime endsAt,
    int capacity = 20,
  }) async {
    final id = _uuid.v4();
    await _db.transaction((tx) async {
      await q.insertClassSession(
        tx,
        id: id,
        programId: programId,
        organizationId: organizationId,
        locationId: locationId,
        startsAt: startsAt,
        endsAt: endsAt,
        capacity: capacity,
      );
    });
    return (await q.getSessionDetail(_db, id))!;
  }

  Future<List<Map<String, dynamic>>> listByDateRange({
    required String organizationId,
    required DateTime from,
    required DateTime to,
  }) {
    return q.listSessionsByDateRange(
      _db,
      organizationId: organizationId,
      from: from,
      to: to,
    );
  }

  Future<List<Map<String, dynamic>>> athleteCalendar({
    required String userId,
    required DateTime from,
    required DateTime to,
  }) {
    return q.listAthleteCalendar(_db, userId: userId, from: from, to: to);
  }

  Future<Map<String, dynamic>?> getSession(String sessionId) {
    return q.getSessionDetail(_db, sessionId);
  }

  Future<Map<String, dynamic>?> getSessionWithPersonalizedLoads({
    required String sessionId,
    required String userId,
  }) async {
    final session = await q.getSessionDetail(_db, sessionId);
    if (session == null) return null;

    final programId = session['programId'] as String?;
    if (programId == null) return session;

    final blocksResult = await _db.query(
      '''
      SELECT cbe.exercise_id, cbe.percentage_rm
      FROM class_block_exercises cbe
      JOIN class_program_blocks cpb ON cpb.id = cbe.block_id
      WHERE cpb.program_id = @programId AND cbe.percentage_rm IS NOT NULL
      ''',
      parameters: {'programId': programId},
    );

    final personalizedLoads = <Map<String, dynamic>>[];
    for (final row in blocksResult) {
      final cols = row.toColumnMap();
      final exerciseId = cols['exercise_id']?.toString();
      final pctRm = cols['percentage_rm'] as String?;
      if (exerciseId == null || pctRm == null) continue;

      final pct = double.tryParse(pctRm);
      if (pct == null) continue;

      final pr = await prq.getCurrentPr(
        _db,
        userId: userId,
        exerciseId: exerciseId,
        metric: '1rm',
      );

      final oneRm = double.tryParse(pr?['valueNumeric']?.toString() ?? '');
      if (oneRm != null) {
        personalizedLoads.add({
          'exerciseId': exerciseId,
          'oneRm': oneRm,
          'percentage': pct,
          'recommendedKg': (oneRm * pct / 100).roundToDouble(),
        });
      }
    }

    session['personalizedLoads'] = personalizedLoads;
    return session;
  }

  Future<void> assignCoach({
    required String sessionId,
    required String coachId,
  }) {
    return q.assignCoach(
      _db,
      id: _uuid.v4(),
      sessionId: sessionId,
      coachId: coachId,
    );
  }

  Future<void> registerAttendee({
    required String sessionId,
    required String userId,
  }) {
    return q.registerAttendee(
      _db,
      id: _uuid.v4(),
      sessionId: sessionId,
      userId: userId,
    );
  }

  Future<void> cancelAttendee({
    required String sessionId,
    required String userId,
  }) {
    return q.cancelAttendee(_db, sessionId: sessionId, userId: userId);
  }
}
