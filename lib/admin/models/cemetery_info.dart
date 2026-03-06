/// Cemetery contact and display info (name, address, hours, etc.).
class CemeteryInfo {
  final String name;
  final String? address;
  final String? contactPhone;
  final String? contactEmail;
  final String? openingHours;
  final String? description;

  const CemeteryInfo({
    this.name = 'Sanad Cemetery',
    this.address,
    this.contactPhone,
    this.contactEmail,
    this.openingHours,
    this.description,
  });

  factory CemeteryInfo.fromJson(Map<String, dynamic>? json) {
    if (json == null) return const CemeteryInfo();
    return CemeteryInfo(
      name: json['name'] as String? ?? 'Sanad Cemetery',
      address: json['address'] as String?,
      contactPhone: json['contactPhone'] as String?,
      contactEmail: json['contactEmail'] as String?,
      openingHours: json['openingHours'] as String?,
      description: json['description'] as String?,
    );
  }

  Map<String, dynamic> toJson() => {
        'name': name,
        'address': address,
        'contactPhone': contactPhone,
        'contactEmail': contactEmail,
        'openingHours': openingHours,
        'description': description,
      };

  CemeteryInfo copyWith({
    String? name,
    String? address,
    String? contactPhone,
    String? contactEmail,
    String? openingHours,
    String? description,
  }) {
    return CemeteryInfo(
      name: name ?? this.name,
      address: address ?? this.address,
      contactPhone: contactPhone ?? this.contactPhone,
      contactEmail: contactEmail ?? this.contactEmail,
      openingHours: openingHours ?? this.openingHours,
      description: description ?? this.description,
    );
  }
}
