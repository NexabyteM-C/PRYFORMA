import 'package:shelf/shelf.dart';
import 'package:shelf_router/shelf_router.dart';
import '../auth/auth_middleware.dart' as auth;
import '../middleware/org_scope_middleware.dart' as org;
import '../models/api_response.dart';
import '../services/organization_service.dart';

Router organizationRoutes(OrganizationService orgService) {
  final router = Router();

  router.post('/api/v1/organizations', (Request request) async {
    final uid = auth.userId(request);
    final body = await parseJsonBody(request);
    if (body == null) {
      return jsonResponse(ApiResponse.error(message: 'Invalid JSON'), statusCode: 400);
    }

    final name = body['name'] as String?;
    final slug = body['slug'] as String?;
    final locationName = body['locationName'] as String?;
    if (name == null || slug == null || locationName == null) {
      return jsonResponse(
        ApiResponse.error(message: 'name, slug, and locationName are required'),
        statusCode: 400,
      );
    }

    try {
      final org = await orgService.createOrganization(
        ownerId: uid,
        name: name,
        slug: slug,
        description: body['description'] as String?,
        logoUrl: body['logoUrl'] as String?,
        locationName: locationName,
        locationAddress: body['locationAddress'] as String?,
        timezone: body['timezone'] as String? ?? 'America/Bogota',
      );
      return jsonResponse(ApiResponse.success(data: org), statusCode: 201);
    } on OrganizationException catch (e) {
      return jsonResponse(ApiResponse.error(message: e.message), statusCode: 409);
    }
  });

  router.get('/api/v1/organizations', (Request request) async {
    final uid = auth.userId(request);
    final orgs = await orgService.listUserOrganizations(uid);
    return jsonResponse(ApiResponse.success(data: orgs));
  });

  router.get('/api/v1/organizations/<orgId>', (Request request, String orgId) async {
    final data = await orgService.getOrganization(orgId);
    if (data == null) {
      return jsonResponse(ApiResponse.error(message: 'Not found'), statusCode: 404);
    }
    return jsonResponse(ApiResponse.success(data: data));
  });

  router.get('/api/v1/organizations/<orgId>/members', (Request request, String orgId) async {
    final page = int.tryParse(request.url.queryParameters['page'] ?? '') ?? 1;
    final perPage = int.tryParse(request.url.queryParameters['perPage'] ?? '') ?? 50;
    final offset = (page - 1) * perPage;

    final members = await orgService.listMembers(orgId, limit: perPage, offset: offset);
    final total = await orgService.countMembers(orgId);
    return jsonResponse(ApiResponse.paginated(
      data: members,
      total: total,
      page: page,
      perPage: perPage,
    ));
  });

  router.put('/api/v1/organizations/<orgId>/members/<userId>/role',
      (Request request, String orgId, String userId) async {
    final role = org.orgRole(request);
    if (!org.hasMinRole(role, 'admin')) {
      return jsonResponse(ApiResponse.error(message: 'Insufficient permissions'), statusCode: 403);
    }

    final body = await parseJsonBody(request);
    final newRole = body?['role'] as String?;
    if (newRole == null) {
      return jsonResponse(ApiResponse.error(message: 'role is required'), statusCode: 400);
    }

    await orgService.updateMemberRole(orgId: orgId, userId: userId, role: newRole);
    return jsonResponse(ApiResponse.success(message: 'Role updated'));
  });

  router.delete('/api/v1/organizations/<orgId>/members/<userId>',
      (Request request, String orgId, String userId) async {
    final role = org.orgRole(request);
    final callerId = auth.userId(request);
    if (callerId != userId && !org.hasMinRole(role, 'admin')) {
      return jsonResponse(ApiResponse.error(message: 'Insufficient permissions'), statusCode: 403);
    }
    await orgService.removeMember(orgId: orgId, userId: userId);
    return jsonResponse(ApiResponse.success(message: 'Member removed'));
  });

  router.post('/api/v1/organizations/<orgId>/invitations',
      (Request request, String orgId) async {
    final role = org.orgRole(request);
    if (!org.hasMinRole(role, 'admin')) {
      return jsonResponse(ApiResponse.error(message: 'Insufficient permissions'), statusCode: 403);
    }

    final body = await parseJsonBody(request);
    final email = body?['email'] as String?;
    final inviteRole = body?['role'] as String? ?? 'athlete';
    if (email == null) {
      return jsonResponse(ApiResponse.error(message: 'email is required'), statusCode: 400);
    }

    final uid = auth.userId(request);
    final token = await orgService.createInvitation(
      orgId: orgId,
      email: email,
      role: inviteRole,
      invitedBy: uid,
    );
    return jsonResponse(
      ApiResponse.success(data: {'token': token}),
      statusCode: 201,
    );
  });

  router.post('/api/v1/invitations/accept', (Request request) async {
    final body = await parseJsonBody(request);
    final token = body?['token'] as String?;
    if (token == null) {
      return jsonResponse(ApiResponse.error(message: 'token is required'), statusCode: 400);
    }

    final uid = auth.userId(request);
    try {
      await orgService.acceptInvitation(token: token, userId: uid);
      return jsonResponse(ApiResponse.success(message: 'Invitation accepted'));
    } on OrganizationException catch (e) {
      return jsonResponse(ApiResponse.error(message: e.message), statusCode: 400);
    }
  });

  router.get('/api/v1/organizations/<orgId>/locations',
      (Request request, String orgId) async {
    final locations = await orgService.listLocations(orgId);
    return jsonResponse(ApiResponse.success(data: locations));
  });

  return router;
}
