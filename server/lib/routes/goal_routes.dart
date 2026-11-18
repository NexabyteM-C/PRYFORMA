import 'package:shelf/shelf.dart';
import 'package:shelf_router/shelf_router.dart';
import '../auth/auth_middleware.dart' as auth;
import '../models/api_response.dart';
import '../services/goal_service.dart';

Router goalRoutes(GoalService goalService) {
  final router = Router();

  router.post('/api/v1/goals', (Request request) async {
    final uid = auth.userId(request);
    final body = await parseJsonBody(request);
    if (body == null) {
      return jsonResponse(ApiResponse.error(message: 'Invalid JSON'), statusCode: 400);
    }

    final exerciseId = body['exerciseId'] as String?;
    final metric = body['metric'] as String?;
    final targetValue = (body['targetValue'] as num?)?.toDouble();
    if (exerciseId == null || metric == null || targetValue == null) {
      return jsonResponse(
        ApiResponse.error(message: 'exerciseId, metric, and targetValue are required'),
        statusCode: 400,
      );
    }

    final goal = await goalService.createGoal(
      userId: uid,
      exerciseId: exerciseId,
      metric: metric,
      targetValue: targetValue,
      deadline: body['deadline'] != null ? DateTime.parse(body['deadline'] as String) : null,
    );
    return jsonResponse(ApiResponse.success(data: goal), statusCode: 201);
  });

  router.get('/api/v1/goals', (Request request) async {
    final uid = auth.userId(request);
    final status = request.url.queryParameters['status'];
    final page = int.tryParse(request.url.queryParameters['page'] ?? '') ?? 1;
    final perPage = int.tryParse(request.url.queryParameters['perPage'] ?? '') ?? 20;
    final offset = (page - 1) * perPage;

    final goals = await goalService.listGoals(
      uid,
      status: status,
      limit: perPage,
      offset: offset,
    );
    return jsonResponse(ApiResponse.success(data: goals));
  });

  router.get('/api/v1/goals/<id>', (Request request, String id) async {
    final uid = auth.userId(request);
    final goal = await goalService.getGoal(id, uid);
    if (goal == null) {
      return jsonResponse(ApiResponse.error(message: 'Not found'), statusCode: 404);
    }

    final milestones = await goalService.listMilestones(id);
    goal['milestones'] = milestones;
    return jsonResponse(ApiResponse.success(data: goal));
  });

  router.put('/api/v1/goals/<id>', (Request request, String id) async {
    final uid = auth.userId(request);
    final body = await parseJsonBody(request);
    if (body == null) {
      return jsonResponse(ApiResponse.error(message: 'Invalid JSON'), statusCode: 400);
    }

    await goalService.updateGoal(
      goalId: id,
      userId: uid,
      targetValue: (body['targetValue'] as num?)?.toDouble(),
      currentValue: (body['currentValue'] as num?)?.toDouble(),
      status: body['status'] as String?,
      deadline: body['deadline'] != null ? DateTime.parse(body['deadline'] as String) : null,
    );

    final updated = await goalService.getGoal(id, uid);
    return jsonResponse(ApiResponse.success(data: updated));
  });

  router.post('/api/v1/goals/<id>/milestones', (Request request, String id) async {
    final body = await parseJsonBody(request);
    if (body == null) {
      return jsonResponse(ApiResponse.error(message: 'Invalid JSON'), statusCode: 400);
    }

    final value = (body['value'] as num?)?.toDouble();
    if (value == null) {
      return jsonResponse(ApiResponse.error(message: 'value is required'), statusCode: 400);
    }

    final milestone = await goalService.addMilestone(
      goalId: id,
      value: value,
      note: body['note'] as String?,
    );
    return jsonResponse(ApiResponse.success(data: milestone), statusCode: 201);
  });

  return router;
}
