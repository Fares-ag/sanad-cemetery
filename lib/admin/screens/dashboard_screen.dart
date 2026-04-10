import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:go_router/go_router.dart';
import '../../models/deceased.dart';
import '../../theme/app_theme.dart';
import '../state/admin_data_provider.dart';

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({super.key});

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  final _searchController = TextEditingController();

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  void _quickSearch(BuildContext context, String query, List<Deceased> deceased) {
    final q = query.trim().toLowerCase();
    if (q.isEmpty) {
      context.go('/deceased');
      return;
    }
    final match = deceased.where((d) =>
        d.fullName.toLowerCase().contains(q) ||
        (d.firstName.toLowerCase().contains(q)) ||
        (d.lastName.toLowerCase().contains(q))).toList();
    if (match.length == 1) {
      context.go('/deceased/${match.first.id}');
    } else if (match.isNotEmpty) {
      context.go('/deceased?q=$q');
    } else {
      context.go('/deceased');
    }
  }

  @override
  Widget build(BuildContext context) {
    final data = context.watch<AdminDataProvider>();
    final theme = Theme.of(context);
    final recentDeceased = data.deceased.take(5).toList();

    return ColoredBox(
      color: AppTheme.appScaffoldBackground,
      child: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Container(
              width: double.infinity,
              padding: const EdgeInsets.fromLTRB(24, 28, 24, 32),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [
                    AppTheme.maroon.withValues(alpha: 0.07),
                    AppTheme.appScaffoldBackground,
                    Colors.white,
                  ],
                  stops: const [0.0, 0.45, 1.0],
                ),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Dashboard',
                    style: theme.textTheme.headlineMedium?.copyWith(
                      fontWeight: FontWeight.w700,
                      letterSpacing: -0.6,
                      height: 1.2,
                      color: const Color(0xFF3A0B17),
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Manage cemetery records, sections, and content.',
                    style: theme.textTheme.bodyLarge?.copyWith(
                      color: Colors.black.withValues(alpha: 0.58),
                      height: 1.45,
                    ),
                  ),
                ],
              ),
            ),
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 4, 20, 32),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                const SizedBox(height: 24),
                Row(
                  children: [
                    Expanded(
                      child: _StatCard(
                        title: 'Deceased records',
                        value: '${data.deceased.length}',
                        icon: Icons.person_rounded,
                        color: theme.colorScheme.primary,
                        accent: true,
                        onTap: () => context.go('/deceased'),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: _StatCard(
                        title: 'Open maintenance',
                        value: '${data.openTicketsCount}',
                        icon: Icons.construction_rounded,
                        color: theme.colorScheme.error,
                        onTap: () => context.go('/maintenance'),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: _StatCard(
                        title: 'Sections / sites',
                        value: '${data.sections.length}',
                        icon: Icons.place_rounded,
                        color: theme.colorScheme.secondary,
                        onTap: () => context.go('/sections'),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 24),
                _DashPanel(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 22, vertical: 20),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Quick search',
                          style: theme.textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.w600,
                            color: const Color(0xFF3A0B17),
                          ),
                        ),
                        const SizedBox(height: 12),
                        Row(
                          children: [
                            Expanded(
                              child: TextField(
                                controller: _searchController,
                                decoration: const InputDecoration(
                                  hintText: 'Search by name…',
                                  prefixIcon: Icon(Icons.search_rounded),
                                ),
                                onSubmitted: (v) => _quickSearch(context, v, data.deceased),
                              ),
                            ),
                            const SizedBox(width: 12),
                            FilledButton(
                              onPressed: () => _quickSearch(
                                  context, _searchController.text, data.deceased),
                              child: const Text('Go'),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
                if (recentDeceased.isNotEmpty) ...[
                  const SizedBox(height: 20),
                  _DashPanel(
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 22, vertical: 20),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                'Recent deceased',
                                style: theme.textTheme.titleMedium?.copyWith(
                                  fontWeight: FontWeight.w600,
                                  color: const Color(0xFF3A0B17),
                                ),
                              ),
                              TextButton(
                                onPressed: () => context.go('/deceased'),
                                child: const Text('View all'),
                              ),
                            ],
                          ),
                          const SizedBox(height: 12),
                          ...recentDeceased.map((d) => ListTile(
                                contentPadding: EdgeInsets.zero,
                                title: Text(d.fullName),
                                subtitle: Text(
                                  '${d.sectionId ?? '—'} · ${d.plotNumber ?? '—'}',
                                  style: theme.textTheme.bodySmall,
                                ),
                                trailing: const Icon(Icons.chevron_right_rounded),
                                onTap: () => context.go('/deceased/${d.id}'),
                              )),
                        ],
                      ),
                    ),
                  ),
                ],
                const SizedBox(height: 24),
                _DashPanel(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 22, vertical: 24),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Quick actions',
                          style: theme.textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.w600,
                            color: const Color(0xFF3A0B17),
                          ),
                        ),
                        const SizedBox(height: 16),
                        Wrap(
                          spacing: 12,
                          runSpacing: 12,
                          children: [
                            FilledButton.icon(
                              onPressed: () => context.go('/deceased/new'),
                              icon: const Icon(Icons.add_rounded, size: 22),
                              label: const Text('Add deceased'),
                            ),
                            OutlinedButton.icon(
                              onPressed: () => context.go('/maintenance'),
                              icon: const Icon(Icons.construction_rounded, size: 22),
                              label: const Text('Maintenance'),
                            ),
                            OutlinedButton.icon(
                              onPressed: () => context.go('/sections'),
                              icon: const Icon(Icons.place_rounded, size: 22),
                              label: const Text('Sections'),
                            ),
                            OutlinedButton.icon(
                              onPressed: () => context.go('/settings'),
                              icon: const Icon(Icons.settings_rounded, size: 22),
                              label: const Text('Settings'),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
      ),
    );
  }
}

