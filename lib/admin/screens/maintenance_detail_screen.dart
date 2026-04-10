import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:go_router/go_router.dart';
import '../../models/maintenance_ticket.dart';
import '../../utils/date_format.dart';
import '../../utils/locale_digits.dart';
import '../state/admin_data_provider.dart';

class MaintenanceDetailScreen extends StatelessWidget {
  const MaintenanceDetailScreen({super.key, required this.ticketId});

  final String ticketId;

  @override
  Widget build(BuildContext context) {
    final data = context.watch<AdminDataProvider>();
    final ticket = data.getTicketById(ticketId);
    final theme = Theme.of(context);

    if (ticket == null) {
      return Scaffold(
        body: Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(Icons.error_outline_rounded, size: 48),
              const SizedBox(height: 16),
              const Text('Ticket not found'),
              const SizedBox(height: 24),
              TextButton(
                onPressed: () => context.go('/maintenance'),
                child: const Text('Back to list'),
              ),
            ],
          ),
        ),
      );
    }

    final note = data.getTicketNote(ticketId) ?? '';
    final deceased = ticket.graveId != null ? data.getDeceasedById(ticket.graveId!) : null;

    return SingleChildScrollView(
      padding: const EdgeInsets.fromLTRB(24, 24, 24, 32),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            children: [
              IconButton(
                icon: const Icon(Icons.arrow_back_rounded),
                onPressed: () => context.go('/maintenance'),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  ticket.category,
                  style: theme.textTheme.headlineSmall?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 24),
          Card(
            child: Padding(
              padding: const EdgeInsets.all(24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                        decoration: BoxDecoration(
                          color: theme.colorScheme.primaryContainer.withValues(alpha: 0.5),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Text(
                          ticket.status.displayName,
                          style: TextStyle(
                            fontWeight: FontWeight.w600,
                            color: theme.colorScheme.onPrimaryContainer,
                          ),
                        ),
                      ),
                      const Spacer(),
                      DropdownButton<TicketStatus>(
                        value: ticket.status,
                        items: TicketStatus.values
                            .map((s) => DropdownMenuItem(
                                  value: s,
                                  child: Text(s.displayName),
                                ))
                            .toList(),
                        onChanged: (v) {
                          if (v != null) {
                            context.read<AdminDataProvider>().updateTicketStatus(ticketId, v);
                          }
                        },
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  Text('Created: ${formatDateTimeCompact(context, ticket.createdAt)}'),
                  if (ticket.updatedAt != null) Text('Updated: ${formatDateTimeCompact(context, ticket.updatedAt!)}'),
                  if (ticket.description != null && ticket.description!.isNotEmpty) ...[
                    const SizedBox(height: 12),
                    Text(
                      ticket.description!,
                      style: theme.textTheme.bodyMedium,
                    ),
                  ],
                  const SizedBox(height: 12),
                  Text(
                    'Location: ${localizeWesternDigitsForDisplay(context, '${ticket.lat.toStringAsFixed(5)}, ${ticket.lon.toStringAsFixed(5)}')}',
                    style: theme.textTheme.bodySmall,
                  ),
                  if (deceased != null) ...[
                    const SizedBox(height: 8),
                    Text(
                      'Linked grave: ${deceased.fullName} (${localizeWesternDigitsForDisplay(context, ticket.graveId ?? '')})',
                      style: theme.textTheme.bodySmall,
                    ),
                  ],
                ],
              ),
            ),
          ),
          const SizedBox(height: 20),
          Card(
            child: Padding(
              padding: const EdgeInsets.all(24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Admin notes',
                    style: theme.textTheme.titleSmall?.copyWith(
                      fontWeight: FontWeight.w600,
                      color: theme.colorScheme.primary,
                    ),
                  ),
                  const SizedBox(height: 12),
                  TextFormField(
                    initialValue: note,
                    decoration: const InputDecoration(
                      hintText: 'Internal notes (not visible to reporter)',
                    ),
                    maxLines: 4,
                    onChanged: (v) {
                      context.read<AdminDataProvider>().setTicketNote(ticketId, v);
                    },
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 24),
          Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              TextButton.icon(
                onPressed: () async {
                  final ok = await showDialog<bool>(
                    context: context,
                    builder: (ctx) => AlertDialog(
                      title: const Text('Delete ticket?'),
                      content: const Text('This cannot be undone.'),
                      actions: [
                        TextButton(
                            onPressed: () => Navigator.pop(ctx, false),
                            child: const Text('Cancel')),
                        FilledButton(
                            onPressed: () => Navigator.pop(ctx, true),
                            style: FilledButton.styleFrom(
                              backgroundColor: theme.colorScheme.error,
                            ),
                            child: const Text('Delete')),
                      ],
                    ),
                  );
                  if (ok == true && context.mounted) {
                    context.read<AdminDataProvider>().deleteTicket(ticketId);
                    context.go('/maintenance');
                  }
                },
                icon: Icon(Icons.delete_rounded, color: theme.colorScheme.error),
                label: Text('Delete', style: TextStyle(color: theme.colorScheme.error)),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
