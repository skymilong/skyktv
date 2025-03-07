import 'dart:convert';
import 'package:flutter/material.dart';
import '../../../core/constants/app_constants.dart';
import '../../../core/constants/enum_types.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// 用户偏好设置帮助类
/// 
/// 管理用户偏好设置，如主题、排序方式等
class UserPreferencesHelper {
  // 私有构造函数，防止实例化
  UserPreferencesHelper._();
  
  // SharedPreferences实例
  static SharedPreferences? _prefs;
  
  /// 初始化用户偏好设置
  /// 
  /// 必须在应用启动时调用
  static Future<void> init() async {
    _prefs = await SharedPreferences.getInstance();
  }
  
  /// 获取主题模式
  /// 
  /// 返回当前的主题模式
  static AppThemeMode getThemeMode() {
    final value = _prefs?.getInt(AppConstants.kThemeModeKey) ?? 0;
    return AppThemeMode.values[value];
  }
  
  /// 设置主题模式
  /// 
  /// [mode] 要设置的主题模式
  static Future<void> setThemeMode(AppThemeMode mode) async {
    await _prefs?.setInt(AppConstants.kThemeModeKey, mode.index);
  }
  
  /// 获取排序方式
  /// 
  /// 返回当前的排序方式
  static SortOrder getSortOrder() {
    final value = _prefs?.getInt('sort_order') ?? 0;
    return SortOrder.values[value];
  }
  
  /// 设置排序方式
  /// 
  /// [order] 要设置的排序方式
  static Future<void> setSortOrder(SortOrder order) async {
    await _prefs?.setInt('sort_order', order.index);
  }
  
  /// 获取视图模式
  /// 
  /// 返回当前的视图模式
  static ViewMode getViewMode() {
    final value = _prefs?.getInt('view_mode') ?? 0;
    return ViewMode.values[value];
  }
  
  /// 设置视图模式
  /// 
  /// [mode] 要设置的视图模式
  static Future<void> setViewMode(ViewMode mode) async {
    await _prefs?.setInt('view_mode', mode.index);
  }
  
  /// 获取播放模式
  /// 
  /// 返回当前的播放模式
  static PlayMode getPlayMode() {
    final value = _prefs?.getInt('play_mode') ?? 0;
    return PlayMode.values[value];
  }
  
  /// 设置播放模式
  /// 
  /// [mode] 要设置的播放模式
  static Future<void> setPlayMode(PlayMode mode) async {
    await _prefs?.setInt('play_mode', mode.index);
  }
  
  /// 获取音频模式
  /// 
  /// 返回当前的音频模式
  static AudioMode getAudioMode() {
    final value = _prefs?.getInt('audio_mode') ?? 0;
    return AudioMode.values[value];
  }
  
  /// 设置音频模式
  /// 
  /// [mode] 要设置的音频模式
  static Future<void> setAudioMode(AudioMode mode) async {
    await _prefs?.setInt('audio_mode', mode.index);
  }
  
  /// 获取是否自动下载
  /// 
  /// 返回是否自动下载
  static bool getAutoDownload() {
    return _prefs?.getBool(AppConstants.kAutoDownloadKey) ?? false;
  }
  
  /// 设置是否自动下载
  /// 
  /// [value] 是否自动下载
  static Future<void> setAutoDownload(bool value) async {
    await _prefs?.setBool(AppConstants.kAutoDownloadKey, value);
  }
  
  /// 获取播放音量
  /// 
  /// 返回播放音量（0.0-1.0）
  static double getVolume() {
    return _prefs?.getDouble('volume') ?? AppConstants.kDefaultVolume;
  }
  
  /// 设置播放音量
  /// 
  /// [value] 播放音量（0.0-1.0）
  static Future<void> setVolume(double value) async {
    await _prefs?.setDouble('volume', value);
  }
  
  /// 获取搜索历史
  /// 
  /// 返回搜索历史列表
  static List<String> getSearchHistory() {
    return _prefs?.getStringList('search_history') ?? [];
  }
  
