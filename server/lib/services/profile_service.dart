import '../db/database.dart';
import '../db/queries/profile_queries.dart' as q;

class ProfileService {
  final Database _db;

  ProfileService(this._db);

  Future<Map<String, dynamic>?> getProfile(String userId) {
    return q.getFullProfile(_db, userId);
  }

  Future<void> updateProfile(
    String userId, {
    String? displayName,
    String? avatarUrl,
  }) {
    return q.updateProfile(
      _db,
      userId,
      displayName: displayName,
      avatarUrl: avatarUrl,
    );
  }

  Future<void> upsertAthleteProfile(
    String userId, {
    String? preferredUnit,
    String? experienceLevel,
    String? primarySport,
  }) {
    return q.upsertAthleteProfile(
      _db,
      userId,
      preferredUnit: preferredUnit,
      experienceLevel: experienceLevel,
      primarySport: primarySport,
    );
  }
}
