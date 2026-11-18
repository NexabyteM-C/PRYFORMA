import 'dart:convert';
import 'package:shelf/shelf.dart';
import 'jwt_service.dart';

const _contextKeyUserId = 'auth.userId';

const _publicPaths = {
  '/api/v1/auth/register',
  '/api/v1/auth/login',
  '/api/v1/auth/refresh',
  '/api/v1/auth/forgot-password',
  '/api/v1/auth/reset-password',
  '/api/v1/health',
};

Middleware authMiddleware(JwtService jwtService) {
  return (Handler innerHandler) {
    return (Request request) {
      if (request.method == 'OPTIONS') return innerHandler(request);

      final path = '/${request.url.path}';
      if (_publicPaths.contains(path)) return innerHandler(request);

      final authHeader = request.headers['authorization'];
      if (authHeader == null || !authHeader.startsWith('Bearer ')) {
        return Response(
          401,
          body: jsonEncode({
            'ok': false,
            'error': {'message': 'Missing or invalid authorization header'},
          }),
          headers: {'content-type': 'application/json'},
        );
      }

      final token = authHeader.substring(7);
      final payload = jwtService.verifyAccessToken(token);
      if (payload == null) {
        return Response(
          401,
          body: jsonEncode({
            'ok': false,
            'error': {'message': 'Invalid or expired token'},
          }),
          headers: {'content-type': 'application/json'},
        );
      }

      final updatedRequest = request.change(
        context: {_contextKeyUserId: payload.userId},
      );
      return innerHandler(updatedRequest);
    };
  };
}

String userId(Request request) {
  final id = request.context[_contextKeyUserId] as String?;
  if (id == null) {
    throw StateError('userId not found in request context — auth middleware missing');
  }
  return id;
}
