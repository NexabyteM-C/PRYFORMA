import 'package:intl/intl.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class ProgrammingRemoteDatasource {
  final SupabaseClient _supabase;
  ProgrammingRemoteDatasource(this._supabase);

  Future<List<Map<String, dynamic>>> list(String orgId) async {
    return await _supabase
        .from('class_programs')
        .select(
          '*, sessions:class_sessions(id, program_id, location_id, start_time, end_time, capacity), blocks:class_program_blocks(id, program_id, block_type, title, sort_order)',
        )
        .eq('organization_id', orgId)
        .order('program_date', ascending: false);
  }

  Future<Map<String, dynamic>> getById(String programId) async {
    return await _supabase
        .from('class_programs')
        .select(
          '*, sessions:class_sessions(*), blocks:class_program_blocks(*, exercises:class_block_exercises(*, exercise:exercises(*)))',
        )
        .eq('id', programId)
        .single();
  }

  Future<Map<String, dynamic>> addBlock(Map<String, dynamic> body) async {
    return await _supabase
        .from('class_program_blocks')
        .insert(body)
        .select()
        .single();
  }

  Future<Map<String, dynamic>> updateBlock(
    String id,
    Map<String, dynamic> body,
  ) async {
    return await _supabase
        .from('class_program_blocks')
        .update(body)
        .eq('id', id)
        .select()
        .single();
  }

  Future<void> deleteBlock(String id) async {
    await _supabase.from('class_program_blocks').delete().eq('id', id);
  }

  Future<Map<String, dynamic>> addBlockExercise(
    Map<String, dynamic> body,
  ) async {
    return await _supabase
        .from('class_block_exercises')
        .insert(body)
        .select()
        .single();
  }

  Future<void> deleteBlockExercise(String id) async {
    await _supabase.from('class_block_exercises').delete().eq('id', id);
  }

  Future<Map<String, dynamic>> addSession(Map<String, dynamic> body) async {
    return await _supabase
        .from('class_sessions')
        .insert(body)
        .select()
        .single();
  }

  Future<void> deleteSession(String id) async {
    await _supabase.from('class_sessions').delete().eq('id', id);
  }

  Future<List<Map<String, dynamic>>> sessionsForProgram(String programId) async {
    return await _supabase
        .from('class_sessions')
        .select('*')
        .eq('program_id', programId)
        .order('start_time');
  }

  // ---- Box time slots (reusable weekly schedule the box configures) ----
  Future<List<Map<String, dynamic>>> listTimeSlots(String orgId) async {
    return await _supabase
        .from('box_time_slots')
        .select('*')
        .eq('organization_id', orgId)
        .order('start_minutes');
  }

  Future<Map<String, dynamic>> createTimeSlot(String orgId, Map<String, dynamic> body) async {
    body['organization_id'] = orgId;
    return await _supabase.from('box_time_slots').insert(body).select().single();
  }

  Future<Map<String, dynamic>> updateTimeSlot(String id, Map<String, dynamic> body) async {
    return await _supabase.from('box_time_slots').update(body).eq('id', id).select().single();
  }

  Future<void> deleteTimeSlot(String id) async {
    await _supabase.from('box_time_slots').delete().eq('id', id);
  }

  /// Program templates for an organization (reusable blueprints).
  Future<List<Map<String, dynamic>>> listTemplates(String orgId) async {
    return await _supabase
        .from('program_templates')
        .select('*')
        .eq('organization_id', orgId)
        .order('created_at', ascending: false);
  }

  /// Full template with its blocks and each block's prescribed exercises
  /// (joined to the bilingual exercise catalog). Blocks and their exercises
  /// are returned sorted by `sort_order`.
  Future<Map<String, dynamic>> getTemplateWithBlocks(String templateId) async {
    final data = await _supabase
        .from('program_templates')
        .select(
          '*, blocks:program_template_blocks(*, exercises:template_block_exercises(*, exercise:exercises(*)))',
        )
        .eq('id', templateId)
        .single();

    final blocks =
        ((data['blocks'] as List<dynamic>?) ?? const [])
            .map((e) => e as Map<String, dynamic>)
            .toList()
          ..sort(
            (a, b) => ((a['sort_order'] as num?) ?? 0).compareTo(
              (b['sort_order'] as num?) ?? 0,
            ),
          );
    for (final b in blocks) {
      final exs =
          ((b['exercises'] as List<dynamic>?) ?? const [])
              .map((e) => e as Map<String, dynamic>)
              .toList()
            ..sort(
              (a, b) => ((a['sort_order'] as num?) ?? 0).compareTo(
                (b['sort_order'] as num?) ?? 0,
              ),
            );
      b['exercises'] = exs;
    }
    data['blocks'] = blocks;
    return data;
  }

  /// Materialises a template into a concrete draft [class_programs] row for a
  /// given [date], copying every block and prescribed exercise. Returns the id
  /// of the newly created program.
  Future<String> applyTemplate(
    String orgId,
    String templateId,
    DateTime date, {
    String? locationId,
  }) async {
    final tpl = await getTemplateWithBlocks(templateId);
    final rawName = (tpl['name'] ?? tpl['title'] ?? 'Plantilla') as String;
    final title = rawName.replaceFirst('Plantilla ', '').trim();

    final header = <String, dynamic>{
      'title': title.isEmpty ? rawName : title,
      'program_date': DateFormat('yyyy-MM-dd').format(date),
      'description': tpl['description'],
      'status': 'draft',
      'template_id': templateId,
      'focus_tags': <String>[],
    };
    if (locationId != null) header['location_id'] = locationId;

    // create() sets organization_id and created_by.
    final created = await create(orgId, header);
    final programId = created['id'] as String;

    final blocks = (tpl['blocks'] as List<dynamic>?) ?? const [];
    for (final raw in blocks) {
      final block = raw as Map<String, dynamic>;
      final blockRow = await addBlock({
        'program_id': programId,
        'block_type': block['block_type'],
        'title': block['title'],
        'description': block['description'],
        'scoring_type': block['scoring_type'],
        'coach_notes': block['coach_notes'],
        'duration_minutes': block['duration_minutes'],
        'sort_order': block['sort_order'],
      });
      final blockId = blockRow['id'] as String;

      final exercises = (block['exercises'] as List<dynamic>?) ?? const [];
      for (final rawEx in exercises) {
        final ex = rawEx as Map<String, dynamic>;
        await addBlockExercise({
          'block_id': blockId,
          'exercise_id': ex['exercise_id'],
          'sets': ex['sets'],
          'reps': ex['reps'],
          'weight_prescription': ex['weight_prescription'],
          'distance_m': ex['distance_m'],
          'notes': ex['notes'],
          'sort_order': ex['sort_order'],
        });
      }
    }

    // Generate a session for each active box time slot on this date, so the
    // class appears in the athlete calendar and athletes can enroll by slot.
    await createSessionsFromSlots(
      orgId: orgId,
      programId: programId,
      date: date,
      fallbackLocationId: header['location_id'] as String? ?? locationId,
    );
    return programId;
  }

  /// Creates one class_session per active box time slot on [date].
  Future<void> createSessionsFromSlots({
    required String orgId,
    required String programId,
    required DateTime date,
    String? fallbackLocationId,
  }) async {
    final slots = await listTimeSlots(orgId);
    final existing = await sessionsForProgram(programId);
    final existingStarts = existing
        .map((s) => DateTime.tryParse(s['start_time'] as String? ?? '')?.toLocal())
        .whereType<DateTime>()
        .map((d) => d.hour * 60 + d.minute)
        .toSet();

    for (final s in slots) {
      if (s['is_active'] == false) continue;
      final startMin = (s['start_minutes'] as num?)?.toInt();
      if (startMin == null || existingStarts.contains(startMin)) continue;
      final endMin = (s['end_minutes'] as num?)?.toInt() ?? startMin + 60;
      final day = DateTime(date.year, date.month, date.day);
      await addSession({
        'program_id': programId,
        'location_id': s['location_id'] ?? fallbackLocationId,
        // Store as UTC so the local wall-clock time (box timezone) round-trips
        // correctly; a bare local ISO string is misread as UTC by Postgres.
        'start_time': day.add(Duration(minutes: startMin)).toUtc().toIso8601String(),
        'end_time': day.add(Duration(minutes: endMin)).toUtc().toIso8601String(),
        'capacity': s['capacity'],
      });
    }
  }

  /// Ensures a program offers one session per active box time slot on [date],
  /// WITHOUT disturbing sessions that already match a slot. Existing sessions
  /// keep their id (so athlete links and enrollments survive a re-publish);
  /// only missing slots are added and sessions with no matching slot removed.
  Future<void> syncSessionsFromSlots({
    required String orgId,
    required String programId,
    required DateTime date,
    String? fallbackLocationId,
  }) async {
    final slots = (await listTimeSlots(orgId))
        .where((s) => s['is_active'] != false)
        .toList();
    final existing = await sessionsForProgram(programId);

    // Index existing sessions by their local start minute.
    final existingByMin = <int, Map<String, dynamic>>{};
    for (final s in existing) {
      final dt = DateTime.tryParse(s['start_time'] as String? ?? '')?.toLocal();
      if (dt != null) existingByMin[dt.hour * 60 + dt.minute] = s;
    }

    final day = DateTime(date.year, date.month, date.day);
    final activeMins = <int>{};
    for (final slot in slots) {
      final startMin = (slot['start_minutes'] as num?)?.toInt();
      if (startMin == null) continue;
      activeMins.add(startMin);
      if (existingByMin.containsKey(startMin)) continue; // keep existing id
      final endMin = (slot['end_minutes'] as num?)?.toInt() ?? startMin + 60;
      await addSession({
        'program_id': programId,
        'location_id': slot['location_id'] ?? fallbackLocationId,
        'start_time': day.add(Duration(minutes: startMin)).toUtc().toIso8601String(),
        'end_time': day.add(Duration(minutes: endMin)).toUtc().toIso8601String(),
        'capacity': slot['capacity'],
      });
    }

    // Drop sessions that no longer correspond to an active slot.
    for (final entry in existingByMin.entries) {
      if (!activeMins.contains(entry.key)) {
        await deleteSession(entry.value['id'] as String);
      }
    }
  }

  Future<void> deleteProgram(String id) async {
    await _supabase.from('class_programs').delete().eq('id', id);
  }

  Future<Map<String, dynamic>> create(
    String orgId,
    Map<String, dynamic> body,
  ) async {
    body['organization_id'] = orgId;
    body['created_by'] = _supabase.auth.currentUser!.id;
    return await _supabase
        .from('class_programs')
        .insert(body)
        .select()
        .single();
  }

  Future<Map<String, dynamic>> update(
    String programId,
    Map<String, dynamic> body,
  ) async {
    return await _supabase
        .from('class_programs')
        .update(body)
        .eq('id', programId)
        .select()
        .single();
  }

  Future<void> publish(String programId, {DateTime? scheduledAt}) async {
    final userId = _supabase.auth.currentUser!.id;
    if (scheduledAt != null) {
      await _supabase.from('publication_events').insert({
        'class_program_id': programId,
        'action': 'scheduled',
        'performed_by': userId,
        'scheduled_for': scheduledAt.toIso8601String(),
      });
      await _supabase
          .from('class_programs')
          .update({'status': 'scheduled'})
          .eq('id', programId);
    } else {
      await _supabase.from('publication_events').insert({
        'class_program_id': programId,
        'action': 'published',
        'performed_by': userId,
        'processed_at': DateTime.now().toIso8601String(),
      });
      await _supabase
          .from('class_programs')
          .update({'status': 'published'})
          .eq('id', programId);
    }
  }
}
