import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import '../models/prayer_times_model.dart';

class WidgetService {
  static final WidgetService _instance = WidgetService._internal();
  factory WidgetService() => _instance;
  WidgetService._internal();

  static const MethodChannel _channel = MethodChannel('com.kabesaat.app/widget');

  Future<void> updateWidget({
    required CityLocation city,
    required DayPrayerSchedule schedule,
  }) async {
    try {
      final next = schedule.nextPrayer;
      final now = DateTime.now();

      String nextName = 'İMSAK VAKTİ';
      String nextTime = schedule.imsak.formattedTime;
      String countdown = '';

      if (next != null) {
        nextName = '${next.turkishName.toUpperCase()} VAKTİ';
        nextTime = next.formattedTime;
        final diff = next.time.difference(now);
        final hours = diff.inHours.toString().padLeft(2, '0');
        final mins = (diff.inMinutes % 60).toString().padLeft(2, '0');
        final secs = (diff.inSeconds % 60).toString().padLeft(2, '0');
        countdown = 'Kalan: $hours:$mins:$secs';
      } else {
        countdown = 'Yatsı Vakti İçi';
      }

      await _channel.invokeMethod('updateWidgetData', {
        'city_name': city.name,
        'next_name': nextName,
        'next_time': nextTime,
        'countdown': countdown,
        'time_imsak': schedule.imsak.formattedTime,
        'time_ogle': schedule.ogle.formattedTime,
        'time_ikindi': schedule.ikindi.formattedTime,
        'time_aksam': schedule.aksam.formattedTime,
        'time_yatsi': schedule.yatsi.formattedTime,
      });
    } catch (e) {
      debugPrint('Error updating native Android widget: $e');
    }
  }
}

