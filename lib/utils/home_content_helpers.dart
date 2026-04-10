import '../models/app_content.dart';

/// Next funeral prayer or burial with `serviceDateTime` strictly after [now], earliest first.
AppAnnouncement? nextUpcomingAnnouncement(List<AppAnnouncement> list, DateTime now) {
  final upcoming = <AppAnnouncement>[];
  for (final a in list) {
    final t = DateTime.tryParse(a.serviceDateTime);
    if (t != null && t.isAfter(now)) {
      upcoming.add(a);
    }
  }
  if (upcoming.isEmpty) return null;
  upcoming.sort((a, b) => DateTime.parse(a.serviceDateTime).compareTo(DateTime.parse(b.serviceDateTime)));
  return upcoming.first;
}
