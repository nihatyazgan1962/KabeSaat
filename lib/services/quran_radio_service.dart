import 'package:audioplayers/audioplayers.dart';
import 'package:flutter/foundation.dart';

class RadioStation {
  final String id;
  final String name;
  final String description;
  final String streamUrl;

  const RadioStation({
    required this.id,
    required this.name,
    required this.description,
    required this.streamUrl,
  });
}

class QuranRadioService {
  static final QuranRadioService _instance = QuranRadioService._internal();
  factory QuranRadioService() => _instance;
  QuranRadioService._internal();

  final AudioPlayer _radioPlayer = AudioPlayer();

  static const List<RadioStation> stations = [
    RadioStation(
      id: 'makkah_zeno',
      name: 'Mekke Canlı Kur\'an Radyosu',
      description: 'Mekke-i Mükerreme 24/7 Kesintisiz Canlı Yayın (HD)',
      streamUrl: 'https://stream.zeno.fm/pyc8kax6f2zuv',
    ),
    RadioStation(
      id: 'makkah_radiojar',
      name: 'Mekke Kâbe Tilavet Radyosu',
      description: 'Mescid-i Haram İmamları 24 Saat Canlı Kur\'an',
      streamUrl: 'https://stream.radiojar.com/0tpy1h0kxtzuv',
    ),
    RadioStation(
      id: 'kabe_tilavet',
      name: 'Kâbe-i Muazzama Canlı Yayın',
      description: 'Mekke Canlı Hatim ve Tilavet',
      streamUrl: 'https://stream.zeno.fm/f3wvbbqmdg8uv',
    ),
    RadioStation(
      id: 'sunna_radio',
      name: 'Kahire Kur\'an-ı Kerim Radyosu',
      description: 'Dünyaca Ünlü Kariler 24 Saat Yayında',
      streamUrl: 'http://192.99.170.8:5550/stream',
    ),
    RadioStation(
      id: 'hatim_radio',
      name: '7/24 Kesintisiz Hatim Radyosu',
      description: 'Aşr-ı Şerifler ve Cüz Yayını',
      streamUrl: 'http://66.45.232.131:9994/;stream/1',
    ),
  ];

  RadioStation _currentStation = stations[0];
  bool _isPlaying = false;
  bool _isBuffering = false;
  String _statusMessage = 'Yayına hazır';
  double _volume = 1.0;

  RadioStation get currentStation => _currentStation;
  bool get isPlaying => _isPlaying;
  bool get isBuffering => _isBuffering;
  String get statusMessage => _statusMessage;
  double get volume => _volume;

  final ValueNotifier<bool> isPlayingNotifier = ValueNotifier<bool>(false);
  final ValueNotifier<bool> isBufferingNotifier = ValueNotifier<bool>(false);
  final ValueNotifier<String> statusNotifier = ValueNotifier<String>('Yayına hazır');
  final ValueNotifier<RadioStation> stationNotifier =
      ValueNotifier<RadioStation>(stations[0]);

  Future<void> init() async {
    try {
      await AudioPlayer.global.setAudioContext(
        AudioContext(
          android: const AudioContextAndroid(
            isSpeakerphoneOn: true,
            stayAwake: true,
            contentType: AndroidContentType.music,
            usageType: AndroidUsageType.media,
            audioFocus: AndroidAudioFocus.gain,
          ),
          iOS: AudioContextIOS(
            category: AVAudioSessionCategory.playback,
            options: const {
              AVAudioSessionOptions.mixWithOthers,
              AVAudioSessionOptions.duckOthers,
            },
          ),
        ),
      );

      await _radioPlayer.setPlayerMode(PlayerMode.mediaPlayer);
      await _radioPlayer.setReleaseMode(ReleaseMode.stop);

      _radioPlayer.onPlayerStateChanged.listen((state) {
        _isPlaying = (state == PlayerState.playing);
        if (_isPlaying) {
          _isBuffering = false;
          _statusMessage = 'Canlı Yayında';
          isBufferingNotifier.value = false;
          statusNotifier.value = _statusMessage;
        } else if (state == PlayerState.paused) {
          _statusMessage = 'Duraklatıldı';
          statusNotifier.value = _statusMessage;
        } else if (state == PlayerState.stopped) {
          _statusMessage = 'Durduruldu';
          statusNotifier.value = _statusMessage;
        }
        isPlayingNotifier.value = _isPlaying;
      });

      _radioPlayer.onLog.listen((log) {
        debugPrint('[Radio Log] $log');
      });
    } catch (e) {
      debugPrint('Radio init error: $e');
    }
  }

  Future<void> play({RadioStation? station}) async {
    if (station != null) {
      _currentStation = station;
      stationNotifier.value = _currentStation;
    }

    _isBuffering = true;
    _statusMessage = 'Bağlanıyor...';
    isBufferingNotifier.value = true;
    statusNotifier.value = _statusMessage;

    try {
      await _radioPlayer.stop();
      await _radioPlayer.setSource(UrlSource(_currentStation.streamUrl));
      await _radioPlayer.resume();
      _isPlaying = true;
      _isBuffering = false;
      _statusMessage = 'Canlı Yayında';
      isPlayingNotifier.value = true;
      isBufferingNotifier.value = false;
      statusNotifier.value = _statusMessage;
    } catch (e) {
      debugPrint('Radio play error on ${_currentStation.name}: $e');
      _statusMessage = 'Yedek kanala bağlanılıyor...';
      statusNotifier.value = _statusMessage;

      // Auto-fallback to next station if current fails
      await _fallbackToNextStation();
    }
  }

  Future<void> _fallbackToNextStation() async {
    final currentIndex = stations.indexOf(_currentStation);
    final nextIndex = (currentIndex + 1) % stations.length;
    _currentStation = stations[nextIndex];
    stationNotifier.value = _currentStation;

    try {
      await _radioPlayer.stop();
      await _radioPlayer.setSource(UrlSource(_currentStation.streamUrl));
      await _radioPlayer.resume();
      _isPlaying = true;
      _isBuffering = false;
      _statusMessage = 'Canlı Yayında';
      isPlayingNotifier.value = true;
      isBufferingNotifier.value = false;
      statusNotifier.value = _statusMessage;
    } catch (e2) {
      debugPrint('Fallback radio error: $e2');
      _isPlaying = false;
      _isBuffering = false;
      _statusMessage = 'Yayın başlatılamadı. Lütfen kanalı değiştirin.';
      isPlayingNotifier.value = false;
      isBufferingNotifier.value = false;
      statusNotifier.value = _statusMessage;
    }
  }

  Future<void> pause() async {
    try {
      await _radioPlayer.pause();
      _isPlaying = false;
      _statusMessage = 'Duraklatıldı';
      isPlayingNotifier.value = false;
      statusNotifier.value = _statusMessage;
    } catch (e) {
      debugPrint('Radio pause error: $e');
    }
  }

  Future<void> togglePlayPause() async {
    if (_isPlaying) {
      await pause();
    } else {
      await play();
    }
  }

  Future<void> stop() async {
    try {
      await _radioPlayer.stop();
      _isPlaying = false;
      _isBuffering = false;
      _statusMessage = 'Durduruldu';
      isPlayingNotifier.value = false;
      isBufferingNotifier.value = false;
      statusNotifier.value = _statusMessage;
    } catch (e) {
      debugPrint('Radio stop error: $e');
    }
  }

  Future<void> setVolume(double vol) async {
    _volume = vol.clamp(0.0, 1.0);
    await _radioPlayer.setVolume(_volume);
  }

  void dispose() {
    _radioPlayer.dispose();
  }
}
