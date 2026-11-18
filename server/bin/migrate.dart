import 'dart:io';
import 'package:fitness_server/config/env.dart';
import 'package:fitness_server/db/database.dart';
import 'package:fitness_server/db/migration_runner.dart';

Future<void> main(List<String> args) async {
  print('Loading configuration...');
  final env = Env.load(path: '.env');

  print('Connecting to database ${env.databaseName}@${env.databaseHost}:${env.databasePort}...');
  final db = await Database.create(env);

  try {
    final scriptDir = Platform.script.resolve('../sql/migrations').toFilePath();
    print('Running migrations from: $scriptDir');
    final runner = MigrationRunner(db);
    await runner.migrate(scriptDir);
    print('Done.');
  } finally {
    await db.close();
  }
}
