import 'dart:convert';
import 'package:shelf/shelf.dart';

Middleware rateLimitMiddleware({
  int maxRequests = 100,
  Duration window = const Duration(minutes: 1),
}) {
  final buckets = <String, _Bucket>{};

  return (Handler innerHandler) {
    return (Request request) {
      final ip = request.headers['x-forwarded-for']?.split(',').first.trim() ??
          request.headers['x-real-ip'] ??
          'unknown';

      final now = DateTime.now();
      final bucket = buckets.putIfAbsent(ip, () => _Bucket(now));

      if (now.difference(bucket.windowStart) > window) {
        bucket.windowStart = now;
        bucket.count = 0;
      }

      bucket.count++;

      if (bucket.count > maxRequests) {
        return Response(
          429,
          body: jsonEncode({
            'ok': false,
            'error': {'message': 'Too many requests'},
          }),
          headers: {'content-type': 'application/json'},
        );
      }

      return innerHandler(request);
    };
  };
}

class _Bucket {
  DateTime windowStart;
  int count = 0;
  _Bucket(this.windowStart);
}
