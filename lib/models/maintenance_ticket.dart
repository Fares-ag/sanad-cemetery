/// Maintenance request ticket (sunken grave, damaged stone, overgrown grass, etc.).
class MaintenanceTicket {
  final String id;
  final String category; // Sunken Grave, Damaged Stone, Overgrown Grass, Other
  final String? description;
  final String photoPath; // local or uploaded URL
  final double lat;
  final double lon;
  final String? graveId; // tombstone ID when reported via QR scan
  final TicketStatus status;
  final DateTime createdAt;
  final DateTime? updatedAt;
  final String? reportedByUserId;
  /// Ministry of Awqaf / high-priority channel (demo flag for future SLA).
  final bool highPriorityFromAwqaf;
  final String? submittedByRole;

  const MaintenanceTicket({
    required this.id,
    required this.category,
    this.description,
    required this.photoPath,
    required this.lat,
    required this.lon,
    this.graveId,
    this.status = TicketStatus.reported,
    required this.createdAt,
    this.updatedAt,
    this.reportedByUserId,
    this.highPriorityFromAwqaf = false,
    this.submittedByRole,
  });

  factory MaintenanceTicket.fromJson(Map<String, dynamic> json) {
    return MaintenanceTicket(
      id: json['id'] as String,
      category: json['category'] as String,
      description: json['description'] as String?,
      photoPath: json['photoPath'] as String,
      lat: (json['lat'] as num).toDouble(),
      lon: (json['lon'] as num).toDouble(),
      graveId: json['graveId'] as String?,
      status: TicketStatus.values.byName((json['status'] as String?) ?? 'reported'),
      createdAt: DateTime.parse(json['createdAt'] as String),
      updatedAt: json['updatedAt'] != null ? DateTime.parse(json['updatedAt'] as String) : null,
      reportedByUserId: json['reportedByUserId'] as String?,
      highPriorityFromAwqaf: json['highPriorityFromAwqaf'] as bool? ?? false,
      submittedByRole: json['submittedByRole'] as String?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'category': category,
      'description': description,
      'photoPath': photoPath,
      'lat': lat,
      'lon': lon,
      'graveId': graveId,
      'status': status.name,
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt?.toIso8601String(),
      'reportedByUserId': reportedByUserId,
      'highPriorityFromAwqaf': highPriorityFromAwqaf,
      'submittedByRole': submittedByRole,
    };
  }
}

enum TicketStatus {
  reported,
  inProgress,
  resolved,
}

extension TicketStatusX on TicketStatus {
  String get displayName {
    switch (this) {
      case TicketStatus.reported:
        return 'Reported';
      case TicketStatus.inProgress:
        return 'In Progress';
      case TicketStatus.resolved:
        return 'Resolved';
    }
  }
}
