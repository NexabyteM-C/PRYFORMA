import 'package:shelf/shelf.dart';
import 'package:shelf_router/shelf_router.dart';
import '../auth/auth_middleware.dart' as auth;
import '../middleware/org_scope_middleware.dart' as org;
import '../models/api_response.dart';
import '../services/class_session_service.dart';
import '../services/workout_service.dart';

Router classSessionRoutes(
  ClassSessionService sessionService,
  WorkoutService workoutService,
) {
  final router = Router();

  // Admin: list sessions for org by date range
  router.get('/api/v1/organizations/<orgId>/sessions',
      (Request request, String orgId) async {
    final from = request.url.queryParameters['from'];
    final to = request.url.queryParameters['to'];
    if (from == null || to == null) {
      return jsonResponse(
        ApiResponse.error(message: 'from and to query params are required'),
        statusCode: 400,
      );
    }

    final sessions = await sessionService.listByDateRange(
      organizationId: orgId,
      from: DateTime.parse(from),
      to: DateTime.parse(to),
    );
    return jsonResponse(ApiResponse.success(data: sessions));
  });

  // Admin: create session
  router.post('/api/v1/organizations/<orgId>/sessions',
      (Request request, String orgId) async {
    final role = org.orgRole(request);
    if (!org.hasMinRole(role, 'coach')) {
      return jsonResponse(ApiResponse.error(message: 'Insufficient permissions'), statusCode: 403);
    }

    final body = await parseJsonBody(request);
    if (body == null) {
      return jsonResponse(ApiResponse.error(message: 'Invalid JSON'), statusCode: 400);
    }

    final programId = body['programId'] as String?;
    final locationId = body['locationId'] as String?;
    final startsAt = body['startsAt'] as String?;
    final endsAt = body['endsAt'] as String?;
    if (programId == null || locationId == null || startsAt == null || endsAt == null) {
      return jsonResponse(
        ApiResponse.error(message: 'programId, locationId, startsAt, endsAt are required'),
        statusCode: 400,
      );
    }

    final session = await sessionService.createSession(
      programId: programId,
      organizationId: orgId,
      locationId: locationId,
      startsAt: DateTime.parse(startsAt),
      endsAt: DateTime.parse(endsAt),
      capacity: body['capacity'] as int? ?? 20,
    );
    return jsonResponse(ApiResponse.success(data: session), statusCode: 201);
  });

  // Athlete: calendar across all boxes
  router.get('/api/v1/classes/calendar', (Request request) async {
    final uid = auth.userId(request);
    final from = request.url.queryParameters['from'];
    final to = request.url.queryParameters['to'];
    if (from == null || to == null) {
      return jsonResponse(
        ApiResponse.error(message: 'from and to are required'),
        statusCode: 400,
      );
    }

    final sessions = await sessionService.athleteCalendar(
      userId: uid,
      from: DateTime.parse(from),
      to: DateTime.parse(to),
    );
    return jsonResponse(ApiResponse.success(data: sessions));
  });

  // Athlete: session detail with personalized loads
  router.get('/api/v1/classes/<sessionId>', (Request request, String sessionId) async {
    final uid = auth.userId(request);
    final session = await sessionService.getSessionWithPersonalizedLoads(
      sessionId: sessionId,
      userId: uid,
    );
    if (session == null) {
      return jsonResponse(ApiResponse.error(message: 'Not found'), statusCode: 404);
    }
    return jsonResponse(ApiResponse.success(data: session));
  });

  // Athlete: register for a session
  router.post('/api/v1/classes/<sessionId>/register',
      (Request request, String sessionId) async {
    final uid = auth.userId(request);
    await sessionService.registerAttendee(sessionId: sessionId, userId: uid);
    return jsonResponse(ApiResponse.success(message: 'Registered'));
  });

  // Athlete: cancel registration
  router.delete('/api/v1/classes/<sessionId>/register',
      (Request request, String sessionId) async {
    final uid = auth.userId(request);
    await sessionService.cancelAttendee(sessionId: sessionId, userId: uid);
    return jsonResponse(ApiResponse.success(message: 'Cancelled'));
  });

  // Athlete: record results from a class session
  router.post('/api/v1/classes/<sessionId>/results',
      (Request request, String sessionId) async {
    final uid = auth.userId(request);
    final body = await parseJsonBody(request);
    if (body == null) {
      return jsonResponse(ApiResponse.error(message: 'Invalid JSON'), statusCode: 400);
    }

    final exercises = (body['exercises'] as List?)?.cast<Map<String, dynamic>>();
    if (exercises == null || exercises.isEmpty) {
      return jsonResponse(
        ApiResponse.error(message: 'exercises are required'),
        statusCode: 400,
      );
    }

    final session = await sessionService.getSession(sessionId);
    if (session == null) {
      return jsonResponse(ApiResponse.error(message: 'Session not found'), statusCode: 404);
    }

    final workout = await workoutService.createWorkout(
      userId: uid,
      organizationId: session['organizationId'] as String?,
      classSessionId: sessionId,
      startedAt: DateTime.now().toUtc(),
      exercises: exercises,
    );

    return jsonResponse(ApiResponse.success(data: workout), statusCode: 201);
  });

  // Admin: assign coach
  router.post('/api/v1/organizations/<orgId>/sessions/<sessionId>/coaches',
      (Request request, String orgId, String sessionId) async {
    final role = org.orgRole(request);
    if (!org.hasMinRole(role, 'admin')) {
      return jsonResponse(ApiResponse.error(message: 'Insufficient permissions'), statusCode: 403);
    }

    final body = await parseJsonBody(request);
    final coachId = body?['coachId'] as String?;
    if (coachId == null) {
      return jsonResponse(ApiResponse.error(message: 'coachId is required'), statusCode: 400);
    }

    await sessionService.assignCoach(sessionId: sessionId, coachId: coachId);
    return jsonResponse(ApiResponse.success(message: 'Coach assigned'));
  });

  return router;
}
