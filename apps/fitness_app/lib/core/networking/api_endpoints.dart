abstract final class ApiEndpoints {
  static const auth = _Auth();
  static const profile = _Profile();
  static const exercises = _Exercises();
  static const workouts = _Workouts();
  static const personalRecords = _PersonalRecords();
  static const goals = _Goals();
  static const organizations = _Organizations();
  static const classes = _Classes();
  static const notifications = _Notifications();
}

class _Auth {
  const _Auth();
  String get register => '/auth/register';
  String get login => '/auth/login';
  String get refresh => '/auth/refresh';
  String get forgotPassword => '/auth/forgot-password';
  String get resetPassword => '/auth/reset-password';
}

class _Profile {
  const _Profile();
  String get me => '/profile/me';
  String get athlete => '/profile/me/athlete';
}

class _Exercises {
  const _Exercises();
  String get list => '/exercises';
  String byId(String id) => '/exercises/$id';
}

class _Workouts {
  const _Workouts();
  String get list => '/workouts';
  String byId(String id) => '/workouts/$id';
}

class _PersonalRecords {
  const _PersonalRecords();
  String get list => '/personal-records';
  String byExercise(String exerciseId) =>
      '/personal-records/exercise/$exerciseId';
}

class _Goals {
  const _Goals();
  String get list => '/goals';
  String byId(String id) => '/goals/$id';
}

class _Organizations {
  const _Organizations();
  String get list => '/organizations';
  String byId(String orgId) => '/organizations/$orgId';
  String members(String orgId) => '/organizations/$orgId/members';
  String invitations(String orgId) => '/organizations/$orgId/invitations';
  String locations(String orgId) => '/organizations/$orgId/locations';
  String programs(String orgId) => '/organizations/$orgId/programs';
  String program(String orgId, String programId) =>
      '/organizations/$orgId/programs/$programId';
  String announcements(String orgId) => '/organizations/$orgId/announcements';
  String get join => '/organizations/join';
}

class _Classes {
  const _Classes();
  String get calendar => '/classes/calendar';
  String byProgram(String programId) => '/classes/$programId';
  String results(String sessionId) => '/classes/$sessionId/results';
}

class _Notifications {
  const _Notifications();
  String get list => '/notifications';
  String read(String id) => '/notifications/$id/read';
  String get device => '/notifications/device';
}
