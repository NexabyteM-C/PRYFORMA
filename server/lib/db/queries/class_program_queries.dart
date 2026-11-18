import 'package:postgres/postgres.dart';
import '../database.dart';

Future<void> insertClassProgram(
  TxSession tx, {
  required String id,
  required String organizationId,
  required String createdBy,
  required DateTime programDate,
  String? title,
  String? description,
  String? templateId,
  String status = 'draft',
}) async {
  await tx.execute(
    Sql.named('''
      INSERT INTO class_programs
        (id, organization_id, created_by, program_date, title, description, template_id, status)
      VALUES (@id, @orgId, @createdBy, @programDate, @title, @description, @templateId, @status)
    '''),
    parameters: {
      'id': id,
      'orgId': organizationId,
      'createdBy': createdBy,
      'programDate': programDate,
      'title': title,
      'description': description,
      'templateId': templateId,
      'status': status,
    },
  );
}

Future<void> insertProgramBlock(
  TxSession tx, {
  required String id,
  required String programId,
  required String name,
  required int sortOrder,
  String blockType = 'strength',
  String? notes,
  int? timecapMs,
}) async {
  await tx.execute(
    Sql.named('''
      INSERT INTO class_program_blocks
        (id, program_id, name, sort_order, block_type, notes, timecap_ms)
      VALUES (@id, @programId, @name, @sortOrder, @blockType, @notes, @timecapMs)
    '''),
    parameters: {
      'id': id,
      'programId': programId,
      'name': name,
      'sortOrder': sortOrder,
      'blockType': blockType,
      'notes': notes,
      'timecapMs': timecapMs,
    },
  );
}

Future<void> insertBlockExercise(
  TxSession tx, {
  required String id,
  required String blockId,
  required String exerciseId,
  required int sortOrder,
  int? sets,
  String? repsScheme,
  double? prescribedWeightKg,
  String? percentageRm,
  String? notes,
}) async {
  await tx.execute(
    Sql.named('''
      INSERT INTO class_block_exercises
        (id, block_id, exercise_id, sort_order, sets, reps_scheme,
         prescribed_weight_kg, percentage_rm, notes)
      VALUES (@id, @blockId, @exerciseId, @sortOrder, @sets, @repsScheme,
              @prescribedWeightKg, @percentageRm, @notes)
    '''),
    parameters: {
      'id': id,
      'blockId': blockId,
      'exerciseId': exerciseId,
      'sortOrder': sortOrder,
      'sets': sets,
      'repsScheme': repsScheme,
      'prescribedWeightKg': prescribedWeightKg,
      'percentageRm': percentageRm,
      'notes': notes,
    },
  );
}

Future<List<Map<String, dynamic>>> listClassPrograms(
  Database db,
  String orgId, {
  DateTime? from,
  DateTime? to,
  String? status,
  int limit = 30,
  int offset = 0,
}) async {
  final where = <String>['cp.organization_id = @orgId'];
  final params = <String, dynamic>{
    'orgId': orgId,
    'lim': limit,
    'off': offset,
  };

  if (from != null) {
    where.add('cp.program_date >= @from');
    params['from'] = from;
  }
  if (to != null) {
    where.add('cp.program_date <= @to');
    params['to'] = to;
  }
  if (status != null) {
    where.add('cp.status = @status');
    params['status'] = status;
  }

  final result = await db.query(
    '''
    SELECT cp.id, cp.program_date, cp.title, cp.description, cp.status,
           cp.created_by, cp.template_id, cp.published_at, cp.created_at,
           p.display_name as author_name
    FROM class_programs cp
    LEFT JOIN profiles p ON p.id = cp.created_by
    WHERE ${where.join(' AND ')}
    ORDER BY cp.program_date DESC
    LIMIT @lim OFFSET @off
    ''',
    parameters: params,
  );
  return result.map((row) {
    final cols = row.toColumnMap();
    return {
      'id': cols['id']?.toString(),
      'programDate': cols['program_date']?.toString(),
      'title': cols['title'] as String?,
      'description': cols['description'] as String?,
      'status': cols['status'] as String?,
      'createdBy': cols['created_by']?.toString(),
      'authorName': cols['author_name'] as String?,
      'templateId': cols['template_id']?.toString(),
      'publishedAt': cols['published_at']?.toString(),
      'createdAt': cols['created_at']?.toString(),
    };
  }).toList();
}

