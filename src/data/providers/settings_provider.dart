import 'package:flutter/foundation.dart';
import '../models/user_preferences.dart';
import '../local/preferences/user_preferences_helper.dart';
import '../repositories/song_repository.dart';
import '../../core/constants/enum_types.dart';

/// 设置数据提供者
/// 
/// 管理应用设置和曲库同步
class SettingsProvider extends ChangeNotifier {
  final SongRepository _songRepository;
  
  /// 用户偏好设置
  UserPreferences _preferences = UserPreferences.defaultPreferences();
  
  /// 是否正在同步
  bool _isSyncing = false;
  
  /// 同步状态
  SyncStatus _syncStatus = SyncStatus.notSynced;
  
  /// 同步进度（0.0到1.0）
  double _syncProgress = 0.0;
  
  /// 同步状态消息
  String _syncMessage = '';
  
  /// 歌曲总数
  int _songCount = 0;
  
  /// 已下载歌曲数量
  int _downloadedSongCount = 0;
  
  /// 收藏歌曲数量
  int _favoriteSongCount = 0;
  
  /// 构造函数
  SettingsProvider(this._songRepository) {
    _loadPreferences();
    _loadCounts();
  }
  
  /// 获取用户偏好设置
  UserPreferences get preferences => _preferences;
  
  /// 获取是否正在同步
  bool get isSyncing => _isSyncing;
  
  /// 获取同步状态
  SyncStatus get syncStatus => _syncStatus;
  
  /// 获取同步进度
  double get syncProgress => _syncProgress;
  
  /// 获取同步状态消息
  String get syncMessage => _syncMessage;
  
  /// 获取歌曲总数
  int get songCount => _songCount;
  
  /// 获取已下载歌曲数量
  int get downloadedSongCount => _downloadedSongCount;
  
  /// 获取收藏歌曲数量
  int get favoriteSongCount => _favoriteSongCount;
  
  /// 加载用户偏好设置
  Future<void> _loadPreferences() async {
    try {
      _preferences = await UserPreferencesHelper.getPreferences();
      notifyListeners();
    } catch (e) {
      debugPrint('Error loading preferences: $e');
    }
  }
  
  /// 加载统计数据
  Future<void> _loadCounts() async {
    try {
      _songCount = await _songRepository.getSongCount();
      _downloadedSongCount = await _songRepository.getDownloadedSongCount();
      _favoriteSongCount = await _songRepository.getFavoriteSongCount();
      notifyListeners();
    } catch (e) {
      debugPrint('Error loading counts: $e');
    }
  }
  
  /// 保存用户偏好设置
  Future<void> savePreferences(UserPreferences preferences) async {
    try {
      await UserPreferencesHelper.savePreferences(preferences);
      _preferences = preferences;
      notifyListeners();
    } catch (e) {
      debugPrint('Error saving preferences: $e');
    }
  }
  
  /// 更新主题模式
  Future<void> updateThemeMode(AppThemeMode themeMode) async {
    final updatedPreferences = _preferences.copyWith(themeMode: themeMode);
    await savePreferences(updatedPreferences);
  }
  
  /// 更新自动下载设置
  Future<void> updateAutoDownload(bool autoDownload) async {
    final updatedPreferences = _preferences.copyWith(autoDownload: autoDownload);
    await savePreferences(updatedPreferences);
  }
  
  /// 更新显示歌词设置
  Future<void> updateShowLyrics(bool showLyrics) async {
    final updatedPreferences = _preferences.copyWith(showLyrics: showLyrics);
    await savePreferences(updatedPreferences);
  }
  
  /// 更新显示通知设置
  Future<void> updateShowNotification(bool showNotification) async {
    final updatedPreferences = _preferences.copyWith(showNotification: showNotification);
    await savePreferences(updatedPreferences);
  }
  
  /// 更新默认音量
  Future<void> updateDefaultVolume(double volume) async {
    final updatedPreferences = _preferences.copyWith(defaultVolume: volume);
    await savePreferences(updatedPreferences);
  }
  
  /// 更新默认排序方式
  Future<void> updateDefaultSortOrder(SortOrder sortOrder) async {
    final updatedPreferences = _preferences.copyWith(defaultSortOrder: sortOrder);
    await savePreferences(updatedPreferences);
  }
  
  /// 更新默认视图模式
  Future<void> updateDefaultViewMode(ViewMode viewMode) async {
    final updatedPreferences = _preferences.copyWith(defaultViewMode: viewMode);
    await savePreferences(updatedPreferences);
  }
  
  /// 更新默认播放模式
  Future<void> updateDefaultPlayMode(PlayMode playMode) async {
    final updatedPreferences = _preferences.copyWith(defaultPlayMode: playMode);
    await savePreferences(updatedPreferences);
  }
  
  /// 检查曲库更新
  Future<bool> checkForUpdates() async {
    try {
      _syncStatus = SyncStatus.checking;
      notifyListeners();
      
      final hasUpdate = await _songRepository.checkForUpdates(_preferences.libraryVersion);
      
      _syncStatus = hasUpdate ? SyncStatus.notSynced : SyncStatus.upToDate;
      notifyListeners();
      
      return hasUpdate;
    } catch (e) {
      debugPrint('Error checking for updates: $e');
      _syncStatus = SyncStatus.failed;
      notifyListeners();
      return false;
    }
  }
  
  /// 同步曲库
  Future<bool> syncLibrary() async {
    if (_isSyncing) return false;
    
    _isSyncing = true;
    _syncStatus = SyncStatus.syncing;
    _syncProgress = 0.0;
    _syncMessage = '准备同步...';
    notifyListeners();
    
    try {
      final success = await _songRepository.syncFullLibrary(
        (message, progress) {
          _syncMessage = message;
          _syncProgress = progress;
          notifyListeners();
        },
        _preferences.libraryVersion,
      );
      
      if (success) {
        // 更新库版本和同步时间
        final response = await _songRepository.checkForUpdates(0); // 获取最新版本
        if (response) {
          final updatedPreferences = _preferences.copyWith(
            libraryVersion: _preferences.libraryVersion + 1,
            lastSyncTime: DateTime.now(),
          );
          await savePreferences(updatedPreferences);
        }
        
        _syncStatus = SyncStatus.completed;
        await _loadCounts();
      } else {
        _syncStatus = SyncStatus.failed;
      }
      
      _isSyncing = false;
      notifyListeners();
      
      return success;
    } catch (e) {
      debugPrint('Error syncing library: $e');
      _syncStatus = SyncStatus.failed;
      _isSyncing = false;
      notifyListeners();
      return false;
    }
  }
  
  /// 重置设置为默认值
  Future<void> resetToDefaults() async {
    await savePreferences(UserPreferences.defaultPreferences());
  }
  
  /// 刷新统计数据
  Future<void> refreshCounts() async {
    await _loadCounts();
  }
}
