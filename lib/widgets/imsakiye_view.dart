import 'package:flutter/material.dart';
import '../models/prayer_times_model.dart';
import '../services/prayer_calculator.dart';
import '../services/theme_service.dart';

class ImsakiyeView extends StatefulWidget {
  final CityLocation city;
  final VoidCallback onClose;

  const ImsakiyeView({
    super.key,
    required this.city,
    required this.onClose,
  });

  @override
  State<ImsakiyeView> createState() => _ImsakiyeViewState();
}

class _ImsakiyeViewState extends State<ImsakiyeView> {
  late DateTime _selectedMonth;

  static const List<String> turkishMonths = [
    '',
    'Ocak',
    'Şubat',
    'Mart',
    'Nisan',
    'Mayıs',
    'Haziran',
    'Temmuz',
    'Ağustos',
    'Eylül',
    'Ekim',
    'Kasım',
    'Aralık',
  ];

  static const List<String> turkishDays = [
    '',
    'Pzt',
    'Sal',
    'Çar',
    'Per',
    'Cum',
    'Cmt',
    'Paz',
  ];

  @override
  void initState() {
    super.initState();
    final now = DateTime.now();
    _selectedMonth = DateTime(now.year, now.month, 1);
  }

  void _previousMonth() {
    setState(() {
      _selectedMonth = DateTime(_selectedMonth.year, _selectedMonth.month - 1, 1);
    });
  }

  void _nextMonth() {
    setState(() {
      _selectedMonth = DateTime(_selectedMonth.year, _selectedMonth.month + 1, 1);
    });
  }

