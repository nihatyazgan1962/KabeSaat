import 'dart:math' as math;
import '../models/prayer_times_model.dart';

class PrayerCalculator {
  static const double kaabaLat = 21.422487;
  static const double kaabaLng = 39.826206;

  static const List<CityLocation> popularCities = [
    CityLocation(name: 'İstanbul', latitude: 41.0082, longitude: 28.9784, qiblaAngle: 151.0),
    CityLocation(name: 'Ankara', latitude: 39.9334, longitude: 32.8597, qiblaAngle: 154.5),
    CityLocation(name: 'İzmir', latitude: 38.4237, longitude: 27.1428, qiblaAngle: 147.0),
    CityLocation(name: 'Bursa', latitude: 40.1885, longitude: 29.0610, qiblaAngle: 150.8),
    CityLocation(name: 'Antalya', latitude: 36.8969, longitude: 30.7133, qiblaAngle: 151.3),
    CityLocation(name: 'Konya', latitude: 37.8746, longitude: 32.4932, qiblaAngle: 153.8),
    CityLocation(name: 'Adana', latitude: 37.0000, longitude: 35.3213, qiblaAngle: 161.4),
    CityLocation(name: 'Gaziantep', latitude: 37.0662, longitude: 37.3833, qiblaAngle: 167.2),
    CityLocation(name: 'Diyarbakır', latitude: 37.9144, longitude: 40.2306, qiblaAngle: 173.5),
    CityLocation(name: 'Şanlıurfa', latitude: 37.1674, longitude: 38.7955, qiblaAngle: 170.1),
    CityLocation(name: 'Kayseri', latitude: 38.7205, longitude: 35.4826, qiblaAngle: 159.2),
    CityLocation(name: 'Eskişehir', latitude: 39.7767, longitude: 30.5206, qiblaAngle: 151.9),
    CityLocation(name: 'Trabzon', latitude: 41.0027, longitude: 39.7168, qiblaAngle: 170.8),
    CityLocation(name: 'Samsun', latitude: 41.2867, longitude: 36.33, qiblaAngle: 163.5),
    CityLocation(name: 'Erzurum', latitude: 39.9043, longitude: 41.2678, qiblaAngle: 177.3),
    CityLocation(name: 'Mekke-i Mükerreme', latitude: 21.4225, longitude: 39.8262, qiblaAngle: 0.0),
    CityLocation(name: 'Medine-i Münevvere', latitude: 24.5247, longitude: 39.5692, qiblaAngle: 176.3),
    CityLocation(name: 'Kudüs', latitude: 31.7683, longitude: 35.2137, qiblaAngle: 155.6),
  ];

  static double calculateQibla(double lat, double lng) {
    final phi1 = lat * math.pi / 180.0;
    const phi2 = kaabaLat * math.pi / 180.0;
    final deltaLambda = (kaabaLng - lng) * math.pi / 180.0;

    final y = math.sin(deltaLambda);
    final x = math.cos(phi1) * math.tan(phi2) - math.sin(phi1) * math.cos(deltaLambda);
    var qibla = math.atan2(y, x) * 180.0 / math.pi;
    if (qibla < 0) {
      qibla += 360.0;
    }
    return qibla;
  }

  static double distanceToKaabaKm(double lat, double lng) {
    const r = 6371.0; // Earth radius in km
    final dLat = (kaabaLat - lat) * math.pi / 180.0;
    final dLng = (kaabaLng - lng) * math.pi / 180.0;
    final a = math.sin(dLat / 2) * math.sin(dLat / 2) +
        math.cos(lat * math.pi / 180.0) *
            math.cos(kaabaLat * math.pi / 180.0) *
            math.sin(dLng / 2) *
            math.sin(dLng / 2);
    final c = 2 * math.atan2(math.sqrt(a), math.sqrt(1 - a));
    return r * c;
  }

