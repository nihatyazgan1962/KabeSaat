import 'package:flutter/material.dart';

enum AppThemeId {
  altinGece,
  kabeKisvesi,
  zumrutRavza,
  safirGece,
  beyazMermer,
}

class AppThemeData {
  final AppThemeId id;
  final String name;
  final String description;
  final Color primaryColor;
  final Color accentColor;
  final Color backgroundColor;
  final Color cardColor;
  final Color cardBorderColor;
  final List<Color> backgroundGradient;
  final bool isDark;

  const AppThemeData({
    required this.id,
    required this.name,
    required this.description,
    required this.primaryColor,
    required this.accentColor,
    required this.backgroundColor,
    required this.cardColor,
    required this.cardBorderColor,
    required this.backgroundGradient,
    this.isDark = true,
  });

  static const List<AppThemeData> allThemes = [
    AppThemeData(
      id: AppThemeId.altinGece,
      name: 'Altın Gece (Varsayılan)',
      description: 'Zengin altın sarısı, zümrüt dokunuşlar ve gece göğü',
      primaryColor: Color(0xFFD4AF37),
      accentColor: Color(0xFFFFD700),
      backgroundColor: Color(0xFF0A0C10),
      cardColor: Color(0xFF141722),
      cardBorderColor: Color(0x66D4AF37),
      backgroundGradient: [
        Color(0xFF1A1D26),
        Color(0xFF0F1218),
        Color(0xFF06080C),
      ],
    ),
    AppThemeData(
      id: AppThemeId.kabeKisvesi,
      name: 'Kâbe Kisvesi (AMOLED)',
      description: 'Saf kadife siyahı ve parlayan altın hat tezhibi',
      primaryColor: Color(0xFFFFD700),
      accentColor: Color(0xFFFFE082),
      backgroundColor: Color(0xFF000000),
      cardColor: Color(0xFF0D0D0E),
      cardBorderColor: Color(0x55FFD700),
      backgroundGradient: [
        Color(0xFF0D0D0D),
        Color(0xFF050505),
        Color(0xFF000000),
      ],
    ),
    AppThemeData(
      id: AppThemeId.zumrutRavza,
      name: 'Zümrüt Ravza & Harem',
      description: 'Mescid-i Nebevi yeşili ve Kâbe altın süslemeleri',
      primaryColor: Color(0xFF00E676),
      accentColor: Color(0xFFFFD700),
      backgroundColor: Color(0xFF06140D),
      cardColor: Color(0xFF0C2417),
      cardBorderColor: Color(0x6600E676),
      backgroundGradient: [
        Color(0xFF0D281A),
        Color(0xFF071910),
        Color(0xFF030A06),
      ],
    ),
    AppThemeData(
      id: AppThemeId.safirGece,
      name: 'Gece Safiri (Lacivert)',
      description: 'Mekke geceleri derin safir mavisi ve altın hilal',
      primaryColor: Color(0xFF64B5F6),
      accentColor: Color(0xFFFFD700),
      backgroundColor: Color(0xFF060C18),
      cardColor: Color(0xFF0E1A30),
      cardBorderColor: Color(0x6664B5F6),
      backgroundGradient: [
        Color(0xFF10203D),
        Color(0xFF091224),
        Color(0xFF040810),
      ],
    ),
    AppThemeData(
      id: AppThemeId.beyazMermer,
      name: 'Haremeyn Mermeri (Aydınlık)',
      description: 'Tavaf alanının serin beyaz mermeri ve altın varak',
      primaryColor: Color(0xFFB8860B),
      accentColor: Color(0xFFD4AF37),
      backgroundColor: Color(0xFF1E2128),
      cardColor: Color(0xFF282D38),
      cardBorderColor: Color(0x66D4AF37),
      backgroundGradient: [
        Color(0xFF2D3340),
        Color(0xFF212530),
        Color(0xFF161922),
      ],
    ),
  ];

  static AppThemeData getById(String idStr) {
    for (final t in allThemes) {
      if (t.id.name == idStr) return t;
    }
    return allThemes[0];
  }
}

