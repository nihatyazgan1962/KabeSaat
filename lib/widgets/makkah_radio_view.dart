import 'dart:math' as math;
import 'package:flutter/material.dart';
import '../services/quran_radio_service.dart';

class MakkahRadioView extends StatefulWidget {
  final VoidCallback? onClose;

  const MakkahRadioView({super.key, this.onClose});

  @override
  State<MakkahRadioView> createState() => _MakkahRadioViewState();
}

class _MakkahRadioViewState extends State<MakkahRadioView>
    with SingleTickerProviderStateMixin {
  final QuranRadioService _radioService = QuranRadioService();
  late AnimationController _waveController;

  @override
  void initState() {
    super.initState();
    _waveController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1200),
    )..repeat();
  }

  @override
  void dispose() {
    _waveController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: const Color(0xFF0F131D).withOpacity(0.98),
        borderRadius: const BorderRadius.vertical(top: Radius.circular(28)),
        border: Border.all(color: const Color(0xFFD4AF37), width: 1.5),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.8),
            blurRadius: 20,
            spreadRadius: 6,
          ),
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Drag handle
          Container(
            width: 44,
            height: 4,
            margin: const EdgeInsets.only(bottom: 12),
            decoration: BoxDecoration(
              color: Colors.white24,
              borderRadius: BorderRadius.circular(2),
            ),
          ),

          // Header
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Row(
                children: [
                  Icon(Icons.radio, color: Color(0xFFFFD700), size: 24),
                  SizedBox(width: 10),
                  Text(
                    'MEKKE KUR\'AN RADYOSU',
                    style: TextStyle(
                      color: Color(0xFFFFD700),
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      letterSpacing: 0.8,
                    ),
                  ),
                ],
              ),
              IconButton(
                icon: const Icon(Icons.close, color: Colors.white70),
                onPressed: () {
                  if (widget.onClose != null) {
                    widget.onClose!();
                  } else {
                    Navigator.pop(context);
                  }
                },
              ),
            ],
          ),

          const SizedBox(height: 12),

          // Station Card
          ValueListenableBuilder<RadioStation>(
            valueListenable: _radioService.stationNotifier,
            builder: (context, station, _) {
              return Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: [Color(0xFF1B2333), Color(0xFF141924)],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(color: const Color(0xFFD4AF37).withOpacity(0.4)),
                ),
                child: Column(
                  children: [
                    // Live Badge & Station Icon
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                          decoration: BoxDecoration(
                            color: const Color(0xFFD4AF37).withOpacity(0.15),
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(color: const Color(0xFFD4AF37).withOpacity(0.3)),
                          ),
                          child: const Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(Icons.circle, color: Color(0xFF00FF88), size: 8),
                              SizedBox(width: 6),
                              Text(
                                '24/7 CANLI YAYIN',
                                style: TextStyle(
                                  color: Color(0xFF00FF88),
                                  fontSize: 10,
                                  fontWeight: FontWeight.bold,
                                  letterSpacing: 0.8,
                                ),
                              ),
                            ],
                          ),
                        ),
                        const Icon(Icons.mosque, color: Color(0xFFFFD700), size: 22),
                      ],
                    ),

                    const SizedBox(height: 14),

                    // Station Name
                    Text(
                      station.name,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 17,
                        fontWeight: FontWeight.bold,
                      ),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 4),
                    Text(
                      station.description,
                      style: const TextStyle(color: Colors.white60, fontSize: 12),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 6),
                    ValueListenableBuilder<String>(
                      valueListenable: _radioService.statusNotifier,
                      builder: (context, status, _) {
                        return Container(
                          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 2),
                          decoration: BoxDecoration(
                            color: Colors.black26,
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: Text(
                            status,
                            style: TextStyle(
                              color: status.contains('Yayında')
                                  ? const Color(0xFF00FF88)
                                  : const Color(0xFFFFD700),
                              fontSize: 11,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        );
                      },
                    ),

                    const SizedBox(height: 18),

                    // Visualizer Waves
                    ValueListenableBuilder<bool>(
                      valueListenable: _radioService.isPlayingNotifier,
                      builder: (context, isPlaying, _) {
                        return SizedBox(
                          height: 36,
                          child: AnimatedBuilder(
                            animation: _waveController,
                            builder: (context, child) {
                              return Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: List.generate(18, (i) {
                                  final wave = isPlaying
                                      ? (0.25 + 0.75 * ((math.sin(_waveController.value * 2 * math.pi + i * 0.45) + 1) / 2))
                                      : 0.15;
                                  return Container(
                                    width: 4,
                                    height: 32 * wave,
                                    margin: const EdgeInsets.symmetric(horizontal: 2.5),
                                    decoration: BoxDecoration(
                                      color: isPlaying
                                          ? const Color(0xFFFFD700).withOpacity(0.85)
                                          : Colors.white24,
                                      borderRadius: BorderRadius.circular(2),
                                    ),
                                  );
                                }),
                              );
                            },
                          ),
                        );
                      },
                    ),

                    const SizedBox(height: 18),

                    // Big Play/Pause Button
                    ValueListenableBuilder<bool>(
                      valueListenable: _radioService.isBufferingNotifier,
                      builder: (context, isBuffering, _) {
                        return ValueListenableBuilder<bool>(
                          valueListenable: _radioService.isPlayingNotifier,
                          builder: (context, isPlaying, _) {
                            return ElevatedButton(
                              style: ElevatedButton.styleFrom(
                                backgroundColor: const Color(0xFFD4AF37),
                                foregroundColor: Colors.black,
                                shape: const CircleBorder(),
                                padding: const EdgeInsets.all(18),
                                elevation: 8,
                              ),
                              onPressed: () {
                                _radioService.togglePlayPause();
                              },
                              child: isBuffering
                                  ? const SizedBox(
                                      width: 32,
                                      height: 32,
                                      child: CircularProgressIndicator(
                                        color: Colors.black,
                                        strokeWidth: 3,
                                      ),
                                    )
                                  : Icon(
                                      isPlaying ? Icons.pause : Icons.play_arrow,
                                      size: 34,
                                    ),
                            );
                          },
                        );
                      },
                    ),
                  ],
                ),
              );
            },
          ),

          const SizedBox(height: 16),

          // Station Selector
          const Align(
            alignment: Alignment.centerLeft,
            child: Text(
              'KANAL SEÇİMİ',
              style: TextStyle(
                color: Color(0xFFFFD700),
                fontSize: 11,
                fontWeight: FontWeight.bold,
                letterSpacing: 1.0,
              ),
            ),
          ),
          const SizedBox(height: 6),

          Column(
            children: QuranRadioService.stations.map((st) {
              return ValueListenableBuilder<RadioStation>(
                valueListenable: _radioService.stationNotifier,
                builder: (context, current, _) {
                  final isCurrent = current.id == st.id;
                  return Container(
                    margin: const EdgeInsets.only(bottom: 6),
                    decoration: BoxDecoration(
                      color: isCurrent
                          ? const Color(0xFFD4AF37).withOpacity(0.15)
                          : Colors.white.withOpacity(0.04),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                        color: isCurrent ? const Color(0xFFD4AF37) : Colors.transparent,
                      ),
                    ),
                    child: ListTile(
                      contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 0),
                      dense: true,
                      leading: Icon(
                        isCurrent ? Icons.radio_button_checked : Icons.radio_button_unchecked,
                        color: isCurrent ? const Color(0xFFFFD700) : Colors.white38,
                        size: 20,
                      ),
                      title: Text(
                        st.name,
                        style: TextStyle(
                          color: isCurrent ? const Color(0xFFFFD700) : Colors.white,
                          fontWeight: isCurrent ? FontWeight.bold : FontWeight.normal,
                          fontSize: 13,
                        ),
                      ),
                      subtitle: Text(
                        st.description,
                        style: const TextStyle(color: Colors.white54, fontSize: 10),
                      ),
                      onTap: () {
                        _radioService.play(station: st);
                      },
                    ),
                  );
                },
              );
            }).toList(),
          ),

          const SizedBox(height: 10),

          // Volume Slider
          Row(
            children: [
              const Icon(Icons.volume_down, color: Colors.white54, size: 20),
              Expanded(
                child: SliderTheme(
                  data: SliderTheme.of(context).copyWith(
                    activeTrackColor: const Color(0xFFFFD700),
                    inactiveTrackColor: Colors.white24,
                    thumbColor: const Color(0xFFFFD700),
                    overlayColor: const Color(0xFFFFD700).withOpacity(0.2),
                    thumbShape: const RoundSliderThumbShape(enabledThumbRadius: 6),
                  ),
                  child: Slider(
                    value: _radioService.volume,
                    min: 0.0,
                    max: 1.0,
                    onChanged: (v) {
                      setState(() {
                        _radioService.setVolume(v);
                      });
                    },
                  ),
                ),
              ),
              const Icon(Icons.volume_up, color: Colors.white54, size: 20),
            ],
          ),
        ],
      ),
    );
  }
}
