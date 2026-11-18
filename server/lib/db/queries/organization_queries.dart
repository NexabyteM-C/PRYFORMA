import 'package:postgres/postgres.dart';
import '../database.dart';

Future<Map<String, dynamic>> insertOrganization(
  TxSession tx, {
  required String id,
  required String name,
  required String slug,
  String? description,
  String? logoUrl,
  required String ownerId,
}) async {
  await tx.execute(
    Sql.named('''
      INSERT INTO organizations (id, name, slug, description, logo_url, owner_id)
      VALUES (@id, @name, @slug, @description, @logoUrl, @ownerId)
    '''),
    parameters: {
      'id': id,
      'name': name,
      'slug': slug,
      'description': description,
      'logoUrl': logoUrl,
      'ownerId': ownerId,
    },
  );
  return {'id': id, 'name': name, 'slug': slug};
}

Future<void> insertOrganizationLocation(
  TxSession tx, {
  required String id,
  required String organizationId,
  required String name,
  String? address,
  String timezone = 'America/Bogota',
}) async {
  await tx.execute(
    Sql.named('''
      INSERT INTO organization_locations (id, organization_id, name, address, timezone)
      VALUES (@id, @orgId, @name, @address, @timezone)
    '''),
    parameters: {
      'id': id,
      'orgId': organizationId,
      'name': name,
      'address': address,
      'timezone': timezone,
    },
  );
}

Future<void> insertMember(
  TxSession tx, {
  required String id,
  required String organizationId,
  required String userId,
  required String role,
  String status = 'active',
}) async {
  await tx.execute(
    Sql.named('''
      INSERT INTO organization_members (id, organization_id, user_id, role, status)
      VALUES (@id, @orgId, @userId, @role::member_role, @status::member_status)
    '''),
    parameters: {
      'id': id,
      'orgId': organizationId,
      'userId': userId,
      'role': role,
      'status': status,
    },
  );
}

Future<Map<String, dynamic>?> findOrganizationById(
  Database db,
  String orgId,
) async {
  final result = await db.query(
    '''
    SELECT o.id, o.name, o.slug, o.description, o.logo_url, o.owner_id,
           o.created_at, o.updated_at
    FROM organizations o
    WHERE o.id = @orgId
    ''',
    parameters: {'orgId': orgId},
  );
  if (result.isEmpty) return null;
  return _orgRowToMap(result.first);
}

Future<List<Map<String, dynamic>>> listUserOrganizations(
  Database db,
  String userId,
) async {
  final result = await db.query(
    '''
    SELECT o.id, o.name, o.slug, o.description, o.logo_url, o.owner_id,
           o.created_at, o.updated_at, om.role, om.status
    FROM organizations o
    JOIN organization_members om ON om.organization_id = o.id
    WHERE om.user_id = @userId AND om.status = 'active'
    ORDER BY o.name
    ''',
    parameters: {'userId': userId},
  );
  return result.map((row) {
    final m = _orgRowToMap(row);
    final cols = row.toColumnMap();
    m['memberRole'] = cols['role']?.toString();
    m['memberStatus'] = cols['status']?.toString();
    return m;
  }).toList();
}

Future<List<Map<String, dynamic>>> listMembers(
  Database db,
  String orgId, {
  int limit = 50,
  int offset = 0,
}) async {
  final result = await db.query(
    '''
    SELECT om.id, om.user_id, om.role, om.status, om.joined_at,
           p.display_name, p.email, p.avatar_url
    FROM organization_members om
    JOIN profiles p ON p.id = om.user_id
    WHERE om.organization_id = @orgId
    ORDER BY om.joined_at DESC
    LIMIT @lim OFFSET @off
    ''',
    parameters: {'orgId': orgId, 'lim': limit, 'off': offset},
  );
  return result.map((row) {
    final cols = row.toColumnMap();
    return {
      'id': cols['id']?.toString(),
      'userId': cols['user_id']?.toString(),
      'role': cols['role']?.toString(),
      'status': cols['status']?.toString(),
      'joinedAt': cols['joined_at']?.toString(),
      'displayName': cols['display_name'] as String?,
      'email': cols['email'] as String?,
      'avatarUrl': cols['avatar_url'] as String?,
    };
  }).toList();
}

