import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:intl/intl.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'models/app_theme.dart';
import 'models/prayer_times_model.dart';
import 'services/audio_service.dart';
import 'services/diyanet_prayer_service.dart';
import 'services/prayer_calculator.dart';
import 'services/quran_radio_service.dart';
import 'services/theme_service.dart';
import 'services/widget_service.dart';
import 'widgets/city_selector_dialog.dart';
import 'widgets/imsakiye_view.dart';
import 'widgets/ismail_cosar_player.dart';
import 'widgets/kabe_analog_clock.dart';
import 'widgets/makkah_radio_view.dart';
import 'widgets/notification_settings_dialog.dart';
import 'widgets/prayer_ribbon.dart';
import 'widgets/qibla_compass_view.dart';
import 'widgets/screensaver_view.dart';
import 'widgets/theme_selector_dialog.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await initializeDateFormatting('tr_TR', null);
  AudioService().init();
  QuranRadioService().init();
  await ThemeService().init();

  SystemChrome.setSystemUIOverlayStyle(
    const SystemUiOverlayStyle(
      statusBarColor: Colors.transparent,
      statusBarIconBrightness: Brightness.light,
      systemNavigationBarColor: Colors.black,
      systemNavigationBarIconBrightness: Brightness.light,
    ),
  );
  runApp(const KabeSaatApp());
}

class KabeSaatApp extends StatelessWidget {
  const KabeSaatApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Kabe Saat ve Ezan',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        brightness: Brightness.dark,
        scaffoldBackgroundColor: const Color(0xFF0A0C10),
        colorScheme: const ColorScheme.dark(
          primary: Color(0xFFD4AF37),
          secondary: Color(0xFFFFD700),
          surface: Color(0xFF121620),
        ),
        fontFamily: 'sans-serif',
      ),
      home: const KabeSaatHomeScreen(),
    );
  }
}

class KabeSaatHomeScreen extends StatefulWidget {
  const KabeSaatHomeScreen({super.key});

  @override
  State<KabeSaatHomeScreen> createState() => _KabeSaatHomeScreenState();
}

class _KabeSaatHomeScreenState extends State<KabeSaatHomeScreen> {
  DateTime _currentTime = DateTime.now();
  late Timer _timer;
  CityLocation _selectedCity = PrayerCalculator.popularCities[0]; // Istanbul
  late DayPrayerSchedule _todaySchedule;
  bool _showControls = true; // "Ekrana dokununca çıksın"
  bool _enableTawaf = true; // "kabe etrafında tavaf hareketi"
  bool _isScreensaverActive = false; // "ekran koruyucu ekle"
  Timer? _autoHideTimer;
  bool _isDiyanetLive = false;

  @override
  void initState() {
    super.initState();
    _recalculateSchedule();
    _loadSavedCity();

    // High-precision clock tick & widget sync
    _timer = Timer.periodic(const Duration(milliseconds: 250), (timer) {
      if (mounted) {
        final now = DateTime.now();
        setState(() {
          _currentTime = now;
        });

        // Sync Android widget every 15 seconds
        if (now.second % 15 == 0 && now.millisecond < 300) {
          WidgetService().updateWidget(city: _selectedCity, schedule: _todaySchedule);
        }
      }
    });

    _startAutoHideTimer();
    _fetchLiveDiyanet();
  }

