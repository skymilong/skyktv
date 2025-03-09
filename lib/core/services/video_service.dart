import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:better_player/better_player.dart';
import '../../data/models/song.dart';
import '../constants/enum_types.dart';

class VideoService extends ChangeNotifier {
  static final VideoService _instance = VideoService._internal();
  factory VideoService() => _instance;

  BetterPlayerController? _controller;
  PlaybackStatus _status = PlaybackStatus.none;
  Duration _position = Duration.zero;
  Duration _duration = Duration.zero;
  double _volume = 1.0;
  String? _currentsongUrl;
  String? _nextsongUrl;
  BetterPlayerController? _preloadController;
  String? _error;

  VideoService._internal();

  /// 初始化视频播放器
  Future<void> initialize({
    required Song song,
    required BetterPlayerConfiguration configuration,
  }) async {
    try {
      _controller?.dispose();
      _error = null;

      // 创建数据源
      final BetterPlayerDataSource dataSource;
      if (song.isDownloaded && song.localPath != null) {
        dataSource = BetterPlayerDataSource(
          BetterPlayerDataSourceType.file,
          song.localPath!,
        );
      } else if (song.songUrl != null) {
        dataSource = BetterPlayerDataSource(
          BetterPlayerDataSourceType.network,
          song.songUrl!,
        );
      } else {
        throw Exception('No valid source for video');
      }

      // 创建新的控制器并设置数据源
      _controller = BetterPlayerController(
        configuration,
        betterPlayerDataSource: dataSource,
      );

      // 设置事件监听
      _controller!.addEventsListener(_onPlayerEvent);

      // 等待数据源设置完成
      await _controller!.setupDataSource(dataSource);
      
      notifyListeners();
    } catch (e) {
      _error = '视频初始化失败: $e';
      _status = PlaybackStatus.error;
      notifyListeners();
      rethrow;
    }
  }

  void _onPlayerEvent(BetterPlayerEvent event) {
    switch (event.betterPlayerEventType) {
      case BetterPlayerEventType.play:
        _status = PlaybackStatus.playing;
        break;
      case BetterPlayerEventType.pause:
        _status = PlaybackStatus.paused;
        break;
      case BetterPlayerEventType.finished:
        _status = PlaybackStatus.stopped;
        break;
      case BetterPlayerEventType.progress:
        _position = event.parameters?["progress"] ?? Duration.zero;
        _duration = event.parameters?["duration"] ?? Duration.zero;
        break;
      case BetterPlayerEventType.exception:
        _error = event.parameters?["error"] ?? "Unknown error";
        _status = PlaybackStatus.error;
        break;
      default:
        break;
    }
    notifyListeners();
  }

  /// 预加载下一个视频
  Future<void> preloadVideo(String? songUrl) async {
    if (songUrl == null || songUrl == _currentsongUrl || songUrl == _nextsongUrl) {
      return;
    }

    _nextsongUrl = songUrl;
    
    try {
      _preloadController?.dispose();
      
      final config = BetterPlayerConfiguration(
        autoPlay: false,
        handleLifecycle: false,
      );
      
      final dataSource = BetterPlayerDataSource(
        BetterPlayerDataSourceType.network,
        songUrl,
        videoFormat: _getVideoFormat(songUrl),
        cacheConfiguration: const BetterPlayerCacheConfiguration(
          useCache: true,
          maxCacheSize: 100 * 1024 * 1024,
          maxCacheFileSize: 10 * 1024 * 1024,
        ),
      );

      _preloadController = BetterPlayerController(config);
      await _preloadController!.setupDataSource(dataSource);
      // 预加载但不播放
      await _preloadController!.pause();
    } catch (e) {
      debugPrint('预加载视频失败: $e');
    }
  }

