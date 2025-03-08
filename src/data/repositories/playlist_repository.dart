import '../../core/constants/enum_types.dart';
import '../models/playlist.dart';
import '../models/song.dart';
import '../local/database/song_dao.dart';
import '../local/database/playlist_dao.dart';

/// 播放列表仓库
/// 
/// 管理播放列表的创建、更新和删除
class PlaylistRepository {
  /// 构造函数
  PlaylistRepository();
  
  /// 获取所有播放列表
  Future<List<Playlist>> getAllPlaylists() async {
    return await PlaylistDao.getAllPlaylists();
  }
  
  /// 获取播放列表详情
  Future<Playlist?> getPlaylist(String id) async {
    return await PlaylistDao.getPlaylist(id);
  }
  
  /// 创建新播放列表
  Future<Playlist> createPlaylist(String name, {String description = ''}) async {
    final now = DateTime.now();
    final playlist = Playlist(
      id: 'playlist_${now.millisecondsSinceEpoch}',
      name: name,
      description: description,
      createdAt: now,
      updatedAt: now,
    );
    
    await PlaylistDao.createPlaylistFromOther(playlist);
    return playlist;
  }
  
  /// 更新播放列表
  Future<void> updatePlaylist(Playlist playlist) async {
    await PlaylistDao.updatePlaylist(playlist.copyWith(
      updatedAt: DateTime.now(),
    ));
  }
  
  /// 删除播放列表
  Future<void> deletePlaylist(String id) async {
    await PlaylistDao.deletePlaylist(id);
  }
  
  /// 添加歌曲到播放列表
  Future<void> addSongToPlaylist(String playlistId, String songId) async {
    final playlist = await PlaylistDao.getPlaylist(playlistId);
    if (playlist != null) {
      final updatedPlaylist = playlist.addSong(songId);
      await PlaylistDao.updatePlaylist(updatedPlaylist);
    }
  }
  
  /// 从播放列表中移除歌曲
  Future<void> removeSongFromPlaylist(String playlistId, String songId, MediaType type) async {
    final playlist = await PlaylistDao.getPlaylist(playlistId);
    if (playlist != null) {
      final updatedPlaylist = playlist.removeSong(songId, type);
      await PlaylistDao.updatePlaylist(updatedPlaylist);
    }
  }
  
  /// 清空播放列表
  Future<void> clearPlaylist(String playlistId) async {
    final playlist = await PlaylistDao.getPlaylist(playlistId);
    if (playlist != null) {
      final updatedPlaylist = playlist.clearSongs();
      await PlaylistDao.updatePlaylist(updatedPlaylist);
    }
  }
  
  /// 获取播放列表中的歌曲
  Future<List<Song>> getPlaylistSongs(String playlistId) async {
    final playlist = await PlaylistDao.getPlaylist(playlistId);
    if (playlist == null) {
      return [];
    }
    
    final songs = <Song>[];
    for (final songId in playlist.songIds) {
      final song = await SongDao.getSong(songId);
      if (song != null) {
        songs.add(song);
      }
    }
    
    return songs;
  }
  
  /// 初始化系统播放列表
  Future<void> initSystemPlaylists() async {
    // 检查"我的收藏"播放列表是否存在
    final favorites = await PlaylistDao.getPlaylist('system_favorites');
    if (favorites == null) {
      await PlaylistDao.createPlaylistFromOther(Playlist.favorites());
    }
    
    // 检查"最近播放"播放列表是否存在
    final recentlyPlayed = await PlaylistDao.getPlaylist('system_recently_played');
    if (recentlyPlayed == null) {
      await PlaylistDao.createPlaylistFromOther(Playlist.recentlyPlayed());
    }
  }
  
  /// 添加歌曲到"最近播放"
  Future<void> addToRecentlyPlayed(String songId) async {
    const maxRecentSongs = 50; // 最多保存50首最近播放的歌曲
    
    final recentlyPlayed = await PlaylistDao.getPlaylist('system_recently_played');
    if (recentlyPlayed == null) {
      return;
    }
    
    // 如果歌曲已经在列表中，先移除它
    List<String> songIds = List.from(recentlyPlayed.songIds);
    songIds.remove(songId);
    
    // 将歌曲添加到列表开头
    songIds.insert(0, songId);
    
    // 如果超过最大数量，移除最旧的歌曲
    if (songIds.length > maxRecentSongs) {
      songIds = songIds.sublist(0, maxRecentSongs);
    }
    
    // 更新播放列表
    final updatedPlaylist = recentlyPlayed.copyWith(
      songIds: songIds,
      updatedAt: DateTime.now(),
    );
    
    await PlaylistDao.updatePlaylist(updatedPlaylist);
  }
  
  /// 获取系统播放列表
  Future<List<Playlist>> getSystemPlaylists() async {
    final playlists = await PlaylistDao.getAllPlaylists();
    return playlists.where((playlist) => playlist.isSystem).toList();
  }
  
  /// 获取用户创建的播放列表
  Future<List<Playlist>> getUserPlaylists() async {
    final playlists = await PlaylistDao.getAllPlaylists();
    return playlists.where((playlist) => !playlist.isSystem).toList();
  }
  
  /// 获取播放列表数量
  Future<int> getPlaylistCount() async {
    return await PlaylistDao.getAllPlaylists().length;
  }
}
