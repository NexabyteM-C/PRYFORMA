import 'package:shelf/shelf.dart';
import '../config/env.dart';

Middleware corsMiddleware(Env env) {
  final allowedOrigins = env.corsAllowedOrigins;

  return (Handler innerHandler) {
    return (Request request) async {
      final origin = request.headers['origin'] ?? '';
      final isAllowed =
          allowedOrigins.contains('*') || allowedOrigins.contains(origin);
      final allowOrigin = isAllowed ? origin : '';

      if (request.method == 'OPTIONS') {
        return Response(204, headers: {
          'Access-Control-Allow-Origin': allowOrigin,
          'Access-Control-Allow-Methods': 'GET, POST, PUT, PATCH, DELETE, OPTIONS',
          'Access-Control-Allow-Headers':
              'Origin, Content-Type, Accept, Authorization',
          'Access-Control-Allow-Credentials': 'true',
          'Access-Control-Max-Age': '86400',
        });
      }

      final response = await innerHandler(request);
      return response.change(headers: {
        'Access-Control-Allow-Origin': allowOrigin,
        'Access-Control-Allow-Credentials': 'true',
      });
    };
  };
}
