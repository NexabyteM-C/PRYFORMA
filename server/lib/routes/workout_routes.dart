import 'package:shelf/shelf.dart';
import 'package:shelf_router/shelf_router.dart';
import '../auth/auth_middleware.dart' as auth;
import '../models/api_response.dart';
import '../services/workout_service.dart';

Router workoutRoutes(WorkoutService workoutService) {
  final router = Router();

  router.post('/api/v1/workouts', (Request request) async {
    final uid = auth.userId(request);
    final body = await parseJsonBody(request);
    if (body == null) {
      return jsonResponse(ApiResponse.error(message: 'Invalid JSON'), statusCode: 400);
    }

    final exercises = (body['exercises'] as List?)?.cast<Map<String, dynamic>>();
    if (exercises == null || exercises.isEmpty) {
      return jsonResponse(
        ApiResponse.error(message: 'At least one exercise is required'),
        statusCode: 400,
      );
    }

    final startedAtStr = body['startedAt'] as String?;
    if (startedAtStr == null) {
      return jsonResponse(
        ApiResponse.error(message: 'startedAt is required'),
        statusCode: 400,
      );
    }

    final workout = await workoutService.createWorkout(
      userId: uid,
      organizationId: body['organizationId'] as String?,
      classSessionId: body['classSessionId'] as String?,
      clientId: body['clientId'] as String?,
      notes: body['notes'] as String?,
      startedAt: DateTime.parse(startedAtStr),
      finishedAt: body['finishedAt'] != null
          ? DateTime.parse(body['finishedAt'] as String)
          : null,
      exercises: exercises,
    );

    return jsonResponse(ApiResponse.success(data: workout), statusCode: 201);
  });

  router.get('/api/v1/workouts', (Request request) async {
    final uid = auth.userId(request);
    final orgId = request.url.queryParameters['organizationId'];
    final page = int.tryParse(request.url.queryParameters['page'] ?? '') ?? 1;
    final perPage = int.tryParse(request.url.queryParameters['perPage'] ?? '') ?? 20;
    final offset = (page - 1) * perPage;

    final workouts = await workoutService.listWorkouts(
      uid,
      organizationId: orgId,
      limit: perPage,
      offset: offset,
    );
    final total = await workoutService.countWorkouts(uid, organizationId: orgId);

    return jsonResponse(ApiResponse.paginated(
      data: workouts,
      total: total,
      page: page,
      perPage: perPage,
    ));
  });

  router.get('/api/v1/workouts/<id>', (Request request, String id) async {
    final uid = auth.userId(request);
    final workout = await workoutService.getWorkout(id, uid);
    if (workout == null) {
      return jsonResponse(ApiResponse.error(message: 'Not found'), statusCode: 404);
    }
    return jsonResponse(ApiResponse.success(data: workout));
  });

  return router;
}
