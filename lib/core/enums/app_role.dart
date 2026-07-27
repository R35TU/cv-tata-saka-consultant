enum AppRole {
  konsultan,
  kontraktor,
  dinas,
  eksternal;

  static AppRole fromString(String value) {
    return AppRole.values.firstWhere(
      (role) => role.name.toLowerCase() == value.toLowerCase(),
      orElse: () => AppRole.eksternal,
    );
  }

  String get label {
    switch (this) {
      case AppRole.konsultan:
        return 'Konsultan';
      case AppRole.kontraktor:
        return 'Kontraktor';
      case AppRole.dinas:
        return 'Dinas';
      case AppRole.eksternal:
        return 'Eksternal';
    }
  }

  bool get canManageAdministration => this == AppRole.konsultan;
  bool get canManageProjects => this == AppRole.konsultan;
  bool get canManageUsers => this == AppRole.konsultan;
  bool get canManageReports => this == AppRole.konsultan || this == AppRole.kontraktor;
  bool get canViewAllProjects => this == AppRole.konsultan || this == AppRole.dinas;
  bool get canViewSensitiveAdministration => this == AppRole.konsultan || this == AppRole.dinas;
  bool get canViewInternalDocuments => this != AppRole.eksternal;
  bool get canCreateProject => this == AppRole.konsultan;
  bool get canEditProject => this == AppRole.konsultan;
  bool get canDeleteProject => this == AppRole.konsultan;
  bool get canUploadContractorReport => this == AppRole.kontraktor;
  bool get canInputSupervisorReport => this == AppRole.konsultan;
  bool get canVerifyReport => this == AppRole.konsultan;
  bool get isKonsultan => this == AppRole.konsultan;
  bool get isKontraktor => this == AppRole.kontraktor;
  bool get isDinas => this == AppRole.dinas;
  bool get isEksternal => this == AppRole.eksternal;
}
