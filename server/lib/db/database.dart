import 'package:postgres/postgres.dart';
import '../config/env.dart';

class Database {
  final Pool _pool;

  Database._(this._pool);

  static Future<Database> create(Env env) async {
    final endpoint = Endpoint(
      host: env.databaseHost,
      port: env.databasePort,
      database: env.databaseName,
      username: env.databaseUser,
      password: env.databasePassword,
    );

    final pool = Pool.withEndpoints(
      [endpoint],
      settings: PoolSettings(
        maxConnectionCount: 10,
        sslMode: env.databaseSsl ? SslMode.require : SslMode.disable,
      ),
    );

    return Database._(pool);
  }

  Future<Result> query(
    String sql, {
    Map<String, dynamic>? parameters,
  }) async {
    if (parameters != null && parameters.isNotEmpty) {
      return _pool.execute(Sql.named(sql), parameters: parameters);
    }
    return _pool.execute(sql);
  }

  Future<T> transaction<T>(
    Future<T> Function(TxSession tx) action,
  ) async {
    return _pool.runTx(action);
  }

  Future<void> close() async {
    await _pool.close();
  }
}
