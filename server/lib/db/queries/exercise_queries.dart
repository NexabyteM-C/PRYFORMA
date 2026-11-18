import 'package:postgres/postgres.dart';
import '../database.dart';

Future<List<Map<String, dynamic>>> listExercises(
  Database db, {
  String? search,
  String? category,
  int limit = 50,
  int offset = 0,
}) async {
  final where = <String>[];
  final params = <String, dynamic>{'lim': limit, 'off': offset};

  if (search != null && search.isNotEmpty) {
    where.add("(e.name ILIKE @search OR e.name_en ILIKE @search)");
    params['search'] = '%$search%';
  }
  if (category != null && category.isNotEmpty) {
    where.add("e.category = @category");
    params['category'] = category;
  }

  final whereClause = where.isEmpty ? '' : 'WHERE ${where.join(' AND ')}';

  final result = await db.query(
    '''
    SELECT e.id, e.name, e.name_en, e.category, e.description,
           e.default_metric, e.is_compound, e.created_at
    FROM exercises e
    $whereClause
    ORDER BY e.name
    LIMIT @lim OFFSET @off
    ''',
    parameters: params,
  );
  return result.map(_exerciseRowToMap).toList();
}

Future<int> countExercises(
  Database db, {
  String? search,
  String? category,
}) async {
  final where = <String>[];
  final params = <String, dynamic>{};

  if (search != null && search.isNotEmpty) {
    where.add("(name ILIKE @search OR name_en ILIKE @search)");
    params['search'] = '%$search%';
  }
  if (category != null && category.isNotEmpty) {
    where.add("category = @category");
    params['category'] = category;
  }

  final whereClause = where.isEmpty ? '' : 'WHERE ${where.join(' AND ')}';

  final result = await db.query(
    'SELECT COUNT(*) as cnt FROM exercises $whereClause',
    parameters: params,
  );
  return result.first.toColumnMap()['cnt'] as int? ?? 0;
}

Future<Map<String, dynamic>?> findExerciseById(
  Database db,
  String exerciseId,
) async {
  final result = await db.query(
    '''
    SELECT e.id, e.name, e.name_en, e.category, e.description,
           e.default_metric, e.is_compound, e.created_at
    FROM exercises e
    WHERE e.id = @id
    ''',
    parameters: {'id': exerciseId},
  );
  if (result.isEmpty) return null;

  final exercise = _exerciseRowToMap(result.first);

  final variants = await db.query(
    '''
    SELECT id, name, description FROM exercise_variants
    WHERE exercise_id = @id ORDER BY name
    ''',
    parameters: {'id': exerciseId},
  );
  exercise['variants'] = variants.map((r) {
    final c = r.toColumnMap();
    return {
      'id': c['id']?.toString(),
      'name': c['name'] as String?,
      'description': c['description'] as String?,
    };
  }).toList();

  final metrics = await db.query(
    '''
    SELECT id, name, unit, data_type FROM exercise_metric_definitions
    WHERE exercise_id = @id ORDER BY name
    ''',
    parameters: {'id': exerciseId},
  );
  exercise['metrics'] = metrics.map((r) {
    final c = r.toColumnMap();
    return {
      'id': c['id']?.toString(),
      'name': c['name'] as String?,
      'unit': c['unit'] as String?,
      'dataType': c['data_type'] as String?,
    };
  }).toList();

  return exercise;
}

Future<void> insertExercise(
  TxSession tx, {
  required String id,
  required String name,
  String? nameEn,
  required String category,
  String? description,
  String defaultMetric = 'weight_reps',
  bool isCompound = true,
}) async {
  await tx.execute(
    Sql.named('''
      INSERT INTO exercises (id, name, name_en, category, description, default_metric, is_compound)
      VALUES (@id, @name, @nameEn, @category, @description, @defaultMetric, @isCompound)
    '''),
    parameters: {
      'id': id,
      'name': name,
      'nameEn': nameEn,
      'category': category,
      'description': description,
      'defaultMetric': defaultMetric,
      'isCompound': isCompound,
    },
  );
}

Map<String, dynamic> _exerciseRowToMap(ResultRow row) {
  final cols = row.toColumnMap();
  return {
    'id': cols['id']?.toString(),
    'name': cols['name'] as String?,
    'nameEn': cols['name_en'] as String?,
    'category': cols['category'] as String?,
    'description': cols['description'] as String?,
    'defaultMetric': cols['default_metric'] as String?,
    'isCompound': cols['is_compound'] as bool? ?? true,
    'createdAt': cols['created_at']?.toString(),
  };
}
