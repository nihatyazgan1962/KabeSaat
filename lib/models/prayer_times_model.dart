class PrayerTime {
  final String name;
  final String turkishName;
  final DateTime time;
  final String makam;
  final String ismailCosarNote;

  PrayerTime({
    required this.name,
    required this.turkishName,
    required this.time,
    required this.makam,
    required this.ismailCosarNote,
  });

  String get formattedTime {
    final h = time.hour.toString().padLeft(2, '0');
    final m = time.minute.toString().padLeft(2, '0');
    return '$h:$m';
  }
}

class DayPrayerSchedule {
  final DateTime date;
  final String hijriDate;
  final PrayerTime imsak;
  final PrayerTime gunes;
  final PrayerTime ogle;
  final PrayerTime ikindi;
  final PrayerTime aksam;
  final PrayerTime yatsi;

  DayPrayerSchedule({
    required this.date,
    required this.hijriDate,
    required this.imsak,
    required this.gunes,
    required this.ogle,
    required this.ikindi,
    required this.aksam,
    required this.yatsi,
  });

  List<PrayerTime> get allPrayers => [imsak, gunes, ogle, ikindi, aksam, yatsi];

  PrayerTime? get nextPrayer {
    final now = DateTime.now();
    for (final p in allPrayers) {
      if (p.time.isAfter(now)) {
        return p;
      }
    }
    // If all passed, next is tomorrow's imsak
    return null;
  }

  PrayerTime get currentPrayer {
    final now = DateTime.now();
    if (now.isBefore(imsak.time)) return yatsi; // from yesterday
    if (now.isBefore(gunes.time)) return imsak;
    if (now.isBefore(ogle.time)) return gunes;
    if (now.isBefore(ikindi.time)) return ogle;
    if (now.isBefore(aksam.time)) return ikindi;
    if (now.isBefore(yatsi.time)) return aksam;
    return yatsi;
  }
}

class CityLocation {
  final String name;
  final double latitude;
  final double longitude;
  final double qiblaAngle; // degrees from North

  const CityLocation({
    required this.name,
    required this.latitude,
    required this.longitude,
    required this.qiblaAngle,
  });
}

