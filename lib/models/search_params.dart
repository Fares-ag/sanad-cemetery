/// Search parameters for global search (fuzzy + filters).
class SearchParams {
  final String? firstName;
  final String? middleName;
  final String? lastName;
  final String? maidenName;
  final int? birthYearFrom;
  final int? birthYearTo;
  final int? deathYearFrom;
  final int? deathYearTo;
  final bool? isVeteran;
  final String? branchOfService;

  const SearchParams({
    this.firstName,
    this.middleName,
    this.lastName,
    this.maidenName,
    this.birthYearFrom,
    this.birthYearTo,
    this.deathYearFrom,
    this.deathYearTo,
    this.isVeteran,
    this.branchOfService,
  });

  bool get hasAnyFilter =>
      firstName != null ||
      middleName != null ||
      lastName != null ||
      maidenName != null ||
      birthYearFrom != null ||
      birthYearTo != null ||
      deathYearFrom != null ||
      deathYearTo != null ||
      isVeteran != null ||
      (branchOfService != null && branchOfService!.isNotEmpty);

  SearchParams copyWith({
    String? firstName,
    String? middleName,
    String? lastName,
    String? maidenName,
    int? birthYearFrom,
    int? birthYearTo,
    int? deathYearFrom,
    int? deathYearTo,
    bool? isVeteran,
    String? branchOfService,
  }) {
    return SearchParams(
      firstName: firstName ?? this.firstName,
      middleName: middleName ?? this.middleName,
      lastName: lastName ?? this.lastName,
      maidenName: maidenName ?? this.maidenName,
      birthYearFrom: birthYearFrom ?? this.birthYearFrom,
      birthYearTo: birthYearTo ?? this.birthYearTo,
      deathYearFrom: deathYearFrom ?? this.deathYearFrom,
      deathYearTo: deathYearTo ?? this.deathYearTo,
      isVeteran: isVeteran ?? this.isVeteran,
      branchOfService: branchOfService ?? this.branchOfService,
    );
  }
}
