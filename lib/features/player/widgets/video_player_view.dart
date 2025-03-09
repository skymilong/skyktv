import 'package:flutter/material.dart';
import 'package:better_player/better_player.dart';
import 'package:provider/provider.dart';
import 'package:wakelock_plus/wakelock_plus.dart';
import '../../../data/models/song.dart';
import '../../../core/services/video_service.dart';
import '../../../core/constants/enum_types.dart';

class VideoPlayerView extends StatefulWidget {
  final Song song;
  final bool showControls;
  final bool autoPlay;
  final bool looping;
  final double aspectRatio;
  final void Function(bool)? onFullScreenToggle;
  final bool isFullScreen;
  final void Function(bool)? onPlayingChanged;
  final void Function(Duration)? onProgressChanged;

  const VideoPlayerView({
    Key? key,
    required this.song,
    this.showControls = true,
    this.autoPlay = true,
    this.looping = false,
    this.aspectRatio = 16 / 9,
    this.onFullScreenToggle,
    this.isFullScreen = false,
    this.onPlayingChanged,
    this.onProgressChanged,
  }) : super(key: key);

  @override
  State<VideoPlayerView> createState() => _VideoPlayerViewState();
}

class _VideoPlayerViewState extends State<VideoPlayerView> {
  late final VideoService _videoService;
  bool _isInitialized = false;

  @override
  void initState() {
    super.initState();
    _videoService = context.read<VideoService>();
    _initializePlayer();
  }

  void _initializePlayer() async {
    try {
      await WakelockPlus.enable();

      // 配置 BetterPlayerConfiguration
      final betterPlayerConfiguration = BetterPlayerConfiguration(
        aspectRatio: widget.aspectRatio,
        autoPlay: widget.autoPlay,
        looping: widget.looping,
        controlsConfiguration: BetterPlayerControlsConfiguration(
          enableFullscreen: false, // 禁用默认全屏按钮
          showControls: widget.showControls,
        ),
        fullScreenByDefault: widget.isFullScreen,
      );

      await _videoService.initialize(
        song: widget.song,
        configuration: betterPlayerConfiguration,
      );

      if (mounted) {
        setState(() {
          _isInitialized = true;
        });
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('视频初始化失败: $e')),
        );
      }
    }
  }

  void _onVideoStateChanged() {
    // 处理播放状态变化
    if (widget.onPlayingChanged != null) {
      widget.onPlayingChanged!(_videoService.isPlaying);
    }
    
    // 处理进度变化
    if (widget.onProgressChanged != null) {
      widget.onProgressChanged!(_videoService.position);
    }

    // 处理错误
    if (_videoService.error != null) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(_videoService.error!),
            action: SnackBarAction(
              label: '重试',
              onPressed: () {
                _videoService.retry();
              },
            ),
          ),
        );
      }
    }

    // 处理播放完成
    if (_videoService.status == PlaybackStatus.stopped && widget.looping) {
      _videoService.seekTo(Duration.zero);
      _videoService.play();
    }
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async {
        if (widget.isFullScreen) {
          widget.onFullScreenToggle?.call(false);
          return false;
        }
        return true;
      },
      child: Consumer<VideoService>(
        builder: (context, videoService, child) {
          if (!_isInitialized) {
            return const Center(child: CircularProgressIndicator());
          }

          if (videoService.error != null) {
            return _buildErrorWidget(videoService);
          }

          if (videoService.controller == null) {
            return const Center(child: Text('视频播放器未初始化'));
          }

          return AspectRatio(
            aspectRatio: widget.isFullScreen ? 16/9 : widget.aspectRatio,
            child: Stack(
              children: [
                BetterPlayer(controller: videoService.controller!),
                if (widget.showControls)
                  Positioned(
                    right: 8,
                    top: 8,
                    child: Material(
                      color: Colors.transparent,
                      child: IconButton(
                        icon: Icon(
                          widget.isFullScreen 
                              ? Icons.fullscreen_exit 
                              : Icons.fullscreen,
                          color: Colors.white,
                        ),
                        onPressed: () {
                          widget.onFullScreenToggle?.call(!widget.isFullScreen);
                          // 同步更新 BetterPlayer 的全屏状态
                          if (widget.isFullScreen) {
                            videoService.exitFullScreen();
                          } else {
                            videoService.enterFullScreen();
                          }
                        },
                      ),
                    ),
                  ),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildErrorWidget(VideoService videoService) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            videoService.error!,
            style: Theme.of(context).textTheme.titleMedium,
          ),
          const SizedBox(height: 16),
          ElevatedButton(
            onPressed: () => videoService.retry(),
            child: const Text('重试'),
          ),
        ],
      ),
    );
  }

  @override
  void dispose() {
    _videoService.removeListener(_onVideoStateChanged);
    WakelockPlus.disable();
    super.dispose();
  }
} 