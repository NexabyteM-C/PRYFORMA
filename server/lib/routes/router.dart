import 'dart:convert';
import 'package:shelf/shelf.dart';
import 'package:shelf_router/shelf_router.dart';
import '../db/database.dart';
import '../services/auth_service.dart';
import '../services/profile_service.dart';
import '../services/organization_service.dart';
import '../services/exercise_service.dart';
import '../services/workout_service.dart';
import '../services/personal_record_service.dart';
import '../services/goal_service.dart';
import '../services/program_service.dart';
import '../services/publication_service.dart';
import '../services/notification_service.dart';
import '../services/class_session_service.dart';
import 'auth_routes.dart';
import 'profile_routes.dart';
import 'organization_routes.dart';
import 'exercise_routes.dart';
import 'workout_routes.dart';
import 'personal_record_routes.dart';
import 'goal_routes.dart';
import 'class_program_routes.dart';
import 'class_session_routes.dart';
import 'announcement_routes.dart';
import 'notification_routes.dart';

Router buildRootRouter({
  required Database db,
  required AuthService authService,
  required ProfileService profileService,
  required OrganizationService organizationService,
  required ExerciseService exerciseService,
  required WorkoutService workoutService,
  required PersonalRecordService personalRecordService,
  required GoalService goalService,
  required ProgramService programService,
  required PublicationService publicationService,
  required NotificationService notificationService,
  required ClassSessionService classSessionService,
}) {
  final router = Router();

  router.get('/api/v1/health', (Request request) {
    return Response.ok(
      jsonEncode({
        'ok': true,
        'timestamp': DateTime.now().toUtc().toIso8601String(),
      }),
      headers: {'content-type': 'application/json'},
    );
  });

  final auth = authRoutes(authService);
  router.mount('/', auth.call);

  final profile = profileRoutes(profileService);
  router.mount('/', profile.call);

  final orgs = organizationRoutes(organizationService);
  router.mount('/', orgs.call);

  final exercises = exerciseRoutes(exerciseService);
  router.mount('/', exercises.call);

  final workouts = workoutRoutes(workoutService);
  router.mount('/', workouts.call);

  final prs = personalRecordRoutes(personalRecordService);
  router.mount('/', prs.call);

  final goals = goalRoutes(goalService);
  router.mount('/', goals.call);

  final programs = classProgramRoutes(programService, publicationService);
  router.mount('/', programs.call);

  final sessions = classSessionRoutes(classSessionService, workoutService);
  router.mount('/', sessions.call);

  final announcements = announcementRoutes(db, notificationService);
  router.mount('/', announcements.call);

  final notifications = notificationRoutes(notificationService);
  router.mount('/', notifications.call);

  router.all('/<ignored|.*>', (Request request) {
    return Response.notFound(
      jsonEncode({
        'ok': false,
        'error': {'message': 'Not found'},
      }),
      headers: {'content-type': 'application/json'},
    );
  });

  return router;
}
