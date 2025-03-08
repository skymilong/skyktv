import 'package:flutter/foundation.dart';
import '../../models/playlist.dart';
import '../../models/song.dart';
import 'app_database.dart';
import 'song_dao.dart';

/// 播放列表数据访问对象
/// 
/// 提供对播放列表数据的CRUD操作
class PlaylistDao {
  // 私有构造函数，防止实例化
  PlaylistDao._();
  
  /// 创建新的播放列表
  /// 
  /// [name] 播放列表名称
  /// [description] 播放列表描述
  /// 
  /// 返回创建的播放列表ID
  static Future<String> createPlaylist(String name, {String description = ''}) async {
    try {
      final id = DateTime.now().millisecondsSinceEpoch.toString();
      final playlist = Playlist(
        id: id,
        name: name,
        description: description,
        songIds: [],
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      );
      
      await AppDatabase.playlistsBox.put(id, playlist.toJson());
      return id;
    } catch (e) {
      debugPrint('Error creating playlist: $e');
      return '';
    }
  }

  static Future<String> createPlaylistFromOther(Playlist playlist) async {
    try {
      await AppDatabase.playlistsBox.put(playlist.id, playlist.toJson());
      return playlist.id;
    } catch (e) {
      debugPrint('Error creating playlist: $e');
      return '';
    }
  }
  
  /// 获取播放列表
  /// 
  /// [id] 播放列表ID
  /// 
  /// 返回播放列表对象，如果不存在则返回null
  static Playlist? getPlaylist(String id) {
    try {
      final json = AppDatabase.playlistsBox.get(id);
      if (json == null) return null;
      return Playlist.fromJson(Map<String, dynamic>.from(json));
    } catch (e) {
      debugPrint('Error getting playlist: $e');
      return null;
    }
  }
  
  /// 获取所有播放列表
  /// 
  /// 返回所有播放列表的列表
  static List<Playlist> getAllPlaylists() {
    try {
      return AppDatabase.playlistsBox.values
          .map((json) => Playlist.fromJson(Map<String, dynamic>.from(json)))
          .toList();
    } catch (e) {
      debugPrint('Error getting all playlists: $e');
      return [];
    }
  }
  
  /// 更新播放列表
  /// 
  /// [playlist] 要更新的播放列表
  /// 
  /// 返回是否更新成功
  static Future<bool> updatePlaylist(Playlist playlist) async {
    try {
      playlist.updatedAt = DateTime.now();
      await AppDatabase.playlistsBox.put(playlist.id, playlist.toJson());
      return true;
    } catch (e) {
      debugPrint('Error updating playlist: $e');
      return false;
    }
  }
  
  /// 删除播放列表
  /// 
  /// [id] 播放列表ID
  /// 
  /// 返回是否删除成功
  static Future<bool> deletePlaylist(String id) async {
    try {
      await AppDatabase.playlistsBox.delete(id);
      return true;
    } catch (e) {
      debugPrint('Error deleting playlist: $e');
      return false;
    }
  }
  
  /// 向播放列表添加歌曲
  /// 
  /// [playlistId] 播放列表ID
  /// [songId] 歌曲ID
  /// 
  /// 返回是否添加成功
  static Future<bool> addSongToPlaylist(String playlistId, String songId) async {
    try {
      final playlist = getPlaylist(playlistId);
      if (playlist == null) return false;
      
      // 检查歌曲是否已在播放列表中
      if (playlist.songIds.contains(songId)) {
        return true; // 歌曲已在播放列表中
      }
      
      playlist.songIds.add(songId);
      playlist.updatedAt = DateTime.now();
      
      await AppDatabase.playlistsBox.put(playlistId, playlist.toJson());
      return true;
    } catch (e) {
      debugPrint('Error adding song to playlist: $e');
      return false;
    }
  }
  
  /// 从播放列表移除歌曲
  /// 
  /// [playlistId] 播放列表ID
  /// [songId] 歌曲ID
  /// 
  /// 返回是否移除成功
  static Future<bool> removeSongFromPlaylist(String playlistId, String songId) async {
    try {
      final playlist = getPlaylist(playlistId);
      if (playlist == null) return false;
      
      playlist.songIds.remove(songId);
      playlist.updatedAt = DateTime.now();
      
      await AppDatabase.playlistsBox.put(playlistId, playlist.toJson());
      return true;
    } catch (e) {
      debugPrint('Error removing song from playlist: $e');
      return false;
    }
  }
  
