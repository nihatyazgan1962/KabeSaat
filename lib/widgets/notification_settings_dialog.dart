import 'package:flutter/material.dart';
import '../services/audio_service.dart';
import '../services/notification_settings_service.dart';

class NotificationSettingsDialog extends StatefulWidget {
  const NotificationSettingsDialog({super.key});

  @override
  State<NotificationSettingsDialog> createState() => _NotificationSettingsDialogState();
}

class _NotificationSettingsDialogState extends State<NotificationSettingsDialog> {
  late AppNotificationSettings _settings;
  bool _isLoading = true;
  String? _currentlyTestingSound;

  final Map<String, String> _prayerNames = {
    'imsak': 'İmsak / Sahur Vakti',
    'gunes': 'Güneş Doğuşu',
    'ogle': 'Öğle Namazı Vakti',
    'ikindi': 'İkindi Namazı Vakti',
    'aksam': 'Akşam / İftar Vakti',
    'yatsi': 'Yatsı Namazı Vakti',
  };

  final Map<String, IconData> _prayerIcons = {
    'imsak': Icons.nights_stay,
    'gunes': Icons.wb_sunny,
    'ogle': Icons.wb_twilight,
    'ikindi': Icons.sunny,
    'aksam': Icons.brightness_4,
    'yatsi': Icons.bedtime,
  };

  @override
  void initState() {
    super.initState();
    _loadCurrentSettings();
  }

  Future<void> _loadCurrentSettings() async {
    final s = await NotificationSettingsService().loadSettings();
    if (mounted) {
      setState(() {
        _settings = s;
        _isLoading = false;
      });
    }
  }

  void _playSoundPreview(String soundType) {
    setState(() {
      _currentlyTestingSound = soundType;
    });

    if (soundType == 'ezan_ismail_cosar') {
      AudioService().playEzan();
    } else if (soundType == 'tekbir') {
      AudioService().playTekbir();
    }

    Future.delayed(const Duration(seconds: 4), () {
      if (mounted && _currentlyTestingSound == soundType) {
        AudioService().stop();
        setState(() {
          _currentlyTestingSound = null;
        });
      }
    });
  }

  @override
  void dispose() {
    AudioService().stop();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return Container(
        height: 300,
        alignment: Alignment.center,
        color: const Color(0xFF0F1218),
        child: const CircularProgressIndicator(color: Color(0xFFFFD700)),
      );
    }

