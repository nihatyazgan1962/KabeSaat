import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../models/prayer_times_model.dart';
import '../services/audio_service.dart';
import '../services/compass_service.dart';
import '../services/prayer_calculator.dart';
import 'kabe_analog_clock.dart';

class QiblaCompassView extends StatefulWidget {
  final CityLocation city;
  final VoidCallback onClose;

  const QiblaCompassView({
    super.key,
    required this.city,
    required this.onClose,
  });

  @override
  State<QiblaCompassView> createState() => _QiblaCompassViewState();
}

class _QiblaCompassViewState extends State<QiblaCompassView> {
  final CompassService _compassService = CompassService();
  double _currentHeading = 0.0;
  bool _useManual = false;
  bool _wasAligned = false;
  bool _qiblaSoundEnabled = true;

  @override
  void initState() {
    super.initState();
    _compassService.startListening();
    _compassService.headingNotifier.addListener(_onHeadingChanged);
  }

  void _onHeadingChanged() {
    if (!_useManual && mounted) {
      setState(() {
        _currentHeading = _compassService.headingNotifier.value;
      });

      final qiblaAngle = widget.city.qiblaAngle;
      final diff = ((qiblaAngle - _currentHeading) + 360) % 360;
      final isAligned = (diff < 3.5 || diff > 356.5);

      if (isAligned && !_wasAligned) {
        HapticFeedback.heavyImpact();
        if (_qiblaSoundEnabled) {
          AudioService().playQiblaLockFeedback();
        }
        _wasAligned = true;
      } else if (!isAligned && (diff > 8.0 && diff < 352.0)) {
        _wasAligned = false;
      }
    }
  }

  @override
  void dispose() {
    _compassService.headingNotifier.removeListener(_onHeadingChanged);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final qiblaAngle = widget.city.qiblaAngle;
    final diff = ((qiblaAngle - _currentHeading) + 360) % 360;
    final isAligned = (diff < 3.5 || diff > 356.5);
    final distanceKm = PrayerCalculator.distanceToKaabaKm(
      widget.city.latitude,
      widget.city.longitude,
    );

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 18),
      decoration: BoxDecoration(
        color: const Color(0xFF0F1218).withOpacity(0.98),
        borderRadius: const BorderRadius.vertical(top: Radius.circular(28)),
        border: Border.all(color: const Color(0xFFD4AF37), width: 1.5),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Drag handle & title
          Container(
            width: 44,
            height: 4,
            margin: const EdgeInsets.only(bottom: 12),
            decoration: BoxDecoration(
              color: Colors.white24,
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'KÂBE KIBLE PUSULASI',
                    style: TextStyle(
                      color: Color(0xFFFFD700),
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      letterSpacing: 1.1,
                    ),
                  ),
                  Text(
                    '${widget.city.name} için Kıble Açısı: ${qiblaAngle.toStringAsFixed(1)}°',
                    style: const TextStyle(color: Colors.white70, fontSize: 13),
                  ),
                ],
              ),
              Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  IconButton(
                    icon: Icon(
                      _qiblaSoundEnabled ? Icons.volume_up : Icons.volume_off,
                      color: _qiblaSoundEnabled ? const Color(0xFFFFD700) : Colors.white38,
                    ),
                    tooltip: _qiblaSoundEnabled ? 'Kıble Sesi Açık' : 'Kıble Sesi Kapalı',
                    onPressed: () {
                      setState(() {
                        _qiblaSoundEnabled = !_qiblaSoundEnabled;
                      });
                    },
                  ),
                  IconButton(
                    icon: const Icon(Icons.close, color: Colors.white70),
                    onPressed: widget.onClose,
                  ),
                ],
              ),
            ],
          ),
          const SizedBox(height: 14),

          // Kaaba Clock Compass Dial
          KabeAnalogClock(
            currentTime: DateTime.now(),
            size: 260,
            qiblaAngle: qiblaAngle,
            compassHeading: _currentHeading,
            isQiblaMode: true,
          ),

          const SizedBox(height: 16),

          // Status Badge: Aligned or Searching
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 9),
            decoration: BoxDecoration(
              color: isAligned
                  ? const Color(0xFF00AA55).withOpacity(0.28)
                  : const Color(0xFFD4AF37).withOpacity(0.15),
              borderRadius: BorderRadius.circular(24),
              border: Border.all(
                color: isAligned ? const Color(0xFF00FF77) : const Color(0xFFD4AF37),
                width: 1.5,
              ),
              boxShadow: isAligned
                  ? [
                      BoxShadow(
                        color: const Color(0xFF00FF77).withOpacity(0.35),
                        blurRadius: 16,
                      )
                    ]
                  : null,
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  isAligned ? Icons.check_circle : Icons.explore,
                  color: isAligned ? const Color(0xFF00FF77) : const Color(0xFFFFD700),
                  size: 20,
                ),
                const SizedBox(width: 8),
                Text(
                  isAligned
                      ? '✓ KIBLE DÜZ HİZALANDI! (KÂBE-İ MUAZZAMA)'
                      : 'Kıble İbresini Saatin 12 Yönüne Düz Hizalayın',
                  style: TextStyle(
                    color: isAligned ? const Color(0xFF00FF77) : Colors.white,
                    fontWeight: FontWeight.bold,
                    fontSize: 13,
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: 14),

          // Distance & Coordinates Info
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _infoTile('Mekke-i Mükerreme', '${distanceKm.toStringAsFixed(0)} km'),
              _infoTile('Telefon Açısı', '${_currentHeading.toStringAsFixed(0)}°'),
              _infoTile('Hedef Kıble', '${qiblaAngle.toStringAsFixed(1)}°'),
            ],
          ),

          const SizedBox(height: 8),

          // Manual rotation slider for testing/calibration
          Row(
            children: [
              const Text('Manuel Açı:', style: TextStyle(color: Colors.white54, fontSize: 11)),
              Expanded(
                child: Slider(
                  value: _currentHeading,
                  min: 0,
                  max: 360,
                  activeColor: const Color(0xFFD4AF37),
                  inactiveColor: Colors.white24,
                  onChanged: (val) {
                    setState(() {
                      _useManual = true;
                      _currentHeading = val;
                    });
                  },
                ),
              ),
              IconButton(
                tooltip: 'Pusula Sensörüne Dön',
                icon: Icon(
                  _useManual ? Icons.screen_rotation : Icons.sensors,
                  color: _useManual ? Colors.orangeAccent : const Color(0xFF00FF77),
                  size: 20,
                ),
                onPressed: () {
                  setState(() {
                    _useManual = false;
                  });
                },
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _infoTile(String label, String value) {
    return Column(
      children: [
        Text(label, style: const TextStyle(color: Colors.white54, fontSize: 11)),
        const SizedBox(height: 3),
        Text(
          value,
          style: const TextStyle(
            color: Color(0xFFFFD700),
            fontSize: 14,
            fontWeight: FontWeight.bold,
          ),
        ),
      ],
    );
  }
}