Future<int> countMembers(Database db, String orgId) async {
  final result = await db.query(
    'SELECT COUNT(*) as cnt FROM organization_members WHERE organization_id = @orgId',
    parameters: {'orgId': orgId},
  );
  return result.first.toColumnMap()['cnt'] as int? ?? 0;
}

Future<void> updateMemberRole(
  Database db, {
  required String orgId,
  required String userId,
  required String role,
}) async {
  await db.query(
    '''
    UPDATE organization_members SET role = @role::member_role
    WHERE organization_id = @orgId AND user_id = @userId
    ''',
    parameters: {'orgId': orgId, 'userId': userId, 'role': role},
  );
}

Future<void> removeMember(
  Database db, {
  required String orgId,
  required String userId,
}) async {
  await db.query(
    '''
    UPDATE organization_members SET status = 'inactive'
    WHERE organization_id = @orgId AND user_id = @userId
    ''',
    parameters: {'orgId': orgId, 'userId': userId},
  );
}

Future<void> insertInvitation(
  Database db, {
  required String id,
  required String orgId,
  required String email,
  required String role,
  required String invitedBy,
  required String token,
}) async {
  await db.query(
    '''
    INSERT INTO organization_invitations (id, organization_id, email, role, invited_by, token)
    VALUES (@id, @orgId, @email, @role::member_role, @invitedBy, @token)
    ''',
    parameters: {
      'id': id,
      'orgId': orgId,
      'email': email,
      'role': role,
      'invitedBy': invitedBy,
      'token': token,
    },
  );
}

Future<Map<String, dynamic>?> findInvitationByToken(
  Database db,
  String token,
) async {
  final result = await db.query(
    '''
    SELECT id, organization_id, email, role, status, expires_at
    FROM organization_invitations
    WHERE token = @token AND status = 'pending' AND expires_at > NOW()
    ''',
    parameters: {'token': token},
  );
  if (result.isEmpty) return null;
  final cols = result.first.toColumnMap();
  return {
    'id': cols['id']?.toString(),
    'organizationId': cols['organization_id']?.toString(),
    'email': cols['email'] as String?,
    'role': cols['role']?.toString(),
    'status': cols['status']?.toString(),
    'expiresAt': cols['expires_at']?.toString(),
  };
}

Future<void> acceptInvitation(Database db, String invitationId) async {
  await db.query(
    "UPDATE organization_invitations SET status = 'accepted' WHERE id = @id",
    parameters: {'id': invitationId},
  );
}

Future<List<Map<String, dynamic>>> listLocations(
  Database db,
  String orgId,
) async {
  final result = await db.query(
    '''
    SELECT id, name, address, timezone, is_primary, created_at
    FROM organization_locations
    WHERE organization_id = @orgId
    ORDER BY is_primary DESC, name
    ''',
    parameters: {'orgId': orgId},
  );
  return result.map((row) {
    final cols = row.toColumnMap();
    return {
      'id': cols['id']?.toString(),
      'name': cols['name'] as String?,
      'address': cols['address'] as String?,
      'timezone': cols['timezone'] as String?,
      'isPrimary': cols['is_primary'] as bool? ?? false,
      'createdAt': cols['created_at']?.toString(),
    };
  }).toList();
}

Map<String, dynamic> _orgRowToMap(ResultRow row) {
  final cols = row.toColumnMap();
  return {
    'id': cols['id']?.toString(),
    'name': cols['name'] as String?,
    'slug': cols['slug'] as String?,
    'description': cols['description'] as String?,
    'logoUrl': cols['logo_url'] as String?,
    'ownerId': cols['owner_id']?.toString(),
    'createdAt': cols['created_at']?.toString(),
    'updatedAt': cols['updated_at']?.toString(),
  };
}