/// White panel aligned with web `.panel` (border + soft shadow).
class _DashPanel extends StatelessWidget {
  const _DashPanel({required this.child});

  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppTheme.hubCardBorderColor),
        boxShadow: AppTheme.cardElevationShadow,
      ),
      clipBehavior: Clip.antiAlias,
      child: child,
    );
  }
}

class _StatCard extends StatelessWidget {
  const _StatCard({
    required this.title,
    required this.value,
    required this.icon,
    required this.color,
    required this.onTap,
    this.accent = false,
  });

  final String title;
  final String value;
  final IconData icon;
  final Color color;
  final VoidCallback onTap;
  final bool accent;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(14),
        child: Ink(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(14),
            gradient: accent
                ? const LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [
                      Color(0xFFFFFFFF),
                      Color(0xFFFFF8FA),
                      Color(0xFFFCEEF2),
                    ],
                    stops: [0.0, 0.5, 1.0],
                  )
                : null,
            color: accent ? null : Colors.white,
            border: Border.all(
              color: accent
                  ? AppTheme.maroon.withValues(alpha: 0.14)
                  : AppTheme.hubCardBorderColor,
            ),
            boxShadow: AppTheme.cardElevationShadow,
          ),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 18),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(14),
                  decoration: BoxDecoration(
                    color: color.withValues(alpha: 0.12),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Icon(icon, size: 26, color: color),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        title.toUpperCase(),
                        style: theme.textTheme.labelSmall?.copyWith(
                          fontWeight: FontWeight.w600,
                          letterSpacing: 0.6,
                          color: Colors.black.withValues(alpha: 0.5),
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        value,
                        style: theme.textTheme.headlineSmall?.copyWith(
                          fontWeight: FontWeight.w700,
                          letterSpacing: -0.3,
                          color: const Color(0xFF1C1C1C),
                        ),
                      ),
                    ],
                  ),
                ),
                Icon(
                  Icons.chevron_right_rounded,
                  size: 24,
                  color: theme.colorScheme.onSurfaceVariant.withValues(alpha: 0.65),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
