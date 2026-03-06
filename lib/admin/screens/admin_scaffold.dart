import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class AdminScaffold extends StatelessWidget {
  const AdminScaffold({
    super.key,
    required this.child,
    required this.currentPath,
  });

  final Widget child;
  final String currentPath;

  int _selectedIndex() {
    if (currentPath.startsWith('/deceased')) return 1;
    if (currentPath.startsWith('/maintenance')) return 2;
    if (currentPath.startsWith('/sections')) return 3;
    if (currentPath.startsWith('/settings')) return 4;
    return 0;
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Scaffold(
      backgroundColor: theme.colorScheme.surface,
      body: Row(
        children: [
          Container(
            decoration: BoxDecoration(
              color: Colors.white,
              border: Border(
                right: BorderSide(
                  color: theme.colorScheme.primary.withValues(alpha: 0.08),
                ),
              ),
            ),
            child: NavigationRail(
              extended: MediaQuery.sizeOf(context).width > 800,
              leading: Padding(
                padding: const EdgeInsets.fromLTRB(16, 24, 16, 16),
                child: Text(
                  'Sanad Cemetery',
                  style: theme.textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w700,
                    color: theme.colorScheme.primary,
                    letterSpacing: -0.2,
                  ),
                ),
              ),
              selectedIndex: _selectedIndex(),
              onDestinationSelected: (index) {
                switch (index) {
                  case 0:
                    context.go('/');
                    break;
                  case 1:
                    context.go('/deceased');
                    break;
                  case 2:
                    context.go('/maintenance');
                    break;
                  case 3:
                    context.go('/sections');
                    break;
                  case 4:
                    context.go('/settings');
                    break;
                }
              },
              destinations: const [
                NavigationRailDestination(
                  icon: Icon(Icons.dashboard_rounded),
                  label: Text('Dashboard'),
                ),
                NavigationRailDestination(
                  icon: Icon(Icons.person_rounded),
                  label: Text('Deceased'),
                ),
                NavigationRailDestination(
                  icon: Icon(Icons.construction_rounded),
                  label: Text('Maintenance'),
                ),
                NavigationRailDestination(
                  icon: Icon(Icons.place_rounded),
                  label: Text('Sections'),
                ),
                NavigationRailDestination(
                  icon: Icon(Icons.settings_rounded),
                  label: Text('Settings'),
                ),
              ],
            ),
          ),
          Expanded(
            child: ColoredBox(
              color: theme.colorScheme.surface,
              child: child,
            ),
          ),
        ],
      ),
    );
  }
}
