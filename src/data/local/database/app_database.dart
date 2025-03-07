import 'package:hive/hive.dart';
import 'package:hive_flutter/hive_flutter.dart';
import '../../../core/constants/app_constants.dart';
import '../../models/song.dart';
import '../../models/playlist.dart';

/// 应用数据库
/// 
/// 管理Hive数据库的初始化和操作
class AppDatabase {
  // 私有构造函数，防止实例化
  AppDatabase._();
  
  // 数据库是否已初始化
  static bool _initialized = false;
  
  // 各种盒子
  static Box<Map>? _songsBox;
  static Box<Map>? _playlistsBox;
  static Box<String>? _favoritesBox;
  static Box? _settingsBox;
  
  /// 初始化数据库
  /// 
  /// 必须在应用启动时调用
  static Future<void> init() async {
    if (_initialized) return;
    
    try {
      // 初始化Hive
      await Hive.initFlutter();
      
      // 注册适配器（如果使用TypeAdapter，这里需要注册）
      // Hive.registerAdapter(SongAdapter());
      // Hive.registerAdapter(PlaylistAdapter());
      
      // 打开盒子
      _songsBox = await Hive.openBox<Map>(AppConstants.kSongsBoxName);
      _playlistsBox = await Hive.openBox<Map>(AppConstants.kPlaylistsBoxName);
      _favoritesBox = await Hive.openBox<String>(AppConstants.kFavoritesBoxName);
      _settingsBox = await Hive.openBox(AppConstants.kSettingsBoxName);
      
      _initialized = true;
    } catch (e) {
      print('Error initializing AppDatabase: $e');
      rethrow;
    }
  }
  
  /// 获取歌曲盒子
  static Box<Map> get songsBox {
    if (!_initialized || _songsBox == null) {
      throw StateError('AppDatabase not initialized. Call init() first.');
    }
    return _songsBox!;
  }
  
  /// 获取播放列表盒子
  static Box<Map> get playlistsBox {
    if (!_initialized || _playlistsBox == null) {
      throw StateError('AppDatabase not initialized. Call init() first.');
    }
    return _playlistsBox!;
  }
  
  /// 获取收藏夹盒子
  static Box<String> get favoritesBox {
    if (!_initialized || _favoritesBox == null) {
      throw StateError('AppDatabase not initialized. Call init() first.');
    }
    return _favoritesBox!;
  }
  
  /// 获取设置盒子
  static Box get settingsBox {
    if (!_initialized || _settingsBox == null) {
      throw StateError('AppDatabase not initialized. Call init() first.');
    }
    return _settingsBox!;
  }
  
  /// 关闭数据库
  static Future<void> close() async {
    if (!_initialized) return;
    
    await _songsBox?.close();
    await _playlistsBox?.close();
    await _favoritesBox?.close();
    await _settingsBox?.close();
    
    _songsBox = null;
    _playlistsBox = null;
    _favoritesBox = null;
    _settingsBox = null;
    
    _initialized = false;
  }
  
  /// 清空数据库
  static Future<void> clear() async {
    if (!_initialized) return;
    
    await _songsBox?.clear();
    await _playlistsBox?.clear();
    await _favoritesBox?.clear();
    await _settingsBox?.clear();
  }
  
  /// 获取数据库状态
  /// 
  /// 返回包含数据库状态信息的映射表
  static Map<String, dynamic> getDatabaseStats() {
    if (!_initialized) {
      return {'initialized': false};
    }
    
    return {
      'initialized': true,
      'songCount': _songsBox?.length ?? 0,
      'playlistCount': _playlistsBox?.length ?? 0,
      'favoritesCount': _favoritesBox?.length ?? 0,
      'settingsCount': _settingsBox?.length ?? 0,
    };
  }
  
  /// 最后同步时间
  static DateTime? get lastSyncTime {
    final timestamp = _settingsBox?.get(AppConstants.kLastSyncTimeKey);
    return timestamp != null 
        ? DateTime.fromMillisecondsSinceEpoch(timestamp as int) 
        : null;
  }
  
  /// 设置最后同步时间
  static Future<void> setLastSyncTime(DateTime time) async {
    await _settingsBox?.put(
      AppConstants.kLastSyncTimeKey,
      time.millisecondsSinceEpoch,
    );
  }
  
  /// 获取曲库版本
  static int get libraryVersion {
    return _settingsBox?.get(AppConstants.kLibraryVersionKey, defaultValue: 0) as int;
  }
  
  /// 设置曲库版本
  static Future<void> setLibraryVersion(int version) async {
    await _settingsBox?.put(AppConstants.kLibraryVersionKey, version);
  }
}
