/// Portal role (demo / future SSO). Drives priority flags and menu visibility.
enum UserRole {
  visitor,
  municipalityCrew,
  ministryMunicipality,
  admin,
  superAdmin,
}

extension UserRoleX on UserRole {
  bool get hasStaffPrivileges =>
      this == UserRole.municipalityCrew ||
      this == UserRole.ministryMunicipality ||
      this == UserRole.admin ||
      this == UserRole.superAdmin;
}
