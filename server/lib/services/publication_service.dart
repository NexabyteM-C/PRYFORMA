import 'package:uuid/uuid.dart';
import '../db/database.dart';

class PublicationService {
  final Database _db;
  final _uuid = const Uuid();

  PublicationService(this._db);

  Future<void> processScheduledPublications() async {
    final result = await _db.query(
      '''
      SELECT id FROM class_programs
      WHERE status = 'scheduled' AND scheduled_publish_at <= NOW()
      FOR UPDATE SKIP LOCKED
      LIMIT 10
      ''',
    );

    for (final row in result) {
      final id = row.toColumnMap()['id']?.toString();
      if (id == null) continue;

      await _db.query(
        '''
        UPDATE class_programs
        SET status = 'published', published_at = NOW(), version = version + 1
        WHERE id = @id AND status = 'scheduled'
        ''',
        parameters: {'id': id},
      );

      await _createPublicationEvent(programId: id);
    }
  }

  Future<void> publishNow(String programId) async {
    await _db.query(
      '''
      UPDATE class_programs
      SET status = 'published', published_at = NOW(), version = version + 1
      WHERE id = @id AND status IN ('draft', 'scheduled')
      ''',
      parameters: {'id': programId},
    );
    await _createPublicationEvent(programId: programId);
  }

  Future<void> schedulePublication({
    required String programId,
    required DateTime publishAt,
  }) async {
    await _db.query(
      '''
      UPDATE class_programs
      SET status = 'scheduled', scheduled_publish_at = @publishAt
      WHERE id = @id AND status = 'draft'
      ''',
      parameters: {'id': programId, 'publishAt': publishAt},
    );
  }

  Future<void> _createPublicationEvent({required String programId}) async {
    await _db.query(
      '''
      INSERT INTO publication_events (id, program_id, event_type, processed_at)
      VALUES (@id, @programId, 'published', NOW())
      ON CONFLICT DO NOTHING
      ''',
      parameters: {'id': _uuid.v4(), 'programId': programId},
    );
  }
}
