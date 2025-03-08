import 'package:flutter/material.dart';
import 'package:better_player/better_player.dart';
import 'package:provider/provider.dart';
import 'package:wakelock/wakelock.dart';
import '../../../data/models/song.dart';
import '../../../core/services/video_service.dart';
import '../../../core/constants/enum_types.dart';

class VideoPlayerView extends StatefulWidget {
  final Song song;
  final bool showControls;
  final bool autoPlay;
  final bool looping;
  final double aspectRatio;
  final void Function(bool)? onPlayingChanged;
  final void Function(Duration)? onProgressChanged;

  const VideoPlayerView({
    Key? key,
    required this.song,
    this.showControls = true,
    this.autoPlay = true,
    this.looping = false,
    this.aspectRatio = 16 / 9,
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
      // 保持屏幕常亮
      await Wakelock.enable();

      await _videoService.initialize(
        widget.song,
        aspectRatio: widget.aspectRatio,
        autoPlay: widget.autoPlay,
        looping: widget.looping,
        showControls: widget.showControls,
      );

      // 监听播放状态变化
      _videoService.addListener(_onVideoStateChanged);

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
    return Consumer<VideoService>(
      builder: (context, videoService, child) {
        if (!_isInitialized) {
          return const Center(
            child: CircularProgressIndicator(),
          );
        }

        if (videoService.error != null) {
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

        if (videoService.controller == null) {
          return const Center(
            child: Text('视频播放器未初始化'),
          );
        }

        return AspectRatio(
          aspectRatio: widget.aspectRatio,
          child: BetterPlayer(
            controller: videoService.controller!,
          ),
        );
      },
    );
  }

  @override
  void dispose() {
    _videoService.removeListener(_onVideoStateChanged);
    Wakelock.disable();
    super.dispose();
  }
} 