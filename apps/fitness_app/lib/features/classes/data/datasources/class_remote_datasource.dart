import 'package:supabase_flutter/supabase_flutter.dart';

class ClassRemoteDatasource {
  final SupabaseClient _supabase;
  ClassRemoteDatasource(this._supabase);

  /// Organizations the current user actively belongs to.
  Future<List<String>> _myOrgIds() async {
    final userId = _supabase.auth.currentUser!.id;
    final rows = await _supabase
        .from('organization_members')
        .select('organization_id')
        .eq('user_id', userId)
        .eq('status', 'active');
    return rows.map((r) => r['organization_id'] as String).toList();
  }

  /// Published class sessions for the user's boxes in a date window.
  /// Returns rich maps (session + program + organization + location + coaches).
  Future<List<Map<String, dynamic>>> calendar({
    required String weekStart,
    required String weekEnd,
  }) async {
    final orgIds = await _myOrgIds();
    if (orgIds.isEmpty) return [];

    final rows = await _supabase
        .from('class_sessions')
        .select(
          '*, program:class_programs!inner(id, title, description, focus_tags, objective, coach_notes, status, organization_id, organization:organizations(id, name, slug)), '
          'location:organization_locations(id, name), '
          'coaches:class_session_coaches(coach:profiles(id, display_name))',
        )
        .gte('start_time', weekStart)
        .lte('start_time', weekEnd)
        .eq('program.status', 'published')
        .inFilter('program.organization_id', orgIds)
        .order('start_time');
    return List<Map<String, dynamic>>.from(rows);
  }

  /// Recent published classes in the athlete's boxes (last ~3 weeks to today),
  /// for linking a logged workout to the class actually worked.
  Future<List<Map<String, dynamic>>> recentProgrammedClasses() async {
    final orgIds = await _myOrgIds();
    if (orgIds.isEmpty) return [];
    final from = DateTime.now()
        .subtract(const Duration(days: 21))
        .toUtc()
        .toIso8601String();
    final to =
        DateTime.now().add(const Duration(days: 1)).toUtc().toIso8601String();
    final rows = await _supabase
        .from('class_sessions')
        .select(
          'id, start_time, program:class_programs!inner(id, title, status, organization_id, organization:organizations(name))',
        )
        .gte('start_time', from)
        .lte('start_time', to)
        .eq('program.status', 'published')
        .inFilter('program.organization_id', orgIds)
        .order('start_time', ascending: false);
    return List<Map<String, dynamic>>.from(rows);
  }

  /// A full program with blocks + exercises (flattened, no version wrapper).
  Future<Map<String, dynamic>> getProgram(String programId) async {
    return await _supabase
        .from('class_programs')
        .select(
          '*, organization:organizations(id, name), location:organization_locations(id, name, timezone), '
          'blocks:class_program_blocks(*, exercises:class_block_exercises(*, exercise:exercises(*))), '
          'sessions:class_sessions(id, start_time, end_time, capacity, coaches:class_session_coaches(coach:profiles(id, display_name)))',
        )
        .eq('id', programId)
        .single();
  }

  /// A session with its program (used by class detail / record).
  Future<Map<String, dynamic>> getSession(String sessionId) async {
    return await _supabase
        .from('class_sessions')
        .select(
          '*, program:class_programs(*, organization:organizations(id, name), '
          'blocks:class_program_blocks(*, exercises:class_block_exercises(*, exercise:exercises(*)))), '
          'location:organization_locations(id, name), '
          'coaches:class_session_coaches(coach:profiles(id, display_name))',
        )
        .eq('id', sessionId)
        .single();
  }

  // ---- Enrollment (athlete signs up for a time-slot session) ----

  /// Sessions of a program with their enrollment counts (for picking a time).
  Future<List<Map<String, dynamic>>> sessionsForProgram(String programId) async {
    return await _supabase
        .from('class_sessions')
        .select('*, location:organization_locations(id, name), coaches:class_session_coaches(coach:profiles(id, display_name))')
        .eq('program_id', programId)
        .order('start_time');
  }

  /// The current athlete's active enrollments (optionally within a session set).
  Future<List<Map<String, dynamic>>> myEnrollments() async {
    final userId = _supabase.auth.currentUser!.id;
    return await _supabase
        .from('class_enrollments')
        .select('*')
        .eq('athlete_id', userId)
        .eq('status', 'enrolled');
  }

  Future<Map<String, dynamic>?> myEnrollmentForSession(String sessionId) async {
    final userId = _supabase.auth.currentUser!.id;
    return await _supabase
        .from('class_enrollments')
        .select('*')
        .eq('athlete_id', userId)
        .eq('class_session_id', sessionId)
        .maybeSingle();
  }

  Future<void> enroll(String sessionId) async {
    final userId = _supabase.auth.currentUser!.id;
    await _supabase.from('class_enrollments').upsert({
      'class_session_id': sessionId,
      'athlete_id': userId,
      'status': 'enrolled',
      'enrolled_at': DateTime.now().toIso8601String(),
    }, onConflict: 'class_session_id,athlete_id');
  }

  Future<void> cancelEnrollment(String sessionId) async {
    final userId = _supabase.auth.currentUser!.id;
    await _supabase
        .from('class_enrollments')
        .update({'status': 'cancelled'})
        .eq('class_session_id', sessionId)
        .eq('athlete_id', userId);
  }

  /// Roster of a session (who enrolled) — for coaches.
  Future<List<Map<String, dynamic>>> sessionRoster(String sessionId) async {
    return await _supabase
        .from('class_enrollments')
        .select('*, athlete:profiles(id, display_name, email)')
        .eq('class_session_id', sessionId)
        .eq('status', 'enrolled')
        .order('enrolled_at');
  }

  /// Per-movement result (actual weight/reps used) for a class session.
  Future<Map<String, dynamic>> saveMovementResult(Map<String, dynamic> body) async {
    body['user_id'] = _supabase.auth.currentUser!.id;
    return await _supabase
        .from('athlete_movement_results')
        .upsert(body, onConflict: 'class_session_id,user_id,exercise_id')
        .select()
        .single();
  }

  Future<Map<String, dynamic>> submitResults(
      String sessionId, Map<String, dynamic> body) async {
    body['class_session_id'] = sessionId;
    body['user_id'] = _supabase.auth.currentUser!.id;
    return await _supabase
        .from('athlete_class_results')
        .upsert(body, onConflict: 'class_session_id,user_id,block_id')
        .select()
        .single();
  }
}