  /// 添加搜索历史
  /// 
  /// [query] 搜索关键词
  static Future<void> addSearchHistory(String query) async {
    if (query.isEmpty) return;
    
    final history = getSearchHistory();
    
    // 如果已存在，先移除
    history.remove(query);
    
    // 添加到开头
    history.insert(0, query);
    
    // 限制历史记录数量
    if (history.length > 10) {
      history.removeLast();
    }
    
    await _prefs?.setStringList('search_history', history);
  }
  
  /// 清空搜索历史
  static Future<void> clearSearchHistory() async {
    await _prefs?.setStringList('search_history', []);
  }
  
  /// 获取最后播放的歌曲ID
  /// 
  /// 返回最后播放的歌曲ID
  static String? getLastPlayedSongId() {
    return _prefs?.getString('last_played_song_id');
  }
  
  /// 设置最后播放的歌曲ID
  /// 
  /// [songId] 歌曲ID
  static Future<void> setLastPlayedSongId(String songId) async {
    await _prefs?.setString('last_played_song_id', songId);
  }
  
  /// 获取最后播放位置（秒）
  /// 
  /// 返回最后播放位置
  static int getLastPlayPosition() {
    return _prefs?.getInt('last_play_position') ?? 0;
  }
  
  /// 设置最后播放位置（秒）
  /// 
  /// [position] 播放位置
  static Future<void> setLastPlayPosition(int position) async {
    await _prefs?.setInt('last_play_position', position);
  }
  
  /// 获取是否首次启动
  /// 
  /// 返回是否首次启动
  static bool isFirstLaunch() {
    return _prefs?.getBool('is_first_launch') ?? true;
  }
  
  /// 设置首次启动标志
  /// 
  /// [value] 是否首次启动
  static Future<void> setFirstLaunch(bool value) async {
    await _prefs?.setBool('is_first_launch', value);
  }
  
  /// 获取上次更新检查时间
  /// 
  /// 返回上次更新检查时间
  static DateTime? getLastUpdateCheckTime() {
    final timestamp = _prefs?.getInt('last_update_check_time');
    return timestamp != null 
        ? DateTime.fromMillisecondsSinceEpoch(timestamp) 
        : null;
  }
  
  /// 设置上次更新检查时间
  /// 
  /// [time] 时间
  static Future<void> setLastUpdateCheckTime(DateTime time) async {
    await _prefs?.setInt('last_update_check_time', time.millisecondsSinceEpoch);
  }
  
  /// 获取自定义设置
  /// 
  /// [key] 设置键
  /// [defaultValue] 默认值
  /// 
  /// 返回设置值
  static T? getCustomSetting<T>(String key, [T? defaultValue]) {
    switch (T) {
      case String:
        return _prefs?.getString(key) as T? ?? defaultValue;
      case int:
        return _prefs?.getInt(key) as T? ?? defaultValue;
      case double:
        return _prefs?.getDouble(key) as T? ?? defaultValue;
      case bool:
        return _prefs?.getBool(key) as T? ?? defaultValue;
      case List:
        return _prefs?.getStringList(key) as T? ?? defaultValue;
      default:
        final jsonString = _prefs?.getString(key);
        if (jsonString == null) return defaultValue;
        try {
          return jsonDecode(jsonString) as T;
        } catch (e) {
          return defaultValue;
        }
    }
  }
  
  /// 设置自定义设置
  /// 
  /// [key] 设置键
  /// [value] 设置值
  static Future<void> setCustomSetting<T>(String key, T value) async {
    switch (T) {
      case String:
        await _prefs?.setString(key, value as String);
        break;
      case int:
        await _prefs?.setInt(key, value as int);
        break;
      case double:
        await _prefs?.setDouble(key, value as double);
        break;
      case bool:
        await _prefs?.setBool(key, value as bool);
        break;
      case List:
        if (value is List<String>) {
          await _prefs?.setStringList(key, value);
        }
        break;
      default:
        await _prefs?.setString(key, jsonEncode(value));
        break;
    }
  }
  
  /// 删除设置
  /// 
  /// [key] 设置键
  static Future<void> removeSetting(String key) async {
    await _prefs?.remove(key);
  }
  
  /// 清空所有设置
  static Future<void> clearAllSettings() async {
    await _prefs?.clear();
  }
}
