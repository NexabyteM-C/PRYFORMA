import 'package:postgres/postgres.dart';
import '../database.dart';

Future<void> insertNotification(
  TxSession tx, {
  required String id,
  required String userId,
  required String eventId,
  required String channel,
  required String title,
  String? body,
  String? actionUrl,
}) async {
  await tx.execute(
    Sql.named('''
      INSERT INTO notification_deliveries
        (id, user_id, event_id, channel, title, body, action_url)
      VALUES (@id, @userId, @eventId, @channel, @title, @body, @actionUrl)
      ON CONFLICT (event_id, user_id, channel) DO NOTHING
    '''),
    parameters: {
      'id': id,
      'userId': userId,
      'eventId': eventId,
      'channel': channel,
      'title': title,
      'body': body,
      'actionUrl': actionUrl,
    },
  );
}

Future<List<Map<String, dynamic>>> listNotifications(
  Database db,
  String userId, {
  bool? unreadOnly,
  int limit = 30,
  int offset = 0,
}) async {
  final where = <String>['nd.user_id = @userId', "nd.channel = 'in_app'"];
  final params = <String, dynamic>{
    'userId': userId,
    'lim': limit,
    'off': offset,
  };

  if (unreadOnly == true) {
    where.add('nd.read_at IS NULL');
  }

  final result = await db.query(
    '''
    SELECT nd.id, nd.event_id, nd.title, nd.body, nd.action_url,
           nd.read_at, nd.created_at
    FROM notification_deliveries nd
    WHERE ${where.join(' AND ')}
    ORDER BY nd.created_at DESC
    LIMIT @lim OFFSET @off
    ''',
    parameters: params,
  );
  return result.map((row) {
    final cols = row.toColumnMap();
    return {
      'id': cols['id']?.toString(),
      'eventId': cols['event_id']?.toString(),
      'title': cols['title'] as String?,
      'body': cols['body'] as String?,
      'actionUrl': cols['action_url'] as String?,
      'readAt': cols['read_at']?.toString(),
      'createdAt': cols['created_at']?.toString(),
    };
  }).toList();
}

Future<void> markRead(
  Database db,
  String notificationId,
  String userId,
) async {
  await db.query(
    '''
    UPDATE notification_deliveries SET read_at = NOW()
    WHERE id = @id AND user_id = @userId AND read_at IS NULL
    ''',
    parameters: {'id': notificationId, 'userId': userId},
  );
}

Future<void> markAllRead(Database db, String userId) async {
  await db.query(
    '''
    UPDATE notification_deliveries SET read_at = NOW()
    WHERE user_id = @userId AND read_at IS NULL AND channel = 'in_app'
    ''',
    parameters: {'userId': userId},
  );
}

Future<int> countUnread(Database db, String userId) async {
  final result = await db.query(
    '''
    SELECT COUNT(*) as cnt FROM notification_deliveries
    WHERE user_id = @userId AND read_at IS NULL AND channel = 'in_app'
    ''',
    parameters: {'userId': userId},
  );
  return result.first.toColumnMap()['cnt'] as int? ?? 0;
}
