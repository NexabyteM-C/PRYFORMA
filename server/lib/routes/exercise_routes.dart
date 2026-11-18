import 'package:shelf/shelf.dart';
import 'package:shelf_router/shelf_router.dart';
import '../models/api_response.dart';
import '../services/exercise_service.dart';

Router exerciseRoutes(ExerciseService exerciseService) {
  final router = Router();

  router.get('/api/v1/exercises', (Request request) async {
    final search = request.url.queryParameters['q'];
    final category = request.url.queryParameters['category'];
    final page = int.tryParse(request.url.queryParameters['page'] ?? '') ?? 1;
    final perPage = int.tryParse(request.url.queryParameters['perPage'] ?? '') ?? 50;
    final offset = (page - 1) * perPage;

    final exercises = await exerciseService.listExercises(
      search: search,
      category: category,
      limit: perPage,
      offset: offset,
    );
    final total = await exerciseService.countExercises(
      search: search,
      category: category,
    );

    return jsonResponse(ApiResponse.paginated(
      data: exercises,
      total: total,
      page: page,
      perPage: perPage,
    ));
  });

  router.get('/api/v1/exercises/<id>', (Request request, String id) async {
    final exercise = await exerciseService.getExercise(id);
    if (exercise == null) {
      return jsonResponse(ApiResponse.error(message: 'Exercise not found'), statusCode: 404);
    }
    return jsonResponse(ApiResponse.success(data: exercise));
  });

  return router;
}
