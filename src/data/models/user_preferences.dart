import 'package:equatable/equatable.dart';
import '../../core/constants/enum_types.dart';

/// 用户偏好设置模型类
/// 
/// 存储用户的应用设置和偏好
class UserPreferences extends Equatable {
  /// 主题模式
  final AppThemeMode themeMode;
  
  /// 是否自动下载歌曲
  final bool autoDownload;
  
  /// 是否在播放时显示歌词
  final bool showLyrics;
  
  /// 是否在后台播放时显示通知
  final bool showNotification;
  
  /// 默认音量（0.0到1.0）
  final double defaultVolume;
  
  /// 默认排序方式
  final SortOrder defaultSortOrder;
  
  /// 默认视图模式
  final ViewMode defaultViewMode;
  
  /// 最后同步时间
  final DateTime? lastSyncTime;
  
  /// 曲库版本
  final int libraryVersion;
  
  /// 是否在启动时自动检查更新
  final bool autoCheckUpdate;
  
  /// 默认播放模式
  final PlayMode defaultPlayMode;
  
  /// 是否在Wi-Fi下自动下载
  final bool autoDownloadOnWifi;
  
  /// 是否启用音效
  final bool enableSoundEffects;
  
  /// 是否启用振动反馈
  final bool enableVibration;
  
  /// 最大下载并发数
  final int maxConcurrentDownloads;
  
  /// 最大缓存大小（MB）
  final int maxCacheSize;

  /// 构造函数
  const UserPreferences({
    this.themeMode = AppThemeMode.system,
    this.autoDownload = false,
    this.showLyrics = true,
    this.showNotification = true,
    this.defaultVolume = 0.7,
    this.defaultSortOrder = SortOrder.byName,
    this.defaultViewMode = ViewMode.list,
    this.lastSyncTime,
    this.libraryVersion = 0,
    this.autoCheckUpdate = true,
    this.defaultPlayMode = PlayMode.sequential,
    this.autoDownloadOnWifi = true,
    this.enableSoundEffects = true,
    this.enableVibration = true,
    this.maxConcurrentDownloads = 3,
    this.maxCacheSize = 1000,
  });

  /// 从JSON构造
  factory UserPreferences.fromJson(Map<String, dynamic> json) {
    return UserPreferences(
      themeMode: _parseThemeMode(json['themeMode']),
      autoDownload: json['autoDownload'] as bool? ?? false,
      showLyrics: json['showLyrics'] as bool? ?? true,
      showNotification: json['showNotification'] as bool? ?? true,
      defaultVolume: (json['defaultVolume'] as num?)?.toDouble() ?? 0.7,
      defaultSortOrder: _parseSortOrder(json['defaultSortOrder']),
      defaultViewMode: _parseViewMode(json['defaultViewMode']),
      lastSyncTime: json['lastSyncTime'] != null
          ? DateTime.parse(json['lastSyncTime'] as String)
          : null,
      libraryVersion: json['libraryVersion'] as int? ?? 0,
      autoCheckUpdate: json['autoCheckUpdate'] as bool? ?? true,
      defaultPlayMode: _parsePlayMode(json['defaultPlayMode']),
      autoDownloadOnWifi: json['autoDownloadOnWifi'] as bool? ?? true,
      enableSoundEffects: json['enableSoundEffects'] as bool? ?? true,
      enableVibration: json['enableVibration'] as bool? ?? true,
      maxConcurrentDownloads: json['maxConcurrentDownloads'] as int? ?? 3,
      maxCacheSize: json['maxCacheSize'] as int? ?? 1000,
    );
  }

  /// 转换为JSON
  Map<String, dynamic> toJson() {
    return {
      'themeMode': themeMode.index,
      'autoDownload': autoDownload,
      'showLyrics': showLyrics,
      'showNotification': showNotification,
      'defaultVolume': defaultVolume,
      'defaultSortOrder': defaultSortOrder.index,
      'defaultViewMode': defaultViewMode.index,
      'lastSyncTime': lastSyncTime?.toIso8601String(),
      'libraryVersion': libraryVersion,
      'autoCheckUpdate': autoCheckUpdate,
      'defaultPlayMode': defaultPlayMode.index,
      'autoDownloadOnWifi': autoDownloadOnWifi,
      'enableSoundEffects': enableSoundEffects,
      'enableVibration': enableVibration,
      'maxConcurrentDownloads': maxConcurrentDownloads,
      'maxCacheSize': maxCacheSize,
    };
  }

