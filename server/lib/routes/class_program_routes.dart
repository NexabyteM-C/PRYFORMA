import 'package:shelf/shelf.dart';
import 'package:shelf_router/shelf_router.dart';
import '../auth/auth_middleware.dart' as auth;
import '../middleware/org_scope_middleware.dart' as org;
import '../models/api_response.dart';
import '../services/program_service.dart';
import '../services/publication_service.dart';

Router classProgramRoutes(
  ProgramService programService,
  PublicationService publicationService,
) {
  final router = Router();

  router.post('/api/v1/organizations/<orgId>/programs',
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

    final dateStr = body['programDate'] as String?;
    if (dateStr == null) {
      return jsonResponse(
        ApiResponse.error(message: 'programDate is required'),
        statusCode: 400,
      );
    }

    final program = await programService.createProgram(
      organizationId: orgId,
      createdBy: uid,
      programDate: DateTime.parse(dateStr),
      title: body['title'] as String?,
      description: body['description'] as String?,
      templateId: body['templateId'] as String?,
      blocks: (body['blocks'] as List?)?.cast<Map<String, dynamic>>(),
    );
    return jsonResponse(ApiResponse.success(data: program), statusCode: 201);
  });

  router.get('/api/v1/organizations/<orgId>/programs',
      (Request request, String orgId) async {
    final from = request.url.queryParameters['from'];
    final to = request.url.queryParameters['to'];
    final status = request.url.queryParameters['status'];
    final page = int.tryParse(request.url.queryParameters['page'] ?? '') ?? 1;
    final perPage = int.tryParse(request.url.queryParameters['perPage'] ?? '') ?? 30;
    final offset = (page - 1) * perPage;

    final programs = await programService.listPrograms(
      orgId,
      from: from != null ? DateTime.parse(from) : null,
      to: to != null ? DateTime.parse(to) : null,
      status: status,
      limit: perPage,
      offset: offset,
    );
    return jsonResponse(ApiResponse.success(data: programs));
  });

  router.get('/api/v1/organizations/<orgId>/programs/<programId>',
      (Request request, String orgId, String programId) async {
    final program = await programService.getProgram(programId);
    if (program == null) {
      return jsonResponse(ApiResponse.error(message: 'Not found'), statusCode: 404);
    }
    return jsonResponse(ApiResponse.success(data: program));
  });

  router.post('/api/v1/organizations/<orgId>/programs/<programId>/publish',
      (Request request, String orgId, String programId) async {
    final role = org.orgRole(request);
    if (!org.hasMinRole(role, 'coach')) {
      return jsonResponse(ApiResponse.error(message: 'Insufficient permissions'), statusCode: 403);
    }

    final body = await parseJsonBody(request);
    final scheduleAt = body?['scheduleAt'] as String?;

    if (scheduleAt != null) {
      await publicationService.schedulePublication(
        programId: programId,
        publishAt: DateTime.parse(scheduleAt),
      );
    } else {
      await publicationService.publishNow(programId);
    }

    final updated = await programService.getProgram(programId);
    return jsonResponse(ApiResponse.success(data: updated));
  });

  router.post('/api/v1/organizations/<orgId>/programs/<programId>/cancel',
      (Request request, String orgId, String programId) async {
    final role = org.orgRole(request);
    if (!org.hasMinRole(role, 'coach')) {
      return jsonResponse(ApiResponse.error(message: 'Insufficient permissions'), statusCode: 403);
    }

    await programService.cancel(programId);
    return jsonResponse(ApiResponse.success(message: 'Program cancelled'));
  });

  router.delete('/api/v1/organizations/<orgId>/programs/<programId>',
      (Request request, String orgId, String programId) async {
    final role = org.orgRole(request);
    if (!org.hasMinRole(role, 'coach')) {
      return jsonResponse(ApiResponse.error(message: 'Insufficient permissions'), statusCode: 403);
    }

    await programService.deleteDraft(programId);
    return jsonResponse(ApiResponse.success(message: 'Draft deleted'));
  });

  return router;
}
