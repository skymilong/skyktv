import 'package:just_audio/just_audio.dart';
import 'package:flutter/foundation.dart';
import '../../data/local/database/song_dao.dart';
import '../../data/models/song.dart';
import '../../features/player/models/lyric.dart';
import '../constants/enum_types.dart';
import 'storage_service.dart';

import 'dart:math';
import 'dart:io';

/// 播放器服务
class PlayerService extends ChangeNotifier {
  // 单例实例
  static final PlayerService _instance = PlayerService._internal();
  factory PlayerService() => _instance;

  final AudioPlayer _player = AudioPlayer();
  
  // 使用 late 延迟初始化
  late final StorageService _storage;

  // 添加当前歌曲属性
  Song? _currentSong;
  List<Song> _playlist = [];
  int _currentIndex = -1;

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

  // 修改歌词相关属性
  Lyrics? _lyrics;
  
  // 修改 getter
  Lyrics? get lyrics => _lyrics;

  // Getters
  Song? get currentSong => _currentSong;
  double get progress => _duration.inMilliseconds > 0 
      ? _position.inMilliseconds / _duration.inMilliseconds 
      : 0.0;
  Duration get position => _position;

  PlayerService._internal() {
    _storage = StorageService();
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
      _updateLyrics();
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

  // 加载歌曲
  Future<void> loadSong(String songId) async {
    try {
      final song =SongDao.getSong(songId);
      if (song != null) {
        _currentSong = song;
        if (song.isDownloaded && song.localPath != null) {
          await _player.setFilePath(song.localPath!);
        } else {
          await _player.setUrl(song.songUrl!);
        }
        notifyListeners();
      }
    } catch (e) {
      debugPrint('Error loading song: $e');
      _status = PlaybackStatus.error;
      notifyListeners();
    }
  }

  // 播放
  Future<void> play() async {
    if (_currentSong == null) return;
    await _player.play();
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
  Future<void> seekTo(Duration position) async {
    await _player.seek(position);
  }

  // 下一首
  Future<void> next() async {
    if (_playlist.isEmpty) return;
    
    int nextIndex;
    switch (_playMode) {
      case PlayMode.sequence:
        nextIndex = (_currentIndex + 1) % _playlist.length;
        break;
      case PlayMode.repeatAll:
        nextIndex = (_currentIndex + 1) % _playlist.length;
        break;
      case PlayMode.shuffle:
        nextIndex = _getRandomIndex();
        break;
      case PlayMode.repeat:
        nextIndex = _currentIndex;
        break;
    }
    
    await _playAtIndex(nextIndex);
  }

  // 上一首
  Future<void> previous() async {
    if (_playlist.isEmpty) return;
    
    int prevIndex;
    switch (_playMode) {
      case PlayMode.sequence:
      case PlayMode.repeatAll:
        prevIndex = _currentIndex > 0 ? _currentIndex - 1 : _playlist.length - 1;
        break;
      case PlayMode.shuffle:
        prevIndex = _getRandomIndex();
        break;
      case PlayMode.repeat:
        prevIndex = _currentIndex;
        break;
    }
    
    await _playAtIndex(prevIndex);
  }

  // 播放指定索引的歌曲
  Future<void> _playAtIndex(int index) async {
    if (index < 0 || index >= _playlist.length) return;
    
    _currentIndex = index;
    await loadSong(_playlist[index].id);
    await play();
  }

  // 获取随机索引
  int _getRandomIndex() {
    if (_playlist.length <= 1) return 0;
    int newIndex;
    do {
      newIndex = Random().nextInt(_playlist.length);
    } while (newIndex == _currentIndex);
    return newIndex;
  }

  // 设置播放列表
  Future<void> setPlaylist(List<Song> songs, [int initialIndex = 0]) async {
    _playlist = songs;
    if (songs.isNotEmpty) {
      await _playAtIndex(initialIndex);
    }
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
  // 获取总时长
  Duration get duration => _duration;
  // 是否正在播放
  bool get isPlaying => _status == PlaybackStatus.playing;

  /// 加载歌词
  Future<List<LyricLine>> loadLyrics(String songId) async {
    try {
      final song = SongDao.getSong(songId);
      if (song == null) {
        _lyrics = null;
        notifyListeners();
        return [];
      }

      if (song.isDownloaded && song.localPath != null) {
        // 从本地加载歌词
        final lyricsFile = File('${song.localPath!}.lrc');
        if (await lyricsFile.exists()) {
          final content = await lyricsFile.readAsString();
          _lyrics = Lyrics.fromLrcContent(content);
          notifyListeners();
          return _lyrics?.lines ?? [];
        }
      }

      // 从网络加载歌词
      // TODO: 实现网络歌词加载
      _lyrics = null;
      notifyListeners();
      return [];
    } catch (e) {
      debugPrint('Error loading lyrics: $e');
      _lyrics = null;
      notifyListeners();
      return [];
    }
  }

  /// 更新当前歌词
  void _updateLyrics() {
    _lyrics?.updateCurrentLine(_position);
    notifyListeners();
  }

  @override
  void dispose() {
    _player.dispose();
    super.dispose();
  }
} 