// Legacy: kept for future migration to self-hosted PostgreSQL server.
// Currently unused — the app connects to Supabase directly.
import 'dart:convert';
import 'package:http/http.dart' as http;
import '../storage/secure_storage.dart';

class ApiException implements Exception {
  final int statusCode;
  final String message;
  final dynamic details;

  const ApiException({
    required this.statusCode,
    required this.message,
    this.details,
  });

  @override
  String toString() => 'ApiException($statusCode): $message';
}

class ApiClient {
  final http.Client _client;
  final SecureStorageService _storage;
  final String _baseUrl;

  ApiClient({
    http.Client? client,
    required SecureStorageService storage,
    String? baseUrl,
  })  : _client = client ?? http.Client(),
        _storage = storage,
        _baseUrl = baseUrl ?? 'http://localhost:8080/api/v1';

  Future<Map<String, String>> _headers({bool auth = true}) async {
    final headers = <String, String>{
      'Content-Type': 'application/json',
      'Accept': 'application/json',
    };
    if (auth) {
      final token = await _storage.getAccessToken();
      if (token != null) {
        headers['Authorization'] = 'Bearer $token';
      }
    }
    return headers;
  }

  Future<Map<String, dynamic>> _handleResponse(http.Response response) async {
    final body = jsonDecode(response.body) as Map<String, dynamic>;

    if (response.statusCode == 401) {
      final refreshed = await _tryRefreshToken();
      if (refreshed) {
        throw const ApiException(
          statusCode: 401,
          message: 'Token refreshed, retry the request',
        );
      }
      await _storage.clearTokens();
      throw const ApiException(statusCode: 401, message: 'No autenticado');
    }

    if (response.statusCode >= 400) {
      final error = body['error'] as Map<String, dynamic>?;
      throw ApiException(
        statusCode: response.statusCode,
        message: error?['message'] as String? ?? 'Error desconocido',
        details: error?['details'],
      );
    }

    return body;
  }

  Future<bool> _tryRefreshToken() async {
    final refreshToken = await _storage.getRefreshToken();
    if (refreshToken == null) return false;

    try {
      final response = await _client.post(
        Uri.parse('$_baseUrl/auth/refresh'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({'refreshToken': refreshToken}),
      );

      if (response.statusCode == 200) {
        final body = jsonDecode(response.body) as Map<String, dynamic>;
        final data = body['data'] as Map<String, dynamic>;
        await _storage.saveTokens(
          accessToken: data['accessToken'] as String,
          refreshToken: data['refreshToken'] as String,
        );
        return true;
      }
    } catch (_) {}
    return false;
  }

  Future<Map<String, dynamic>> get(
    String path, {
    Map<String, String>? queryParameters,
    bool auth = true,
  }) async {
    final uri = Uri.parse('$_baseUrl$path')
        .replace(queryParameters: queryParameters);
    final response = await _client.get(uri, headers: await _headers(auth: auth));
    return _handleResponse(response);
  }

  Future<Map<String, dynamic>> post(
    String path, {
    Map<String, dynamic>? body,
    bool auth = true,
  }) async {
    final response = await _client.post(
      Uri.parse('$_baseUrl$path'),
      headers: await _headers(auth: auth),
      body: body != null ? jsonEncode(body) : null,
    );
    return _handleResponse(response);
  }

  Future<Map<String, dynamic>> put(
    String path, {
    Map<String, dynamic>? body,
    bool auth = true,
  }) async {
    final response = await _client.put(
      Uri.parse('$_baseUrl$path'),
      headers: await _headers(auth: auth),
      body: body != null ? jsonEncode(body) : null,
    );
    return _handleResponse(response);
  }

  Future<Map<String, dynamic>> delete(
    String path, {
    bool auth = true,
  }) async {
    final response = await _client.delete(
      Uri.parse('$_baseUrl$path'),
      headers: await _headers(auth: auth),
    );
    return _handleResponse(response);
  }

  void dispose() => _client.close();
}