  /// 获取播放列表中的歌曲
  /// 
  /// [playlistId] 播放列表ID
  /// 
  /// 返回播放列表中的歌曲列表
  static List<Song> getPlaylistSongs(String playlistId) {
    try {
      final playlist = getPlaylist(playlistId);
      if (playlist == null) return [];
      
      return playlist.songIds
          .map((id) => SongDao.getSong(id))
          .where((song) => song != null)
          .cast<Song>()
          .toList();
    } catch (e) {
      debugPrint('Error getting playlist songs: $e');
      return [];
    }
  }
  
  /// 重新排序播放列表中的歌曲
  /// 
  /// [playlistId] 播放列表ID
  /// [songIds] 排序后的歌曲ID列表
  /// 
  /// 返回是否重排成功
  static Future<bool> reorderPlaylistSongs(String playlistId, List<String> songIds) async {
    try {
      final playlist = getPlaylist(playlistId);
      if (playlist == null) return false;
      
      playlist.songIds = songIds;
      playlist.updatedAt = DateTime.now();
      
      await AppDatabase.playlistsBox.put(playlistId, playlist.toJson());
      return true;
    } catch (e) {
      debugPrint('Error reordering playlist songs: $e');
      return false;
    }
  }
  
  /// 清空播放列表
  /// 
  /// [playlistId] 播放列表ID
  /// 
  /// 返回是否清空成功
  static Future<bool> clearPlaylist(String playlistId) async {
    try {
      final playlist = getPlaylist(playlistId);
      if (playlist == null) return false;
      
      playlist.songIds = [];
      playlist.updatedAt = DateTime.now();
      
      await AppDatabase.playlistsBox.put(playlistId, playlist.toJson());
      return true;
    } catch (e) {
      debugPrint('Error clearing playlist: $e');
      return false;
    }
  }
  
  /// 获取收藏夹中的歌曲ID列表
  /// 
  /// 返回收藏夹中的歌曲ID列表
  static List<String> getFavorites() {
    try {
      return AppDatabase.favoritesBox.values.toList();
    } catch (e) {
      debugPrint('Error getting favorites: $e');
      return [];
    }
  }
  
  /// 获取收藏夹中的歌曲
  /// 
  /// 返回收藏夹中的歌曲列表
  static List<Song> getFavoriteSongs() {
    try {
      final favoriteIds = getFavorites();
      
      return favoriteIds
          .map((id) => SongDao.getSong(id))
          .where((song) => song != null)
          .cast<Song>()
          .toList();
    } catch (e) {
      debugPrint('Error getting favorite songs: $e');
      return [];
    }
  }
  
  /// 添加歌曲到收藏夹
  /// 
  /// [songId] 歌曲ID
  /// 
  /// 返回是否添加成功
  static Future<bool> addToFavorites(String songId) async {
    try {
      // 检查歌曲是否存在
      final song = SongDao.getSong(songId);
      if (song == null) return false;
      
      // 检查是否已在收藏夹中
      if (isFavorite(songId)) return true;
      
      await AppDatabase.favoritesBox.add(songId);
      return true;
    } catch (e) {
      debugPrint('Error adding to favorites: $e');
      return false;
    }
  }
  
  /// 从收藏夹中移除歌曲
  /// 
  /// [songId] 歌曲ID
  /// 
  /// 返回是否移除成功
  static Future<bool> removeFromFavorites(String songId) async {
    try {
      final favoriteIds = getFavorites();
      final index = favoriteIds.indexOf(songId);
      
      if (index == -1) return true; // 歌曲不在收藏夹中
      
      // 获取键
      final key = AppDatabase.favoritesBox.keyAt(index);
      await AppDatabase.favoritesBox.delete(key);
      
      return true;
    } catch (e) {
      debugPrint('Error removing from favorites: $e');
      return false;
    }
  }
  
  /// 检查歌曲是否在收藏夹中
  /// 
  /// [songId] 歌曲ID
  /// 
  /// 返回是否在收藏夹中
  static bool isFavorite(String songId) {
    return getFavorites().contains(songId);
  }
  
  /// 切换歌曲的收藏状态
  /// 
  /// [songId] 歌曲ID
  /// 
  /// 返回更新后的收藏状态
  static Future<bool> toggleFavorite(String songId) async {
    final isFav = isFavorite(songId);
    
    if (isFav) {
      await removeFromFavorites(songId);
      return false;
    } else {
      await addToFavorites(songId);
      return true;
    }
  }
  
  /// 清空收藏夹
  /// 
  /// 返回是否清空成功
  static Future<bool> clearFavorites() async {
    try {
      await AppDatabase.favoritesBox.clear();
      return true;
    } catch (e) {
      debugPrint('Error clearing favorites: $e');
      return false;
    }
  }
}
