import 'package:flutter/material.dart';
import '../models/prayer_times_model.dart';

class PrayerRibbon extends StatelessWidget {
  final DayPrayerSchedule schedule;
  final Function(PrayerTime) onPlayEzan;

  const PrayerRibbon({
    super.key,
    required this.schedule,
    required this.onPlayEzan,
  });

  @override
  Widget build(BuildContext context) {
    final prayers = schedule.allPrayers;
    final current = schedule.currentPrayer;
    final next = schedule.nextPrayer;

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 14),
      padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 10),
      decoration: BoxDecoration(
        color: const Color(0xFF161A22).withOpacity(0.88),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: const Color(0xFFD4AF37).withOpacity(0.4),
          width: 1.5,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.5),
            blurRadius: 15,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Header: Hijri date + Next prayer reminder
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  const Icon(Icons.calendar_month, color: Color(0xFFD4AF37), size: 16),
                  const SizedBox(width: 6),
                  Text(
                    schedule.hijriDate,
                    style: const TextStyle(
                      color: Color(0xFFE2C974),
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
              if (next != null)
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                  decoration: BoxDecoration(
                    color: const Color(0xFFD4AF37).withOpacity(0.2),
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(color: const Color(0xFFD4AF37), width: 0.8),
                  ),
                  child: Row(
                    children: [
                      const Icon(Icons.timer_outlined, color: Color(0xFFFFD700), size: 14),
                      const SizedBox(width: 4),
                      Text(
                        'Sıradaki: ${next.turkishName} (${next.formattedTime})',
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                ),
            ],
          ),
          const SizedBox(height: 10),
          // 6 Prayer items
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: prayers.map((p) {
              final isCurrent = p.name == current.name;
              final isNext = next != null && p.name == next.name;

              return Expanded(
                child: GestureDetector(
                  onTap: () => onPlayEzan(p),
                  child: Container(
                    margin: const EdgeInsets.symmetric(horizontal: 2),
                    padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 2),
                    decoration: BoxDecoration(
                      color: isCurrent
                          ? const Color(0xFFD4AF37).withOpacity(0.25)
                          : (isNext
                              ? Colors.white.withOpacity(0.08)
                              : Colors.transparent),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                        color: isCurrent
                            ? const Color(0xFFFFD700)
                            : (isNext ? const Color(0xFFD4AF37).withOpacity(0.5) : Colors.transparent),
                        width: isCurrent ? 1.5 : 1.0,
                      ),
                    ),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          p.turkishName,
                          style: TextStyle(
                            color: isCurrent ? const Color(0xFFFFD700) : Colors.white70,
                            fontSize: 11,
                            fontWeight: isCurrent ? FontWeight.bold : FontWeight.w500,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          p.formattedTime,
                          style: TextStyle(
                            color: isCurrent ? Colors.white : Colors.white.withOpacity(0.9),
                            fontSize: 13,
                            fontWeight: isCurrent ? FontWeight.w900 : FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Icon(
                          p.name == 'gunes' ? Icons.wb_sunny_outlined : Icons.volume_up,
                          size: 13,
                          color: isCurrent
                              ? const Color(0xFFFFD700)
                              : const Color(0xFFD4AF37).withOpacity(0.6),
                        ),
                      ],
                    ),
                  ),
                ),
              );
            }).toList(),
          ),
        ],
      ),
    );
  }
}

