import 'package:shelf/shelf.dart';
import 'package:shelf_router/shelf_router.dart';
import '../auth/auth_middleware.dart' as auth;
import '../models/api_response.dart';
import '../services/notification_service.dart';

Router notificationRoutes(NotificationService notificationService) {
  final router = Router();

  router.get('/api/v1/notifications', (Request request) async {
    final uid = auth.userId(request);
    final unreadOnly = request.url.queryParameters['unreadOnly'] == 'true';
    final page = int.tryParse(request.url.queryParameters['page'] ?? '') ?? 1;
    final perPage = int.tryParse(request.url.queryParameters['perPage'] ?? '') ?? 30;
    final offset = (page - 1) * perPage;

    final notifications = await notificationService.listNotifications(
      uid,
      unreadOnly: unreadOnly ? true : null,
      limit: perPage,
      offset: offset,
    );
    final unreadCount = await notificationService.countUnread(uid);

    return jsonResponse(ApiResponse.success(data: {
      'items': notifications,
      'unreadCount': unreadCount,
    }));
  });

  router.put('/api/v1/notifications/<id>/read',
      (Request request, String id) async {
    final uid = auth.userId(request);
    await notificationService.markRead(id, uid);
    return jsonResponse(ApiResponse.success(message: 'Marked as read'));
  });

  router.put('/api/v1/notifications/read-all', (Request request) async {
    final uid = auth.userId(request);
    await notificationService.markAllRead(uid);
    return jsonResponse(ApiResponse.success(message: 'All marked as read'));
  });

  return router;
}
