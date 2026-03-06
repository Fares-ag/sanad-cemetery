import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:go_router/go_router.dart';
import '../../models/deceased.dart';
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

    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Container(
            width: double.infinity,
            padding: const EdgeInsets.fromLTRB(24, 32, 24, 36),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [
                  theme.colorScheme.primary.withValues(alpha: 0.08),
                  theme.colorScheme.surface,
                ],
              ),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Dashboard',
                  style: theme.textTheme.headlineMedium?.copyWith(
                    fontWeight: FontWeight.w700,
                    letterSpacing: -0.8,
                    height: 1.2,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  'Manage cemetery records, sections, and content.',
                  style: theme.textTheme.bodyLarge?.copyWith(
                    color: theme.colorScheme.onSurfaceVariant,
                    height: 1.4,
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
                Card(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 22, vertical: 20),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Quick search',
                          style: theme.textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.w600,
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
                  Card(
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
                Card(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 22, vertical: 24),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Quick actions',
                          style: theme.textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.w600,
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
  });

  final String title;
  final String value;
  final IconData icon;
  final Color color;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Card(
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 22, vertical: 20),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: color.withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(14),
                ),
                child: Icon(icon, size: 26, color: color),
              ),
              const SizedBox(width: 20),
              Expanded(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      value,
                      style: theme.textTheme.headlineSmall?.copyWith(
                        fontWeight: FontWeight.w600,
                        letterSpacing: -0.2,
                      ),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      title,
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: theme.colorScheme.onSurfaceVariant,
                        height: 1.35,
                      ),
                    ),
                  ],
                ),
              ),
              Icon(
                Icons.chevron_right_rounded,
                size: 24,
                color: theme.colorScheme.onSurfaceVariant.withValues(alpha: 0.7),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
