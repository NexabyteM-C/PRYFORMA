import 'package:postgres/postgres.dart';
import '../database.dart';

Future<void> insertProfile(
  TxSession tx, {
  required String id,
  required String email,
  required String passwordHash,
  required String displayName,
}) async {
  await tx.execute(
    Sql.named('''
      INSERT INTO profiles (id, email, password_hash, display_name)
      VALUES (@id, @email, @passwordHash, @displayName)
    '''),
    parameters: {
      'id': id,
      'email': email,
      'passwordHash': passwordHash,
      'displayName': displayName,
    },
  );
}

Future<Map<String, dynamic>?> findProfileByEmail(
  Database db,
  String email,
) async {
  final result = await db.query(
    'SELECT id, email, password_hash, display_name, avatar_url, '
    'email_verified_at, created_at, updated_at '
    'FROM profiles WHERE email = @email',
    parameters: {'email': email},
  );
  if (result.isEmpty) return null;
  return _rowToMap(result.first);
}

Future<Map<String, dynamic>?> findProfileById(
  Database db,
  String id,
) async {
  final result = await db.query(
    'SELECT id, email, password_hash, display_name, avatar_url, '
    'email_verified_at, created_at, updated_at '
    'FROM profiles WHERE id = @id',
    parameters: {'id': id},
  );
  if (result.isEmpty) return null;
  return _rowToMap(result.first);
}

Map<String, dynamic> _rowToMap(ResultRow row) {
  final schema = row.toColumnMap();
  return {
    'id': schema['id']?.toString(),
    'email': schema['email'] as String?,
    'password_hash': schema['password_hash'] as String?,
    'display_name': schema['display_name'] as String?,
    'avatar_url': schema['avatar_url'] as String?,
    'email_verified_at': schema['email_verified_at']?.toString(),
    'created_at': schema['created_at']?.toString(),
    'updated_at': schema['updated_at']?.toString(),
  };
}
