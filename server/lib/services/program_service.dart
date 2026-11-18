import 'package:uuid/uuid.dart';
import '../db/database.dart';
import '../db/queries/class_program_queries.dart' as q;

class ProgramService {
  final Database _db;
  final _uuid = const Uuid();

  ProgramService(this._db);

  Future<Map<String, dynamic>> createProgram({
    required String organizationId,
    required String createdBy,
    required DateTime programDate,
    String? title,
    String? description,
    String? templateId,
    List<Map<String, dynamic>>? blocks,
  }) async {
    final programId = _uuid.v4();

    await _db.transaction((tx) async {
      await q.insertClassProgram(
        tx,
        id: programId,
        organizationId: organizationId,
        createdBy: createdBy,
        programDate: programDate,
        title: title,
        description: description,
        templateId: templateId,
      );

      if (blocks != null) {
        for (var i = 0; i < blocks.length; i++) {
          final block = blocks[i];
          final blockId = _uuid.v4();
          await q.insertProgramBlock(
            tx,
            id: blockId,
            programId: programId,
            name: block['name'] as String? ?? 'Block ${i + 1}',
            sortOrder: i,
            blockType: block['blockType'] as String? ?? 'strength',
            notes: block['notes'] as String?,
            timecapMs: block['timecapMs'] as int?,
          );

          final exercises =
              (block['exercises'] as List?)?.cast<Map<String, dynamic>>() ?? [];
          for (var j = 0; j < exercises.length; j++) {
            final ex = exercises[j];
            await q.insertBlockExercise(
              tx,
              id: _uuid.v4(),
              blockId: blockId,
              exerciseId: ex['exerciseId'] as String,
              sortOrder: j,
              sets: ex['sets'] as int?,
              repsScheme: ex['repsScheme'] as String?,
              prescribedWeightKg: (ex['prescribedWeightKg'] as num?)?.toDouble(),
              percentageRm: ex['percentageRm'] as String?,
              notes: ex['notes'] as String?,
            );
          }
        }
      }
    });

    return (await q.getClassProgramDetail(_db, programId))!;
  }

  Future<List<Map<String, dynamic>>> listPrograms(
    String orgId, {
    DateTime? from,
    DateTime? to,
    String? status,
    int limit = 30,
    int offset = 0,
  }) {
    return q.listClassPrograms(
      _db,
      orgId,
      from: from,
      to: to,
      status: status,
      limit: limit,
      offset: offset,
    );
  }

  Future<Map<String, dynamic>?> getProgram(String programId) {
    return q.getClassProgramDetail(_db, programId);
  }

  Future<void> publish(String programId) {
    return q.updateProgramStatus(_db, programId: programId, status: 'published');
  }

  Future<void> cancel(String programId) {
    return q.updateProgramStatus(_db, programId: programId, status: 'cancelled');
  }

  Future<void> schedule(String programId) {
    return q.updateProgramStatus(_db, programId: programId, status: 'scheduled');
  }

  Future<void> deleteDraft(String programId) {
    return q.deleteProgram(_db, programId);
  }
}
