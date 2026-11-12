import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

class PrayerNotificationConfig {
  bool enabled;
  int minutesBefore; // 0, 15, 30, 45
  String soundType; // 'ezan_ismail_cosar', 'tekbir', 'bip', 'sessiz'
  bool vibrate;

  PrayerNotificationConfig({
    required this.enabled,
    required this.minutesBefore,
    required this.soundType,
    this.vibrate = true,
  });

  Map<String, dynamic> toJson() => {
        'enabled': enabled,
        'minutesBefore': minutesBefore,
        'soundType': soundType,
        'vibrate': vibrate,
      };

  factory PrayerNotificationConfig.fromJson(Map<String, dynamic> json) =>
      PrayerNotificationConfig(
        enabled: json['enabled'] ?? true,
        minutesBefore: json['minutesBefore'] ?? 0,
        soundType: json['soundType'] ?? 'tekbir',
        vibrate: json['vibrate'] ?? true,
      );
}

class AppNotificationSettings {
  bool generalEnabled;
  String defaultSound;
  bool generalVibrate;
  Map<String, PrayerNotificationConfig> prayerConfigs;

  AppNotificationSettings({
    this.generalEnabled = true,
    this.defaultSound = 'tekbir',
    this.generalVibrate = true,
    required this.prayerConfigs,
  });

  factory AppNotificationSettings.defaults() {
    return AppNotificationSettings(
      generalEnabled: true,
      defaultSound: 'tekbir',
      generalVibrate: true,
      prayerConfigs: {
        'imsak': PrayerNotificationConfig(
          enabled: true,
          minutesBefore: 45, // Sahur alarm
          soundType: 'tekbir',
        ),
        'gunes': PrayerNotificationConfig(
          enabled: false,
          minutesBefore: 15,
          soundType: 'bip',
        ),
        'ogle': PrayerNotificationConfig(
          enabled: true,
          minutesBefore: 0,
          soundType: 'ezan_ismail_cosar',
        ),
        'ikindi': PrayerNotificationConfig(
          enabled: true,
          minutesBefore: 0,
          soundType: 'ezan_ismail_cosar',
        ),
        'aksam': PrayerNotificationConfig(
          enabled: true,
          minutesBefore: 0,
          soundType: 'ezan_ismail_cosar',
        ),
        'yatsi': PrayerNotificationConfig(
          enabled: true,
          minutesBefore: 0,
          soundType: 'ezan_ismail_cosar',
        ),
      },
    );
  }

  Map<String, dynamic> toJson() => {
        'generalEnabled': generalEnabled,
        'defaultSound': defaultSound,
        'generalVibrate': generalVibrate,
        'prayerConfigs':
            prayerConfigs.map((k, v) => MapEntry(k, v.toJson())),
      };

  factory AppNotificationSettings.fromJson(Map<String, dynamic> json) {
    final rawPrayers = json['prayerConfigs'] as Map<String, dynamic>? ?? {};
    final prayerMap = <String, PrayerNotificationConfig>{};
    for (final entry in rawPrayers.entries) {
      if (entry.value is Map<String, dynamic>) {
        prayerMap[entry.key] =
            PrayerNotificationConfig.fromJson(entry.value as Map<String, dynamic>);
      }
    }

    final defaults = AppNotificationSettings.defaults();
    for (final key in defaults.prayerConfigs.keys) {
      if (!prayerMap.containsKey(key)) {
        prayerMap[key] = defaults.prayerConfigs[key]!;
      }
    }

    return AppNotificationSettings(
      generalEnabled: json['generalEnabled'] ?? true,
      defaultSound: json['defaultSound'] ?? 'tekbir',
      generalVibrate: json['generalVibrate'] ?? true,
      prayerConfigs: prayerMap,
    );
  }
}

class NotificationSettingsService {
  static final NotificationSettingsService _instance =
      NotificationSettingsService._internal();
  factory NotificationSettingsService() => _instance;
  NotificationSettingsService._internal();

  static const String _storageKey = 'kabe_saat_notification_settings_v1';
  AppNotificationSettings? _cachedSettings;

  Future<AppNotificationSettings> loadSettings() async {
    if (_cachedSettings != null) return _cachedSettings!;
    try {
      final prefs = await SharedPreferences.getInstance();
      final str = prefs.getString(_storageKey);
      if (str != null && str.isNotEmpty) {
        final decoded = json.decode(str) as Map<String, dynamic>;
        _cachedSettings = AppNotificationSettings.fromJson(decoded);
        return _cachedSettings!;
      }
    } catch (e) {
      debugPrint('Error loading notification settings: $e');
    }
    _cachedSettings = AppNotificationSettings.defaults();
    return _cachedSettings!;
  }

  Future<bool> saveSettings(AppNotificationSettings settings) async {
    _cachedSettings = settings;
    try {
      final prefs = await SharedPreferences.getInstance();
      final encoded = json.encode(settings.toJson());
      return await prefs.setString(_storageKey, encoded);
    } catch (e) {
      debugPrint('Error saving notification settings: $e');
      return false;
    }
  }
}

