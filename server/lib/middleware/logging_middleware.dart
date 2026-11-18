import 'package:shelf/shelf.dart';

Middleware loggingMiddleware() {
  return (Handler innerHandler) {
    return (Request request) async {
      final stopwatch = Stopwatch()..start();
      final response = await innerHandler(request);
      stopwatch.stop();

      final timestamp =
          DateTime.now().toIso8601String().substring(0, 19).replaceFirst('T', ' ');
      final path = '/${request.url.path}';
      print(
        '[$timestamp] ${request.method} $path → ${response.statusCode} (${stopwatch.elapsedMilliseconds}ms)',
      );

      return response;
    };
  };
}
