import 'dart:convert';
import 'package:flutter/foundation.dart';
import '../../../core/utils/pinyin_utils.dart';
import '../../models/song.dart';
import 'app_database.dart';

/// 歌曲数据访问对象
/// 
/// 提供对歌曲数据的CRUD操作
class SongDao {
  // 私有构造函数，防止实例化
  SongDao._();
  
  /// 保存单首歌曲
  /// 
  /// [song] 要保存的歌曲
  /// 
  /// 返回是否保存成功
  static Future<bool> saveSong(Song song) async {
    try {
      await AppDatabase.songsBox.put(song.id, song.toJson());
      return true;
    } catch (e) {
      debugPrint('Error saving song: $e');
      return false;
    }
  }
  
  /// 批量保存歌曲
  /// 
  /// [songs] 要保存的歌曲列表
  /// 
  /// 返回是否保存成功
  static Future<bool> saveSongs(List<Song> songs) async {
    try {
      final batch = <String, Map<String, dynamic>>{};
      for (var song in songs) {
        batch[song.id] = song.toJson();
      }
      await AppDatabase.songsBox.putAll(batch);
      return true;
    } catch (e) {
      debugPrint('Error saving songs: $e');
      return false;
    }
  }
  
  /// 根据ID获取歌曲
  /// 
  /// [id] 歌曲ID
  /// 
  /// 返回歌曲对象，如果不存在则返回null
  static Song? getSong(String id) {
    try {
      final json = AppDatabase.songsBox.get(id);
      if (json == null) return null;
      return Song.fromJson(Map<String, dynamic>.from(json));
    } catch (e) {
      debugPrint('Error getting song: $e');
      return null;
    }
  }
  
  /// 获取所有歌曲
  /// 
  /// 返回所有歌曲的列表
  static List<Song> getAllSongs() {
    try {
      return AppDatabase.songsBox.values
          .map((json) => Song.fromJson(Map<String, dynamic>.from(json)))
          .toList();
    } catch (e) {
      debugPrint('Error getting all songs: $e');
      return [];
    }
  }
  
  /// 获取歌曲总数
  /// 
  /// 返回歌曲总数
  static int getSongCount() {
    return AppDatabase.songsBox.length;
  }
  
  /// 更新歌曲下载状态
  /// 
  /// [id] 歌曲ID
  /// [isDownloaded] 是否已下载
  /// [localPath] 本地文件路径
  /// 
  /// 返回是否更新成功
  static Future<bool> updateSongDownloadStatus(
    String id,
    bool isDownloaded,
    [String? localPath]
  ) async {
    try {
      final song = getSong(id);
      if (song == null) return false;
      
      song.isDownloaded = isDownloaded;
      if (localPath != null) {
        song.localPath = localPath;
      }
      
      await saveSong(song);
      return true;
    } catch (e) {
      debugPrint('Error updating song download status: $e');
      return false;
    }
  }

  static Future<bool> updateSong(Song song) async {
    try {
      await saveSong(song);
      return true;
    } catch (e) {
      debugPrint('Error updating song: $e');
      return false;
    }
  }

  /// 搜索歌曲
  /// 
  /// [query] 搜索关键词
  /// 
  /// 返回匹配的歌曲列表
  static List<Song> searchSongs(String query) {
    if (query.isEmpty) return [];
    
    try {
      final lowercaseQuery = query.toLowerCase();
      
      return getAllSongs().where((song) {
        return song.title.toLowerCase().contains(lowercaseQuery) ||
               song.artist.toLowerCase().contains(lowercaseQuery) ||
               song.album.toLowerCase().contains(lowercaseQuery) ||
               song.pinyin.toLowerCase().contains(lowercaseQuery) ||
               song.pinyinFirst.toLowerCase().contains(lowercaseQuery);
      }).toList();
    } catch (e) {
      debugPrint('Error searching songs: $e');
      return [];
    }
  }
  
  /// 根据首字母获取歌曲
  /// 
  /// [letter] 首字母
  /// 
  /// 返回首字母匹配的歌曲列表
  static List<Song> getSongsByFirstLetter(String letter) {
    try {
      final uppercaseLetter = letter.toUpperCase();
      
      return getAllSongs().where((song) {
        if (song.pinyinFirst.isEmpty) return false;
        return song.pinyinFirst.startsWith(uppercaseLetter);
      }).toList();
    } catch (e) {
      debugPrint('Error getting songs by first letter: $e');
      return [];
    }
  }
  
  /// 获取按首字母分组的歌曲
  /// 
  /// 返回按首字母分组的歌曲映射表
  static Map<String, List<Song>> getSongsGroupedByFirstLetter() {
    try {
      return PinyinUtils.groupByFirstLetter<Song>(
        getAllSongs(),
        (song) => song.title,
      );
    } catch (e) {
      debugPrint('Error grouping songs by first letter: $e');
      return {};
    }
  }
  
  /// 根据分类获取歌曲
  /// 
  /// [category] 分类名称
  /// 
  /// 返回属于该分类的歌曲列表
  static List<Song> getSongsByCategory(String category) {
    if (category == '全部') {
      return getAllSongs();
    }
    
    try {
      return getAllSongs().where((song) {
        return song.categories.contains(category);
      }).toList();
    } catch (e) {
      debugPrint('Error getting songs by category: $e');
      return [];
    }
  }
  
  /// 获取已下载的歌曲
  /// 
  /// 返回所有已下载的歌曲列表
  static List<Song> getDownloadedSongs() {
    try {
      return getAllSongs().where((song) => song.isDownloaded).toList();
    } catch (e) {
      debugPrint('Error getting downloaded songs: $e');
      return [];
    }
  }
  
  /// 重置所有歌曲的下载状态
  /// 
  /// 返回是否重置成功
  static Future<bool> resetAllDownloadStatus() async {
    try {
      final songs = getAllSongs();
      for (var song in songs) {
        song.isDownloaded = false;
        song.localPath = null;
        await saveSong(song);
      }
      return true;
    } catch (e) {
      debugPrint('Error resetting download status: $e');
      return false;
    }
  }
  
  /// 删除歌曲
  /// 
  /// [id] 歌曲ID
  /// 
  /// 返回是否删除成功
  static Future<bool> deleteSong(String id) async {
    try {
      await AppDatabase.songsBox.delete(id);
      return true;
    } catch (e) {
      debugPrint('Error deleting song: $e');
      return false;
    }
  }
  
  /// 清空所有歌曲
  /// 
  /// 返回是否清空成功
  static Future<bool> clearAllSongs() async {
    try {
      await AppDatabase.songsBox.clear();
      return true;
    } catch (e) {
      debugPrint('Error clearing songs: $e');
      return false;
    }
  }
  
  /// 导入歌曲数据（从JSON字符串）
  /// 
  /// [jsonString] JSON字符串
  /// 
  /// 返回是否导入成功
  static Future<bool> importFromJson(String jsonString) async {
    try {
      final jsonData = jsonDecode(jsonString) as List;
      final songs = jsonData.map((item) => Song.fromJson(item)).toList();
      return await saveSongs(songs);
    } catch (e) {
      debugPrint('Error importing songs from JSON: $e');
      return false;
    }
  }
  
  /// 导出歌曲数据（到JSON字符串）
  /// 
  /// 返回JSON字符串
  static String exportToJson() {
    try {
      final songs = getAllSongs();
      final jsonList = songs.map((song) => song.toJson()).toList();
      return jsonEncode(jsonList);
    } catch (e) {
      debugPrint('Error exporting songs to JSON: $e');
      return '[]';
    }
  }

}