Future<Map<String, dynamic>?> getClassProgramDetail(
  Database db,
  String programId,
) async {
  final pResult = await db.query(
    '''
    SELECT cp.id, cp.organization_id, cp.program_date, cp.title, cp.description,
           cp.status, cp.created_by, cp.template_id, cp.published_at,
           cp.version, cp.created_at,
           p.display_name as author_name
    FROM class_programs cp
    LEFT JOIN profiles p ON p.id = cp.created_by
    WHERE cp.id = @id
    ''',
    parameters: {'id': programId},
  );
  if (pResult.isEmpty) return null;

  final pCols = pResult.first.toColumnMap();
  final program = {
    'id': pCols['id']?.toString(),
    'organizationId': pCols['organization_id']?.toString(),
    'programDate': pCols['program_date']?.toString(),
    'title': pCols['title'] as String?,
    'description': pCols['description'] as String?,
    'status': pCols['status'] as String?,
    'createdBy': pCols['created_by']?.toString(),
    'authorName': pCols['author_name'] as String?,
    'templateId': pCols['template_id']?.toString(),
    'publishedAt': pCols['published_at']?.toString(),
    'version': pCols['version'] as int? ?? 1,
    'createdAt': pCols['created_at']?.toString(),
  };

  final blocksResult = await db.query(
    '''
    SELECT id, name, sort_order, block_type, notes, timecap_ms
    FROM class_program_blocks
    WHERE program_id = @programId
    ORDER BY sort_order
    ''',
    parameters: {'programId': programId},
  );

  final blocks = <Map<String, dynamic>>[];
  for (final bRow in blocksResult) {
    final bCols = bRow.toColumnMap();
    final blockId = bCols['id']?.toString();

    final exResult = await db.query(
      '''
      SELECT cbe.id, cbe.exercise_id, cbe.sort_order, cbe.sets, cbe.reps_scheme,
             cbe.prescribed_weight_kg, cbe.percentage_rm, cbe.notes,
             e.name as exercise_name, e.category
      FROM class_block_exercises cbe
      JOIN exercises e ON e.id = cbe.exercise_id
      WHERE cbe.block_id = @blockId
      ORDER BY cbe.sort_order
      ''',
      parameters: {'blockId': blockId},
    );

    blocks.add({
      'id': blockId,
      'name': bCols['name'] as String?,
      'sortOrder': bCols['sort_order'] as int? ?? 0,
      'blockType': bCols['block_type'] as String?,
      'notes': bCols['notes'] as String?,
      'timecapMs': bCols['timecap_ms'] as int?,
      'exercises': exResult.map((eRow) {
        final eCols = eRow.toColumnMap();
        return {
          'id': eCols['id']?.toString(),
          'exerciseId': eCols['exercise_id']?.toString(),
          'exerciseName': eCols['exercise_name'] as String?,
          'category': eCols['category'] as String?,
          'sortOrder': eCols['sort_order'] as int? ?? 0,
          'sets': eCols['sets'] as int?,
          'repsScheme': eCols['reps_scheme'] as String?,
          'prescribedWeightKg': eCols['prescribed_weight_kg']?.toString(),
          'percentageRm': eCols['percentage_rm'] as String?,
          'notes': eCols['notes'] as String?,
        };
      }).toList(),
    });
  }

  program['blocks'] = blocks;
  return program;
}

Future<void> updateProgramStatus(
  Database db, {
  required String programId,
  required String status,
}) async {
  final extra = status == 'published' ? ', published_at = NOW(), version = version + 1' : '';
  await db.query(
    'UPDATE class_programs SET status = @status$extra WHERE id = @id',
    parameters: {'id': programId, 'status': status},
  );
}

Future<void> deleteProgram(Database db, String programId) async {
  await db.query(
    'DELETE FROM class_programs WHERE id = @id AND status = \'draft\'',
    parameters: {'id': programId},
  );
}
