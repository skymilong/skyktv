import 'package:flutter/foundation.dart';
import '../models/song.dart';
import 'storage_service.dart';
import '../constants/app_constants.dart';

/// 播放列表管理服务
class PlaylistService extends ChangeNotifier {
  // 单例实例
  static final PlaylistService _instance = PlaylistService._internal();
  factory PlaylistService() => _instance;

  final StorageService _storage = StorageService();

  // 播放列表
  List<String> _playlist = [];
  // 当前播放索引
  int _currentIndex = -1;

  PlaylistService._internal() {
    _loadPlaylist();
  }

  // 加载播放列表
  Future<void> _loadPlaylist() async {
    try {
      _playlist = await _storage.getFromBox<List<String>>(
        AppConstants.kPlaylistsBoxName,
        'current_playlist',
        [],
      );
      _currentIndex = await _storage.getFromBox<int>(
        AppConstants.kPlaylistsBoxName,
        'current_index',
        -1,
      );
      notifyListeners();
    } catch (e) {
      debugPrint('Error loading playlist: $e');
    }
  }

  // 保存播放列表
  Future<void> _savePlaylist() async {
    try {
      await _storage.putInBox(
        AppConstants.kPlaylistsBoxName,
        'current_playlist',
        _playlist,
      );
      await _storage.putInBox(
        AppConstants.kPlaylistsBoxName,
        'current_index',
        _currentIndex,
      );
    } catch (e) {
      debugPrint('Error saving playlist: $e');
    }
  }

  // 添加歌曲到播放列表
  Future<void> addToPlaylist(String songId) async {
    if (!_playlist.contains(songId)) {
      _playlist.add(songId);
      await _savePlaylist();
      notifyListeners();
    }
  }

  // 从播放列表移除歌曲
  Future<void> removeFromPlaylist(String songId) async {
    final index = _playlist.indexOf(songId);
    if (index != -1) {
      _playlist.removeAt(index);
      if (_currentIndex >= index) {
        _currentIndex--;
      }
      await _savePlaylist();
      notifyListeners();
    }
  }

  // 清空播放列表
  Future<void> clearPlaylist() async {
    _playlist.clear();
    _currentIndex = -1;
    await _savePlaylist();
    notifyListeners();
  }

  // 设置当前播放索引
  Future<void> setCurrentIndex(int index) async {
    if (index >= -1 && index < _playlist.length) {
      _currentIndex = index;
      await _savePlaylist();
      notifyListeners();
    }
  }

  // 获取下一首歌曲ID
  String? getNextSongId() {
    if (_playlist.isEmpty) return null;
    if (_currentIndex >= _playlist.length - 1) return null;
    return _playlist[_currentIndex + 1];
  }

  // 获取上一首歌曲ID
  String? getPreviousSongId() {
    if (_playlist.isEmpty) return null;
    if (_currentIndex <= 0) return null;
    return _playlist[_currentIndex - 1];
  }

  // 获取当前播放的歌曲ID
  String? getCurrentSongId() {
    if (_currentIndex < 0 || _currentIndex >= _playlist.length) return null;
    return _playlist[_currentIndex];
  }

  // 移动歌曲位置
  Future<void> moveSong(int oldIndex, int newIndex) async {
    if (oldIndex < 0 || oldIndex >= _playlist.length) return;
    if (newIndex < 0 || newIndex >= _playlist.length) return;

    final songId = _playlist.removeAt(oldIndex);
    _playlist.insert(newIndex, songId);

    if (_currentIndex == oldIndex) {
      _currentIndex = newIndex;
    } else if (_currentIndex > oldIndex && _currentIndex <= newIndex) {
      _currentIndex--;
    } else if (_currentIndex < oldIndex && _currentIndex >= newIndex) {
      _currentIndex++;
    }

    await _savePlaylist();
    notifyListeners();
  }

  // 获取播放列表
  List<String> get playlist => List.unmodifiable(_playlist);

  // 获取当前播放索引
  int get currentIndex => _currentIndex;

  // 获取播放列表长度
  int get length => _playlist.length;

  // 检查播放列表是否为空
  bool get isEmpty => _playlist.isEmpty;

  // 检查歌曲是否在播放列表中
  bool contains(String songId) => _playlist.contains(songId);
} 