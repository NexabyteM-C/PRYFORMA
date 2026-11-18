import 'package:uuid/uuid.dart';
import '../db/database.dart';
import '../db/queries/notification_queries.dart' as q;

class NotificationService {
  final Database _db;
  final _uuid = const Uuid();

  NotificationService(this._db);

  Future<void> notifyOrganizationMembers({
    required String organizationId,
    required String eventId,
    required String title,
    String? body,
    String? actionUrl,
    String? targetRole,
  }) async {
    final where = "om.organization_id = @orgId AND om.status = 'active'";
    final roleFilter =
        targetRole != null ? " AND om.role = @role" : '';

    final members = await _db.query(
      'SELECT om.user_id FROM organization_members om WHERE $where$roleFilter',
      parameters: {
        'orgId': organizationId,
        if (targetRole != null) 'role': targetRole,
      },
    );

    await _db.transaction((tx) async {
      for (final row in members) {
        final userId = row.toColumnMap()['user_id']?.toString();
        if (userId == null) continue;

        await q.insertNotification(
          tx,
          id: _uuid.v4(),
          userId: userId,
          eventId: eventId,
          channel: 'in_app',
          title: title,
          body: body,
          actionUrl: actionUrl,
        );
      }
    });
  }

  Future<List<Map<String, dynamic>>> listNotifications(
    String userId, {
    bool? unreadOnly,
    int limit = 30,
    int offset = 0,
  }) {
    return q.listNotifications(
      _db,
      userId,
      unreadOnly: unreadOnly,
      limit: limit,
      offset: offset,
    );
  }

  Future<void> markRead(String notificationId, String userId) {
    return q.markRead(_db, notificationId, userId);
  }

  Future<void> markAllRead(String userId) {
    return q.markAllRead(_db, userId);
  }

  Future<int> countUnread(String userId) {
    return q.countUnread(_db, userId);
  }
}
