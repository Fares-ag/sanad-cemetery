import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:go_router/go_router.dart';
import '../../models/maintenance_ticket.dart';
import '../state/admin_data_provider.dart';

class MaintenanceListScreen extends StatefulWidget {
  const MaintenanceListScreen({super.key});

  @override
  State<MaintenanceListScreen> createState() => _MaintenanceListScreenState();
}

class _MaintenanceListScreenState extends State<MaintenanceListScreen> {
  TicketStatus? _filterStatus;

  @override
  Widget build(BuildContext context) {
    final data = context.watch<AdminDataProvider>();
    final theme = Theme.of(context);
    var list = data.tickets;
    if (_filterStatus != null) {
      list = list.where((t) => t.status == _filterStatus).toList();
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Container(
          width: double.infinity,
          padding: const EdgeInsets.fromLTRB(24, 32, 24, 24),
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
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Maintenance tickets',
                    style: theme.textTheme.headlineMedium?.copyWith(
                      fontWeight: FontWeight.w700,
                      letterSpacing: -0.8,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    '${data.openTicketsCount} open · ${list.length} shown',
                    style: theme.textTheme.bodyLarge?.copyWith(
                      color: theme.colorScheme.onSurfaceVariant,
                      height: 1.4,
                    ),
                  ),
                ],
              ),
              Row(
                children: [
                  DropdownButton<TicketStatus?>(
                    value: _filterStatus,
                    hint: const Text('Filter'),
                    items: [
                      const DropdownMenuItem(value: null, child: Text('All')),
                      ...TicketStatus.values
                          .map((s) => DropdownMenuItem(value: s, child: Text(s.displayName))),
                    ],
                    onChanged: (v) => setState(() => _filterStatus = v),
                  ),
                  const SizedBox(width: 12),
                  FilledButton.icon(
                    onPressed: () => _showAddTicketDialog(context),
                    icon: const Icon(Icons.add_rounded, size: 22),
                    label: const Text('Add ticket'),
                  ),
                ],
              ),
            ],
          ),
        ),
        Expanded(
          child: list.isEmpty
              ? Center(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        Icons.construction_rounded,
                        size: 64,
                        color: theme.colorScheme.outline.withValues(alpha: 0.6),
                      ),
                      const SizedBox(height: 16),
                      Text(
                        _filterStatus != null ? 'No tickets with this status' : 'No tickets yet',
                        style: theme.textTheme.titleLarge,
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'Add a ticket or connect the app to sync reports.',
                        style: theme.textTheme.bodyMedium?.copyWith(
                          color: theme.colorScheme.onSurfaceVariant,
                        ),
                      ),
                      const SizedBox(height: 24),
                      FilledButton.icon(
                        onPressed: () => _showAddTicketDialog(context),
                        icon: const Icon(Icons.add_rounded),
                        label: const Text('Add ticket'),
                      ),
                    ],
                  ),
                )
              : ListView.builder(
                  padding: const EdgeInsets.fromLTRB(20, 8, 20, 32),
                  itemCount: list.length,
                  itemBuilder: (context, index) {
                    final t = list[index];
                    return _TicketCard(
                      ticket: t,
                      onTap: () => context.go('/maintenance/${t.id}'),
                    );
                  },
                ),
        ),
      ],
    );
  }

  void _showAddTicketDialog(BuildContext context) {
    var category = 'sunkenGrave';
    var description = '';
    var lat = 25.196;
    var lon = 51.487;
    showDialog(
      context: context,
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setDialog) {
          return AlertDialog(
            title: const Text('Add maintenance ticket'),
            content: SizedBox(
              width: 400,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  DropdownButtonFormField<String>(
                    value: category,
                    decoration: const InputDecoration(labelText: 'Category'),
                    items: ['sunkenGrave', 'damagedStone', 'overgrownGrass', 'other']
                        .map((k) => DropdownMenuItem(value: k, child: Text(k)))
                        .toList(),
                    onChanged: (v) => setDialog(() => category = v ?? category),
                  ),
                  const SizedBox(height: 12),
                  TextFormField(
                    initialValue: description,
                    decoration: const InputDecoration(labelText: 'Description'),
                    maxLines: 2,
                    onChanged: (v) => description = v,
                  ),
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      Expanded(
                        child: TextFormField(
                          initialValue: lat.toString(),
                          decoration: const InputDecoration(labelText: 'Lat'),
                          onChanged: (v) => lat = double.tryParse(v) ?? lat,
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: TextFormField(
                          initialValue: lon.toString(),
                          decoration: const InputDecoration(labelText: 'Lon'),
                          onChanged: (v) => lon = double.tryParse(v) ?? lon,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            actions: [
              TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Cancel')),
              FilledButton(
                onPressed: () {
                  final provider = ctx.read<AdminDataProvider>();
                  provider.addTicket(MaintenanceTicket(
                    id: provider.newTicketId(),
                    category: category,
                    description: description.isEmpty ? null : description,
                    photoPath: '',
                    lat: lat,
                    lon: lon,
                    status: TicketStatus.reported,
                    createdAt: DateTime.now(),
                  ));
                  Navigator.pop(ctx);
                },
                child: const Text('Add'),
              ),
            ],
          );
        },
      ),
    );
  }
}

class _TicketCard extends StatelessWidget {
  const _TicketCard({required this.ticket, required this.onTap});

  final MaintenanceTicket ticket;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isResolved = ticket.status == TicketStatus.resolved;

    return Card(
      margin: const EdgeInsets.only(bottom: 6),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 22, vertical: 16),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: (isResolved ? theme.colorScheme.primary : theme.colorScheme.error)
                      .withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(14),
                ),
                child: Icon(
                  isResolved ? Icons.check_circle_rounded : Icons.construction_rounded,
                  color: isResolved ? theme.colorScheme.primary : theme.colorScheme.error,
                  size: 24,
                ),
              ),
              const SizedBox(width: 18),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      ticket.category,
                      style: theme.textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      '${ticket.status.displayName} · ${ticket.createdAt.toString().substring(0, 16)}',
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: theme.colorScheme.onSurfaceVariant,
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
