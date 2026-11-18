import 'dart:convert';
import 'package:shelf/shelf.dart';

class ApiResponse {
  final Map<String, dynamic> _body;

  ApiResponse._(this._body);

  factory ApiResponse.success({dynamic data, String? message}) {
    return ApiResponse._({
      'ok': true,
      if (data != null) 'data': data,
      if (message != null) 'message': message,
    });
  }

  factory ApiResponse.error({
    required String message,
    int? code,
    dynamic details,
  }) {
    return ApiResponse._({
      'ok': false,
      'error': {
        'message': message,
        if (code != null) 'code': code,
        if (details != null) 'details': details,
      },
    });
  }

  factory ApiResponse.paginated({
    required List<dynamic> data,
    required int total,
    required int page,
    required int perPage,
  }) {
    return ApiResponse._({
      'ok': true,
      'data': data,
      'pagination': {
        'total': total,
        'page': page,
        'perPage': perPage,
        'totalPages': (total / perPage).ceil(),
      },
    });
  }

  Map<String, dynamic> toJson() => _body;
}

Response jsonResponse(ApiResponse response, {int statusCode = 200}) {
  return Response(
    statusCode,
    body: jsonEncode(response.toJson()),
    headers: {'content-type': 'application/json'},
  );
}

Future<Map<String, dynamic>?> parseJsonBody(Request request) async {
  try {
    final body = await request.readAsString();
    if (body.isEmpty) return null;
    return jsonDecode(body) as Map<String, dynamic>;
  } catch (_) {
    return null;
  }
}
