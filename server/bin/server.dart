import 'dart:io';
import 'package:shelf/shelf.dart';
import 'package:shelf/shelf_io.dart' as shelf_io;
import 'package:fitness_server/config/env.dart';
import 'package:fitness_server/db/database.dart';
import 'package:fitness_server/db/migration_runner.dart';
import 'package:fitness_server/auth/password_service.dart';
import 'package:fitness_server/auth/jwt_service.dart';
import 'package:fitness_server/auth/auth_middleware.dart';
import 'package:fitness_server/middleware/cors_middleware.dart';
import 'package:fitness_server/middleware/logging_middleware.dart';
import 'package:fitness_server/middleware/rate_limit_middleware.dart';
import 'package:fitness_server/services/auth_service.dart';
import 'package:fitness_server/services/profile_service.dart';
import 'package:fitness_server/services/organization_service.dart';
import 'package:fitness_server/services/exercise_service.dart';
import 'package:fitness_server/services/workout_service.dart';
import 'package:fitness_server/services/personal_record_service.dart';
import 'package:fitness_server/services/goal_service.dart';
import 'package:fitness_server/services/program_service.dart';
import 'package:fitness_server/services/publication_service.dart';
import 'package:fitness_server/services/notification_service.dart';
import 'package:fitness_server/services/class_session_service.dart';
import 'package:fitness_server/routes/router.dart';

Future<void> main() async {
  final env = Env.load(path: '.env');

  print('Connecting to database...');
  final db = await Database.create(env);

  final scriptDir = Platform.script.resolve('../sql/migrations').toFilePath();
  print('Running migrations...');
  await MigrationRunner(db).migrate(scriptDir);

  final passwordService = PasswordService();
  final jwtService = JwtService(env);
  final authService = AuthService(db, passwordService, jwtService);
  final profileService = ProfileService(db);
  final organizationService = OrganizationService(db);
  final exerciseService = ExerciseService(db);
  final workoutService = WorkoutService(db);
  final personalRecordService = PersonalRecordService(db);
  final goalService = GoalService(db);
  final programService = ProgramService(db);
  final publicationService = PublicationService(db);
  final notificationService = NotificationService(db);
  final classSessionService = ClassSessionService(db);

  final router = buildRootRouter(
    db: db,
    authService: authService,
    profileService: profileService,
    organizationService: organizationService,
    exerciseService: exerciseService,
    workoutService: workoutService,
    personalRecordService: personalRecordService,
    goalService: goalService,
    programService: programService,
    publicationService: publicationService,
    notificationService: notificationService,
    classSessionService: classSessionService,
  );

  final handler = const Pipeline()
      .addMiddleware(loggingMiddleware())
      .addMiddleware(corsMiddleware(env))
      .addMiddleware(rateLimitMiddleware())
      .addMiddleware(authMiddleware(jwtService))
      .addHandler(router.call);

  final server = await shelf_io.serve(
    handler,
    InternetAddress.anyIPv4,
    env.serverPort,
  );

  print('Server running on port ${server.port}');

  ProcessSignal.sigint.watch().listen((_) async {
    print('\nShutting down...');
    await db.close();
    server.close(force: true);
    exit(0);
  });
}
