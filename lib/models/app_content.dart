/// Cemetery contact / hours — optional; may come from API or bundled fallback.
class SiteInfo {
  const SiteInfo({
    this.openingHours,
    this.openingHoursAr,
    this.phone,
    this.website,
  });

  final String? openingHours;
  final String? openingHoursAr;
  final String? phone;
  final String? website;

  factory SiteInfo.fromJson(Map<String, dynamic> json) {
    return SiteInfo(
      openingHours: json['openingHours'] as String?,
      openingHoursAr: json['openingHoursAr'] as String?,
      phone: json['phone'] as String?,
      website: json['website'] as String?,
    );
  }
}

/// One line of overlay copy on the mobile home hero carousel.
class HomeHeroSlide {
  const HomeHeroSlide({required this.text, this.textAr});

  final String text;
  final String? textAr;

  factory HomeHeroSlide.fromJson(Map<String, dynamic> json) {
    return HomeHeroSlide(
      text: json['text'] as String? ?? '',
      textAr: json['textAr'] as String?,
    );
  }
}

/// Municipality-editable home hero: background image URL + carousel lines + primary button labels.
class HomeHeroConfig {
  const HomeHeroConfig({
    this.imageUrl,
    required this.slides,
    this.reportCtaEn,
    this.reportCtaAr,
  });

  /// HTTPS URL to a wide image; empty → bundled asset in the app.
  final String? imageUrl;
  final List<HomeHeroSlide> slides;
  final String? reportCtaEn;
  final String? reportCtaAr;

  factory HomeHeroConfig.fromJson(Map<String, dynamic> json) {
    final raw = json['slides'];
    final list = raw is List
        ? raw
            .map((e) => HomeHeroSlide.fromJson(Map<String, dynamic>.from(e as Map)))
            .where((s) => s.text.trim().isNotEmpty)
            .toList()
        : <HomeHeroSlide>[];
    return HomeHeroConfig(
      imageUrl: json['imageUrl'] as String?,
      slides: list,
      reportCtaEn: json['reportCtaEn'] as String?,
      reportCtaAr: json['reportCtaAr'] as String?,
    );
  }
}

/// Public app content from the municipality content API (burial announcements + ministry headline).
class MinistryPublicStats {
  const MinistryPublicStats({
    required this.deceasedToday,
    required this.deceasedThisMonth,
    this.feedNote,
    this.feedNoteAr,
  });

  final int deceasedToday;
  final int deceasedThisMonth;
  final String? feedNote;
  final String? feedNoteAr;

  factory MinistryPublicStats.fromJson(Map<String, dynamic> json) {
    return MinistryPublicStats(
      deceasedToday: (json['deceasedToday'] as num?)?.toInt() ?? 0,
      deceasedThisMonth: (json['deceasedThisMonth'] as num?)?.toInt() ?? 0,
      feedNote: json['feedNote'] as String?,
      feedNoteAr: json['feedNoteAr'] as String?,
    );
  }
}

class AppAnnouncement {
  const AppAnnouncement({
    required this.id,
    required this.name,
    this.nameAr,
    required this.passedAwayDate,
    required this.serviceType,
    required this.serviceDateTime,
    required this.burialLocation,
    this.burialLocationAr,
    this.iconKey,
  });

  final String id;
  final String name;
  final String? nameAr;
  /// ISO date string `YYYY-MM-DD`
  final String passedAwayDate;
  final String serviceType;
  final String serviceDateTime;
  final String burialLocation;
  final String? burialLocationAr;
  final String? iconKey;

  factory AppAnnouncement.fromJson(Map<String, dynamic> json) {
    return AppAnnouncement(
      id: json['id'] as String? ?? '',
      name: json['name'] as String? ?? '',
      nameAr: json['nameAr'] as String?,
      passedAwayDate: json['passedAwayDate'] as String? ?? '',
      serviceType: json['serviceType'] as String? ?? 'funeral_prayers',
      serviceDateTime: json['serviceDateTime'] as String? ?? '',
      burialLocation: json['burialLocation'] as String? ?? '',
      burialLocationAr: json['burialLocationAr'] as String?,
      iconKey: json['iconKey'] as String?,
    );
  }
}

class AppContentPayload {
  const AppContentPayload({
    required this.ministryStats,
    required this.announcements,
    this.siteInfo,
    this.homeHero,
  });

  final MinistryPublicStats ministryStats;
  final List<AppAnnouncement> announcements;
  final SiteInfo? siteInfo;
  final HomeHeroConfig? homeHero;

  factory AppContentPayload.fromJson(Map<String, dynamic> json) {
    final raw = json['announcements'];
    final list = raw is List
        ? raw
            .map((e) => AppAnnouncement.fromJson(Map<String, dynamic>.from(e as Map)))
            .toList()
        : <AppAnnouncement>[];
    return AppContentPayload(
      ministryStats: MinistryPublicStats.fromJson(
        Map<String, dynamic>.from(json['ministryStats'] as Map? ?? {}),
      ),
      announcements: list,
      siteInfo: json['siteInfo'] is Map
          ? SiteInfo.fromJson(Map<String, dynamic>.from(json['siteInfo'] as Map))
          : null,
      homeHero: json['homeHero'] is Map
          ? HomeHeroConfig.fromJson(Map<String, dynamic>.from(json['homeHero'] as Map))
          : null,
    );
  }
}
