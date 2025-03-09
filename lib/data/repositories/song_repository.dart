import 'dart:convert';
import 'package:http/http.dart' as http;
import '../local/database/song_favorite_dao.dart';
import '../models/song.dart';
import '../local/database/song_dao.dart';
import '../../core/constants/api_endpoints.dart';
import '../../core/constants/enum_types.dart';
import '../../core/utils/pinyin_utils.dart';

/// 歌曲仓库
/// 
/// 管理歌曲数据的获取、存储和同步
class SongRepository {


  /// 获取所有歌曲
  Future<List<Song>> getAllSongs() async {
    return await SongDao.getAllSongs();
  }
  
  /// 获取歌曲详情
  Future<Song?> getSongById(String id) async {
    return await SongDao.getSong(id);
  }
  
  /// 搜索歌曲
  Future<List<Song>> searchSongs(String query) async {
    if (query.isEmpty) {
      return [];
    }
    
    final songs = await SongDao.getAllSongs();
    final lowercaseQuery = query.toLowerCase();
    
    return songs.where((song) {
      return song.title.toLowerCase().contains(lowercaseQuery) ||
             song.artist.toLowerCase().contains(lowercaseQuery) ||
             song.pinyin.toLowerCase().contains(lowercaseQuery) ||
             song.pinyinFirst.toLowerCase().contains(lowercaseQuery);
    }).toList();
  }
  
  /// 按字母获取歌曲
  Future<List<Song>> getSongsByFirstLetter(String letter) async {
    final songs = await SongDao.getAllSongs();
    return songs.where((song) {
      return song.pinyinFirst.startsWith(letter.toUpperCase());
    }).toList();
  }
  
  /// 按类别获取歌曲
  Future<List<Song>> getSongsByCategory(String category) async {
    final songs = await SongDao.getAllSongs();
    if (category == '全部') {
      return songs;
    }
    return songs.where((song) {
      return song.categories.contains(category);
    }).toList();
  }
  
  /// 获取收藏的歌曲
  Future<List<Song>> getFavoriteSongs() async {
    final songs = await SongDao.getAllSongs();
    return songs.where((song) => song.isDownloaded).toList();
  }
  
  /// 获取已下载的歌曲
  Future<List<Song>> getDownloadedSongs() async {
    final songs = await SongDao.getAllSongs();
    return songs.where((song) => song.isDownloaded).toList();
  }
  
  /// 更新歌曲下载状态
  Future<void> updateSongDownloadStatus(
    String songId, 
    bool isDownloaded, 
    String? localPath,
    DownloadStatus status,
  ) async {
    final song = await SongDao.getSong(songId);
    if (song != null) {
      final updatedSong = song.copyWith(
        isDownloaded: isDownloaded,
        localPath: localPath,
        downloadStatus: status,
      );
      await SongDao.updateSong(updatedSong);
    }
  }
  
  /// 更新歌曲收藏状态
  Future<void> updateSongFavoriteStatus(String songId, bool isFavorite) async {
    final song = await SongDao.getSong(songId);
    if (song != null) {
      final updatedSong = song.copyWith(isFavorite: isFavorite);
      await SongDao.updateSong(updatedSong);
    }
  }
  
  /// 检查曲库更新
  Future<bool> checkForUpdates(int currentVersion) async {
    try {
      final response = await http.get(Uri.parse(ApiEndpoints.effectiveLibraryInfoUrl));
      if (response.statusCode != 200) return false;
      
      final info = jsonDecode(response.body);
      final serverVersion = info['version'] as int;
      
      return serverVersion > currentVersion;
    } catch (e) {
      print('Error checking for updates: $e');
      return false;
    }
  }
  
  /// 同步完整曲库
  Future<bool> syncFullLibrary(
    void Function(String, double) onProgress,
    int currentVersion,
  ) async {
    try {
      onProgress('正在下载曲库数据...', 0.1);
      
      final response = await http.get(Uri.parse(ApiEndpoints.effectiveFullLibraryUrl));
      if (response.statusCode != 200) return false;
      
      onProgress('正在处理曲库数据...', 0.5);
      
      final data = jsonDecode(response.body);
      final info = data['info'];
      final songsData = data['songs'] as List;
      
      final songs = songsData.map((json) {
        // 确保每首歌都有拼音信息
        if (!json.containsKey('pinyin') || json['pinyin'] == null) {
          json['pinyin'] = PinyinUtils.toPinyin(json['title']);
        }
        if (!json.containsKey('pinyinFirst') || json['pinyinFirst'] == null) {
          json['pinyinFirst'] = PinyinUtils.getFirstLetters(json['title']);
        }
        
        return Song.fromJson(json);
      }).toList();
      
      onProgress('正在保存曲库数据...', 0.8);
      
      // 清空并重建数据库
      await SongDao.clearAllSongs();
      await SongDao.saveSongs(songs);
      
      onProgress('同步完成！', 1.0);
      return true;
    } catch (e) {
      print('Error syncing library: $e');
      onProgress('同步失败: $e', 0);
      return false;
    }
  }
  
  /// 按排序方式获取歌曲
  Future<List<Song>> getSongsBySortOrder(SortOrder sortOrder) async {
    final songs = await SongDao.getAllSongs();
    
    switch (sortOrder) {
      case SortOrder.byName:
        return songs..sort((a, b) => a.title.compareTo(b.title));
      case SortOrder.byArtist:
        return songs..sort((a, b) => a.artist.compareTo(b.artist));
      case SortOrder.byAddedDate:
        return songs..sort((a, b) => b.addedTime.compareTo(a.addedTime));
      case SortOrder.byPopularity:
        return songs..sort((a, b) => b.popularity.compareTo(a.popularity));
      default:
        return songs;
    }
  }
  
  /// 获取所有歌曲类别
  Future<List<String>> getAllCategories() async {
    final songs = SongDao.getAllSongs();
    final Set<String> categories = {};
    
    for (final song in songs) {
      categories.addAll(song.categories);
    }
    
    return ['全部', ...categories.toList()..sort()];
  }
  
  /// 获取歌曲总数
  Future<int> getSongCount() async {
    return SongDao.getSongCount();
  }
  
  /// 获取已下载歌曲数量
  Future<int> getDownloadedSongCount() async {
    return await SongDao.getDownloadedSongs().length;
  }
  
  /// 获取收藏歌曲数量
  Future<int> getFavoriteSongCount() async {
    return await FavoriteSongDao.getFavoriteSongCount();
  }
}
