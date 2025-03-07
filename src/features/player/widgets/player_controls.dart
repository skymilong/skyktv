import 'package:flutter/material.dart';
import '../../../core/constants/enum_types.dart';

class PlayerControls extends StatelessWidget {
  final PlaybackStatus status;
  final PlayMode playMode;
  final Duration position;
  final Duration duration;
  final double volume;
  final VoidCallback? onPlayPause;
  final VoidCallback? onNext;
  final VoidCallback? onPrevious;
  final ValueChanged<Duration>? onSeek;
  final ValueChanged<double>? onVolumeChanged;
  final VoidCallback? onPlayModeChanged;

  const PlayerControls({
    Key? key,
    required this.status,
    required this.playMode,
    required this.position,
    required this.duration,
    required this.volume,
    this.onPlayPause,
    this.onNext,
    this.onPrevious,
    this.onSeek,
    this.onVolumeChanged,
    this.onPlayModeChanged,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        // 进度条
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: Row(
            children: [
              Text(_formatDuration(position)),
              Expanded(
                child: Slider(
                  value: position.inMilliseconds.toDouble(),
                  min: 0,
                  max: duration.inMilliseconds.toDouble(),
                  onChanged: (value) {
                    onSeek?.call(Duration(milliseconds: value.round()));
                  },
                ),
              ),
              Text(_formatDuration(duration)),
            ],
          ),
        ),
        // 控制按钮
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // 播放模式
            IconButton(
              icon: _getPlayModeIcon(),
              onPressed: onPlayModeChanged,
            ),
            // 上一首
            IconButton(
              icon: const Icon(Icons.skip_previous),
              onPressed: onPrevious,
            ),
            // 播放/暂停
            Container(
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: Theme.of(context).primaryColor,
              ),
              child: IconButton(
                icon: Icon(
                  status == PlaybackStatus.playing
                      ? Icons.pause
                      : Icons.play_arrow,
                  color: Colors.white,
                ),
                iconSize: 32,
                onPressed: onPlayPause,
              ),
            ),
            // 下一首
            IconButton(
              icon: const Icon(Icons.skip_next),
              onPressed: onNext,
            ),
            // 音量控制
            IconButton(
              icon: Icon(volume == 0
                  ? Icons.volume_off
                  : volume < 0.5
                      ? Icons.volume_down
                      : Icons.volume_up),
              onPressed: () {
                if (volume > 0) {
                  onVolumeChanged?.call(0);
                } else {
                  onVolumeChanged?.call(1);
                }
              },
            ),
          ],
        ),
        // 音量滑块
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: Row(
            children: [
              const Icon(Icons.volume_down, size: 20),
              Expanded(
                child: Slider(
                  value: volume,
                  min: 0,
                  max: 1,
                  onChanged: onVolumeChanged,
                ),
              ),
              const Icon(Icons.volume_up, size: 20),
            ],
          ),
        ),
      ],
    );
  }

  Widget _getPlayModeIcon() {
    switch (playMode) {
      case PlayMode.sequence:
        return const Icon(Icons.repeat);
      case PlayMode.repeat:
        return const Icon(Icons.repeat_one);
      case PlayMode.repeatAll:
        return Stack(
          children: const [
            Icon(Icons.repeat),
            Positioned(
              right: 0,
              bottom: 0,
              child: Icon(Icons.all_inclusive, size: 12),
            ),
          ],
        );
      case PlayMode.shuffle:
        return const Icon(Icons.shuffle);
    }
  }

  String _formatDuration(Duration duration) {
    String twoDigits(int n) => n.toString().padLeft(2, '0');
    final minutes = twoDigits(duration.inMinutes.remainder(60));
    final seconds = twoDigits(duration.inSeconds.remainder(60));
    return '$minutes:$seconds';
  }
}