  @override
  Widget build(BuildContext context) {
    final now = DateTime.now();
    final theme = ThemeService().currentTheme;

    // Number of days in selected month
    final nextMonth = DateTime(_selectedMonth.year, _selectedMonth.month + 1, 1);
    final daysInMonth = nextMonth.difference(_selectedMonth).inDays;

    final list = <DayPrayerSchedule>[];
    for (int i = 0; i < daysInMonth; i++) {
      final date = _selectedMonth.add(Duration(days: i));
      list.add(PrayerCalculator.calculateTimes(date, widget.city));
    }

    final todaySchedule = PrayerCalculator.calculateTimes(now, widget.city);
    final monthName = turkishMonths[_selectedMonth.month];

    return Container(
      height: MediaQuery.of(context).size.height * 0.88,
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
      decoration: BoxDecoration(
        color: const Color(0xFF0D1117).withOpacity(0.98),
        borderRadius: const BorderRadius.vertical(top: Radius.circular(28)),
        border: Border.all(color: theme.primaryColor, width: 1.5),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.85),
            blurRadius: 20,
            spreadRadius: 6,
          ),
        ],
      ),
      child: Column(
        children: [
          // Drag handle & title
          Container(
            width: 44,
            height: 4,
            margin: const EdgeInsets.only(bottom: 10),
            decoration: BoxDecoration(
              color: Colors.white24,
              borderRadius: BorderRadius.circular(2),
            ),
          ),

          // Header
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    '${widget.city.name.toUpperCase()} İMSAKİYESİ',
                    style: TextStyle(
                      color: theme.accentColor,
                      fontSize: 17,
                      fontWeight: FontWeight.bold,
                      letterSpacing: 1.0,
                    ),
                  ),
                  Text(
                    'Hicri: ${todaySchedule.hijriDate}',
                    style: const TextStyle(color: Colors.white70, fontSize: 11),
                  ),
                ],
              ),
              IconButton(
                icon: const Icon(Icons.close, color: Colors.white70),
                onPressed: widget.onClose,
              ),
            ],
          ),

          const SizedBox(height: 10),

          // Month Selector Row with Turkish Month Name
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
            decoration: BoxDecoration(
              color: const Color(0xFF161C28),
              borderRadius: BorderRadius.circular(14),
              border: Border.all(color: Colors.white.withOpacity(0.08)),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                IconButton(
                  icon: const Icon(Icons.chevron_left, color: Color(0xFFFFD700)),
                  tooltip: 'Önceki Ay',
                  onPressed: _previousMonth,
                ),
                Row(
                  children: [
                    const Icon(Icons.calendar_month, color: Color(0xFFFFD700), size: 18),
                    const SizedBox(width: 8),
                    Text(
                      '$monthName ${_selectedMonth.year}'.toUpperCase(),
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 15,
                        fontWeight: FontWeight.bold,
                        letterSpacing: 1.2,
                      ),
                    ),
                  ],
                ),
                IconButton(
                  icon: const Icon(Icons.chevron_right, color: Color(0xFFFFD700)),
                  tooltip: 'Sonraki Ay',
                  onPressed: _nextMonth,
                ),
              ],
            ),
          ),

          const SizedBox(height: 10),

          // Ramadan Highlights: Sahur & Iftar Today
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                colors: [Color(0xFF281C0C), Color(0xFF19130A)],
              ),
              borderRadius: BorderRadius.circular(14),
              border: Border.all(color: theme.primaryColor.withOpacity(0.4)),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                _ramadanBox('Bugün Sahur (İmsak)', todaySchedule.imsak.formattedTime, Icons.nightlight_round, theme),
                Container(width: 1, height: 32, color: Colors.white24),
                _ramadanBox('Bugün İftar (Akşam)', todaySchedule.aksam.formattedTime, Icons.dinner_dining, theme),
              ],
            ),
          ),

          const SizedBox(height: 10),

          // Table Header
          Container(
            padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 6),
            decoration: BoxDecoration(
              color: const Color(0xFF1A1F2C),
              borderRadius: BorderRadius.circular(10),
            ),
            child: const Row(
              children: [
                Expanded(flex: 3, child: Text('Tarih (Ay & Gün)', style: _headerStyle)),
                Expanded(flex: 2, child: Text('İmsak', style: _headerStyle, textAlign: TextAlign.center)),
                Expanded(flex: 2, child: Text('Güneş', style: _headerStyle, textAlign: TextAlign.center)),
                Expanded(flex: 2, child: Text('Öğle', style: _headerStyle, textAlign: TextAlign.center)),
                Expanded(flex: 2, child: Text('İkindi', style: _headerStyle, textAlign: TextAlign.center)),
                Expanded(flex: 2, child: Text('İftar', style: _headerGoldStyle, textAlign: TextAlign.center)),
                Expanded(flex: 2, child: Text('Yatsı', style: _headerStyle, textAlign: TextAlign.center)),
              ],
            ),
          ),

          const SizedBox(height: 4),

          // 30 Days List with Turkish Months
          Expanded(
            child: ListView.builder(
              itemCount: list.length,
              itemBuilder: (context, index) {
                final item = list[index];
                final isToday = item.date.day == now.day &&
                    item.date.month == now.month &&
                    item.date.year == now.year;
                final dayNum = item.date.day;
                final trMonth = turkishMonths[item.date.month];
                final trDay = turkishDays[item.date.weekday];

                return Container(
                  margin: const EdgeInsets.symmetric(vertical: 2.5),
                  padding: const EdgeInsets.symmetric(vertical: 7, horizontal: 6),
                  decoration: BoxDecoration(
                    color: isToday
                        ? theme.primaryColor.withOpacity(0.25)
                        : (index % 2 == 0
                            ? Colors.white.withOpacity(0.03)
                            : Colors.transparent),
                    borderRadius: BorderRadius.circular(8),
                    border: isToday
                        ? Border.all(color: theme.accentColor, width: 1.2)
                        : null,
                  ),
                  child: Row(
                    children: [
                      // Date with Turkish Month and Day Name: e.g. "1 Kasım Paz"
                      Expanded(
                        flex: 3,
                        child: Text(
                          '$dayNum $trMonth $trDay',
                          style: TextStyle(
                            color: isToday ? theme.accentColor : Colors.white,
                            fontWeight: isToday ? FontWeight.bold : FontWeight.w500,
                            fontSize: 11,
                          ),
                        ),
                      ),
                      Expanded(
                        flex: 2,
                        child: Text(
                          item.imsak.formattedTime,
                          style: _cellStyle(isToday),
                          textAlign: TextAlign.center,
                        ),
                      ),
                      Expanded(
                        flex: 2,
                        child: Text(
                          item.gunes.formattedTime,
                          style: _cellMutedStyle(isToday),
                          textAlign: TextAlign.center,
                        ),
                      ),
                      Expanded(
                        flex: 2,
                        child: Text(
                          item.ogle.formattedTime,
                          style: _cellStyle(isToday),
                          textAlign: TextAlign.center,
                        ),
                      ),
                      Expanded(
                        flex: 2,
                        child: Text(
                          item.ikindi.formattedTime,
                          style: _cellStyle(isToday),
                          textAlign: TextAlign.center,
                        ),
                      ),
                      Expanded(
                        flex: 2,
                        child: Text(
                          item.aksam.formattedTime,
                          style: TextStyle(
                            color: isToday ? const Color(0xFFFFD700) : const Color(0xFFE5C158),
                            fontWeight: FontWeight.bold,
                            fontSize: 12,
                          ),
                          textAlign: TextAlign.center,
                        ),
                      ),
                      Expanded(
                        flex: 2,
                        child: Text(
                          item.yatsi.formattedTime,
                          style: _cellStyle(isToday),
                          textAlign: TextAlign.center,
                        ),
                      ),
                    ],
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  static const TextStyle _headerStyle = TextStyle(
    color: Colors.white70,
    fontSize: 11,
    fontWeight: FontWeight.w600,
  );

  static const TextStyle _headerGoldStyle = TextStyle(
    color: Color(0xFFFFD700),
    fontSize: 11,
    fontWeight: FontWeight.bold,
  );

  static TextStyle _cellStyle(bool isToday) => TextStyle(
        color: isToday ? Colors.white : Colors.white70,
        fontWeight: isToday ? FontWeight.bold : FontWeight.normal,
        fontSize: 11.5,
      );

  static TextStyle _cellMutedStyle(bool isToday) => TextStyle(
        color: isToday ? Colors.white60 : Colors.white38,
        fontSize: 11.5,
      );

  Widget _ramadanBox(String title, String time, IconData icon, dynamic theme) {
    return Row(
      children: [
        Icon(icon, color: const Color(0xFFFFD700), size: 18),
        const SizedBox(width: 8),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(title, style: const TextStyle(color: Colors.white70, fontSize: 10)),
            Text(
              time,
              style: const TextStyle(
                color: Color(0xFFFFD700),
                fontSize: 15,
                fontWeight: FontWeight.w900,
              ),
            ),
          ],
        ),
      ],
    );
  }
}
