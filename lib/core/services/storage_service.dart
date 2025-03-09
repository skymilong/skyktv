import 'dart:convert';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter/foundation.dart';
import '../constants/app_constants.dart';

/// 存储服务
/// 
/// 管理应用的本地存储，包括Hive数据库和SharedPreferences
class StorageService {
  // 单例实例
  static final StorageService _instance = StorageService._internal();
  
  // 工厂构造函数
  factory StorageService() => _instance;
  
  // 私有构造函数
  StorageService._internal();
  
  // Hive盒子映射表
  final Map<String, Box> _boxes = {};
  
  // SharedPreferences实例
  SharedPreferences? _prefs;
  
  /// 初始化存储服务
  /// 
  /// 必须在应用启动时调用
  Future<void> init() async {
    try {
      // 初始化Hive
      await Hive.initFlutter();
      
      // 初始化SharedPreferences
      _prefs = await SharedPreferences.getInstance();
      
      // 打开常用的Hive盒子
      await _openBox(AppConstants.kSongsBoxName);
      await _openBox(AppConstants.kSettingsBoxName);
      await _openBox(AppConstants.kPlaylistsBoxName);
      await _openBox(AppConstants.kFavoritesBoxName);
      
      debugPrint('StorageService initialized successfully');
    } catch (e) {
      debugPrint('Error initializing StorageService: $e');
      rethrow;
    }
  }
  
  /// 打开Hive盒子
  /// 
  /// [boxName] 盒子名称
  /// 
  /// 返回打开的盒子
  Future<Box> _openBox(String boxName) async {
    if (_boxes.containsKey(boxName)) {
      return _boxes[boxName]!;
    }
    
    final box = await Hive.openBox(boxName);
    _boxes[boxName] = box;
    return box;
  }
  
  /// 获取Hive盒子
  /// 
  /// [boxName] 盒子名称
  /// 
  /// 返回盒子实例，如果不存在则打开
  Future<Box> getBox(String boxName) async {
    return _boxes[boxName] ?? await _openBox(boxName);
  }
  
  /// 关闭Hive盒子
  /// 
  /// [boxName] 盒子名称
  Future<void> closeBox(String boxName) async {
    if (_boxes.containsKey(boxName)) {
      final box = _boxes[boxName]!;
      await box.close();
      _boxes.remove(boxName);
    }
  }
  
  /// 关闭所有Hive盒子
  Future<void> closeAllBoxes() async {
    for (final boxName in _boxes.keys.toList()) {
      await closeBox(boxName);
    }
  }
  
  /// 将值保存到Hive盒子
  /// 
  /// [boxName] 盒子名称
  /// [key] 键
  /// [value] 值
  Future<void> putInBox(String boxName, dynamic key, dynamic value) async {
    final box = await getBox(boxName);
    await box.put(key, value);
  }
  
  /// 从Hive盒子中获取值
  /// 
  /// [boxName] 盒子名称
  /// [key] 键
  /// [defaultValue] 默认值
  /// 
  /// 返回存储的值，如果不存在则返回默认值
  Future<T?> getFromBox<T>(String boxName, dynamic key, [T? defaultValue]) async {
    final box = await getBox(boxName);
    return box.get(key, defaultValue: defaultValue) as T?;
  }
  
  /// 从Hive盒子中删除值
  /// 
  /// [boxName] 盒子名称
  /// [key] 键
  Future<void> deleteFromBox(String boxName, dynamic key) async {
    final box = await getBox(boxName);
    await box.delete(key);
  }
  
  /// 清空Hive盒子
  /// 
  /// [boxName] 盒子名称
  Future<void> clearBox(String boxName) async {
    final box = await getBox(boxName);
    await box.clear();
  }
  
  /// 获取Hive盒子中的所有键
  /// 
  /// [boxName] 盒子名称
  /// 
  /// 返回所有键的列表
  Future<List<dynamic>> getBoxKeys(String boxName) async {
    final box = await getBox(boxName);
    return box.keys.toList();
  }
  
  /// 获取Hive盒子中的所有值
  /// 
  /// [boxName] 盒子名称
  /// 
  /// 返回所有值的列表
  Future<List<dynamic>> getBoxValues(String boxName) async {
    final box = await getBox(boxName);
    return box.values.toList();
  }
  
  /// 批量将值保存到Hive盒子
  /// 
  /// [boxName] 盒子名称
  /// [entries] 键值对映射表
  Future<void> putAllInBox(String boxName, Map<dynamic, dynamic> entries) async {
    final box = await getBox(boxName);
    await box.putAll(entries);
  }
  
  /// 将字符串保存到SharedPreferences
  /// 
  /// [key] 键
  /// [value] 值
  Future<bool> setString(String key, String value) async {
    return await _prefs?.setString(key, value) ?? false;
  }
  
