import 'dart:convert';
import 'package:shelf/shelf.dart';
import '../auth/auth_middleware.dart' as auth;
import '../db/database.dart';

const _contextKeyOrgRole = 'org.role';
const _contextKeyOrgId = 'org.id';

Middleware orgScopeMiddleware(Database db) {
  return (Handler innerHandler) {
    return (Request request) async {
      final pathSegments = request.url.pathSegments;
      final orgIndex = pathSegments.indexOf('organizations');
      if (orgIndex == -1 || orgIndex + 1 >= pathSegments.length) {
        return innerHandler(request);
      }

      final orgId = pathSegments[orgIndex + 1];
      final uid = auth.userId(request);

      final result = await db.query(
        '''
        SELECT role FROM organization_members
        WHERE organization_id = @orgId AND user_id = @userId AND status = 'active'
        ''',
        parameters: {'orgId': orgId, 'userId': uid},
      );

      if (result.isEmpty) {
        return Response(
          403,
          body: jsonEncode({
            'ok': false,
            'error': {'message': 'Not a member of this organization'},
          }),
          headers: {'content-type': 'application/json'},
        );
      }

      final role = result.first.toColumnMap()['role']?.toString() ?? 'athlete';

      final updatedRequest = request.change(
        context: {
          _contextKeyOrgRole: role,
          _contextKeyOrgId: orgId,
        },
      );
      return innerHandler(updatedRequest);
    };
  };
}

String orgRole(Request request) {
  final role = request.context[_contextKeyOrgRole] as String?;
  if (role == null) {
    throw StateError('orgRole not found — org_scope_middleware missing');
  }
  return role;
}

String orgId(Request request) {
  final id = request.context[_contextKeyOrgId] as String?;
  if (id == null) {
    throw StateError('orgId not found — org_scope_middleware missing');
  }
  return id;
}

bool hasMinRole(String actual, String required) {
  const hierarchy = ['visitor', 'athlete', 'coach', 'admin', 'owner', 'superadmin'];
  final actualIdx = hierarchy.indexOf(actual);
  final requiredIdx = hierarchy.indexOf(required);
  if (actualIdx == -1 || requiredIdx == -1) return false;
  return actualIdx >= requiredIdx;
}
