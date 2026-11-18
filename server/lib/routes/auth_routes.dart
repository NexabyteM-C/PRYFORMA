import 'package:shelf/shelf.dart';
import 'package:shelf_router/shelf_router.dart';
import '../models/api_response.dart';
import '../services/auth_service.dart';

Router authRoutes(AuthService authService) {
  final router = Router();

  router.post('/api/v1/auth/register', (Request request) async {
    final body = await parseJsonBody(request);
    if (body == null) {
      return jsonResponse(
        ApiResponse.error(message: 'Invalid JSON body'),
        statusCode: 400,
      );
    }

    final email = body['email'] as String?;
    final password = body['password'] as String?;
    final displayName = body['displayName'] as String?;

    if (email == null || email.isEmpty) {
      return jsonResponse(
        ApiResponse.error(message: 'Email is required'),
        statusCode: 400,
      );
    }
    if (!RegExp(r'^[^@\s]+@[^@\s]+\.[^@\s]+$').hasMatch(email)) {
      return jsonResponse(
        ApiResponse.error(message: 'Invalid email format'),
        statusCode: 400,
      );
    }
    if (password == null || password.length < 8) {
      return jsonResponse(
        ApiResponse.error(message: 'Password must be at least 8 characters'),
        statusCode: 400,
      );
    }
    if (displayName == null || displayName.isEmpty) {
      return jsonResponse(
        ApiResponse.error(message: 'Display name is required'),
        statusCode: 400,
      );
    }

    try {
      final result = await authService.register(email, password, displayName);
      return jsonResponse(
        ApiResponse.success(data: result.toJson()),
        statusCode: 201,
      );
    } on AuthException catch (e) {
      return jsonResponse(
        ApiResponse.error(message: e.message),
        statusCode: 409,
      );
    }
  });

  router.post('/api/v1/auth/login', (Request request) async {
    final body = await parseJsonBody(request);
    if (body == null) {
      return jsonResponse(
        ApiResponse.error(message: 'Invalid JSON body'),
        statusCode: 400,
      );
    }

    final email = body['email'] as String?;
    final password = body['password'] as String?;

    if (email == null || email.isEmpty || password == null || password.isEmpty) {
      return jsonResponse(
        ApiResponse.error(message: 'Email and password are required'),
        statusCode: 400,
      );
    }

    try {
      final result = await authService.login(email, password);
      return jsonResponse(ApiResponse.success(data: result.toJson()));
    } on AuthException catch (e) {
      return jsonResponse(
        ApiResponse.error(message: e.message),
        statusCode: 401,
      );
    }
  });

  router.post('/api/v1/auth/refresh', (Request request) async {
    final body = await parseJsonBody(request);
    if (body == null) {
      return jsonResponse(
        ApiResponse.error(message: 'Invalid JSON body'),
        statusCode: 400,
      );
    }

    final refreshToken = body['refreshToken'] as String?;
    if (refreshToken == null || refreshToken.isEmpty) {
      return jsonResponse(
        ApiResponse.error(message: 'Refresh token is required'),
        statusCode: 400,
      );
    }

    try {
      final tokens = await authService.refreshTokens(refreshToken);
      return jsonResponse(ApiResponse.success(data: tokens.toJson()));
    } on AuthException catch (e) {
      return jsonResponse(
        ApiResponse.error(message: e.message),
        statusCode: 401,
      );
    }
  });

  return router;
}
