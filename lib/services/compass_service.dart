import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';

class CompassService {
  static final CompassService _instance = CompassService._internal();
  factory CompassService() => _instance;
  CompassService._internal();

  static const EventChannel _compassChannel = EventChannel('com.kabesaat.app/compass');

  final ValueNotifier<double> headingNotifier = ValueNotifier<double>(0.0);
  final ValueNotifier<bool> hasSensorNotifier = ValueNotifier<bool>(false);

  StreamSubscription? _subscription;
  double _filteredHeading = 0.0;
  bool _initialized = false;

  void startListening() {
    _subscription?.cancel();

    try {
      _subscription = _compassChannel.receiveBroadcastStream().listen(
        (dynamic event) {
          if (event is num) {
            hasSensorNotifier.value = true;
            final currentHeading = (event.toDouble() % 360.0 + 360.0) % 360.0;

            if (!_initialized) {
              _filteredHeading = currentHeading;
              _initialized = true;
            } else {
              var diff = currentHeading - _filteredHeading;
              while (diff < -180.0) {
                diff += 360.0;
              }
              while (diff > 180.0) {
                diff -= 360.0;
              }
              // 0.40 provides instant, real-time hardware response with zero lag
              _filteredHeading = (_filteredHeading + diff * 0.40 + 360.0) % 360.0;
            }

            headingNotifier.value = _filteredHeading;
          }
        },
        onError: (err) {
          debugPrint('Native Kotlin compass channel error: $err');
          hasSensorNotifier.value = false;
        },
      );
    } catch (e) {
      debugPrint('Error starting native compass channel: $e');
      hasSensorNotifier.value = false;
    }
  }

  void stopListening() {
    _subscription?.cancel();
    _subscription = null;
    _initialized = false;
  }

  void setManualHeading(double heading) {
    headingNotifier.value = (heading + 360.0) % 360.0;
  }
}
