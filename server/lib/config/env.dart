import 'dart:io';
import 'package:dotenv/dotenv.dart';

class Env {
  final DotEnv _dotEnv;

  Env._(this._dotEnv);

  factory Env.load({String path = '.env'}) {
    final dotEnv = DotEnv();
    if (File(path).existsSync()) {
      dotEnv.load([path]);
    }
    return Env._(dotEnv);
  }

  String _get(String key, {String? fallback}) {
    return _dotEnv[key] ??
        Platform.environment[key] ??
        fallback ??
        (throw StateError('Missing environment variable: $key'));
  }

  String get databaseHost => _get('DATABASE_HOST', fallback: 'localhost');
  int get databasePort =>
      int.parse(_get('DATABASE_PORT', fallback: '5432'));
  String get databaseName =>
      _get('DATABASE_NAME', fallback: 'fitness_platform');
  String get databaseUser => _get('DATABASE_USER', fallback: 'postgres');
  String get databasePassword => _get('DATABASE_PASSWORD', fallback: '');
  bool get databaseSsl =>
      _get('DATABASE_SSL', fallback: 'false').toLowerCase() == 'true';

  String get jwtSecret => _get('JWT_SECRET');
  int get jwtAccessExpiryMinutes =>
      int.parse(_get('JWT_ACCESS_EXPIRY_MINUTES', fallback: '60'));
  int get jwtRefreshExpiryDays =>
      int.parse(_get('JWT_REFRESH_EXPIRY_DAYS', fallback: '30'));

  int get serverPort =>
      int.parse(_get('SERVER_PORT', fallback: '8080'));

  List<String> get corsAllowedOrigins =>
      _get('CORS_ALLOWED_ORIGINS', fallback: '*')
          .split(',')
          .map((s) => s.trim())
          .where((s) => s.isNotEmpty)
          .toList();

  String get fcmServerKey => _get('FCM_SERVER_KEY', fallback: '');
}
