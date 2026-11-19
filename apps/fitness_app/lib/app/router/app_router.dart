import 'package:design_system/design_system.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../theme/app_colors.dart';
import 'package:go_router/go_router.dart';
import '../../features/admin_athletes/presentation/screens/athletes_list_screen.dart';
import '../../features/admin_members/presentation/screens/admin_results_screen.dart';
import '../../features/admin_members/presentation/screens/members_hub_screen.dart';
import '../../features/admin_programming/presentation/screens/program_editor_screen.dart';
import '../../features/admin_programming/presentation/screens/program_enrollments_screen.dart';
import '../../features/admin_programming/presentation/screens/programming_calendar_screen.dart';
import '../../features/admin_programming/presentation/screens/template_library_screen.dart';
import '../../features/admin_programming/presentation/screens/schedule_settings_screen.dart';
import '../../features/announcements/presentation/screens/announcement_detail_screen.dart';
import '../../features/announcements/presentation/screens/announcement_list_screen.dart';
import '../../features/announcements/presentation/screens/create_announcement_screen.dart';
import '../../features/auth/presentation/providers/auth_provider.dart';
import '../../features/auth/presentation/screens/login_screen.dart';
import '../../features/auth/presentation/screens/register_screen.dart';
import '../../features/classes/presentation/screens/class_calendar_screen.dart';
import '../../features/classes/presentation/screens/class_detail_screen.dart';
import '../../features/classes/presentation/screens/class_record_screen.dart';
import '../../features/exercises/presentation/screens/exercise_detail_screen.dart';
import '../../features/exercises/presentation/screens/exercise_list_screen.dart';
import '../../features/goals/presentation/screens/goal_detail_screen.dart';
import '../../features/goals/presentation/screens/goal_list_screen.dart';
import '../../features/home/presentation/screens/admin_dashboard_screen.dart';
import '../../features/home/presentation/screens/athlete_home_screen.dart';
import '../../features/notifications/presentation/screens/notification_screen.dart';
import '../../features/organizations/presentation/screens/my_boxes_screen.dart';
import '../../features/organizations/presentation/screens/organization_detail_screen.dart';
import '../../features/personal_records/presentation/screens/exercise_progress_screen.dart';
import '../../features/personal_records/presentation/screens/pr_list_screen.dart';
import '../../features/profile/presentation/screens/edit_profile_screen.dart';
import '../../features/profile/presentation/screens/measurements_screen.dart';
import '../../features/profile/presentation/screens/profile_screen.dart';
import '../../features/workouts/presentation/screens/workout_list_screen.dart';
import '../../features/workouts/presentation/screens/workout_session_screen.dart';
import '../../features/organizations/presentation/providers/membership_provider.dart';
import '../../features/skills/presentation/screens/skills_hub_screen.dart';
import '../../features/skills/presentation/screens/skill_progression_screen.dart';

final _rootNavigatorKey = GlobalKey<NavigatorState>();
final _athleteShellKey = GlobalKey<NavigatorState>();
final _adminShellKey = GlobalKey<NavigatorState>();

/// Rebuilds GoRouter redirects when auth, memberships, or UI mode change.
class _RouterRefresh extends ChangeNotifier {
  _RouterRefresh(Ref ref) {
    ref.listen(authStateProvider, (_, _) => notifyListeners());
    ref.listen(myMembershipsProvider, (_, _) => notifyListeners());
    ref.listen(currentModeProvider, (_, _) => notifyListeners());
  }
}

