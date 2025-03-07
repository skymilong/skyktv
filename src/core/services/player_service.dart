import 'package:just_audio/just_audio.dart';
import 'package:flutter/foundation.dart';
import '../constants/enum_types.dart';
import 'storage_service.dart';

/// 播放器服务
class PlayerService extends ChangeNotifier {
  // 单例实例
  static final PlayerService _instance = PlayerService._internal();
  factory PlayerService() => _instance;

  final AudioPlayer _player = AudioPlayer();
  final StorageService _storage = StorageService();

  // 当前播放状态
  PlaybackStatus _status = PlaybackStatus.none;
  // 当前播放模式
  PlayMode _playMode = PlayMode.sequence;
  // 当前音量
  double _volume = 1.0;
  // 当前进度
  Duration _position = Duration.zero;
  // 总时长
  Duration _duration = Duration.zero;

  PlayerService._internal() {
    _initPlayer();
  }

  // 初始化播放器
  void _initPlayer() {
    // 加载保存的设置
    _loadSettings();

    // 监听播放状态
    _player.playerStateStream.listen((state) {
      switch (state.processingState) {
        case ProcessingState.idle:
          _status = PlaybackStatus.none;
          break;
        case ProcessingState.loading:
          _status = PlaybackStatus.loading;
          break;
        case ProcessingState.ready:
          _status = state.playing ? PlaybackStatus.playing : PlaybackStatus.paused;
          break;
        case ProcessingState.completed:
          _status = PlaybackStatus.stopped;
          break;
        default:
          _status = PlaybackStatus.error;
      }
      notifyListeners();
    });

    // 监听进度
    _player.positionStream.listen((position) {
      _position = position;
      notifyListeners();
    });

    // 监听总时长
    _player.durationStream.listen((duration) {
      _duration = duration ?? Duration.zero;
      notifyListeners();
    });
  }

  // 加载设置
  Future<void> _loadSettings() async {
    _volume = _storage.getDouble('player_volume', 1.0);
    _player.setVolume(_volume);

    final modeIndex = _storage.getInt('player_mode', 0);
    _playMode = PlayMode.values[modeIndex];
  }

  // 保存设置
  Future<void> _saveSettings() async {
    await _storage.setDouble('player_volume', _volume);
    await _storage.setInt('player_mode', _playMode.index);
  }

  // 播放音频
  Future<void> play(String url) async {
    try {
      await _player.setUrl(url);
      await _player.play();
    } catch (e) {
      debugPrint('Error playing audio: $e');
      _status = PlaybackStatus.error;
      notifyListeners();
    }
  }

  // 暂停
  Future<void> pause() async {
    await _player.pause();
  }

  // 继续播放
  Future<void> resume() async {
    await _player.play();
  }

  // 停止
  Future<void> stop() async {
    await _player.stop();
  }

  // 跳转到指定位置
  Future<void> seek(Duration position) async {
    await _player.seek(position);
  }

  // 设置音量
  Future<void> setVolume(double volume) async {
    _volume = volume.clamp(0.0, 1.0);
    await _player.setVolume(_volume);
    await _saveSettings();
    notifyListeners();
  }

  // 设置播放模式
  Future<void> setPlayMode(PlayMode mode) async {
    _playMode = mode;
    await _saveSettings();
    notifyListeners();
  }

  // 获取当前状态
  PlaybackStatus get status => _status;
  // 获取当前播放模式
  PlayMode get playMode => _playMode;
  // 获取当前音量
  double get volume => _volume;
  // 获取当前进度
  Duration get position => _position;
  // 获取总时长
  Duration get duration => _duration;
  // 是否正在播放
  bool get isPlaying => _status == PlaybackStatus.playing;

  @override
  void dispose() {
    _player.dispose();
    super.dispose();
  }
} 