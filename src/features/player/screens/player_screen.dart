import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../core/services/player_service.dart';
import '../../../core/services/video_service.dart';
import '../../../data/models/song.dart';
import '../../../core/constants/enum_types.dart';
import '../widgets/player_controls.dart';
import '../widgets/audio_visualizer.dart';
import '../widgets/lyrics_display.dart';
import '../widgets/video_player_view.dart';

class PlayerScreen extends StatefulWidget {
  final String? initialSongId;

  const PlayerScreen({Key? key, this.initialSongId}) : super(key: key);

  @override
  _PlayerScreenState createState() => _PlayerScreenState();
}

class _PlayerScreenState extends State<PlayerScreen> with WidgetsBindingObserver {
  late final PlayerService _playerService;
  late final VideoService _videoService;
  bool _isFullScreen = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _playerService = context.read<PlayerService>();
    _videoService = context.read<VideoService>();
    _initializePlayer();
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    switch (state) {
      case AppLifecycleState.paused:
        _playerService.pause();
        break;
      case AppLifecycleState.resumed:
        // 可选：恢复播放
        break;
      default:
        break;
    }
  }

  Future<void> _initializePlayer() async {
    if (widget.initialSongId != null) {
      await _playerService.loadSong(widget.initialSongId!);
    }
  }

  void _onPlayPause() {
    if (_playerService.isPlaying) {
      _playerService.pause();
    } else {
      _playerService.play();
    }
  }

  void _onNext() {
    _playerService.next();
  }

  void _onPrevious() {
    _playerService.previous();
  }

  void _onSeek(double value) {
    final duration = _playerService.currentSong?.duration ?? Duration.zero;
    final position = duration * value;
    _playerService.seekTo(position);
  }

  void _onVolumeChanged(double value) {
    _playerService.setVolume(value);
  }

  void _toggleFullScreen() {
    setState(() {
      _isFullScreen = !_isFullScreen;
    });
    if (_isFullScreen) {
      _videoService.enterFullScreen();
    } else {
      _videoService.exitFullScreen();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<PlayerService>(
      builder: (context, playerService, child) {
        final song = playerService.currentSong;
        final isPlaying = playerService.isPlaying;
        final progress = playerService.progress;
        final volume = playerService.volume;

        return Scaffold(
          appBar: _isFullScreen 
            ? null 
            : AppBar(
                title: Text(song?.title ?? '未在播放'),
                actions: [
                  IconButton(
                    icon: const Icon(Icons.playlist_play),
                    onPressed: () {
                      // TODO: 显示播放列表
                    },
                  ),
                ],
              ),
          body: SafeArea(
            child: Column(
              children: [
                Expanded(
                  child: song?.type == MediaType.video || song?.type == MediaType.karaoke
                    ? VideoPlayerView(
                        onFullScreenToggle: _toggleFullScreen,
                        isFullScreen: _isFullScreen,
                      )
                    : Center(
                        child: AudioVisualizer(
                          isPlaying: isPlaying,
                        ),
                      ),
                ),
                if (!_isFullScreen) ...[
                  LyricsDisplay(
                    songId: song?.id,
                    position: playerService.position,
                  ),
                  PlayerControls(
                    isPlaying: isPlaying,
                    onPlayPause: _onPlayPause,
                    onNext: _onNext,
                    onPrevious: _onPrevious,
                    onVolumeChanged: _onVolumeChanged,
                    volume: volume,
                  ),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16.0),
                    child: Row(
                      children: [
                        Text(_formatDuration(playerService.position)),
                        Expanded(
                          child: Slider(
                            value: progress,
                            onChanged: _onSeek,
                          ),
                        ),
                        Text(_formatDuration(song?.duration ?? Duration.zero)),
                      ],
                    ),
                  ),
                  const SizedBox(height: 16),
                ],
              ],
            ),
          ),
        );
      },
    );
  }

  String _formatDuration(Duration duration) {
    String twoDigits(int n) => n.toString().padLeft(2, '0');
    final minutes = twoDigits(duration.inMinutes.remainder(60));
    final seconds = twoDigits(duration.inSeconds.remainder(60));
    return '$minutes:$seconds';
  }
}