final routerProvider = Provider<GoRouter>((ref) {
  bool canAdmin() {
    final m = ref.read(myMembershipsProvider).valueOrNull ?? const [];
    return m.any((e) => isAdminRole(e.role));
  }

  return GoRouter(
    navigatorKey: _rootNavigatorKey,
    initialLocation: '/auth/login',
    refreshListenable: _RouterRefresh(ref),
    redirect: (context, state) {
      final isLoggedIn = ref.read(authStateProvider).valueOrNull != null;
      final loc = state.matchedLocation;
      final isAuthRoute = loc.startsWith('/auth');
      final mode = ref.read(currentModeProvider);

      if (!isLoggedIn && !isAuthRoute) return '/auth/login';
      if (isLoggedIn && isAuthRoute) {
        return (canAdmin() && mode == 'admin') ? '/admin/dashboard' : '/athlete/home';
      }
      // Guard admin routes against non-admin users.
      if (isLoggedIn && loc.startsWith('/admin') && !canAdmin()) {
        return '/athlete/home';
      }
      return null;
    },
    routes: [
      GoRoute(path: '/auth/login', builder: (context, state) => const LoginScreen()),
      GoRoute(path: '/auth/register', builder: (context, state) => const RegisterScreen()),

      // Athlete shell (mobile bottom nav)
      StatefulShellRoute.indexedStack(
        builder: (context, state, navigationShell) {
          return AthleteShell(
            key: ValueKey(AppColors.isDark),
            currentIndex: navigationShell.currentIndex,
            onNavigate: (index) => navigationShell.goBranch(index, initialLocation: index == navigationShell.currentIndex),
            items: const [
              FitBottomNavItem(icon: Icon(Icons.home_rounded), label: 'Inicio'),
              FitBottomNavItem(icon: Icon(Icons.calendar_today_rounded), label: 'Clases'),
              FitBottomNavItem(icon: Icon(Icons.show_chart_rounded), label: 'Progreso'),
              FitBottomNavItem(icon: Icon(Icons.person_outline_rounded), label: 'Perfil'),
            ],
            child: _ModeSwitchOverlay(target: 'admin', child: navigationShell),
          );
        },
        branches: [
          // Home (also hosts the free-training & exercise-catalog routes, which
          // are no longer a bottom-nav tab but remain reachable via deep links
          // and internal navigation).
          StatefulShellBranch(
            navigatorKey: _athleteShellKey,
            routes: [
              GoRoute(path: '/athlete/home', builder: (context, state) => const AthleteHomeScreen()),
              GoRoute(
                path: '/athlete/train',
                builder: (context, state) => const WorkoutListScreen(),
                routes: [
                  GoRoute(path: 'new', builder: (context, state) => const WorkoutSessionScreen()),
                  GoRoute(path: 'exercises', builder: (context, state) => const ExerciseListScreen()),
                  GoRoute(path: 'exercise/:id', builder: (context, state) => ExerciseDetailScreen(exerciseId: state.pathParameters['id']!)),
                ],
              ),
            ],
          ),
          // Classes
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: '/athlete/classes',
                builder: (context, state) => const ClassCalendarScreen(),
                routes: [
                  GoRoute(path: ':programId', builder: (context, state) => ClassDetailScreen(programId: state.pathParameters['programId']!)),
                  GoRoute(path: ':programId/record', builder: (context, state) => ClassRecordScreen(programId: state.pathParameters['programId']!)),
                ],
              ),
            ],
          ),
          // Progress
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: '/athlete/progress',
                builder: (context, state) => const PrListScreen(),
                routes: [
                  GoRoute(path: 'exercise/:id', builder: (context, state) => ExerciseProgressScreen(exerciseId: state.pathParameters['id']!)),
                  GoRoute(path: 'goals', builder: (context, state) => const GoalListScreen()),
                  GoRoute(path: 'goal/:id', builder: (context, state) => GoalDetailScreen(goalId: state.pathParameters['id']!)),
                  GoRoute(path: 'skills', builder: (context, state) => const SkillsHubScreen()),
                  GoRoute(path: 'skills/:id', builder: (context, state) => SkillProgressionScreen(exerciseId: state.pathParameters['id']!)),
                ],
              ),
            ],
          ),
          // Profile
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: '/athlete/profile',
                builder: (context, state) => const ProfileScreen(),
                routes: [
                  GoRoute(path: 'edit', builder: (context, state) => const EditProfileScreen()),
                  GoRoute(path: 'measurements', builder: (context, state) => const MeasurementsScreen()),
                  GoRoute(path: 'boxes', builder: (context, state) => const MyBoxesScreen()),
                  GoRoute(path: 'box/:id', builder: (context, state) => OrganizationDetailScreen(orgId: state.pathParameters['id']!)),
                  GoRoute(path: 'notifications', builder: (context, state) => const NotificationScreen()),
                ],
              ),
            ],
          ),
        ],
      ),

      // Admin shell (web sidebar)
      ShellRoute(
        navigatorKey: _adminShellKey,
        builder: (context, state, child) {
          return Consumer(
            builder: (context, ref, _) {
              final adminMemberships = ref.watch(adminMembershipsProvider);
              final org = ref.watch(currentAdminOrgProvider) ??
                  (adminMemberships.isEmpty ? null : adminMemberships.first.organization);
              return AdminShell(
                key: ValueKey(AppColors.isDark),
                currentRoute: state.matchedLocation,
                organizationName: org?.name ?? 'Mi Box',
                onNavigate: (route) {
                  if (route == '/athlete/home') {
                    ref.read(currentModeProvider.notifier).state = 'athlete';
                  }
                  context.go(route);
                },
                items: const [
                  AdminNavItem(route: '/admin/dashboard', label: 'Dashboard', icon: Icon(Icons.dashboard_rounded)),
                  AdminNavItem(route: '/admin/programming', label: 'Programación', icon: Icon(Icons.edit_calendar_rounded)),
                  AdminNavItem(route: '/admin/members', label: 'Atletas y socios', icon: Icon(Icons.groups_rounded)),
                  AdminNavItem(route: '/admin/announcements', label: 'Comunicados', icon: Icon(Icons.campaign_rounded)),
                  AdminNavItem(route: '/admin/results', label: 'Resultados', icon: Icon(Icons.leaderboard_rounded)),
                  AdminNavItem(route: '/admin/settings', label: 'Configuración', icon: Icon(Icons.settings_rounded)),
                  AdminNavItem(route: '/athlete/home', label: 'Vista Atleta', icon: Icon(Icons.swap_horiz_rounded)),
                ],
                child: child,
              );
            },
          );
        },
        routes: [
          GoRoute(path: '/admin/dashboard', builder: (context, state) => const AdminDashboardScreen()),
          GoRoute(
            path: '/admin/programming',
            builder: (context, state) => const ProgrammingCalendarScreen(),
            routes: [
              GoRoute(path: 'new', builder: (context, state) => const ProgramEditorScreen()),
              GoRoute(path: 'templates', builder: (context, state) => const TemplateLibraryScreen()),
              GoRoute(
                path: ':programId',
                builder: (context, state) => ProgramEditorScreen(programId: state.pathParameters['programId']),
                routes: [
                  GoRoute(
                    path: 'roster',
                    builder: (context, state) => ProgramEnrollmentsScreen(programId: state.pathParameters['programId']!),
                  ),
                ],
              ),
            ],
          ),
          GoRoute(path: '/admin/athletes', builder: (context, state) => const AthletesListScreen()),
          GoRoute(path: '/admin/members', builder: (context, state) => const MembersHubScreen()),
          GoRoute(
            path: '/admin/announcements',
            builder: (context, state) => const AnnouncementListScreen(),
            routes: [
              GoRoute(path: 'new', builder: (context, state) => const CreateAnnouncementScreen()),
              GoRoute(path: ':id', builder: (context, state) => AnnouncementDetailScreen(announcementId: state.pathParameters['id']!)),
              GoRoute(path: ':id/edit', builder: (context, state) => CreateAnnouncementScreen(announcementId: state.pathParameters['id']!)),
            ],
          ),
          GoRoute(path: '/admin/results', builder: (context, state) => const AdminResultsScreen()),
          GoRoute(path: '/admin/settings', builder: (context, state) => const ScheduleSettingsScreen()),
        ],
      ),
    ],
  );
});

/// Floating pill that lets admin-capable users jump to the admin experience.
/// Shown only when the user holds a coach+ role in at least one box.
class _ModeSwitchOverlay extends ConsumerWidget {
  const _ModeSwitchOverlay({required this.child, required this.target});
  final Widget child;
  final String target; // 'admin' target shown inside athlete shell

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final canAdmin = ref.watch(canAccessAdminProvider);
    return Stack(
      children: [
        child,
        if (canAdmin)
          Positioned(
            right: 16,
            bottom: 16,
            child: SafeArea(
              child: Material(
                color: const Color(0xFF0B2A6F),
                borderRadius: BorderRadius.circular(24),
                elevation: 3,
                child: InkWell(
                  borderRadius: BorderRadius.circular(24),
                  onTap: () {
                    ref.read(currentModeProvider.notifier).state = target;
                    context.go('/admin/dashboard');
                  },
                  child: const Padding(
                    padding: EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(Icons.admin_panel_settings_rounded, color: Colors.white, size: 18),
                        SizedBox(width: 8),
                        Text('Vista Admin', style: TextStyle(color: Colors.white, fontWeight: FontWeight.w600, fontSize: 13)),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),
      ],
    );
  }
}

