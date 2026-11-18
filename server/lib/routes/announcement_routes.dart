import 'package:shelf/shelf.dart';
import 'package:shelf_router/shelf_router.dart';
import '../auth/auth_middleware.dart' as auth;
import '../middleware/org_scope_middleware.dart' as org;
import '../models/api_response.dart';
import '../services/notification_service.dart';
import '../db/queries/announcement_queries.dart' as aq;
import '../db/database.dart';

Router announcementRoutes(Database db, NotificationService notificationService) {
  final router = Router();

  // Admin: create announcement
  router.post('/api/v1/organizations/<orgId>/announcements',
      (Request request, String orgId) async {
    final role = org.orgRole(request);
    if (!org.hasMinRole(role, 'coach')) {
      return jsonResponse(ApiResponse.error(message: 'Insufficient permissions'), statusCode: 403);
    }

    final uid = auth.userId(request);
    final body = await parseJsonBody(request);
    if (body == null) {
      return jsonResponse(ApiResponse.error(message: 'Invalid JSON'), statusCode: 400);
    }

    final title = body['title'] as String?;
    final announcementBody = body['body'] as String?;
    if (title == null || announcementBody == null) {
      return jsonResponse(
        ApiResponse.error(message: 'title and body are required'),
        statusCode: 400,
      );
    }

    final id = DateTime.now().microsecondsSinceEpoch.toRadixString(36);
    await db.transaction((tx) async {
      await aq.insertAnnouncement(
        tx,
        id: id,
        organizationId: orgId,
        authorId: uid,
        title: title,
        body: announcementBody,
        priority: body['priority'] as String? ?? 'normal',
        targetAudience: body['targetAudience'] as String?,
      );
    });

    await notificationService.notifyOrganizationMembers(
      organizationId: orgId,
      eventId: 'announcement_$id',
      title: title,
      body: announcementBody,
      actionUrl: '/announcements/$id',
    );

    final created = await aq.findAnnouncementById(db, id);
    return jsonResponse(ApiResponse.success(data: created), statusCode: 201);
  });

  // Admin: list org announcements
  router.get('/api/v1/organizations/<orgId>/announcements',
      (Request request, String orgId) async {
    final page = int.tryParse(request.url.queryParameters['page'] ?? '') ?? 1;
    final perPage = int.tryParse(request.url.queryParameters['perPage'] ?? '') ?? 20;
    final offset = (page - 1) * perPage;

    final announcements = await aq.listAnnouncements(db, orgId, limit: perPage, offset: offset);
    return jsonResponse(ApiResponse.success(data: announcements));
  });

  // Admin: delete announcement
  router.delete('/api/v1/organizations/<orgId>/announcements/<id>',
      (Request request, String orgId, String id) async {
    final role = org.orgRole(request);
    if (!org.hasMinRole(role, 'admin')) {
      return jsonResponse(ApiResponse.error(message: 'Insufficient permissions'), statusCode: 403);
    }

    await aq.deleteAnnouncement(db, id);
    return jsonResponse(ApiResponse.success(message: 'Deleted'));
  });

  // Athlete: list announcements from all boxes
  router.get('/api/v1/announcements', (Request request) async {
    final uid = auth.userId(request);
    final page = int.tryParse(request.url.queryParameters['page'] ?? '') ?? 1;
    final perPage = int.tryParse(request.url.queryParameters['perPage'] ?? '') ?? 20;
    final offset = (page - 1) * perPage;

    final announcements = await aq.listAthleteAnnouncements(db, uid, limit: perPage, offset: offset);
    return jsonResponse(ApiResponse.success(data: announcements));
  });

  return router;
}