  Future<void> _loadSavedCity() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final savedName = prefs.getString('saved_city_name');
      final savedLat = prefs.getDouble('saved_city_lat');
      final savedLng = prefs.getDouble('saved_city_lng');
      final savedQibla = prefs.getDouble('saved_city_qibla');
      if (savedName != null && savedLat != null && savedLng != null && savedQibla != null) {
        if (mounted) {
          setState(() {
            _selectedCity = CityLocation(
              name: savedName,
              latitude: savedLat,
              longitude: savedLng,
              qiblaAngle: savedQibla,
            );
            _recalculateSchedule();
          });
          _fetchLiveDiyanet();
        }
      }
    } catch (e) {
      debugPrint('Error loading saved city: $e');
    }
  }

  Future<void> _saveSelectedCity(CityLocation city) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString('saved_city_name', city.name);
      await prefs.setDouble('saved_city_lat', city.latitude);
      await prefs.setDouble('saved_city_lng', city.longitude);
      await prefs.setDouble('saved_city_qibla', city.qiblaAngle);
    } catch (e) {
      debugPrint('Error saving city: $e');
    }
  }

  void _recalculateSchedule() {
    _todaySchedule = PrayerCalculator.calculateTimes(DateTime.now(), _selectedCity);
    WidgetService().updateWidget(city: _selectedCity, schedule: _todaySchedule);
  }

  Future<void> _fetchLiveDiyanet() async {
    try {
      final liveSchedule = await DiyanetPrayerService().fetchDiyanetTimes(
        _selectedCity,
        DateTime.now(),
      );
      if (mounted) {
        setState(() {
          _todaySchedule = liveSchedule;
          _isDiyanetLive = true;
        });
        WidgetService().updateWidget(city: _selectedCity, schedule: _todaySchedule);
      }
    } catch (e) {
      debugPrint('Diyanet live fetch error: $e');
    }
  }

  void _startAutoHideTimer() {
    _autoHideTimer?.cancel();
    _autoHideTimer = Timer(const Duration(seconds: 14), () {
      if (mounted && _showControls) {
        setState(() {
          _showControls = false;
        });
      }
    });
  }

  void _toggleControls() {
    setState(() {
      _showControls = !_showControls;
    });
    if (_showControls) {
      _startAutoHideTimer();
    } else {
      _autoHideTimer?.cancel();
    }
  }

  @override
  void dispose() {
    _timer.cancel();
    _autoHideTimer?.cancel();
    super.dispose();
  }

  void _openQiblaCompass() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) => QiblaCompassView(
        city: _selectedCity,
        onClose: () => Navigator.pop(ctx),
      ),
    );
  }

  void _openImsakiye() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) => ImsakiyeView(
        city: _selectedCity,
        onClose: () => Navigator.pop(ctx),
      ),
    );
  }

  void _openIsmailCosarPlayer([PrayerTime? prayer]) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) => IsmailCosarPlayerSheet(
        selectedPrayer: prayer,
        onClose: () => Navigator.pop(ctx),
      ),
    );
  }

  void _openNotificationSettings() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) => const NotificationSettingsDialog(),
    );
  }

  void _openMakkahRadio() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) => MakkahRadioView(
        onClose: () => Navigator.pop(ctx),
      ),
    );
  }

  void _openThemeSelector() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) => const ThemeSelectorDialog(),
    );
  }

  void _openCitySelector() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) => CitySelectorDialog(
        currentCity: _selectedCity,
        onCitySelected: (newCity) {
          setState(() {
            _selectedCity = newCity;
            _recalculateSchedule();
            _isDiyanetLive = false;
          });
          _saveSelectedCity(newCity);
          _fetchLiveDiyanet();
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<AppThemeData>(
      valueListenable: ThemeService().currentThemeNotifier,
      builder: (context, currentTheme, _) {
        if (_isScreensaverActive) {
          return ScreensaverView(
            city: _selectedCity,
            schedule: _todaySchedule,
            onExit: () {
              setState(() {
                _isScreensaverActive = false;
              });
            },
          );
        }

        final nextPrayer = _todaySchedule.nextPrayer;
        Duration? remainingToNext;
        if (nextPrayer != null) {
          remainingToNext = nextPrayer.time.difference(_currentTime);
          if (remainingToNext.isNegative) {
            remainingToNext = Duration.zero;
          }
        }

        final mediaQuery = MediaQuery.of(context);
        final clockSize = (mediaQuery.size.width * 0.84).clamp(240.0, 360.0);

        return Scaffold(
          body: GestureDetector(
            behavior: HitTestBehavior.opaque,
            onTap: _toggleControls,
            child: Container(
              width: double.infinity,
              height: double.infinity,
              decoration: BoxDecoration(
                gradient: RadialGradient(
                  center: Alignment.center,
                  radius: 1.1,
                  colors: currentTheme.backgroundGradient,
                ),
              ),
              child: Stack(
            children: [
              // Ambient Mosque Islamic Geometry Watermark / Stars in background
              Positioned.fill(
                child: Opacity(
                  opacity: 0.05,
                  child: Image.asset(
                    'assets/images/kabe_saat.jpg',
                    fit: BoxFit.cover,
                  ),
                ),
              ),

              // CENTERPIECE: Kâbe Saat (Wall Clock) with animated Tawaf movement!
              Center(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    // Digital Time & Date Pill Header (when in pure watch mode)
                    if (!_showControls) ...[
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
                        decoration: BoxDecoration(
                          color: Colors.black45,
                          borderRadius: BorderRadius.circular(20),
                          border: Border.all(color: const Color(0xFFD4AF37).withOpacity(0.4)),
                        ),
                        child: Text(
                          DateFormat('HH:mm:ss').format(_currentTime),
                          style: const TextStyle(
                            color: Color(0xFFFFD700),
                            fontSize: 22,
                            fontWeight: FontWeight.bold,
                            letterSpacing: 2,
                          ),
                        ),
                      ),
                      const SizedBox(height: 14),
                    ],

                    // The Kaaba Clock with Animated Tawaf
                    KabeAnalogClock(
                      currentTime: _currentTime,
                      size: clockSize,
                      enableTawaf: _enableTawaf,
                    ),

                    const SizedBox(height: 18),

                    // Tap hint when controls are hidden
                    if (!_showControls)
                      AnimatedOpacity(
                        opacity: 0.7,
                        duration: const Duration(milliseconds: 500),
                        child: Container(
                          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
                          decoration: BoxDecoration(
                            color: Colors.black38,
                            borderRadius: BorderRadius.circular(16),
                            border: Border.all(color: Colors.white12),
                          ),
                          child: const Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(Icons.touch_app, size: 14, color: Color(0xFFD4AF37)),
                              SizedBox(width: 6),
                              Text(
                                'Vakitler, Kıble, Radyo ve Ezan İçin Ekrana Dokunun',
                                style: TextStyle(color: Colors.white70, fontSize: 11),
                              ),
                            ],
                          ),
                        ),
                      ),
                  ],
                ),
              ),

              // FLOATING MECCA RADIO MINI PLAYER (when radio is playing)
              ValueListenableBuilder<bool>(
                valueListenable: QuranRadioService().isPlayingNotifier,
                builder: (context, isPlaying, _) {
                  if (!isPlaying) return const SizedBox.shrink();
                  return Positioned(
                    top: mediaQuery.padding.top + (_showControls ? 66 : 14),
                    left: 20,
                    right: 20,
                    child: GestureDetector(
                      onTap: _openMakkahRadio,
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                        decoration: BoxDecoration(
                          color: const Color(0xFF1A2234).withOpacity(0.95),
                          borderRadius: BorderRadius.circular(25),
                          border: Border.all(color: const Color(0xFFFFD700), width: 1.2),
                          boxShadow: [
                            BoxShadow(
                              color: const Color(0xFFFFD700).withOpacity(0.2),
                              blurRadius: 10,
                            ),
                          ],
                        ),
                        child: Row(
                          children: [
                            const Icon(Icons.radio, color: Color(0xFFFFD700), size: 18),
                            const SizedBox(width: 8),
                            const Expanded(
                              child: Text(
                                'Mekke Canlı Kur\'an Radyosu Yayında',
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 12,
                                  fontWeight: FontWeight.bold,
                                ),
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                            IconButton(
                              icon: const Icon(Icons.pause_circle_filled, color: Color(0xFFFFD700), size: 22),
                              padding: EdgeInsets.zero,
                              constraints: const BoxConstraints(),
                              onPressed: () => QuranRadioService().pause(),
                            ),
                          ],
                        ),
                      ),
                    ),
                  );
                },
              ),

              // REVEALED UI ON TAP ("Ekrana dokununca çıksın")
              // TOP BAR
              AnimatedPositioned(
                duration: const Duration(milliseconds: 350),
                curve: Curves.easeOutCubic,
                top: _showControls ? mediaQuery.padding.top + 8 : -120,
                left: 14,
                right: 14,
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                  decoration: BoxDecoration(
                    color: const Color(0xFF141722).withOpacity(0.92),
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(color: const Color(0xFFD4AF37).withOpacity(0.4)),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.5),
                        blurRadius: 16,
                      ),
                    ],
                  ),
                  child: Row(
                    children: [
                      // City selector button (All 81 provinces & districts)
                      InkWell(
                        onTap: _openCitySelector,
                        borderRadius: BorderRadius.circular(12),
                        child: Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 4),
                          child: Row(
                            children: [
                              const Icon(Icons.location_on, color: Color(0xFFFFD700), size: 18),
                              const SizedBox(width: 4),
                              ConstrainedBox(
                                constraints: const BoxConstraints(maxWidth: 130),
                                child: Text(
                                  _selectedCity.name,
                                  style: const TextStyle(
                                    color: Colors.white,
                                    fontSize: 14,
                                    fontWeight: FontWeight.bold,
                                  ),
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),
                              const SizedBox(width: 4),
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 1.5),
                                decoration: BoxDecoration(
                                  color: const Color(0xFF00AA55).withOpacity(0.2),
                                  borderRadius: BorderRadius.circular(6),
                                  border: Border.all(color: const Color(0xFF00FF77), width: 0.8),
                                ),
                                child: Text(
                                  _isDiyanetLive ? 'Diyanet Canlı' : 'Diyanet',
                                  style: const TextStyle(
                                    color: Color(0xFF00FF77),
                                    fontSize: 9,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),
                              const Icon(Icons.arrow_drop_down, color: Color(0xFFFFD700), size: 20),
                            ],
                          ),
                        ),
                      ),
                      const Spacer(),
                      // Tawaf motion toggle button
                      IconButton(
                        tooltip: _enableTawaf ? 'Tavaf Hareketi Açık' : 'Tavaf Hareketi Kapalı',
                        icon: Icon(
                          _enableTawaf ? Icons.all_inclusive : Icons.circle_outlined,
                          color: _enableTawaf ? const Color(0xFF00FF88) : Colors.white38,
                          size: 20,
                        ),
                        onPressed: () {
                          setState(() {
                            _enableTawaf = !_enableTawaf;
                          });
                        },
                      ),
                      // Screensaver button (Ekran Koruyucu)
                      IconButton(
                        tooltip: 'Ekran Koruyucu (AMOLED Modu)',
                        icon: const Icon(Icons.nights_stay, color: Color(0xFFBA68C8), size: 20),
                        onPressed: () {
                          setState(() {
                            _isScreensaverActive = true;
                          });
                        },
                      ),
                      // Theme Selector button (Tema Seçimi)
                      IconButton(
                        tooltip: 'Tema Seçimi',
                        icon: Icon(Icons.palette_outlined, color: currentTheme.primaryColor, size: 20),
                        onPressed: _openThemeSelector,
                      ),
                      // Notification Settings button (Bildirim & Vakit Ayarları)
                      IconButton(
                        tooltip: 'Bildirim ve Vakit Ayarları',
                        icon: const Icon(Icons.notifications_active_outlined, color: Color(0xFFFFD700), size: 20),
                        onPressed: _openNotificationSettings,
                      ),
                    ],
                  ),
                ),
              ),

              // BOTTOM CONTROLS & PRAYER RIBBON
              AnimatedPositioned(
                duration: const Duration(milliseconds: 350),
                curve: Curves.easeOutCubic,
                bottom: _showControls ? mediaQuery.padding.bottom + 12 : -320,
                left: 0,
                right: 0,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    // Next prayer countdown banner
                    if (remainingToNext != null && nextPrayer != null)
                      Container(
                        margin: const EdgeInsets.only(bottom: 10),
                        padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 6),
                        decoration: BoxDecoration(
                          gradient: const LinearGradient(
                            colors: [Color(0xFF2C220B), Color(0xFF1E1706)],
                          ),
                          borderRadius: BorderRadius.circular(20),
                          border: Border.all(color: const Color(0xFFFFD700).withOpacity(0.6)),
                          boxShadow: [
                            BoxShadow(
                              color: const Color(0xFFD4AF37).withOpacity(0.2),
                              blurRadius: 10,
                            ),
                          ],
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            const Icon(Icons.hourglass_bottom, color: Color(0xFFFFD700), size: 16),
                            const SizedBox(width: 8),
                            Text(
                              '${nextPrayer.turkishName} vaktine kalan: ${_formatCountdown(remainingToNext)}',
                              style: const TextStyle(
                                color: Color(0xFFFFE57F),
                                fontSize: 13,
                                fontWeight: FontWeight.bold,
                                letterSpacing: 0.5,
                              ),
                            ),
                          ],
                        ),
                      ),

                    // Prayer Times 6-column Ribbon
                    PrayerRibbon(
                      schedule: _todaySchedule,
                      onPlayEzan: (prayer) => _openIsmailCosarPlayer(prayer),
                    ),

                    const SizedBox(height: 12),

                    // Quick Action Menu Buttons
                    Container(
                      margin: const EdgeInsets.symmetric(horizontal: 14),
                      padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 8),
                      decoration: BoxDecoration(
                        color: const Color(0xFF161A24).withOpacity(0.94),
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(color: const Color(0xFFD4AF37).withOpacity(0.3)),
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceAround,
                        children: [
                          _navButton(
                            icon: Icons.explore_outlined,
                            label: 'Kıble',
                            color: const Color(0xFFFFD700),
                            onTap: _openQiblaCompass,
                          ),
                          _navButton(
                            icon: Icons.radio,
                            label: 'Mekke Radyo',
                            color: const Color(0xFFFF8A65),
                            onTap: _openMakkahRadio,
                          ),
                          _navButton(
                            icon: Icons.notifications_active,
                            label: 'Bildirimler',
                            color: const Color(0xFF81C784),
                            onTap: _openNotificationSettings,
                          ),
                          _navButton(
                            icon: Icons.table_chart_outlined,
                            label: 'İmsakiye',
                            color: const Color(0xFF4FC3F7),
                            onTap: _openImsakiye,
                          ),
                          _navButton(
                            icon: Icons.mic_external_on,
                            label: 'İsmail Coşar',
                            color: const Color(0xFFFFD54F),
                            onTap: () => _openIsmailCosarPlayer(),
                          ),
                          _navButton(
                            icon: Icons.palette_outlined,
                            label: 'Temalar',
                            color: currentTheme.primaryColor,
                            onTap: _openThemeSelector,
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
      },
    );
  }

  Widget _navButton({
    required IconData icon,
    required String label,
    required Color color,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, color: color, size: 21),
            const SizedBox(height: 4),
            Text(
              label,
              style: TextStyle(
                color: color.withOpacity(0.95),
                fontSize: 10,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
      ),
    );
  }

  String _formatCountdown(Duration d) {
    final h = d.inHours.toString().padLeft(2, '0');
    final m = d.inMinutes.remainder(60).toString().padLeft(2, '0');
    final s = d.inSeconds.remainder(60).toString().padLeft(2, '0');
    return '$h:$m:$s';
  }
}
