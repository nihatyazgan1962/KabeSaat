import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/app_theme.dart';

class ThemeService {
  static final ThemeService _instance = ThemeService._internal();
  factory ThemeService() => _instance;
  ThemeService._internal();

  static const String _storageKey = 'kabe_saat_selected_theme_id';

  final ValueNotifier<AppThemeData> currentThemeNotifier =
      ValueNotifier<AppThemeData>(AppThemeData.allThemes[0]);

  AppThemeData get currentTheme => currentThemeNotifier.value;

  Future<void> init() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final savedId = prefs.getString(_storageKey);
      if (savedId != null) {
        currentThemeNotifier.value = AppThemeData.getById(savedId);
      }
    } catch (e) {
      debugPrint('Error loading theme: $e');
    }
  }

  Future<void> setTheme(AppThemeData theme) async {
    currentThemeNotifier.value = theme;
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString(_storageKey, theme.id.name);
    } catch (e) {
      debugPrint('Error saving theme: $e');
    }
  }
}