  /// 从SharedPreferences中获取字符串
  /// 
  /// [key] 键
  /// [defaultValue] 默认值
  /// 
  /// 返回存储的字符串，如果不存在则返回默认值
  String getString(String key, [String defaultValue = '']) {
    return _prefs?.getString(key) ?? defaultValue;
  }
  
  /// 将布尔值保存到SharedPreferences
  /// 
  /// [key] 键
  /// [value] 值
  Future<bool> setBool(String key, bool value) async {
    return await _prefs?.setBool(key, value) ?? false;
  }
  
  /// 从SharedPreferences中获取布尔值
  /// 
  /// [key] 键
  /// [defaultValue] 默认值
  /// 
  /// 返回存储的布尔值，如果不存在则返回默认值
  bool getBool(String key, [bool defaultValue = false]) {
    return _prefs?.getBool(key) ?? defaultValue;
  }
  
  /// 将整数保存到SharedPreferences
  /// 
  /// [key] 键
  /// [value] 值
  Future<bool> setInt(String key, int value) async {
    return await _prefs?.setInt(key, value) ?? false;
  }
  
  /// 从SharedPreferences中获取整数
  /// 
  /// [key] 键
  /// [defaultValue] 默认值
  /// 
  /// 返回存储的整数，如果不存在则返回默认值
  int getInt(String key, [int defaultValue = 0]) {
    return _prefs?.getInt(key) ?? defaultValue;
  }
  
  /// 将双精度浮点数保存到SharedPreferences
  /// 
  /// [key] 键
  /// [value] 值
  Future<bool> setDouble(String key, double value) async {
    return await _prefs?.setDouble(key, value) ?? false;
  }
  
  /// 从SharedPreferences中获取双精度浮点数
  /// 
  /// [key] 键
  /// [defaultValue] 默认值
  /// 
  /// 返回存储的双精度浮点数，如果不存在则返回默认值
  double getDouble(String key, [double defaultValue = 0.0]) {
    return _prefs?.getDouble(key) ?? defaultValue;
  }
  
  /// 将字符串列表保存到SharedPreferences
  /// 
  /// [key] 键
  /// [value] 值
  Future<bool> setStringList(String key, List<String> value) async {
    return await _prefs?.setStringList(key, value) ?? false;
  }
  
  /// 从SharedPreferences中获取字符串列表
  /// 
  /// [key] 键
  /// [defaultValue] 默认值
  /// 
  /// 返回存储的字符串列表，如果不存在则返回默认值
  List<String> getStringList(String key, [List<String> defaultValue = const []]) {
    return _prefs?.getStringList(key) ?? defaultValue;
  }
  
  /// 将对象保存到SharedPreferences（JSON序列化）
  /// 
  /// [key] 键
  /// [value] 值
  Future<bool> setObject(String key, Object value) async {
    final jsonString = jsonEncode(value);
    return await setString(key, jsonString);
  }
  
  /// 从SharedPreferences中获取对象（JSON反序列化）
  /// 
  /// [key] 键
  /// [fromJson] 从JSON映射表创建对象的函数
  /// 
  /// 返回反序列化的对象，如果不存在则返回null
  T? getObject<T>(String key, T Function(Map<String, dynamic> json) fromJson) {
    final jsonString = getString(key);
    if (jsonString.isEmpty) {
      return null;
    }
    
    try {
      final json = jsonDecode(jsonString) as Map<String, dynamic>;
      return fromJson(json);
    } catch (e) {
      debugPrint('Error parsing JSON for key $key: $e');
      return null;
    }
  }
  
  /// 从SharedPreferences中删除值
  /// 
  /// [key] 键
  Future<bool> remove(String key) async {
    return await _prefs?.remove(key) ?? false;
  }
  
  /// 清空SharedPreferences
  Future<bool> clear() async {
    return await _prefs?.clear() ?? false;
  }
  
  /// 检查SharedPreferences中是否包含键
  /// 
  /// [key] 键
  /// 
  /// 返回是否包含键
  bool containsKey(String key) {
    return _prefs?.containsKey(key) ?? false;
  }
  
  /// 获取SharedPreferences中的所有键
  /// 
  /// 返回所有键的集合
  Set<String> getKeys() {
    return _prefs?.getKeys() ?? {};
  }
  
  /// 重新加载SharedPreferences
  /// 
  /// 返回是否成功重新加载
  Future<bool> refreshSettings() async {
    if (_prefs == null) {
      throw StateError('App settings manager has not been initialized.');
    }
    try {
      await _prefs!.reload();
      debugPrint('Settings reload initiated.');
      return true; // Assume success if no exception was thrown
    } catch (e) {
      debugPrint('Error reloading settings: $e');
      return false; // Indicate failure if an exception occurred
    }
  }
}
