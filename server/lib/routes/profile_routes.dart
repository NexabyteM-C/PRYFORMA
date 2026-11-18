import 'package:shelf/shelf.dart';
import 'package:shelf_router/shelf_router.dart';
import '../auth/auth_middleware.dart' as auth;
import '../models/api_response.dart';
import '../services/profile_service.dart';

Router profileRoutes(ProfileService profileService) {
  final router = Router();

  router.get('/api/v1/profile/me', (Request request) async {
    final uid = auth.userId(request);
    final profile = await profileService.getProfile(uid);
    if (profile == null) {
      return jsonResponse(
        ApiResponse.error(message: 'Profile not found'),
        statusCode: 404,
      );
    }
    return jsonResponse(ApiResponse.success(data: profile));
  });

  router.put('/api/v1/profile/me', (Request request) async {
    final uid = auth.userId(request);
    final body = await parseJsonBody(request);
    if (body == null) {
      return jsonResponse(
        ApiResponse.error(message: 'Invalid JSON body'),
        statusCode: 400,
      );
    }

    await profileService.updateProfile(
      uid,
      displayName: body['displayName'] as String?,
      avatarUrl: body['avatarUrl'] as String?,
    );

    final updated = await profileService.getProfile(uid);
    return jsonResponse(ApiResponse.success(data: updated));
  });

  router.put('/api/v1/profile/me/athlete', (Request request) async {
    final uid = auth.userId(request);
    final body = await parseJsonBody(request);
    if (body == null) {
      return jsonResponse(
        ApiResponse.error(message: 'Invalid JSON body'),
        statusCode: 400,
      );
    }

    await profileService.upsertAthleteProfile(
      uid,
      preferredUnit: body['preferredUnit'] as String?,
      experienceLevel: body['experienceLevel'] as String?,
      primarySport: body['primarySport'] as String?,
    );

    final updated = await profileService.getProfile(uid);
    return jsonResponse(ApiResponse.success(data: updated));
  });

  return router;
}
