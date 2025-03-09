import 'dart:convert';
import 'package:flutter/foundation.dart';
import '../../../core/utils/pinyin_utils.dart';
import '../../models/song.dart';
import 'app_database.dart';
import 'song_dao.dart';

class FavoriteSongDao{


  /// 获取收藏歌曲数量
  static int getFavoriteSongCount() {
    try {
      return AppDatabase.favoritesBox.length;
    } catch (e) {
      debugPrint('Error getting favorite count: $e');
      return 0;
    }
  }

  /// 获取所有收藏歌曲
  static List<Song> getFavoriteSongs() {
    try {
      final favoriteIds = AppDatabase.favoritesBox.values.toList();
      return SongDao.getAllSongs()
          .where((song) => favoriteIds.contains(song.id))
          .toList();
    } catch (e) {
      debugPrint('Error getting favorite songs: $e');
      return [];
    }
  }

  /// 设置歌曲收藏状态
  static Future<void> setFavorite(String songId, bool isFavorite) async {
    try {
      if (isFavorite) {
        await AppDatabase.favoritesBox.put(songId, songId);
      } else {
        await AppDatabase.favoritesBox.delete(songId);
      }
      
      // 更新歌曲的收藏状态
      final song = SongDao.getSong(songId);
      if (song != null) {
        await SongDao.saveSong(song.copyWith(
          isFavorite: isFavorite,
          favoriteTime: isFavorite ? DateTime.now() : null,
        ));
      }
    } catch (e) {
      debugPrint('Error setting favorite: $e');
    }
  }

  /// 批量设置歌曲收藏状态
  static Future<void> setFavoriteBatch(List<String> songIds, bool isFavorite) async {
    try {
      if (isFavorite) {
        final Map<String, String> favorites = {
          for (var id in songIds) id: id
        };
        await AppDatabase.favoritesBox.putAll(favorites);
      } else {
        await AppDatabase.favoritesBox.deleteAll(songIds);
      }

      // 批量更新歌曲收藏状态
      final now = DateTime.now();
      for (var id in songIds) {
        final song = SongDao.getSong(id);
        if (song != null) {
          await SongDao.saveSong(song.copyWith(
            isFavorite: isFavorite,
            favoriteTime: isFavorite ? now : null,
          ));
        }
      }
    } catch (e) {
      debugPrint('Error setting favorite batch: $e');
    }
  }

  /// 检查歌曲是否已收藏
  static bool isFavorite(String songId) {
    try {
      return AppDatabase.favoritesBox.containsKey(songId);
    } catch (e) {
      debugPrint('Error checking favorite: $e');
      return false;
    }
  }

  /// 切换歌曲收藏状态
  static Future<bool> toggleFavorite(String songId) async {
    final newStatus = !isFavorite(songId);
    await setFavorite(songId, newStatus);
    return newStatus;
  }

  /// 获取最近收藏的歌曲
  static List<Song> getRecentFavorites({int limit = 10}) {
    try {
      final allSongs = SongDao.getAllSongs();
      return allSongs
          .where((song) => song.isFavorite)
          .toList()
          ..sort((a, b) => (b.favoriteTime ?? DateTime(0))
              .compareTo(a.favoriteTime ?? DateTime(0)))
          ..take(limit);
    } catch (e) {
      debugPrint('Error getting recent favorites: $e');
      return [];
    }
  }

  /// 清空所有收藏
  static Future<void> clearAllFavorites() async {
    try {
      await AppDatabase.favoritesBox.clear();
      
      // 更新所有歌曲的收藏状态
      final allSongs = SongDao.getAllSongs();
      for (var song in allSongs) {
        if (song.isFavorite) {
          await SongDao.saveSong(song.copyWith(
            isFavorite: false,
            favoriteTime: null,
          ));
        }
      }
    } catch (e) {
      debugPrint('Error clearing favorites: $e');
    }
  }

  /// 获取收藏歌曲ID列表
  static List<String> getFavoriteIds() {
    try {
      return AppDatabase.favoritesBox.values.toList();
    } catch (e) {
      debugPrint('Error getting favorite ids: $e');
      return [];
    }
  }

  /// 导入收藏列表
  static Future<void> importFavorites(List<String> songIds) async {
    try {
      await setFavoriteBatch(songIds, true);
    } catch (e) {
      debugPrint('Error importing favorites: $e');
    }
  }
} 