  /// 内部方法：预加载下一个视频
  Future<void> _preloadNextVideo() async {
    if (_nextsongUrl == null) return;
    
    try {
      _preloadController?.dispose();
      
      final config = BetterPlayerConfiguration(
        autoPlay: false,
        handleLifecycle: false,
      );
      
      final dataSource = BetterPlayerDataSource(
        BetterPlayerDataSourceType.network,
        _nextsongUrl!,
        videoFormat: _getVideoFormat(_nextsongUrl!),
        cacheConfiguration: const BetterPlayerCacheConfiguration(
          useCache: true,
          maxCacheSize: 100 * 1024 * 1024,
          maxCacheFileSize: 10 * 1024 * 1024,
        ),
      );

      _preloadController = BetterPlayerController(config);
      await _preloadController!.setupDataSource(dataSource);
      // 预加载但不播放
      await _preloadController!.pause();
    } catch (e) {
      debugPrint('预加载下一个视频失败: $e');
    }
  }

  BetterPlayerVideoFormat _getVideoFormat(String url) {
    final extension = url.split('.').last.toLowerCase();
    switch (extension) {
      case 'mp4':
        return BetterPlayerVideoFormat.other;  // 普通MP4
      case 'm3u8':
        return BetterPlayerVideoFormat.hls;    // HLS流
      case 'mkv':
        return BetterPlayerVideoFormat.other;  // MKV容器
      default:
        return BetterPlayerVideoFormat.other;
    }
  }

  Map<String, String>? _buildResolutions(String? quality) {
    if (quality == null) return null;

    final Map<String, String> resolutions = {};
    final baseUrl = _currentsongUrl?.replaceAll(RegExp(r'_\d+p'), '');
    
    if (baseUrl == null) return null;

    if (quality == '1080p') {
      resolutions.addAll({
        '1080p': baseUrl.replaceAll('.mp4', '_1080p.mp4'),
        '720p': baseUrl.replaceAll('.mp4', '_720p.mp4'),
        '480p': baseUrl.replaceAll('.mp4', '_480p.mp4'),
      });
    } else if (quality == '720p') {
      resolutions.addAll({
        '720p': baseUrl.replaceAll('.mp4', '_720p.mp4'),
        '480p': baseUrl.replaceAll('.mp4', '_480p.mp4'),
      });
    } else {
      resolutions['480p'] = baseUrl.replaceAll('.mp4', '_480p.mp4');
    }

    return resolutions;
  }

  Future<void> play() async {
    await _controller?.play();
  }

  Future<void> pause() async {
    await _controller?.pause();
  }

  Future<void> seekTo(Duration position) async {
    await _controller?.seekTo(position);
  }

  Future<void> setVolume(double volume) async {
    if (_controller == null) return;
    
    try {
      _volume = volume.clamp(0.0, 1.0);
      await _controller!.setVolume(_volume);
      notifyListeners();
    } catch (e) {
      _error = '设置音量失败: $e';
      notifyListeners();
    }
  }

  void enterFullScreen() async {
    _controller?.enterFullScreen();
  }

  void exitFullScreen() async {
    _controller?.exitFullScreen();
  }

  Future<void> retry() async {
    try {
      await _controller?.retryDataSource();
      _error = null;
      notifyListeners();
    } catch (e) {
      _error = '重试失败: $e';
      notifyListeners();
    }
  }

  bool get isInitialized => _controller?.isVideoInitialized() ?? false;
  bool get isPlaying => _status == PlaybackStatus.playing;
  PlaybackStatus get status => _status;
  Duration get position => _position;
  Duration get duration => _duration;
  double get volume => _volume;
  String? get error => _error;
  BetterPlayerController? get controller => _controller;

  @override
  void dispose() {
    _controller?.removeEventsListener(_onPlayerEvent);
    _controller?.dispose();
    _preloadController?.dispose();
    super.dispose();
  }

  /// 获取枚举的显示名称
  static String getEnumDisplayName(dynamic enumValue) {
    if (enumValue == null) return '';
    return enumValue.toString().split('.').last;
  }

  /// 获取枚举的本地化名称
  static String getLocalizedName(dynamic enumValue) {
    final name = getEnumDisplayName(enumValue);
    // 这里可以根据实际需求返回本地化的名称
    return name;
  }
} 