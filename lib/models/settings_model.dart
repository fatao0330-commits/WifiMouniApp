class SettingsModel {
  final String language;
  final bool notificationsEnabled;
  final bool darkModeEnabled;

  const SettingsModel({
    required this.language,
    required this.notificationsEnabled,
    required this.darkModeEnabled,
  });

  factory SettingsModel.fromMap(
    Map<String, dynamic>? data,
  ) {
    return SettingsModel(
      language: data?["language"] ?? "fr",
      notificationsEnabled:
          data?["notificationsEnabled"] ?? true,
      darkModeEnabled:
          data?["darkModeEnabled"] ?? false,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      "language": language,
      "notificationsEnabled":
          notificationsEnabled,
      "darkModeEnabled":
          darkModeEnabled,
    };
  }

  SettingsModel copyWith({
    String? language,
    bool? notificationsEnabled,
    bool? darkModeEnabled,
  }) {
    return SettingsModel(
      language:
          language ?? this.language,
      notificationsEnabled:
          notificationsEnabled ??
              this.notificationsEnabled,
      darkModeEnabled:
          darkModeEnabled ??
              this.darkModeEnabled,
    );
  }
}