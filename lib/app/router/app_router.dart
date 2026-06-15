import 'package:go_router/go_router.dart';
import '../../features/auth/presentation/screens/auth_screen.dart';
import '../../features/home/presentation/home_screen.dart';
import '../../features/profile/presentation/profile_screen.dart';
import '../../features/settings/presentation/settings_screen.dart';
import '../../features/shell/presentation/shell_screen.dart';
import '../../features/workspaces/domain/models/workspace_type.dart';
import '../../features/workspaces/presentation/screens/debate_workspace_screen.dart';
import '../../features/workspaces/presentation/screens/discussion_workspace_screen.dart';
import '../../features/workspaces/presentation/screens/images_workspace_screen.dart';
import '../../features/workspaces/presentation/screens/library_workspace_screen.dart';
import '../../features/workspaces/presentation/screens/projects_workspace_screen.dart';
import '../../features/workspaces/presentation/screens/research_workspace_screen.dart';

class AppRouter {
  static const String home = '/';
  static const String settings = '/settings';
  static const String profile = '/profile';
  static const String auth = '/auth';
  
  // Workspace routes
  static const String workspaceDiscussion = '/workspaces/discussion';
static const String workspaceResearch = '/workspaces/research';
static const String workspaceImages = '/workspaces/images';
static const String workspaceDebate = '/workspaces/debate';
static const String workspaceProjects = '/workspaces/projects';
static const String workspaceLibrary = '/workspaces/library';

  static final GoRouter router = GoRouter(
    initialLocation: home,
    routes: [
      GoRoute(
        path: auth,
        builder: (context, state) => const AuthScreen(),
      ),
      ShellRoute(
        builder: (context, state, child) => ShellScreen(child: child),
        routes: [
          GoRoute(
            path: home,
            pageBuilder: (context, state) => const NoTransitionPage(
              child: HomeScreen(),
            ),
          ),
          GoRoute(
            path: settings,
            pageBuilder: (context, state) => const NoTransitionPage(
              child: SettingsScreen(),
            ),
          ),
          GoRoute(
            path: profile,
            pageBuilder: (context, state) => const NoTransitionPage(
              child: ProfileScreen(),
            ),
          ),
          // Workspace routes
          GoRoute(
            path: workspaceDiscussion,
            pageBuilder: (context, state) => const NoTransitionPage(
              child: DiscussionWorkspaceScreen(),
            ),
          ),
          GoRoute(
            path: workspaceResearch,
            pageBuilder: (context, state) => const NoTransitionPage(
              child: ResearchWorkspaceScreen(),
            ),
          ),
          GoRoute(
            path: workspaceImages,
            pageBuilder: (context, state) => const NoTransitionPage(
              child: ImagesWorkspaceScreen(),
            ),
          ),
          GoRoute(
            path: workspaceDebate,
            pageBuilder: (context, state) => const NoTransitionPage(
              child: DebateWorkspaceScreen(),
            ),
          ),
          GoRoute(
            path: workspaceProjects,
            pageBuilder: (context, state) => const NoTransitionPage(
              child: ProjectsWorkspaceScreen(),
            ),
          ),
          GoRoute(
            path: workspaceLibrary,
            pageBuilder: (context, state) => const NoTransitionPage(
              child: LibraryWorkspaceScreen(),
            ),
          ),
        ],
      ),
    ],
  );
}