  /// Calculates prayer times for a given date and location (Diyanet standard formula)
  static DayPrayerSchedule calculateTimes(DateTime date, CityLocation city) {
    final year = date.year;
    final month = date.month;
    final day = date.day;

    // Day of year
    final n = date.difference(DateTime(year, 1, 1)).inDays + 1;

    // Solar coordinates approximation
    final b = 2 * math.pi * (n - 81) / 365.0;
    // Equation of time in minutes
    final eot = 9.87 * math.sin(2 * b) - 7.53 * math.cos(b) - 1.5 * math.sin(b);
    // Solar declination in radians
    final delta = 23.45 * (math.pi / 180.0) * math.sin(2 * math.pi * (284 + n) / 365.0);

    final latRad = city.latitude * math.pi / 180.0;

    // Local solar noon (Öğle) in UTC
    const timezoneOffset = 3.0; // Turkey UTC+3 fixed
    final solarNoonUtcMinutes = 720.0 - (4.0 * city.longitude) - eot;
    final solarNoonLocalMinutes = solarNoonUtcMinutes + (timezoneOffset * 60.0);

    // Sun altitude angles
    // Diyanet standard: Fajr (İmsak) = -18 degrees, Sunrise (Güneş) = -0.833 degrees
    // Isha (Yatsı) = -17 degrees
    double hourAngle(double alphaDeg) {
      final alphaRad = alphaDeg * math.pi / 180.0;
      final cosH = (math.sin(alphaRad) - math.sin(latRad) * math.sin(delta)) /
          (math.cos(latRad) * math.cos(delta));
      if (cosH > 1.0) return 0.0;
      if (cosH < -1.0) return 180.0;
      return math.acos(cosH) * 180.0 / math.pi;
    }

    final hSunrise = hourAngle(-0.8333);
    final hFajr = hourAngle(-18.0);
    final hIsha = hourAngle(-17.0);

    // Asr (İkindi) Shafi'i shadow = shadow = 1 + tan|lat - delta|
    final asrAltRad = math.atan(1.0 / (1.0 + math.tan((latRad - delta).abs())));
    final asrAltDeg = asrAltRad * 180.0 / math.pi;
    final hAsr = hourAngle(asrAltDeg);

    DateTime minutesToDateTime(double totalMinutes) {
      final hours = (totalMinutes / 60.0).floor();
      final mins = (totalMinutes % 60.0).round();
      final normHours = (hours % 24 + 24) % 24;
      return DateTime(year, month, day, normHours, mins);
    }

    final ogleMin = solarNoonLocalMinutes;
    final gunesMin = solarNoonLocalMinutes - (hSunrise * 4.0);
    final imsakMin = solarNoonLocalMinutes - (hFajr * 4.0);
    final ikindiMin = solarNoonLocalMinutes + (hAsr * 4.0);
    final aksamMin = solarNoonLocalMinutes + (hSunrise * 4.0);
    final yatsiMin = solarNoonLocalMinutes + (hIsha * 4.0);

    return DayPrayerSchedule(
      date: date,
      hijriDate: _approximateHijri(date),
      imsak: PrayerTime(
        name: 'imsak',
        turkishName: 'İmsak',
        time: minutesToDateTime(imsakMin),
        makam: 'Saba Makamı',
        ismailCosarNote: 'İsmail Coşar - Sabah Ezanı & Selâ (Saba/Hicaz)',
      ),
      gunes: PrayerTime(
        name: 'gunes',
        turkishName: 'Güneş',
        time: minutesToDateTime(gunesMin),
        makam: 'Kerâhat Vakti',
        ismailCosarNote: 'Güneş Doğuşu (Ezan okunmaz)',
      ),
      ogle: PrayerTime(
        name: 'ogle',
        turkishName: 'Öğle',
        time: minutesToDateTime(ogleMin),
        makam: 'Uşşak Makamı',
        ismailCosarNote: 'İsmail Coşar - Uşşak Makamı Öğle Ezanı',
      ),
      ikindi: PrayerTime(
        name: 'ikindi',
        turkishName: 'İkindi',
        time: minutesToDateTime(ikindiMin),
        makam: 'Rast Makamı',
        ismailCosarNote: 'İsmail Coşar - Rast Makamı İkindi Ezanı',
      ),
      aksam: PrayerTime(
        name: 'aksam',
        turkishName: 'Akşam',
        time: minutesToDateTime(aksamMin),
        makam: 'Segâh Makamı',
        ismailCosarNote: 'İsmail Coşar - Segâh Makamı Akşam & İftar Ezanı',
      ),
      yatsi: PrayerTime(
        name: 'yatsi',
        turkishName: 'Yatsı',
        time: minutesToDateTime(yatsiMin),
        makam: 'Hicaz Makamı',
        ismailCosarNote: 'İsmail Coşar - Hicaz Makamı Yatsı Ezanı',
      ),
    );
  }

  static String _approximateHijri(DateTime date) {
    // Julian Day to Hijri conversion
    final y = date.year;
    final m = date.month;
    final d = date.day;

    int jd;
    if (m > 2) {
      jd = (365.25 * (y + 4716)).floor() + (30.6001 * (m + 1)).floor() + d - 1524;
    } else {
      jd = (365.25 * (y - 1 + 4716)).floor() + (30.6001 * (m + 13)).floor() + d - 1524;
    }

    final l = jd - 1948440 + 10632;
    final n = ((l - 1) / 10631).floor();
    final l2 = l - 10631 * n + 354;
    final j = ((10985 - l2) / 5316).floor() * ((50 * l2) / 17719).floor() +
        (l2 / 5670).floor() * ((43 * l2) / 15238).floor();
    final l3 = l2 - ((30 - j) / 15).floor() * ((17719 * j) / 50).floor() -
        (j / 16).floor() * ((15238 * j) / 43).floor() + 29;
    final hijriMonth = ((24 * l3) / 709).floor();
    final hijriDay = l3 - ((709 * hijriMonth) / 24).floor();
    final hijriYear = 30 * n + j - 30;

    final monthNames = [
      'Muharrem', 'Safer', 'Rebiülevvel', 'Rebiülahir',
      'Cemaziyelevvel', 'Cemaziyelahir', 'Recep', 'Şaban',
      'Ramazan-ı Şerif', 'Şevval', 'Zilkade', 'Zilhicce'
    ];
    final mIndex = (hijriMonth - 1).clamp(0, 11);
    return '$hijriDay ${monthNames[mIndex]} $hijriYear';
  }

  /// Generates a 30-day Imsakiye table for the current month
  static List<DayPrayerSchedule> generateMonthlyImsakiye(DateTime startingDate, CityLocation city) {
    final list = <DayPrayerSchedule>[];
    for (int i = 0; i < 30; i++) {
      final date = startingDate.add(Duration(days: i));
      list.add(calculateTimes(date, city));
    }
    return list;
  }
}