  /// 解析主题模式
  static AppThemeMode _parseThemeMode(dynamic value) {
    if (value == null) return AppThemeMode.system;
    if (value is int) {
      return AppThemeMode.values[value];
    }
    if (value is String) {
      return AppThemeMode.values.firstWhere(
        (e) => e.toString() == 'AppThemeMode.$value',
        orElse: () => AppThemeMode.system,
      );
    }
    return AppThemeMode.system;
  }

  /// 解析排序方式
  static SortOrder _parseSortOrder(dynamic value) {
    if (value == null) return SortOrder.byName;
    if (value is int) {
      return SortOrder.values[value];
    }
    if (value is String) {
      return SortOrder.values.firstWhere(
        (e) => e.toString() == 'SortOrder.$value',
        orElse: () => SortOrder.byName,
      );
    }
    return SortOrder.byName;
  }

  /// 解析视图模式
  static ViewMode _parseViewMode(dynamic value) {
    if (value == null) return ViewMode.list;
    if (value is int) {
      return ViewMode.values[value];
    }
    if (value is String) {
      return ViewMode.values.firstWhere(
        (e) => e.toString() == 'ViewMode.$value',
        orElse: () => ViewMode.list,
      );
    }
    return ViewMode.list;
  }

  /// 解析播放模式
  static PlayMode _parsePlayMode(dynamic value) {
    if (value == null) return PlayMode.sequential;
    if (value is int) {
      return PlayMode.values[value];
    }
    if (value is String) {
      return PlayMode.values.firstWhere(
        (e) => e.toString() == 'PlayMode.$value',
        orElse: () => PlayMode.sequential,
      );
    }
    return PlayMode.sequential;
  }

  /// 创建一个新的UserPreferences实例，但更新部分属性
  UserPreferences copyWith({
    AppThemeMode? themeMode,
    bool? autoDownload,
    bool? showLyrics,
    bool? showNotification,
    double? defaultVolume,
    SortOrder? defaultSortOrder,
    ViewMode? defaultViewMode,
    DateTime? lastSyncTime,
    int? libraryVersion,
    bool? autoCheckUpdate,
    PlayMode? defaultPlayMode,
    bool? autoDownloadOnWifi,
    bool? enableSoundEffects,
    bool? enableVibration,
    int? maxConcurrentDownloads,
    int? maxCacheSize,
  }) {
    return UserPreferences(
      themeMode: themeMode ?? this.themeMode,
      autoDownload: autoDownload ?? this.autoDownload,
      showLyrics: showLyrics ?? this.showLyrics,
      showNotification: showNotification ?? this.showNotification,
      defaultVolume: defaultVolume ?? this.defaultVolume,
      defaultSortOrder: defaultSortOrder ?? this.defaultSortOrder,
      defaultViewMode: defaultViewMode ?? this.defaultViewMode,
      lastSyncTime: lastSyncTime ?? this.lastSyncTime,
      libraryVersion: libraryVersion ?? this.libraryVersion,
      autoCheckUpdate: autoCheckUpdate ?? this.autoCheckUpdate,
      defaultPlayMode: defaultPlayMode ?? this.defaultPlayMode,
      autoDownloadOnWifi: autoDownloadOnWifi ?? this.autoDownloadOnWifi,
      enableSoundEffects: enableSoundEffects ?? this.enableSoundEffects,
      enableVibration: enableVibration ?? this.enableVibration,
      maxConcurrentDownloads: maxConcurrentDownloads ?? this.maxConcurrentDownloads,
      maxCacheSize: maxCacheSize ?? this.maxCacheSize,
    );
  }

  /// 获取默认偏好设置
  factory UserPreferences.defaultPreferences() {
    return const UserPreferences();
  }

  /// 实现Equatable所需的属性列表
  @override
  List<Object?> get props => [
    themeMode, autoDownload, showLyrics, showNotification, defaultVolume,
    defaultSortOrder, defaultViewMode, lastSyncTime, libraryVersion,
    autoCheckUpdate, defaultPlayMode, autoDownloadOnWifi, enableSoundEffects,
    enableVibration, maxConcurrentDownloads, maxCacheSize
  ];
}
