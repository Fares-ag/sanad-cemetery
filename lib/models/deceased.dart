/// Deceased record (digital memorial).
class Deceased {
  final String id;
  final String firstName;
  final String middleName;
  final String lastName;
  final String? maidenName;
  final DateTime? birthDate;
  final DateTime? deathDate;
  final bool isVeteran;
  final String? branchOfService;
  final double lat;
  final double lon;
  final String? sectionId;
  final String? plotNumber;
  final String? bioHtml;
  final List<String> imageUrls;
  final String? legacyVideoUrl;
  final int legacyVideoDurationSeconds;
  final List<FamilyLink> familyLinks;
  final List<Tribute> tributes;
  final String? qrCodeData; // UID or deep link for QR

  const Deceased({
    required this.id,
    required this.firstName,
    this.middleName = '',
    required this.lastName,
    this.maidenName,
    this.birthDate,
    this.deathDate,
    this.isVeteran = false,
    this.branchOfService,
    required this.lat,
    required this.lon,
    this.sectionId,
    this.plotNumber,
    this.bioHtml,
    this.imageUrls = const [],
    this.legacyVideoUrl,
    this.legacyVideoDurationSeconds = 30,
    this.familyLinks = const [],
    this.tributes = const [],
    this.qrCodeData,
  });

  String get fullName {
    final parts = [firstName, if (middleName.isNotEmpty) middleName, lastName];
    return parts.join(' ');
  }

  int? get birthYear => birthDate?.year;
  int? get deathYear => deathDate?.year;

  String get deepLink => 'myapp://grave/$id';

  factory Deceased.fromJson(Map<String, dynamic> json) {
    return Deceased(
      id: json['id'] as String,
      firstName: json['firstName'] as String,
      middleName: json['middleName'] as String? ?? '',
      lastName: json['lastName'] as String,
      maidenName: json['maidenName'] as String?,
      birthDate: json['birthDate'] != null ? DateTime.tryParse(json['birthDate'] as String) : null,
      deathDate: json['deathDate'] != null ? DateTime.tryParse(json['deathDate'] as String) : null,
      isVeteran: json['isVeteran'] as bool? ?? false,
      branchOfService: json['branchOfService'] as String?,
      lat: (json['lat'] as num).toDouble(),
      lon: (json['lon'] as num).toDouble(),
      sectionId: json['sectionId'] as String?,
      plotNumber: json['plotNumber'] as String?,
      bioHtml: json['bioHtml'] as String?,
      imageUrls: (json['imageUrls'] as List<dynamic>?)?.map((e) => e as String).toList() ?? [],
      legacyVideoUrl: json['legacyVideoUrl'] as String?,
      legacyVideoDurationSeconds: json['legacyVideoDurationSeconds'] as int? ?? 30,
      familyLinks: (json['familyLinks'] as List<dynamic>?)
          ?.map((e) => FamilyLink.fromJson(e as Map<String, dynamic>))
          .toList() ?? [],
      tributes: (json['tributes'] as List<dynamic>?)
          ?.map((e) => Tribute.fromJson(e as Map<String, dynamic>))
          .toList() ?? [],
      qrCodeData: json['qrCodeData'] as String?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'firstName': firstName,
      'middleName': middleName,
      'lastName': lastName,
      'maidenName': maidenName,
      'birthDate': birthDate?.toIso8601String(),
      'deathDate': deathDate?.toIso8601String(),
      'isVeteran': isVeteran,
      'branchOfService': branchOfService,
      'lat': lat,
      'lon': lon,
      'sectionId': sectionId,
      'plotNumber': plotNumber,
      'bioHtml': bioHtml,
      'imageUrls': imageUrls,
      'legacyVideoUrl': legacyVideoUrl,
      'legacyVideoDurationSeconds': legacyVideoDurationSeconds,
      'familyLinks': familyLinks.map((e) => e.toJson()).toList(),
      'tributes': tributes.map((e) => e.toJson()).toList(),
      'qrCodeData': qrCodeData ?? deepLink,
    };
  }
}

class FamilyLink {
  final String label; // "Parent", "Spouse", "Child"
  final String deceasedId;
  final String name;

  const FamilyLink({required this.label, required this.deceasedId, required this.name});

  factory FamilyLink.fromJson(Map<String, dynamic> json) {
    return FamilyLink(
      label: json['label'] as String,
      deceasedId: json['deceasedId'] as String,
      name: json['name'] as String,
    );
  }

  Map<String, dynamic> toJson() => {'label': label, 'deceasedId': deceasedId, 'name': name};
}

/// Digital flower / tribute visible for 24 hours.
class Tribute {
  final String id;
  final DateTime placedAt;
  final String? senderName;
  final String iconType; // e.g. "flower", "candle"

  const Tribute({
    required this.id,
    required this.placedAt,
    this.senderName,
    this.iconType = 'flower',
  });

  bool get isExpired => DateTime.now().difference(placedAt).inHours >= 24;

  factory Tribute.fromJson(Map<String, dynamic> json) {
    return Tribute(
      id: json['id'] as String,
      placedAt: DateTime.parse(json['placedAt'] as String),
      senderName: json['senderName'] as String?,
      iconType: json['iconType'] as String? ?? 'flower',
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'placedAt': placedAt.toIso8601String(),
        'senderName': senderName,
        'iconType': iconType,
      };
}
