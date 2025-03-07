import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:better_player/better_player.dart';
import '../constants/enum_types.dart';
import '../models/song.dart';

class VideoService extends ChangeNotifier {
  static final VideoService _instance = VideoService._internal();
  factory VideoService() => _instance;

  BetterPlayerController? _controller;
  PlaybackStatus _status = PlaybackStatus.none;
  Duration _position = Duration.zero;
  Duration _duration = Duration.zero;
  double _volume = 1.0;
  String? _currentVideoUrl;
  String? _nextVideoUrl;
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
    if (song.videoUrl == null) {
      _error = '视频地址不存在';
      notifyListeners();
      return;
    }

    if (song.videoUrl == _currentVideoUrl && _controller != null) {
      // 如果是同一个视频且控制器存在，直接返回
      return;
    }

    try {
      // 释放旧的控制器
      await _controller?.dispose();
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
          errorBuilder: (context, errorMessage) {
            return Center(
              child: Text(
                errorMessage,
                style: const TextStyle(color: Colors.white),
              ),
            );
          },
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
        song.videoUrl!,
        videoFormat: _getVideoFormat(song.videoUrl!),
        cacheConfiguration: const BetterPlayerCacheConfiguration(
          useCache: true,
          maxCacheSize: 100 * 1024 * 1024, // 100MB
          maxCacheFileSize: 10 * 1024 * 1024, // 10MB per file
        ),
        qualities: _buildQualities(song.quality),
        notificationConfiguration: const BetterPlayerNotificationConfiguration(
          showNotification: true,
          title: "当前播放",
          author: "KTV",
        ),
      );

      _controller = BetterPlayerController(betterPlayerConfiguration);
      await _controller!.setupDataSource(dataSource);
      _currentVideoUrl = song.videoUrl;

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
          case BetterPlayerEventType.error:
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
  Future<void> preloadVideo(String? videoUrl) async {
    if (videoUrl == null || videoUrl == _currentVideoUrl || videoUrl == _nextVideoUrl) {
      return;
    }

    _nextVideoUrl = videoUrl;
    
    try {
      await _preloadController?.dispose();
      
      final config = BetterPlayerConfiguration(
        autoPlay: false,
        handleLifecycle: false,
      );
      
      final dataSource = BetterPlayerDataSource(
        BetterPlayerDataSourceType.network,
        videoUrl,
        videoFormat: _getVideoFormat(videoUrl),
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

  List<BetterPlayerDataSourceQuality> _buildQualities(String? quality) {
    if (quality == null) return [];

    final qualities = <BetterPlayerDataSourceQuality>[];
    
    if (quality == '1080p') {
      qualities.addAll([
        BetterPlayerDataSourceQuality(1080, "1080p"),
        BetterPlayerDataSourceQuality(720, "720p"),
        BetterPlayerDataSourceQuality(480, "480p"),
      ]);
    } else if (quality == '720p') {
      qualities.addAll([
        BetterPlayerDataSourceQuality(720, "720p"),
        BetterPlayerDataSourceQuality(480, "480p"),
      ]);
    } else {
      qualities.add(BetterPlayerDataSourceQuality(480, "480p"));
    }

    return qualities;
  }

  Future<void> play() async {
    try {
      await _controller?.play();
    } catch (e) {
      _error = '播放失败: $e';
      _status = PlaybackStatus.error;
      notifyListeners();
    }
  }

  Future<void> pause() async {
    try {
      await _controller?.pause();
    } catch (e) {
      _error = '暂停失败: $e';
      notifyListeners();
    }
  }

  Future<void> seekTo(Duration position) async {
    try {
      await _controller?.seekTo(position);
    } catch (e) {
      _error = '跳转失败: $e';
      notifyListeners();
    }
  }

  Future<void> setVolume(double volume) async {
    try {
      _volume = volume.clamp(0.0, 1.0);
      await _controller?.setVolume(_volume);
      notifyListeners();
    } catch (e) {
      _error = '设置音量失败: $e';
      notifyListeners();
    }
  }

  Future<void> enterFullScreen() async {
    try {
      await _controller?.enterFullScreen();
    } catch (e) {
      _error = '进入全屏失败: $e';
      notifyListeners();
    }
  }

  Future<void> exitFullScreen() async {
    try {
      await _controller?.exitFullScreen();
    } catch (e) {
      _error = '退出全屏失败: $e';
      notifyListeners();
    }
  }

  Future<void> retry() async {
    try {
      _error = null;
      await _controller?.retry();
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
    _controller?.dispose();
    _preloadController?.dispose();
    super.dispose();
  }
} 