    return Container(
      height: MediaQuery.of(context).size.height * 0.88,
      decoration: BoxDecoration(
        color: const Color(0xFF0D1017).withOpacity(0.98),
        borderRadius: const BorderRadius.vertical(top: Radius.circular(28)),
        border: Border.all(color: const Color(0xFFD4AF37), width: 1.5),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.85),
            blurRadius: 25,
            spreadRadius: 8,
          ),
        ],
      ),
      child: Column(
        children: [
          // Drag handle
          Container(
            width: 44,
            height: 4,
            margin: const EdgeInsets.only(top: 12, bottom: 8),
            decoration: BoxDecoration(
              color: Colors.white24,
              borderRadius: BorderRadius.circular(2),
            ),
          ),

          // Header
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Row(
                  children: [
                    Icon(Icons.notifications_active, color: Color(0xFFFFD700), size: 24),
                    SizedBox(width: 10),
                    Text(
                      'BİLDİRİM & VAKİT ALARMI',
                      style: TextStyle(
                        color: Color(0xFFFFD700),
                        fontSize: 16,
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
          ),

          const Divider(color: Colors.white12, height: 1),

          // Scrollable Settings Content
          Expanded(
            child: ListView(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              children: [
                // SECTION 1: GENEL BİLDİRİM AYARLARI
                _buildSectionHeader('GENEL BİLDİRİM AYARLARI', Icons.tune),
                Container(
                  margin: const EdgeInsets.only(bottom: 16),
                  padding: const EdgeInsets.all(14),
                  decoration: BoxDecoration(
                    color: const Color(0xFF161C28),
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: Colors.white.withOpacity(0.08)),
                  ),
                  child: Column(
                    children: [
                      SwitchListTile(
                        contentPadding: EdgeInsets.zero,
                        activeColor: const Color(0xFFFFD700),
                        title: const Text(
                          'Bildirimler Aktif',
                          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
                        ),
                        subtitle: const Text(
                          'Tüm vakit ve tekbir hatırlatmalarını etkinleştirir',
                          style: TextStyle(color: Colors.white54, fontSize: 12),
                        ),
                        value: _settings.generalEnabled,
                        onChanged: (val) {
                          setState(() {
                            _settings.generalEnabled = val;
                          });
                        },
                      ),
                      const Divider(color: Colors.white10),
                      SwitchListTile(
                        contentPadding: EdgeInsets.zero,
                        activeColor: const Color(0xFFFFD700),
                        title: const Text(
                          'Titreşim Bildirimi',
                          style: TextStyle(color: Colors.white, fontSize: 14),
                        ),
                        subtitle: const Text(
                          'Alarm çaldığında cihaz titreşimi etkinleştirilir',
                          style: TextStyle(color: Colors.white54, fontSize: 12),
                        ),
                        value: _settings.generalVibrate,
                        onChanged: (val) {
                          setState(() {
                            _settings.generalVibrate = val;
                          });
                        },
                      ),
                    ],
                  ),
                ),

                // SECTION 2: HER VAKİT İÇİN AYRI BİLDİRİM VE SES SEÇİMİ
                _buildSectionHeader('AYRI VAKİT BİLDİRİMLERİ (ÖZEL AYARLAR)', Icons.access_alarms),
                const Padding(
                  padding: EdgeInsets.only(bottom: 10, left: 4),
                  child: Text(
                    'Her namaz vakti için bildirim zamanını ve sesini ayrı ayrı seçebilirsiniz:',
                    style: TextStyle(color: Colors.white60, fontSize: 12),
                  ),
                ),

                ..._prayerNames.keys.map((prayerKey) => _buildPrayerCard(prayerKey)),

                const SizedBox(height: 20),
              ],
            ),
          ),

          // Bottom Bar with Prominent "KAYDET" Button
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
            decoration: BoxDecoration(
              color: const Color(0xFF131722),
              border: Border(top: BorderSide(color: Colors.white.withOpacity(0.1))),
            ),
            child: Row(
              children: [
                Expanded(
                  child: ElevatedButton.icon(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFFD4AF37),
                      foregroundColor: Colors.black,
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(14),
                      ),
                      elevation: 4,
                    ),
                    icon: const Icon(Icons.check_circle, size: 22),
                    label: const Text(
                      'AYARLARI KAYDET',
                      style: TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.bold,
                        letterSpacing: 1.0,
                      ),
                    ),
                    onPressed: _saveSettings,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSectionHeader(String title, IconData icon) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10, top: 4, left: 2),
      child: Row(
        children: [
          Icon(icon, color: const Color(0xFFFFD700), size: 18),
          const SizedBox(width: 8),
          Text(
            title,
            style: const TextStyle(
              color: Color(0xFFFFD700),
              fontSize: 13,
              fontWeight: FontWeight.bold,
              letterSpacing: 0.8,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPrayerCard(String key) {
    final cfg = _settings.prayerConfigs[key] ??
        PrayerNotificationConfig(enabled: true, minutesBefore: 0, soundType: 'ezan_ismail_cosar');
    final name = _prayerNames[key] ?? key;
    final icon = _prayerIcons[key] ?? Icons.access_time;

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: cfg.enabled ? const Color(0xFF171E2D) : const Color(0xFF12151D),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: cfg.enabled ? const Color(0xFFD4AF37).withOpacity(0.35) : Colors.white10,
        ),
      ),
      child: Theme(
        data: Theme.of(context).copyWith(dividerColor: Colors.transparent),
        child: ExpansionTile(
          initiallyExpanded: cfg.enabled,
          leading: Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: cfg.enabled
                  ? const Color(0xFFD4AF37).withOpacity(0.18)
                  : Colors.white.withOpacity(0.05),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(
              icon,
              color: cfg.enabled ? const Color(0xFFFFD700) : Colors.white38,
              size: 20,
            ),
          ),
          title: Text(
            name,
            style: TextStyle(
              color: cfg.enabled ? Colors.white : Colors.white54,
              fontSize: 14,
              fontWeight: cfg.enabled ? FontWeight.bold : FontWeight.normal,
            ),
          ),
          subtitle: Text(
            cfg.enabled
                ? '${_getTimingLabel(cfg.minutesBefore)} • ${_getSoundLabel(cfg.soundType)}'
                : 'Bildirim Kapalı',
            style: TextStyle(
              color: cfg.enabled ? const Color(0xFFFFD700).withOpacity(0.85) : Colors.white38,
              fontSize: 11,
            ),
          ),
          trailing: Switch(
            activeColor: const Color(0xFFFFD700),
            value: cfg.enabled,
            onChanged: (val) {
              setState(() {
                cfg.enabled = val;
              });
            },
          ),
          children: [
            if (cfg.enabled)
              Padding(
                padding: const EdgeInsets.fromLTRB(16, 0, 16, 14),
                child: Column(
                  children: [
                    const Divider(color: Colors.white12),

                    // Zamanlama Seçimi
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text(
                          'Bildirim Zamanı:',
                          style: TextStyle(color: Colors.white70, fontSize: 13),
                        ),
                        DropdownButton<int>(
                          value: cfg.minutesBefore,
                          dropdownColor: const Color(0xFF1B2232),
                          style: const TextStyle(color: Color(0xFFFFD700), fontSize: 13),
                          underline: Container(height: 1, color: const Color(0xFFFFD700)),
                          items: const [
                            DropdownMenuItem(value: 0, child: Text('Tam Vaktinde')),
                            DropdownMenuItem(value: 15, child: Text('15 Dakika Önce')),
                            DropdownMenuItem(value: 30, child: Text('30 Dakika Önce')),
                            DropdownMenuItem(value: 45, child: Text('45 Dakika Önce')),
                          ],
                          onChanged: (val) {
                            if (val != null) {
                              setState(() {
                                cfg.minutesBefore = val;
                              });
                            }
                          },
                        ),
                      ],
                    ),

                    const SizedBox(height: 8),

                    // Ses Seçimi
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text(
                          'Çalacak Ses:',
                          style: TextStyle(color: Colors.white70, fontSize: 13),
                        ),
                        Row(
                          children: [
                            DropdownButton<String>(
                              value: cfg.soundType,
                              dropdownColor: const Color(0xFF1B2232),
                              style: const TextStyle(color: Color(0xFFFFD700), fontSize: 13),
                              underline: Container(height: 1, color: const Color(0xFFFFD700)),
                              items: const [
                                DropdownMenuItem(
                                  value: 'ezan_ismail_cosar',
                                  child: Text('İsmail Coşar Ezanı'),
                                ),
                                DropdownMenuItem(
                                  value: 'tekbir',
                                  child: Text('Teşrik Tekbiri'),
                                ),
                                DropdownMenuItem(
                                  value: 'bip',
                                  child: Text('Kısa Bip Uyarısı'),
                                ),
                                DropdownMenuItem(
                                  value: 'sessiz',
                                  child: Text('Sessiz (Yalnız Titreşim)'),
                                ),
                              ],
                              onChanged: (val) {
                                if (val != null) {
                                  setState(() {
                                    cfg.soundType = val;
                                  });
                                }
                              },
                            ),
                            const SizedBox(width: 6),
                            IconButton(
                              icon: Icon(
                                _currentlyTestingSound == cfg.soundType
                                    ? Icons.stop_circle
                                    : Icons.play_circle_fill,
                                color: const Color(0xFFFFD700),
                                size: 22,
                              ),
                              tooltip: 'Sesi Dinle',
                              onPressed: () {
                                if (_currentlyTestingSound == cfg.soundType) {
                                  AudioService().stop();
                                  setState(() {
                                    _currentlyTestingSound = null;
                                  });
                                } else {
                                  _playSoundPreview(cfg.soundType);
                                }
                              },
                            ),
                          ],
                        ),
                      ],
                    ),
                  ],
                ),
              ),
          ],
        ),
      ),
    );
  }

  String _getTimingLabel(int mins) {
    if (mins == 0) return 'Tam Vaktinde';
    return '$mins dk önce';
  }

  String _getSoundLabel(String sound) {
    switch (sound) {
      case 'ezan_ismail_cosar':
        return 'İsmail Coşar Ezanı';
      case 'tekbir':
        return 'Teşrik Tekbiri';
      case 'bip':
        return 'Kısa Bip';
      case 'sessiz':
        return 'Sessiz';
      default:
        return sound;
    }
  }

  Future<void> _saveSettings() async {
    final success = await NotificationSettingsService().saveSettings(_settings);
    if (!mounted) return;

    Navigator.pop(context);

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        backgroundColor: const Color(0xFF133220),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
          side: const BorderSide(color: Color(0xFF00FF88), width: 1.2),
        ),
        content: Row(
          children: [
            const Icon(Icons.check_circle, color: Color(0xFF00FF88)),
            const SizedBox(width: 10),
            Text(
              success
                  ? 'Bildirim ve vakit ayarları başarıyla kaydedildi!'
                  : 'Ayarlar kaydedilirken hata oluştu!',
              style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
            ),
          ],
        ),
        duration: const Duration(seconds: 3),
      ),
    );
  }
}

