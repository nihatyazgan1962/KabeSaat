import 'package:flutter/material.dart';
import '../models/prayer_times_model.dart';
import '../services/audio_service.dart';

class IsmailCosarPlayerSheet extends StatefulWidget {
  final PrayerTime? selectedPrayer;
  final VoidCallback onClose;

  const IsmailCosarPlayerSheet({
    super.key,
    this.selectedPrayer,
    required this.onClose,
  });

  @override
  State<IsmailCosarPlayerSheet> createState() => _IsmailCosarPlayerSheetState();
}

class _IsmailCosarPlayerSheetState extends State<IsmailCosarPlayerSheet> {
  final AudioService _audioService = AudioService();
  bool _autoEzanAlarm = true;
  String _selectedNotificationTone = 'tekbir'; // 'tekbir' or 'ezan'

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 18),
      decoration: BoxDecoration(
        color: const Color(0xFF0F1218).withOpacity(0.98),
        borderRadius: const BorderRadius.vertical(top: Radius.circular(28)),
        border: Border.all(color: const Color(0xFFD4AF37), width: 1.5),
      ),
      child: SingleChildScrollView(
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
                    Icon(Icons.mic_external_on, color: Color(0xFFFFD700), size: 24),
                    SizedBox(width: 8),
                    Text(
                      'EZAN & TEKBİR SESLERİ',
                      style: TextStyle(
                        color: Color(0xFFFFD700),
                        fontSize: 17,
                        fontWeight: FontWeight.bold,
                        letterSpacing: 0.8,
                      ),
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

            // Portrait Card of Ismail Cosar
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [Color(0xFF261D0C), Color(0xFF14120E)],
                ),
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: const Color(0xFFD4AF37).withOpacity(0.4)),
              ),
              child: Row(
                children: [
                  Container(
                    width: 52,
                    height: 52,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      border: Border.all(color: const Color(0xFFFFD700), width: 2),
                      color: const Color(0xFF2E2413),
                    ),
                    child: const Center(
                      child: Icon(Icons.person, color: Color(0xFFFFD700), size: 32),
                    ),
                  ),
                  const SizedBox(width: 12),
                  const Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Merhum Hacı Hafız İsmail Coşar',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 13,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        SizedBox(height: 2),
                        Text(
                          'Ankara Maltepe Camii Baş İmam-Hatibi\n(1947 - 2020) • Ezan ve Selâ Bülbülü',
                          style: TextStyle(color: Colors.white70, fontSize: 11),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 14),

            // TRACK 1: İsmail Coşar Ezanı
            ValueListenableBuilder<AudioTrackType>(
              valueListenable: _audioService.trackNotifier,
              builder: (context, track, _) {
                final isEzanActive = track == AudioTrackType.ismailCosarEzan;

                return Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: isEzanActive
                        ? const Color(0xFFD4AF37).withOpacity(0.18)
                        : Colors.white.withOpacity(0.04),
                    borderRadius: BorderRadius.circular(14),
                    border: Border.all(
                      color: isEzanActive ? const Color(0xFFFFD700) : Colors.white12,
                      width: isEzanActive ? 1.5 : 1.0,
                    ),
                  ),
                  child: Row(
                    children: [
                      const Icon(Icons.mosque, color: Color(0xFFFFD700), size: 22),
                      const SizedBox(width: 10),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text(
                              'İsmail Coşar - Makamlı Ezan-ı Şerif',
                              style: TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.bold,
                                fontSize: 13,
                              ),
                            ),
                            Text(
                              widget.selectedPrayer != null
                                  ? '${widget.selectedPrayer!.turkishName} Vakti (${widget.selectedPrayer!.makam})'
                                  : 'Segâh, Hicaz, Rast & Saba Makamları',
                              style: const TextStyle(color: Color(0xFFE2C974), fontSize: 11),
                            ),
                          ],
                        ),
                      ),
                      ElevatedButton.icon(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFFD4AF37),
                          foregroundColor: Colors.black87,
                          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                          minimumSize: Size.zero,
                          tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                        ),
                        icon: Icon(
                          (isEzanActive && _audioService.isPlaying)
                              ? Icons.pause
                              : Icons.play_arrow,
                          size: 16,
                        ),
                        label: Text(
                          (isEzanActive && _audioService.isPlaying) ? 'Duraklat' : 'Dinle',
                          style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 11),
                        ),
                        onPressed: () {
                          if (isEzanActive && _audioService.isPlaying) {
                            _audioService.togglePlayPause();
                          } else {
                            _audioService.playIsmailCosarEzan();
                          }
                        },
                      ),
                    ],
                  ),
                );
              },
            ),

            const SizedBox(height: 10),

            // TRACK 2: "Allahu Ekber..." Tekbir Bildirim Sesi
            ValueListenableBuilder<AudioTrackType>(
              valueListenable: _audioService.trackNotifier,
              builder: (context, track, _) {
                final isTekbirActive = track == AudioTrackType.tekbirBildirim;

                return Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: isTekbirActive
                        ? const Color(0xFF00AA55).withOpacity(0.18)
                        : Colors.white.withOpacity(0.04),
                    borderRadius: BorderRadius.circular(14),
                    border: Border.all(
                      color: isTekbirActive ? const Color(0xFF00FF77) : Colors.white12,
                      width: isTekbirActive ? 1.5 : 1.0,
                    ),
                  ),
                  child: Row(
                    children: [
                      const Icon(Icons.notifications_active, color: Color(0xFF00FF77), size: 22),
                      const SizedBox(width: 10),
                      const Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Bildirim Sesi: Teşrik Tekbiri',
                              style: TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.bold,
                                fontSize: 13,
                              ),
                            ),
                            Text(
                              '"Allâhu ekber, Allâhu ekber, lâ ilâhe illallâhu vallâhu ekber..."',
                              style: TextStyle(
                                color: Color(0xFF81C784),
                                fontSize: 10.5,
                                fontStyle: FontStyle.italic,
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ],
                        ),
                      ),
                      ElevatedButton.icon(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFF00AA55),
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                          minimumSize: Size.zero,
                          tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                        ),
                        icon: Icon(
                          (isTekbirActive && _audioService.isPlaying)
                              ? Icons.pause
                              : Icons.play_arrow,
                          size: 16,
                        ),
                        label: Text(
                          (isTekbirActive && _audioService.isPlaying) ? 'Duraklat' : 'Dinle',
                          style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 11),
                        ),
                        onPressed: () {
                          if (isTekbirActive && _audioService.isPlaying) {
                            _audioService.togglePlayPause();
                          } else {
                            _audioService.playTekbirBildirim();
                          }
                        },
                      ),
                    ],
                  ),
                );
              },
            ),

            const SizedBox(height: 12),

            // Progress bar
            ValueListenableBuilder<Duration>(
              valueListenable: _audioService.positionNotifier,
              builder: (context, position, _) {
                final duration = _audioService.durationNotifier.value;
                final maxSec = duration.inSeconds > 0 ? duration.inSeconds.toDouble() : 1.0;
                final currentSec = position.inSeconds.toDouble().clamp(0.0, maxSec);

                return Column(
                  children: [
                    SliderTheme(
                      data: SliderTheme.of(context).copyWith(
                        thumbColor: const Color(0xFFFFD700),
                        activeTrackColor: const Color(0xFFD4AF37),
                        inactiveTrackColor: Colors.white24,
                        thumbShape: const RoundSliderThumbShape(enabledThumbRadius: 5),
                      ),
                      child: Slider(
                        value: currentSec,
                        min: 0.0,
                        max: maxSec,
                        onChanged: (val) {
                          _audioService.seek(Duration(seconds: val.toInt()));
                        },
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 14),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(_formatDuration(position),
                              style: const TextStyle(color: Colors.white54, fontSize: 11)),
                          Text(_formatDuration(duration),
                              style: const TextStyle(color: Colors.white54, fontSize: 11)),
                        ],
                      ),
                    ),
                  ],
                );
              },
            ),

            const SizedBox(height: 10),

            // Stop button
            IconButton(
              tooltip: 'Durdur',
              icon: const Icon(Icons.stop_circle_outlined, color: Colors.white70, size: 36),
              onPressed: () => _audioService.stop(),
            ),

            const SizedBox(height: 12),

            // Notification Tone Selection Setting
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.04),
                borderRadius: BorderRadius.circular(14),
                border: Border.all(color: Colors.white12),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text(
                        'Vakit Giriş Bildirim Sesi',
                        style: TextStyle(
                          color: Color(0xFFFFD700),
                          fontSize: 13,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Switch(
                        value: _autoEzanAlarm,
                        activeColor: const Color(0xFFFFD700),
                        onChanged: (val) {
                          setState(() {
                            _autoEzanAlarm = val;
                          });
                        },
                      ),
                    ],
                  ),
                  RadioListTile<String>(
                    dense: true,
                    contentPadding: EdgeInsets.zero,
                    activeColor: const Color(0xFFFFD700),
                    title: const Text(
                      'Tekbir Sesi (Allâhu Ekber Allâhu Ekber...)',
                      style: TextStyle(color: Colors.white, fontSize: 12),
                    ),
                    value: 'tekbir',
                    groupValue: _selectedNotificationTone,
                    onChanged: (v) {
                      setState(() {
                        _selectedNotificationTone = v!;
                      });
                    },
                  ),
                  RadioListTile<String>(
                    dense: true,
                    contentPadding: EdgeInsets.zero,
                    activeColor: const Color(0xFFFFD700),
                    title: const Text(
                      'İsmail Coşar Ezanı (Tam Ezan)',
                      style: TextStyle(color: Colors.white, fontSize: 12),
                    ),
                    value: 'ezan',
                    groupValue: _selectedNotificationTone,
                    onChanged: (v) {
                      setState(() {
                        _selectedNotificationTone = v!;
                      });
                    },
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  String _formatDuration(Duration d) {
    final m = d.inMinutes.remainder(60).toString().padLeft(2, '0');
    final s = d.inSeconds.remainder(60).toString().padLeft(2, '0');
    return '$m:$s';
  }
}
