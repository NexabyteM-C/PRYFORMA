import '../database.dart';

Future<Map<String, dynamic>?> getFullProfile(
  Database db,
  String userId,
) async {
  final result = await db.query(
    '''
    SELECT
      p.id, p.email, p.display_name, p.avatar_url,
      p.email_verified_at, p.created_at, p.updated_at,
      ap.experience_level, ap.preferred_unit, ap.primary_sport,
      ap.date_of_birth, ap.height_cm, ap.weight_kg
    FROM profiles p
    LEFT JOIN athlete_profiles ap ON ap.user_id = p.id
    WHERE p.id = @userId
    ''',
    parameters: {'userId': userId},
  );

  if (result.isEmpty) return null;

  final row = result.first.toColumnMap();
  return {
    'id': row['id']?.toString(),
    'email': row['email'] as String?,
    'displayName': row['display_name'] as String?,
    'avatarUrl': row['avatar_url'] as String?,
    'emailVerifiedAt': row['email_verified_at']?.toString(),
    'createdAt': row['created_at']?.toString(),
    'updatedAt': row['updated_at']?.toString(),
    'athleteProfile': row['experience_level'] != null
        ? {
            'experienceLevel': (row['experience_level'] as Enum?)?.name ??
                row['experience_level']?.toString(),
            'preferredUnit': (row['preferred_unit'] as Enum?)?.name ??
                row['preferred_unit']?.toString(),
            'primarySport': row['primary_sport'] as String?,
            'dateOfBirth': row['date_of_birth']?.toString(),
            'heightCm': row['height_cm']?.toString(),
            'weightKg': row['weight_kg']?.toString(),
          }
        : null,
  };
}

Future<void> updateProfile(
  Database db,
  String userId, {
  String? displayName,
  String? avatarUrl,
}) async {
  final setClauses = <String>[];
  final params = <String, dynamic>{'userId': userId};

  if (displayName != null) {
    setClauses.add('display_name = @displayName');
    params['displayName'] = displayName;
  }
  if (avatarUrl != null) {
    setClauses.add('avatar_url = @avatarUrl');
    params['avatarUrl'] = avatarUrl;
  }

  if (setClauses.isEmpty) return;

  await db.query(
    'UPDATE profiles SET ${setClauses.join(', ')} WHERE id = @userId',
    parameters: params,
  );
}

Future<void> upsertAthleteProfile(
  Database db,
  String userId, {
  String? preferredUnit,
  String? experienceLevel,
  String? primarySport,
}) async {
  final unit = preferredUnit ?? 'kg';
  final level = experienceLevel ?? 'beginner';

  await db.query(
    '''
    INSERT INTO athlete_profiles (user_id, preferred_unit, experience_level, primary_sport)
    VALUES (@userId, @unit::weight_unit, @level::experience_level, @primarySport)
    ON CONFLICT (user_id) DO UPDATE SET
      preferred_unit = COALESCE(@unit::weight_unit, athlete_profiles.preferred_unit),
      experience_level = COALESCE(@level::experience_level, athlete_profiles.experience_level),
      primary_sport = COALESCE(@primarySport, athlete_profiles.primary_sport)
    ''',
    parameters: {
      'userId': userId,
      'unit': unit,
      'level': level,
      'primarySport': primarySport,
    },
  );
}
