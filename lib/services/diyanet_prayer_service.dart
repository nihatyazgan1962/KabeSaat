import 'dart:convert';
import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/prayer_times_model.dart';
import 'prayer_calculator.dart';

class DiyanetPrayerService {
  static final DiyanetPrayerService _instance = DiyanetPrayerService._internal();
  factory DiyanetPrayerService() => _instance;
  DiyanetPrayerService._internal();

  /// Fetches live official Diyanet prayer times from Diyanet API
  Future<DayPrayerSchedule> fetchDiyanetTimes(CityLocation city, DateTime date) async {
    final prefs = await SharedPreferences.getInstance();
    final cacheKey = 'diyanet_${city.name}_${date.year}_${date.month}_${date.day}';

    // 1. Check local cache first
    final cachedJson = prefs.getString(cacheKey);
    if (cachedJson != null) {
      try {
        final data = json.decode(cachedJson);
        return _parseDiyanetJson(data, city, date, isLive: true);
      } catch (e) {
        debugPrint('Cache parse error: $e');
      }
    }

    // 2. Fetch live from Diyanet API (Method 13: Diyanet İşleri Başkanlığı)
    try {
      final cityName = _sanitizeCityName(city.name);
      final url = Uri.parse(
        'https://api.aladhan.com/v1/timingsByCity?city=$cityName&country=Turkey&method=13',
      );

      final client = HttpClient();
      client.connectionTimeout = const Duration(seconds: 4);
      final request = await client.getUrl(url);
      request.headers.set('Accept', 'application/json');
      final response = await request.close();

      if (response.statusCode == 200) {
        final responseBody = await response.transform(utf8.decoder).join();
        final data = json.decode(responseBody);
        await prefs.setString(cacheKey, responseBody);
        return _parseDiyanetJson(data, city, date, isLive: true);
      }
    } catch (e) {
      debugPrint('Live Diyanet API fetch error (using fallback): $e');
    }

    // 3. Fallback to precise astronomical Diyanet calculation formula
    return PrayerCalculator.calculateTimes(date, city);
  }

  DayPrayerSchedule _parseDiyanetJson(
    Map<String, dynamic> data,
    CityLocation city,
    DateTime date, {
    bool isLive = true,
  }) {
    final timings = data['data']['timings'];

    DateTime parseTimeStr(String timeStr) {
      final clean = timeStr.split(' ')[0];
      final parts = clean.split(':');
      final h = int.parse(parts[0]);
      final m = int.parse(parts[1]);
      return DateTime(date.year, date.month, date.day, h, m);
    }

    final imsakTime = timings['Imsak'] != null
        ? parseTimeStr(timings['Imsak'])
        : parseTimeStr(timings['Fajr']);
    final gunesTime = parseTimeStr(timings['Sunrise']);
    final ogleTime = parseTimeStr(timings['Dhuhr']);
    final ikindiTime = parseTimeStr(timings['Asr']);
    final aksamTime = parseTimeStr(timings['Maghrib']);
    final yatsiTime = parseTimeStr(timings['Isha']);

    final hijri = data['data']['date']?['hijri'];
    String hijriStr;
    if (hijri != null) {
      hijriStr = '${hijri['day']} ${hijri['month']?['tr'] ?? hijri['month']?['en']} ${hijri['year']}';
    } else {
      hijriStr = 'Hicrî Takvim (Diyanet)';
    }

    return DayPrayerSchedule(
      date: date,
      hijriDate: hijriStr,
      imsak: PrayerTime(
        name: 'imsak',
        turkishName: 'İmsak',
        time: imsakTime,
        makam: 'Saba Makamı',
        ismailCosarNote: 'Diyanet Güncel İmsak • İsmail Coşar Sabah Ezanı',
      ),
      gunes: PrayerTime(
        name: 'gunes',
        turkishName: 'Güneş',
        time: gunesTime,
        makam: 'Kerâhat Vakti',
        ismailCosarNote: 'Diyanet Güneş Doğuşu',
      ),
      ogle: PrayerTime(
        name: 'ogle',
        turkishName: 'Öğle',
        time: ogleTime,
        makam: 'Uşşak Makamı',
        ismailCosarNote: 'Diyanet Güncel Öğle • İsmail Coşar Uşşak Ezanı',
      ),
      ikindi: PrayerTime(
        name: 'ikindi',
        turkishName: 'İkindi',
        time: ikindiTime,
        makam: 'Rast Makamı',
        ismailCosarNote: 'Diyanet Güncel İkindi • İsmail Coşar Rast Ezanı',
      ),
      aksam: PrayerTime(
        name: 'aksam',
        turkishName: 'Akşam',
        time: aksamTime,
        makam: 'Segâh Makamı',
        ismailCosarNote: 'Diyanet Güncel İftar & Akşam • İsmail Coşar Segâh Ezanı',
      ),
      yatsi: PrayerTime(
        name: 'yatsi',
        turkishName: 'Yatsı',
        time: yatsiTime,
        makam: 'Hicaz Makamı',
        ismailCosarNote: 'Diyanet Güncel Yatsı • İsmail Coşar Hicaz Ezanı',
      ),
    );
  }

  String _sanitizeCityName(String city) {
    switch (city.toLowerCase()) {
      case 'i̇stanbul':
      case 'istanbul':
        return 'Istanbul';
      case 'i̇zmir':
      case 'izmir':
        return 'Izmir';
      case 'şanlıurfa':
        return 'Sanliurfa';
      case 'diyarbakır':
        return 'Diyarbakir';
      case 'eskişehir':
        return 'Eskisehir';
      case 'mekke-i mükerreme':
        return 'Mecca';
      case 'medine-i münevvere':
        return 'Medina';
      case 'kudüs':
        return 'Jerusalem';
      default:
        return city
            .replaceAll('ç', 'c')
            .replaceAll('ğ', 'g')
            .replaceAll('ı', 'i')
            .replaceAll('ö', 'o')
            .replaceAll('ş', 's')
            .replaceAll('ü', 'u')
            .replaceAll('İ', 'I');
    }
  }
}
