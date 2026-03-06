import 'package:go_router/go_router.dart';
import 'screens/admin_scaffold.dart';
import 'screens/dashboard_screen.dart';
import 'screens/deceased_list_screen.dart';
import 'screens/deceased_edit_screen.dart';
import 'screens/sections_screen.dart';
import 'screens/maintenance_list_screen.dart';
import 'screens/maintenance_detail_screen.dart';
import 'screens/settings_screen.dart';

final adminRouter = GoRouter(
  initialLocation: '/',
  routes: [
    ShellRoute(
      builder: (context, state, child) => AdminScaffold(
        child: child,
        currentPath: state.uri.path,
      ),
      routes: [
        GoRoute(
          path: '/',
          pageBuilder: (context, state) => const NoTransitionPage(
            child: DashboardScreen(),
          ),
        ),
        GoRoute(
          path: '/deceased',
          pageBuilder: (context, state) => const NoTransitionPage(
            child: DeceasedListScreen(),
          ),
        ),
        GoRoute(
          path: '/deceased/new',
          pageBuilder: (context, state) => const NoTransitionPage(
            child: DeceasedEditScreen(),
          ),
        ),
        GoRoute(
          path: '/deceased/:id',
          pageBuilder: (context, state) => NoTransitionPage(
            child: DeceasedEditScreen(graveId: state.pathParameters['id']!),
          ),
        ),
        GoRoute(
          path: '/maintenance',
          pageBuilder: (context, state) => const NoTransitionPage(
            child: MaintenanceListScreen(),
          ),
        ),
        GoRoute(
          path: '/maintenance/:id',
          pageBuilder: (context, state) => NoTransitionPage(
            child: MaintenanceDetailScreen(ticketId: state.pathParameters['id']!),
          ),
        ),
        GoRoute(
          path: '/sections',
          pageBuilder: (context, state) => const NoTransitionPage(
            child: SectionsScreen(),
          ),
        ),
        GoRoute(
          path: '/settings',
          pageBuilder: (context, state) => const NoTransitionPage(
            child: SettingsScreen(),
          ),
        ),
      ],
    ),
  ],
);
