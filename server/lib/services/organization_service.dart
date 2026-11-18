import 'package:uuid/uuid.dart';
import '../db/database.dart';
import '../db/queries/organization_queries.dart' as q;

class OrganizationService {
  final Database _db;
  final _uuid = const Uuid();

  OrganizationService(this._db);

  Future<Map<String, dynamic>> createOrganization({
    required String ownerId,
    required String name,
    required String slug,
    String? description,
    String? logoUrl,
    required String locationName,
    String? locationAddress,
    String timezone = 'America/Bogota',
  }) async {
    final orgId = _uuid.v4();
    final locationId = _uuid.v4();
    final memberId = _uuid.v4();

    await _db.transaction((tx) async {
      await q.insertOrganization(
        tx,
        id: orgId,
        name: name,
        slug: slug,
        description: description,
        logoUrl: logoUrl,
        ownerId: ownerId,
      );
      await q.insertOrganizationLocation(
        tx,
        id: locationId,
        organizationId: orgId,
        name: locationName,
        address: locationAddress,
        timezone: timezone,
      );
      await q.insertMember(
        tx,
        id: memberId,
        organizationId: orgId,
        userId: ownerId,
        role: 'owner',
      );
    });

    return (await q.findOrganizationById(_db, orgId))!;
  }

  Future<Map<String, dynamic>?> getOrganization(String orgId) {
    return q.findOrganizationById(_db, orgId);
  }

  Future<List<Map<String, dynamic>>> listUserOrganizations(String userId) {
    return q.listUserOrganizations(_db, userId);
  }

  Future<List<Map<String, dynamic>>> listMembers(
    String orgId, {
    int limit = 50,
    int offset = 0,
  }) {
    return q.listMembers(_db, orgId, limit: limit, offset: offset);
  }

  Future<int> countMembers(String orgId) {
    return q.countMembers(_db, orgId);
  }

  Future<void> updateMemberRole({
    required String orgId,
    required String userId,
    required String role,
  }) {
    return q.updateMemberRole(_db, orgId: orgId, userId: userId, role: role);
  }

  Future<void> removeMember({
    required String orgId,
    required String userId,
  }) {
    return q.removeMember(_db, orgId: orgId, userId: userId);
  }

  Future<String> createInvitation({
    required String orgId,
    required String email,
    required String role,
    required String invitedBy,
  }) {
    final id = _uuid.v4();
    final token = _uuid.v4();
    return q
        .insertInvitation(
          _db,
          id: id,
          orgId: orgId,
          email: email,
          role: role,
          invitedBy: invitedBy,
          token: token,
        )
        .then((_) => token);
  }

  Future<void> acceptInvitation({
    required String token,
    required String userId,
  }) async {
    final invitation = await q.findInvitationByToken(_db, token);
    if (invitation == null) {
      throw OrganizationException('Invalid or expired invitation');
    }

    final memberId = _uuid.v4();
    await _db.transaction((tx) async {
      await q.insertMember(
        tx,
        id: memberId,
        organizationId: invitation['organizationId'] as String,
        userId: userId,
        role: invitation['role'] as String? ?? 'athlete',
      );
    });
    await q.acceptInvitation(_db, invitation['id'] as String);
  }

  Future<List<Map<String, dynamic>>> listLocations(String orgId) {
    return q.listLocations(_db, orgId);
  }
}

class OrganizationException implements Exception {
  final String message;
  const OrganizationException(this.message);

  @override
  String toString() => message;
}
