import 'package:shelf/shelf.dart';
import 'package:shelf_router/shelf_router.dart';
import '../auth/auth_middleware.dart' as auth;
import '../models/api_response.dart';
import '../services/personal_record_service.dart';

Router personalRecordRoutes(PersonalRecordService prService) {
  final router = Router();

  router.get('/api/v1/personal-records', (Request request) async {
    final uid = auth.userId(request);
    final exerciseId = request.url.queryParameters['exerciseId'];
    final page = int.tryParse(request.url.queryParameters['page'] ?? '') ?? 1;
    final perPage = int.tryParse(request.url.queryParameters['perPage'] ?? '') ?? 50;
    final offset = (page - 1) * perPage;

    final records = await prService.listRecords(
      uid,
      exerciseId: exerciseId,
      limit: perPage,
      offset: offset,
    );
    return jsonResponse(ApiResponse.success(data: records));
  });

  router.get('/api/v1/personal-records/history/<exerciseId>',
      (Request request, String exerciseId) async {
    final uid = auth.userId(request);
    final limit = int.tryParse(request.url.queryParameters['limit'] ?? '') ?? 30;

    final history = await prService.getExerciseHistory(
      userId: uid,
      exerciseId: exerciseId,
      limit: limit,
    );
    return jsonResponse(ApiResponse.success(data: history));
  });

  return router;
}
