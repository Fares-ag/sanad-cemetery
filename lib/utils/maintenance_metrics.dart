import '../models/maintenance_ticket.dart';

/// Open backlog: not yet resolved.
int countOpenMaintenanceTickets(List<MaintenanceTicket> tickets) {
  return tickets.where((t) => t.status == TicketStatus.reported || t.status == TicketStatus.inProgress).length;
}

int countResolvedMaintenanceTickets(List<MaintenanceTicket> tickets) {
  return tickets.where((t) => t.status == TicketStatus.resolved).length;
}

/// Tickets created within the last 7 days (intake).
int countCreatedLast7Days(List<MaintenanceTicket> tickets, DateTime now) {
  final cutoff = now.subtract(const Duration(days: 7));
  return tickets.where((t) => !t.createdAt.isBefore(cutoff)).length;
}

/// Tickets marked resolved with a timestamp in the last 7 days.
int countResolvedLast7Days(List<MaintenanceTicket> tickets, DateTime now) {
  final cutoff = now.subtract(const Duration(days: 7));
  return tickets.where((t) {
    if (t.status != TicketStatus.resolved) return false;
    final when = t.updatedAt ?? t.createdAt;
    return !when.isBefore(cutoff);
  }).length;
}
