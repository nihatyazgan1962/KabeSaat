import 'package:audioplayers/audioplayers.dart';
import 'package:flutter/foundation.dart';

enum AudioTrackType { none, ismailCosarEzan, tekbirBildirim }

class AudioService {
  static final AudioService _instance = AudioService._internal();
  factory AudioService() => _instance;
  AudioService._internal();

  final AudioPlayer _player = AudioPlayer();
  final AudioPlayer _effectPlayer = AudioPlayer();
  bool _isPlaying = false;
  Duration _duration = Duration.zero;
  Duration _position = Duration.zero;
  double _volume = 1.0;
  AudioTrackType _currentTrack = AudioTrackType.none;
  DateTime _lastQiblaSoundTime = DateTime.fromMillisecondsSinceEpoch(0);

  bool get isPlaying => _isPlaying;
  Duration get duration => _duration;
  Duration get position => _position;
  double get volume => _volume;
  AudioTrackType get currentTrack => _currentTrack;

  final ValueNotifier<bool> isPlayingNotifier = ValueNotifier<bool>(false);
  final ValueNotifier<Duration> positionNotifier = ValueNotifier<Duration>(Duration.zero);
  final ValueNotifier<Duration> durationNotifier = ValueNotifier<Duration>(Duration.zero);
  final ValueNotifier<AudioTrackType> trackNotifier =
      ValueNotifier<AudioTrackType>(AudioTrackType.none);

  void init() {
    _player.onPlayerStateChanged.listen((state) {
      _isPlaying = state == PlayerState.playing;
      isPlayingNotifier.value = _isPlaying;
      if (!_isPlaying && _position >= _duration && _duration > Duration.zero) {
        _currentTrack = AudioTrackType.none;
        trackNotifier.value = AudioTrackType.none;
      }
    });

    _player.onDurationChanged.listen((d) {
      _duration = d;
      durationNotifier.value = d;
    });

    _player.onPositionChanged.listen((p) {
      _position = p;
      positionNotifier.value = p;
    });
  }

  Future<void> playIsmailCosarEzan() async {
    try {
      await _player.stop();
      _currentTrack = AudioTrackType.ismailCosarEzan;
      trackNotifier.value = _currentTrack;
      await _player.play(AssetSource('audio/ismail_cosar_ezan.mp3'));
    } catch (e) {
      debugPrint('Audio playback error (Ismail Cosar): $e');
    }
  }

  Future<void> playTekbirBildirim() async {
    try {
      await _player.stop();
      _currentTrack = AudioTrackType.tekbirBildirim;
      trackNotifier.value = _currentTrack;
      await _player.play(AssetSource('audio/tekbir_bildirim.mp3'));
    } catch (e) {
      debugPrint('Audio playback error (Tekbir): $e');
    }
  }

  Future<void> playEzan() => playIsmailCosarEzan();
  Future<void> playTekbir() => playTekbirBildirim();

  Future<void> playQiblaLockFeedback() async {
    final now = DateTime.now();
    if (now.difference(_lastQiblaSoundTime).inSeconds < 4) return;
    _lastQiblaSoundTime = now;
    try {
      await _effectPlayer.stop();
      await _effectPlayer.setVolume(1.0);
      await _effectPlayer.play(AssetSource('audio/tekbir_bildirim.mp3'));
      Future.delayed(const Duration(milliseconds: 2800), () {
        _effectPlayer.stop();
      });
    } catch (e) {
      debugPrint('Qibla sound error: $e');
    }
  }

  Future<void> togglePlayPause() async {
    if (_isPlaying) {
      await _player.pause();
    } else {
      if (_position > Duration.zero && _position < _duration) {
        await _player.resume();
      } else {
        if (_currentTrack == AudioTrackType.tekbirBildirim) {
          await playTekbirBildirim();
        } else {
          await playIsmailCosarEzan();
        }
      }
    }
  }

  Future<void> stop() async {
    await _player.stop();
    _position = Duration.zero;
    positionNotifier.value = Duration.zero;
    _currentTrack = AudioTrackType.none;
    trackNotifier.value = AudioTrackType.none;
  }

  Future<void> seek(Duration position) async {
    await _player.seek(position);
  }

  Future<void> setVolume(double vol) async {
    _volume = vol.clamp(0.0, 1.0);
    await _player.setVolume(_volume);
  }

  void dispose() {
    _player.dispose();
  }
}
