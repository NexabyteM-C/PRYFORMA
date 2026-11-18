import 'package:postgres/postgres.dart';
import '../database.dart';

Future<void> insertAnnouncement(
  TxSession tx, {
  required String id,
  required String organizationId,
  required String authorId,
  required String title,
  required String body,
  String priority = 'normal',
  String? targetAudience,
}) async {
  await tx.execute(
    Sql.named('''
      INSERT INTO organization_announcements
        (id, organization_id, author_id, title, body, priority, target_audience)
      VALUES (@id, @orgId, @authorId, @title, @body, @priority, @audience)
    '''),
    parameters: {
      'id': id,
      'orgId': organizationId,
      'authorId': authorId,
      'title': title,
      'body': body,
      'priority': priority,
      'audience': targetAudience,
    },
  );
}

Future<List<Map<String, dynamic>>> listAnnouncements(
  Database db,
  String orgId, {
  int limit = 20,
  int offset = 0,
}) async {
  final result = await db.query(
    '''
    SELECT a.id, a.title, a.body, a.priority, a.target_audience,
           a.is_pinned, a.created_at,
           p.display_name as author_name, p.avatar_url as author_avatar
    FROM organization_announcements a
    JOIN profiles p ON p.id = a.author_id
    WHERE a.organization_id = @orgId
    ORDER BY a.is_pinned DESC, a.created_at DESC
    LIMIT @lim OFFSET @off
    ''',
    parameters: {'orgId': orgId, 'lim': limit, 'off': offset},
  );
  return result.map((row) {
    final cols = row.toColumnMap();
    return {
      'id': cols['id']?.toString(),
      'title': cols['title'] as String?,
      'body': cols['body'] as String?,
      'priority': cols['priority'] as String?,
      'targetAudience': cols['target_audience'] as String?,
      'isPinned': cols['is_pinned'] as bool? ?? false,
      'createdAt': cols['created_at']?.toString(),
      'authorName': cols['author_name'] as String?,
      'authorAvatar': cols['author_avatar'] as String?,
    };
  }).toList();
}

Future<List<Map<String, dynamic>>> listAthleteAnnouncements(
  Database db,
  String userId, {
  int limit = 20,
  int offset = 0,
}) async {
  final result = await db.query(
    '''
    SELECT a.id, a.title, a.body, a.priority, a.is_pinned, a.created_at,
           o.id as org_id, o.name as org_name,
           p.display_name as author_name
    FROM organization_announcements a
    JOIN organizations o ON o.id = a.organization_id
    JOIN profiles p ON p.id = a.author_id
    JOIN organization_members om ON om.organization_id = a.organization_id
      AND om.user_id = @userId AND om.status = 'active'
    ORDER BY a.created_at DESC
    LIMIT @lim OFFSET @off
    ''',
    parameters: {'userId': userId, 'lim': limit, 'off': offset},
  );
  return result.map((row) {
    final cols = row.toColumnMap();
    return {
      'id': cols['id']?.toString(),
      'title': cols['title'] as String?,
      'body': cols['body'] as String?,
      'priority': cols['priority'] as String?,
      'isPinned': cols['is_pinned'] as bool? ?? false,
      'createdAt': cols['created_at']?.toString(),
      'orgId': cols['org_id']?.toString(),
      'orgName': cols['org_name'] as String?,
      'authorName': cols['author_name'] as String?,
    };
  }).toList();
}

Future<Map<String, dynamic>?> findAnnouncementById(
  Database db,
  String announcementId,
) async {
  final result = await db.query(
    '''
    SELECT a.id, a.organization_id, a.title, a.body, a.priority,
           a.target_audience, a.is_pinned, a.created_at,
           p.display_name as author_name
    FROM organization_announcements a
    JOIN profiles p ON p.id = a.author_id
    WHERE a.id = @id
    ''',
    parameters: {'id': announcementId},
  );
  if (result.isEmpty) return null;
  final cols = result.first.toColumnMap();
  return {
    'id': cols['id']?.toString(),
    'organizationId': cols['organization_id']?.toString(),
    'title': cols['title'] as String?,
    'body': cols['body'] as String?,
    'priority': cols['priority'] as String?,
    'targetAudience': cols['target_audience'] as String?,
    'isPinned': cols['is_pinned'] as bool? ?? false,
    'createdAt': cols['created_at']?.toString(),
    'authorName': cols['author_name'] as String?,
  };
}

Future<void> deleteAnnouncement(
  Database db,
  String announcementId,
) async {
  await db.query(
    'DELETE FROM organization_announcements WHERE id = @id',
    parameters: {'id': announcementId},
  );
}
