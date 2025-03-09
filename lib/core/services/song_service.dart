import 'package:flutter/foundation.dart';
import '../../data/local/database/song_dao.dart';
import '../../data/models/song.dart';
import '../constants/enum_types.dart';
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
  bool _isLoading = false;
  String? _error;

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
      _songs = songsJson!.map((json) => Song.fromJson(json)).toList();
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
      _favorites = (await _storage.getFromBox<List<String>>(
        AppConstants.kFavoritesBoxName,
        'favorites',
        [],
      ))!;
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
  Future<void> removeSong(String songId , MediaType type) async {
    _songs.removeWhere((song) => song.id == songId);
    await _saveSongs();
    // 如果歌曲在收藏列表中，也需要移除
    if (_favorites.contains(songId)) {
      await removeFavorite(songId);
    }
    // 删除下载的文件
    await _download.deleteSong(songId, type);
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

  // Getters
  List<Song> get songs => _songs;
  bool get isLoading => _isLoading;
  String? get error => _error;

  // 获取所有歌曲
  Future<List<Song>> getAllSongs() async {
    try {
      _isLoading = true;
      notifyListeners();
      
      // 从数据库获取歌曲
      _songs = await SongDao.getAllSongs();
      
      _isLoading = false;
      _error = null;
      notifyListeners();
      return _songs;
    } catch (e) {
      _isLoading = false;
      _error = e.toString();
      notifyListeners();
      return [];
    }
  }

  // 根据ID获取歌曲 - 改为异步方法
  Future<Song?> getSongById(String id) async {
    try {
      // 如果歌曲列表为空，先加载所有歌曲
      if (_songs.isEmpty) {
        await getAllSongs();
      }
      
      return _songs.firstWhere((song) => song.id == id);
    } catch (e) {
      _error = "找不到ID为 $id 的歌曲";
      notifyListeners();
      return null;
    }
  }

  // 搜索歌曲
  Future<List<Song>> searchSongs(String query) async {
    if (query.isEmpty) return [];
    
    try {
      _isLoading = true;
      notifyListeners();
      
      // 如果歌曲列表为空，先加载所有歌曲
      if (_songs.isEmpty) {
        await getAllSongs();
      }
      
      // 执行搜索
      final results = _songs.where((song) {
        final title = song.title.toLowerCase();
        final artist = song.artist.toLowerCase();
        final album = song.album?.toLowerCase() ?? '';
        final searchQuery = query.toLowerCase();
        
        return title.contains(searchQuery) || 
               artist.contains(searchQuery) || 
               album.contains(searchQuery);
      }).toList();
      
      _isLoading = false;
      notifyListeners();
      return results;
    } catch (e) {
      _isLoading = false;
      _error = e.toString();
      notifyListeners();
      return [];
    }
  }

  // 获取收藏的歌曲
  List<Song> get favoriteSongs {
    return _songs.where((song) => _favorites.contains(song.id)).toList();
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