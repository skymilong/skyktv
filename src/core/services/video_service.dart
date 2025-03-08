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
  Future<void> initialize(Song song, {
    double aspectRatio = 16 / 9,
    bool autoPlay = true,
    bool looping = false,
    bool showControls = true,
  }) async {
    if (song.songUrl == null) {
      _error = '视频地址不存在';
      notifyListeners();
      return;
    }

    if (song.songUrl == _currentsongUrl && _controller != null) {
      // 如果是同一个视频且控制器存在，直接返回
      return;
    }

    try {
      // 释放旧的控制器
      _controller?.dispose();
      _error = null;

      final betterPlayerConfiguration = BetterPlayerConfiguration(
        aspectRatio: aspectRatio,
        fit: BoxFit.contain,
        autoPlay: autoPlay,
        looping: looping,
        controlsConfiguration: BetterPlayerControlsConfiguration(
          enableFullscreen: true,
          enablePlayPause: showControls,
          enableProgressBar: showControls,
          enableProgressText: showControls,
          enableAudioTracks: false,
          enableSubtitles: false,
          enableQualities: true,
          enablePip: false,
          enablePlaybackSpeed: false,
          enableSkips: false,
          enableRetry: true,
          showControlsOnInitialize: showControls,
          playerTheme: BetterPlayerTheme.material,
          enableOverflowMenu: false,
          loadingWidget: const Center(
            child: CircularProgressIndicator(),
          ),
        ),
        deviceOrientationsAfterFullScreen: [
          DeviceOrientation.portraitUp,
        ],
        deviceOrientationsOnFullScreen: [
          DeviceOrientation.landscapeLeft,
          DeviceOrientation.landscapeRight,
        ],
        handleLifecycle: true,  // 自动处理应用生命周期
      );

      final dataSource = BetterPlayerDataSource(
        BetterPlayerDataSourceType.network,
        song.songUrl!,
        videoFormat: _getVideoFormat(song.songUrl!),
        cacheConfiguration: const BetterPlayerCacheConfiguration(
          useCache: true,
          maxCacheSize: 100 * 1024 * 1024, // 100MB
          maxCacheFileSize: 10 * 1024 * 1024, // 10MB per file
        ),
        resolutions: _buildResolutions(song.quality),
        notificationConfiguration: const BetterPlayerNotificationConfiguration(
          showNotification: true,
          title: "当前播放",
          author: "KTV",
        ),
      );

      _controller = BetterPlayerController(betterPlayerConfiguration);
      await _controller!.setupDataSource(dataSource);
      _currentsongUrl = song.songUrl;

      // 监听播放状态
      _controller!.addEventsListener((event) {
        switch (event.betterPlayerEventType) {
          case BetterPlayerEventType.initialized:
            _status = PlaybackStatus.paused;
            _duration = _controller!.videoPlayerController?.value.duration ?? Duration.zero;
            break;
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
            if (event.parameters?['progress'] != null) {
              _position = event.parameters!['progress'] as Duration;
            }
            break;
          case BetterPlayerEventType.exception:
            _status = PlaybackStatus.error;
            _error = event.parameters?['error'] ?? '视频播放出错';
            break;
          default:
            break;
        }
        notifyListeners();
      });

      // 预加载下一个视频
      _preloadNextVideo();
    } catch (e) {
      _error = '视频初始化失败: $e';
      _status = PlaybackStatus.error;
      notifyListeners();
    }
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
    if (_controller == null) return;
    
    try {
      await _controller!.play();
    } catch (e) {
      _error = '播放失败: $e';
      _status = PlaybackStatus.error;
      notifyListeners();
    }
  }

  Future<void> pause() async {
    if (_controller == null) return;
    
    try {
      await _controller!.pause();
    } catch (e) {
      _error = '暂停失败: $e';
      notifyListeners();
    }
  }

  Future<void> seekTo(Duration position) async {
    if (_controller == null) return;
    
    try {
      await _controller!.seekTo(position);
    } catch (e) {
      _error = '跳转失败: $e';
      notifyListeners();
    }
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

  Future<void> enterFullScreen() async {
    if (_controller == null) return;
    
    try {
      _controller!.enterFullScreen();
    } catch (e) {
      _error = '进入全屏失败: $e';
      notifyListeners();
    }
  }

  Future<void> exitFullScreen() async {
    if (_controller == null) return;
    
    try {
      _controller!.exitFullScreen();
    } catch (e) {
      _error = '退出全屏失败: $e';
      notifyListeners();
    }
  }

  Future<void> retry() async {
    if (_controller == null) return;
    
    try {
      _error = null;
      await _controller!.retryDataSource();
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
    try {
      _controller?.dispose();
      _preloadController?.dispose();
    } catch (e) {
      debugPrint('Dispose error: $e');
    } finally {
      super.dispose();
    }
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