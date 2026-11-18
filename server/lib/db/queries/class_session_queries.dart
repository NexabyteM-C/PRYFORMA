import 'package:postgres/postgres.dart';
import '../database.dart';

Future<void> insertClassSession(
  TxSession tx, {
  required String id,
  required String programId,
  required String organizationId,
  required String locationId,
  required DateTime startsAt,
  required DateTime endsAt,
  int capacity = 20,
}) async {
  await tx.execute(
    Sql.named('''
      INSERT INTO class_sessions
        (id, program_id, organization_id, location_id, starts_at, ends_at, capacity)
      VALUES (@id, @programId, @orgId, @locationId, @startsAt, @endsAt, @capacity)
    '''),
    parameters: {
      'id': id,
      'programId': programId,
      'orgId': organizationId,
      'locationId': locationId,
      'startsAt': startsAt,
      'endsAt': endsAt,
      'capacity': capacity,
    },
  );
}

Future<List<Map<String, dynamic>>> listSessionsByDateRange(
  Database db, {
  required String organizationId,
  required DateTime from,
  required DateTime to,
}) async {
  final result = await db.query(
    '''
    SELECT cs.id, cs.program_id, cs.starts_at, cs.ends_at, cs.capacity,
           cs.status, cs.location_id,
           cp.title as program_title, cp.status as program_status,
           ol.name as location_name,
           COUNT(csa.id) as attendee_count
    FROM class_sessions cs
    JOIN class_programs cp ON cp.id = cs.program_id
    JOIN organization_locations ol ON ol.id = cs.location_id
    LEFT JOIN class_session_attendees csa ON csa.session_id = cs.id AND csa.status = 'confirmed'
    WHERE cs.organization_id = @orgId
      AND cs.starts_at >= @from AND cs.starts_at < @to
    GROUP BY cs.id, cp.title, cp.status, ol.name
    ORDER BY cs.starts_at
    ''',
    parameters: {'orgId': organizationId, 'from': from, 'to': to},
  );
  return result.map((row) {
    final cols = row.toColumnMap();
    return {
      'id': cols['id']?.toString(),
      'programId': cols['program_id']?.toString(),
      'startsAt': cols['starts_at']?.toString(),
      'endsAt': cols['ends_at']?.toString(),
      'capacity': cols['capacity'] as int? ?? 20,
      'status': cols['status'] as String?,
      'locationId': cols['location_id']?.toString(),
      'programTitle': cols['program_title'] as String?,
      'programStatus': cols['program_status'] as String?,
      'locationName': cols['location_name'] as String?,
      'attendeeCount': cols['attendee_count'] as int? ?? 0,
    };
  }).toList();
}

Future<List<Map<String, dynamic>>> listAthleteCalendar(
  Database db, {
  required String userId,
  required DateTime from,
  required DateTime to,
}) async {
  final result = await db.query(
    '''
    SELECT cs.id, cs.starts_at, cs.ends_at, cs.capacity, cs.status,
           cp.title as program_title,
           o.id as org_id, o.name as org_name,
           ol.name as location_name,
           csa.status as attendance_status
    FROM class_sessions cs
    JOIN class_programs cp ON cp.id = cs.program_id
    JOIN organizations o ON o.id = cs.organization_id
    JOIN organization_locations ol ON ol.id = cs.location_id
    JOIN organization_members om ON om.organization_id = cs.organization_id
      AND om.user_id = @userId AND om.status = 'active'
    LEFT JOIN class_session_attendees csa ON csa.session_id = cs.id AND csa.user_id = @userId
    WHERE cs.starts_at >= @from AND cs.starts_at < @to
      AND cp.status = 'published'
    ORDER BY cs.starts_at
    ''',
    parameters: {'userId': userId, 'from': from, 'to': to},
  );
  return result.map((row) {
    final cols = row.toColumnMap();
    return {
      'id': cols['id']?.toString(),
      'startsAt': cols['starts_at']?.toString(),
      'endsAt': cols['ends_at']?.toString(),
      'capacity': cols['capacity'] as int? ?? 20,
      'status': cols['status'] as String?,
      'programTitle': cols['program_title'] as String?,
      'orgId': cols['org_id']?.toString(),
      'orgName': cols['org_name'] as String?,
      'locationName': cols['location_name'] as String?,
      'attendanceStatus': cols['attendance_status'] as String?,
    };
  }).toList();
}

Future<Map<String, dynamic>?> getSessionDetail(
  Database db,
  String sessionId,
) async {
  final result = await db.query(
    '''
    SELECT cs.id, cs.program_id, cs.organization_id, cs.location_id,
           cs.starts_at, cs.ends_at, cs.capacity, cs.status,
           cp.title as program_title, cp.description as program_description,
           o.name as org_name,
           ol.name as location_name
    FROM class_sessions cs
    JOIN class_programs cp ON cp.id = cs.program_id
    JOIN organizations o ON o.id = cs.organization_id
    JOIN organization_locations ol ON ol.id = cs.location_id
    WHERE cs.id = @id
    ''',
    parameters: {'id': sessionId},
  );
  if (result.isEmpty) return null;
  final cols = result.first.toColumnMap();
  return {
    'id': cols['id']?.toString(),
    'programId': cols['program_id']?.toString(),
    'organizationId': cols['organization_id']?.toString(),
    'locationId': cols['location_id']?.toString(),
    'startsAt': cols['starts_at']?.toString(),
    'endsAt': cols['ends_at']?.toString(),
    'capacity': cols['capacity'] as int? ?? 20,
    'status': cols['status'] as String?,
    'programTitle': cols['program_title'] as String?,
    'programDescription': cols['program_description'] as String?,
    'orgName': cols['org_name'] as String?,
    'locationName': cols['location_name'] as String?,
  };
}

Future<void> assignCoach(
  Database db, {
  required String id,
  required String sessionId,
  required String coachId,
}) async {
  await db.query(
    '''
    INSERT INTO class_session_coaches (id, session_id, coach_id)
    VALUES (@id, @sessionId, @coachId)
    ON CONFLICT (session_id, coach_id) DO NOTHING
    ''',
    parameters: {'id': id, 'sessionId': sessionId, 'coachId': coachId},
  );
}

Future<void> registerAttendee(
  Database db, {
  required String id,
  required String sessionId,
  required String userId,
}) async {
  await db.query(
    '''
    INSERT INTO class_session_attendees (id, session_id, user_id, status)
    VALUES (@id, @sessionId, @userId, 'confirmed')
    ON CONFLICT (session_id, user_id) DO UPDATE SET status = 'confirmed'
    ''',
    parameters: {'id': id, 'sessionId': sessionId, 'userId': userId},
  );
}

Future<void> cancelAttendee(
  Database db, {
  required String sessionId,
  required String userId,
}) async {
  await db.query(
    '''
    UPDATE class_session_attendees SET status = 'cancelled'
    WHERE session_id = @sessionId AND user_id = @userId
    ''',
    parameters: {'sessionId': sessionId, 'userId': userId},
  );
}
