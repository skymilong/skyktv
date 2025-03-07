import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../core/constants/enum_types.dart';
import '../../../core/services/player_service.dart';
import '../../../core/services/song_service.dart';
import '../../../core/services/playlist_service.dart';
import '../../../core/services/lyrics_service.dart';
import '../models/lyric.dart';
import 'lyrics_view.dart';
import 'player_controls.dart';
import 'video_player_view.dart';

class MusicPlayer extends StatefulWidget {
  final String? initialSongId;

  const MusicPlayer({
    Key? key,
    this.initialSongId,
  }) : super(key: key);

  @override
  State<MusicPlayer> createState() => _MusicPlayerState();
}

class _MusicPlayerState extends State<MusicPlayer> {
  Lyrics? _lyrics;
  final _lyricsService = LyricsService();
  StreamSubscription<Duration>? _positionSubscription;
  bool _showVideo = true;  // 控制是否显示视频

  @override
  void initState() {
    super.initState();
    _initPlayer();
  }

  void _initPlayer() async {
    if (widget.initialSongId != null) {
      final songService = context.read<SongService>();
      final playerService = context.read<PlayerService>();
      final song = songService.getSongById(widget.initialSongId!);
      
      if (song != null) {
        // 加载歌词
        _lyrics = await _lyricsService.loadLyrics(
          song.id,
          url: song.lyricsUrl,
        );
        
        if (_lyrics != null) {
          // 监听播放进度以更新歌词
          _positionSubscription = playerService.positionStream.listen((position) {
            if (mounted && _lyrics != null) {
              setState(() {
                _lyrics!.updateCurrentLine(position);
              });
            }
          });
        }
        
        // 设置是否显示视频
        setState(() {
          _showVideo = song.hasVideo && song.videoUrl != null;
        });
        
        // 如果有视频，播放视频，否则播放音频
        if (_showVideo && song.videoUrl != null) {
          // 视频播放由VideoPlayerView处理
        } else {
          await playerService.play(song.audioUrl ?? '');
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Consumer3<PlayerService, SongService, PlaylistService>(
      builder: (context, playerService, songService, playlistService, child) {
        final currentSongId = playlistService.getCurrentSongId();
        final currentSong = currentSongId != null 
            ? songService.getSongById(currentSongId)
            : null;

        if (currentSong == null) {
          return const Center(child: Text('没有正在播放的歌曲'));
        }

        return Column(
          children: [
            // 歌曲信息
            const SizedBox(height: 20),
            Text(
              currentSong.title,
              style: Theme.of(context).textTheme.headlineSmall,
            ),
            const SizedBox(height: 8),
            Text(
              currentSong.artist,
              style: Theme.of(context).textTheme.titleMedium,
            ),

            // 视频/歌词显示区域
            Expanded(
              child: _showVideo && currentSong.videoUrl != null
                  ? VideoPlayerView(
                      song: currentSong,
                      onPlayingChanged: (isPlaying) {
                        // 同步音频播放状态
                        if (isPlaying) {
                          playerService.resume();
                        } else {
                          playerService.pause();
                        }
                      },
                      onProgressChanged: (position) {
                        // 同步歌词显示
                        if (_lyrics != null) {
                          setState(() {
                            _lyrics!.updateCurrentLine(position);
                          });
                        }
                      },
                    )
                  : _lyrics != null
                      ? LyricsView(
                          lyrics: _lyrics!,
                          highlightColor: Theme.of(context).primaryColor,
                        )
                      : const Center(
                          child: Text('暂无歌词'),
                        ),
            ),

            // 切换视频/歌词按钮
            if (currentSong.hasVideo && currentSong.videoUrl != null)
              TextButton.icon(
                icon: Icon(_showVideo ? Icons.lyrics : Icons.video_library),
                label: Text(_showVideo ? '显示歌词' : '显示视频'),
                onPressed: () {
                  setState(() {
                    _showVideo = !_showVideo;
                  });
                },
              ),

            // 播放控制
            PlayerControls(
              status: playerService.status,
              playMode: playerService.playMode,
              position: playerService.position,
              duration: playerService.duration,
              volume: playerService.volume,
              onPlayPause: () {
                if (playerService.isPlaying) {
                  playerService.pause();
                } else {
                  playerService.resume();
                }
              },
              onNext: () async {
                final nextSongId = playlistService.getNextSongId();
                if (nextSongId != null) {
                  final nextSong = songService.getSongById(nextSongId);
                  if (nextSong != null) {
                    // 加载下一首歌的歌词
                    _lyrics = await _lyricsService.loadLyrics(
                      nextSong.id,
                      url: nextSong.lyricsUrl,
                    );
                    
                    // 设置是否显示视频
                    setState(() {
                      _showVideo = nextSong.hasVideo && nextSong.videoUrl != null;
                    });
                    
                    // 如果有视频，播放视频，否则播放音频
                    if (_showVideo && nextSong.videoUrl != null) {
                      // 视频播放由VideoPlayerView处理
                    } else {
                      await playerService.play(nextSong.audioUrl ?? '');
                    }
                    
                    await playlistService.setCurrentIndex(
                      playlistService.currentIndex + 1,
                    );
                  }
                }
              },
              onPrevious: () async {
                final previousSongId = playlistService.getPreviousSongId();
                if (previousSongId != null) {
                  final previousSong = songService.getSongById(previousSongId);
                  if (previousSong != null) {
                    // 加载上一首歌的歌词
                    _lyrics = await _lyricsService.loadLyrics(
                      previousSong.id,
                      url: previousSong.lyricsUrl,
                    );
                    
                    // 设置是否显示视频
                    setState(() {
                      _showVideo = previousSong.hasVideo && previousSong.videoUrl != null;
                    });
                    
                    // 如果有视频，播放视频，否则播放音频
                    if (_showVideo && previousSong.videoUrl != null) {
                      // 视频播放由VideoPlayerView处理
                    } else {
                      await playerService.play(previousSong.audioUrl ?? '');
                    }
                    
                    await playlistService.setCurrentIndex(
                      playlistService.currentIndex - 1,
                    );
                  }
                }
              },
              onSeek: (position) {
                playerService.seek(position);
                if (_lyrics != null) {
                  setState(() {
                    _lyrics!.updateCurrentLine(position);
                  });
                }
              },
              onVolumeChanged: (volume) {
                playerService.setVolume(volume);
              },
              onPlayModeChanged: () {
                final currentMode = playerService.playMode;
                final nextMode = PlayMode.values[
                  (currentMode.index + 1) % PlayMode.values.length
                ];
                playerService.setPlayMode(nextMode);
              },
            ),
            const SizedBox(height: 20),
          ],
        );
      },
    );
  }

  @override
  void dispose() {
    _positionSubscription?.cancel();
    super.dispose();
  }
} 