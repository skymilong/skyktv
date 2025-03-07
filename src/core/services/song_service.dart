import 'package:flutter/foundation.dart';
import '../models/song.dart';
import 'storage_service.dart';
import 'download_service.dart';
import '../constants/app_constants.dart';

/// 歌曲管理服务
class SongService extends ChangeNotifier {
  // 单例实例
  static final SongService _instance = SongService._internal();
  factory SongService() => _instance;

  final StorageService _storage = StorageService();
  final DownloadService _download = DownloadService();

  // 歌曲列表
  List<Song> _songs = [];
  // 收藏歌曲
  List<String> _favorites = [];

  SongService._internal() {
    _loadSongs();
    _loadFavorites();
  }

  // 加载歌曲列表
  Future<void> _loadSongs() async {
    try {
      final songsJson = await _storage.getFromBox<List>(
        AppConstants.kSongsBoxName,
        'songs',
        [],
      );
      _songs = songsJson.map((json) => Song.fromJson(json)).toList();
      notifyListeners();
    } catch (e) {
      debugPrint('Error loading songs: $e');
    }
  }

  // 保存歌曲列表
  Future<void> _saveSongs() async {
    try {
      final songsJson = _songs.map((song) => song.toJson()).toList();
      await _storage.putInBox(
        AppConstants.kSongsBoxName,
        'songs',
        songsJson,
      );
    } catch (e) {
      debugPrint('Error saving songs: $e');
    }
  }

  // 加载收藏列表
  Future<void> _loadFavorites() async {
    try {
      _favorites = await _storage.getFromBox<List<String>>(
        AppConstants.kFavoritesBoxName,
        'favorites',
        [],
      );
      notifyListeners();
    } catch (e) {
      debugPrint('Error loading favorites: $e');
    }
  }

  // 保存收藏列表
  Future<void> _saveFavorites() async {
    try {
      await _storage.putInBox(
        AppConstants.kFavoritesBoxName,
        'favorites',
        _favorites,
      );
    } catch (e) {
      debugPrint('Error saving favorites: $e');
    }
  }

  // 添加歌曲
  Future<void> addSong(Song song) async {
    if (!_songs.any((s) => s.id == song.id)) {
      _songs.add(song);
      await _saveSongs();
      notifyListeners();
    }
  }

  // 删除歌曲
  Future<void> removeSong(String songId) async {
    _songs.removeWhere((song) => song.id == songId);
    await _saveSongs();
    // 如果歌曲在收藏列表中，也需要移除
    if (_favorites.contains(songId)) {
      await removeFavorite(songId);
    }
    // 删除下载的文件
    await _download.deleteSong(songId);
    notifyListeners();
  }

  // 添加到收藏
  Future<void> addFavorite(String songId) async {
    if (!_favorites.contains(songId)) {
      _favorites.add(songId);
      await _saveFavorites();
      notifyListeners();
    }
  }

  // 取消收藏
  Future<void> removeFavorite(String songId) async {
    _favorites.remove(songId);
    await _saveFavorites();
    notifyListeners();
  }

  // 获取所有歌曲
  List<Song> get songs => List.unmodifiable(_songs);

  // 获取收藏的歌曲
  List<Song> get favoriteSongs {
    return _songs.where((song) => _favorites.contains(song.id)).toList();
  }

  // 根据ID获取歌曲
  Song? getSongById(String id) {
    return _songs.firstWhere((song) => song.id == id);
  }

  // 搜索歌曲
  List<Song> searchSongs(String keyword) {
    final lowercaseKeyword = keyword.toLowerCase();
    return _songs.where((song) {
      return song.title.toLowerCase().contains(lowercaseKeyword) ||
          song.artist.toLowerCase().contains(lowercaseKeyword);
    }).toList();
  }

  // 检查歌曲是否已收藏
  bool isFavorite(String songId) {
    return _favorites.contains(songId);
  }

  // 获取歌曲数量
  int get songCount => _songs.length;

  // 获取收藏数量
  int get favoriteCount => _favorites.length;
} 