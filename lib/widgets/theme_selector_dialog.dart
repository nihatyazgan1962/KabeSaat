import 'package:flutter/material.dart';
import '../models/app_theme.dart';
import '../services/theme_service.dart';

class ThemeSelectorDialog extends StatelessWidget {
  const ThemeSelectorDialog({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
      decoration: BoxDecoration(
        color: const Color(0xFF0F131D).withOpacity(0.98),
        borderRadius: const BorderRadius.vertical(top: Radius.circular(28)),
        border: Border.all(color: const Color(0xFFD4AF37), width: 1.5),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.85),
            blurRadius: 20,
            spreadRadius: 6,
          ),
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Drag handle
          Container(
            width: 44,
            height: 4,
            margin: const EdgeInsets.only(bottom: 12),
            decoration: BoxDecoration(
              color: Colors.white24,
              borderRadius: BorderRadius.circular(2),
            ),
          ),

          // Header
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Row(
                children: [
                  Icon(Icons.palette, color: Color(0xFFFFD700), size: 24),
                  SizedBox(width: 10),
                  Text(
                    'TEMA SEÇİMİ',
                    style: TextStyle(
                      color: Color(0xFFFFD700),
                      fontSize: 17,
                      fontWeight: FontWeight.bold,
                      letterSpacing: 0.8,
                    ),
                  ),
                ],
              ),
              IconButton(
                icon: const Icon(Icons.close, color: Colors.white70),
                onPressed: () => Navigator.pop(context),
              ),
            ],
          ),

          const SizedBox(height: 10),

          // Themes List
          ValueListenableBuilder<AppThemeData>(
            valueListenable: ThemeService().currentThemeNotifier,
            builder: (context, activeTheme, _) {
              return Column(
                children: AppThemeData.allThemes.map((theme) {
                  final isSelected = activeTheme.id == theme.id;

                  return Container(
                    margin: const EdgeInsets.only(bottom: 10),
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: theme.backgroundGradient,
                        begin: Alignment.centerLeft,
                        end: Alignment.centerRight,
                      ),
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(
                        color: isSelected
                            ? theme.primaryColor
                            : Colors.white.withOpacity(0.12),
                        width: isSelected ? 2.0 : 1.0,
                      ),
                      boxShadow: isSelected
                          ? [
                              BoxShadow(
                                color: theme.primaryColor.withOpacity(0.3),
                                blurRadius: 10,
                                spreadRadius: 1,
                              ),
                            ]
                          : null,
                    ),
                    child: ListTile(
                      contentPadding:
                          const EdgeInsets.symmetric(horizontal: 14, vertical: 4),
                      leading: Container(
                        width: 38,
                        height: 38,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          border: Border.all(color: theme.primaryColor, width: 2),
                          gradient: LinearGradient(
                            colors: [theme.primaryColor, theme.accentColor],
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                          ),
                        ),
                        child: Icon(
                          isSelected ? Icons.check : Icons.palette_outlined,
                          color: Colors.black87,
                          size: 20,
                        ),
                      ),
                      title: Text(
                        theme.name,
                        style: TextStyle(
                          color: isSelected ? theme.accentColor : Colors.white,
                          fontSize: 14,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      subtitle: Text(
                        theme.description,
                        style: const TextStyle(color: Colors.white60, fontSize: 11),
                      ),
                      trailing: isSelected
                          ? Icon(Icons.check_circle, color: theme.primaryColor)
                          : null,
                      onTap: () {
                        ThemeService().setTheme(theme);
                      },
                    ),
                  );
                }).toList(),
              );
            },
          ),
          const SizedBox(height: 10),
        ],
      ),
    );
  }
}

