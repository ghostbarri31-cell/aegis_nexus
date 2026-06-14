class AppSettings {
  const AppSettings({
    this.darkTheme = true,
    this.notifications = true,
    this.analytics = false,
    this.language = 'English',
    this.apiBaseUrl = 'http://localhost:3000/api/v1',
    this.voiceLocale = 'en_US',
    this.syncWithApi = true,
  });

  final bool darkTheme;
  final bool notifications;
  final bool analytics;
  final String language;
  final String apiBaseUrl;
  final String voiceLocale;
  final bool syncWithApi;

  static const supportedLanguages = [
    'English',
    'Français',
    'Español',
    'Deutsch',
  ];

  AppSettings copyWith({
    bool? darkTheme,
    bool? notifications,
    bool? analytics,
    String? language,
    String? apiBaseUrl,
    String? voiceLocale,
    bool? syncWithApi,
  }) {
    return AppSettings(
      darkTheme: darkTheme ?? this.darkTheme,
      notifications: notifications ?? this.notifications,
      analytics: analytics ?? this.analytics,
      language: language ?? this.language,
      apiBaseUrl: apiBaseUrl ?? this.apiBaseUrl,
      voiceLocale: voiceLocale ?? this.voiceLocale,
      syncWithApi: syncWithApi ?? this.syncWithApi,
    );
  }

  Map<String, dynamic> toJson() => {
        'darkTheme': darkTheme,
        'notifications': notifications,
        'analytics': analytics,
        'language': language,
        'apiBaseUrl': apiBaseUrl,
        'voiceLocale': voiceLocale,
        'syncWithApi': syncWithApi,
      };

  factory AppSettings.fromJson(Map<String, dynamic> json) {
    return AppSettings(
      darkTheme: json['darkTheme'] as bool? ?? true,
      notifications: json['notifications'] as bool? ?? true,
      analytics: json['analytics'] as bool? ?? false,
      language: json['language'] as String? ?? 'English',
      apiBaseUrl: json['apiBaseUrl'] as String? ?? 'http://localhost:3000/api/v1',
      voiceLocale: json['voiceLocale'] as String? ?? 'en_US',
      syncWithApi: json['syncWithApi'] as bool? ?? true,
    );
  }
}
