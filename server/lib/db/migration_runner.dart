import 'dart:io';
import 'package:postgres/postgres.dart';
import 'database.dart';

class MigrationRunner {
  final Database _db;

  MigrationRunner(this._db);

  Future<void> _ensureMigrationsTable() async {
    await _db.query('''
      CREATE TABLE IF NOT EXISTS _schema_migrations (
        version TEXT PRIMARY KEY,
        applied_at TIMESTAMPTZ NOT NULL DEFAULT NOW()
      )
    ''');
  }

  Future<Set<String>> _appliedVersions() async {
    final result = await _db.query(
      'SELECT version FROM _schema_migrations ORDER BY version',
    );
    return result.map((row) => row[0] as String).toSet();
  }

  Future<void> migrate(String migrationsDir) async {
    await _ensureMigrationsTable();
    final applied = await _appliedVersions();

    final dir = Directory(migrationsDir);
    if (!dir.existsSync()) {
      print('Migrations directory not found: $migrationsDir');
      return;
    }

    final files = dir
        .listSync()
        .whereType<File>()
        .where((f) => f.path.endsWith('.sql'))
        .toList()
      ..sort((a, b) => a.uri.pathSegments.last.compareTo(b.uri.pathSegments.last));

    var count = 0;
    for (final file in files) {
      final version = file.uri.pathSegments.last;
      if (applied.contains(version)) continue;

      print('  Applying: $version');
      final sql = file.readAsStringSync();

      await _db.transaction((tx) async {
        await tx.execute(sql);
        await tx.execute(
          Sql.named(
            'INSERT INTO _schema_migrations (version) VALUES (@version)',
          ),
          parameters: {'version': version},
        );
      });
      count++;
    }

    if (count == 0) {
      print('  Database is up to date.');
    } else {
      print('  Applied $count migration(s).');
    }
  }
}
