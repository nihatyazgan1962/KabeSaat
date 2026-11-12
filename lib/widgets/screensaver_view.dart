import 'dart:async';
import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../models/prayer_times_model.dart';
import '../services/theme_service.dart';
import 'kabe_analog_clock.dart';

class ScreensaverView extends StatefulWidget {
  final CityLocation city;
  final DayPrayerSchedule schedule;
  final VoidCallback onExit;

  const ScreensaverView({
    super.key,
    required this.city,
    required this.schedule,
    required this.onExit,
  });

  @override
  State<ScreensaverView> createState() => _ScreensaverViewState();
}

class _ScreensaverViewState extends State<ScreensaverView>
    with SingleTickerProviderStateMixin {
  late Timer _clockTimer;
  late AnimationController _driftController;
  DateTime _currentTime = DateTime.now();
  double _brightness = 1.0; // 1.0, 0.6, 0.35

  @override
  void initState() {
    super.initState();
    _driftController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 40),
    )..repeat(reverse: true);

    _clockTimer = Timer.periodic(const Duration(milliseconds: 500), (_) {
      if (mounted) {
        setState(() {
          _currentTime = DateTime.now();
        });
      }
    });
  }

  @override
  void dispose() {
    _clockTimer.cancel();
    _driftController.dispose();
    super.dispose();
  }

  void _cycleBrightness() {
    setState(() {
      if (_brightness > 0.8) {
        _brightness = 0.55;
      } else if (_brightness > 0.4) {
        _brightness = 0.28;
      } else {
        _brightness = 1.0;
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final theme = ThemeService().currentTheme;
    final next = widget.schedule.nextPrayer;
    String countdownStr = '';
    if (next != null) {
      final diff = next.time.difference(_currentTime);
      final h = diff.inHours.toString().padLeft(2, '0');
      final m = (diff.inMinutes % 60).toString().padLeft(2, '0');
      final s = (diff.inSeconds % 60).toString().padLeft(2, '0');
      countdownStr = '$h:$m:$s';
    }

    final timeStr = DateFormat('HH:mm:ss').format(_currentTime);
    final dateStr = DateFormat('d MMMM yyyy, EEEE', 'tr_TR').format(_currentTime);

    return Scaffold(
      backgroundColor: Colors.black,
      body: Stack(
        children: [
          // Background interactive tap detector
          Positioned.fill(
            child: GestureDetector(
              behavior: HitTestBehavior.opaque,
              onTap: widget.onExit,
              child: Opacity(
                opacity: _brightness,
                child: AnimatedBuilder(
                  animation: _driftController,
                  builder: (context, child) {
                    // Anti-burn-in smooth subtle orbital drift
                    final driftX =
                        math.sin(_driftController.value * 2 * math.pi) * 16.0;
                    final driftY =
                        math.cos(_driftController.value * 2 * math.pi) * 20.0;

                    return Transform.translate(
                      offset: Offset(driftX, driftY),
                      child: Center(
                        child: SingleChildScrollView(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              // Subdued city & hijri banner
                              Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Icon(Icons.location_on,
                                      color: theme.primaryColor, size: 14),
                                  const SizedBox(width: 4),
                                  Text(
                                    widget.city.name.toUpperCase(),
                                    style: TextStyle(
                                      color: theme.primaryColor,
                                      fontSize: 12,
                                      letterSpacing: 1.5,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                  const SizedBox(width: 12),
                                  Text(
                                    '•  ${widget.schedule.hijriDate}',
                                    style: const TextStyle(
                                        color: Colors.white38, fontSize: 11),
                                  ),
                                ],
                              ),

                              const SizedBox(height: 14),

                              // Elegant Compact Analog Clock
                              SizedBox(
                                width: 240,
                                height: 240,
                                child: KabeAnalogClock(
                                  currentTime: _currentTime,
                                  qiblaAngle: widget.city.qiblaAngle,
                                  compassHeading: 0.0,
                                  enableTawaf: true,
                                ),
                              ),

                              const SizedBox(height: 14),

                              // Big Digital Time
                              Text(
                                timeStr,
                                style: TextStyle(
                                  color: theme.accentColor,
                                  fontSize: 34,
                                  fontWeight: FontWeight.w300,
                                  letterSpacing: 2.0,
                                  fontFeatures: const [
                                    FontFeature.tabularFigures()
                                  ],
                                ),
                              ),

                              // Date
                              Text(
                                dateStr,
                                style: const TextStyle(
                                  color: Colors.white54,
                                  fontSize: 13,
                                ),
                              ),

                              const SizedBox(height: 12),

                              // Next Prayer Countdown Pill
                              if (next != null)
                                Container(
                                  padding: const EdgeInsets.symmetric(
                                      horizontal: 16, vertical: 7),
                                  decoration: BoxDecoration(
                                    color: const Color(0xFF11151E),
                                    borderRadius: BorderRadius.circular(20),
                                    border: Border.all(
                                        color: theme.primaryColor
                                            .withOpacity(0.4)),
                                  ),
                                  child: Row(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      Text(
                                        '${next.turkishName.toUpperCase()}: ',
                                        style: TextStyle(
                                          color: theme.primaryColor,
                                          fontSize: 12,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                      Text(
                                        next.formattedTime,
                                        style: const TextStyle(
                                          color: Colors.white,
                                          fontSize: 12,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                      const SizedBox(width: 8),
                                      const Text('•',
                                          style:
                                              TextStyle(color: Colors.white38)),
                                      const SizedBox(width: 8),
                                      Text(
                                        'Kalan $countdownStr',
                                        style: const TextStyle(
                                          color: Color(0xFF00FF88),
                                          fontSize: 12,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),

                              const SizedBox(height: 24),

                              // Tap to wake hint
                              const Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Icon(Icons.touch_app,
                                      color: Colors.white24, size: 14),
                                  SizedBox(width: 6),
                                  Text(
                                    'Uyanmak için ekrana dokunun',
                                    style: TextStyle(
                                        color: Colors.white24, fontSize: 11),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                      ),
                    );
                  },
                ),
              ),
            ),
          ),

          // Top Controls (Exit & Dimness)
          Positioned(
            top: MediaQuery.of(context).padding.top + 8,
            left: 16,
            right: 16,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                // Dimness Level Button
                GestureDetector(
                  onTap: _cycleBrightness,
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 10, vertical: 5),
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(14),
                      border: Border.all(color: Colors.white12),
                    ),
                    child: Row(
                      children: [
                        Icon(
                          _brightness > 0.8
                              ? Icons.brightness_high
                              : (_brightness > 0.4
                                  ? Icons.brightness_medium
                                  : Icons.brightness_low),
                          color: theme.primaryColor,
                          size: 14,
                        ),
                        const SizedBox(width: 5),
                        Text(
                          _brightness > 0.8
                              ? 'Parlak'
                              : (_brightness > 0.4 ? 'Loş' : 'Gece Modu'),
                          style: const TextStyle(
                              color: Colors.white70, fontSize: 11),
                        ),
                      ],
                    ),
                  ),
                ),

                // Exit screensaver button
                IconButton(
                  icon: const Icon(Icons.close, color: Colors.white54, size: 20),
                  onPressed: widget.onExit,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
