/// 应用常量
/// 
/// 定义应用中使用的各种常量值
class AppConstants {
  // 私有构造函数，防止实例化
  AppConstants._();
  
  // 应用信息
  static const String appName = 'KTV点歌系统';
  static const String appVersion = '1.0.0';
  
  // 本地存储键
  static const String kSongsBoxName = 'songs';
  static const String kSettingsBoxName = 'settings';
  static const String kPlaylistsBoxName = 'playlists';
  static const String kFavoritesBoxName = 'favorites';
  
  // 设置键
  static const String kLastSyncTimeKey = 'last_sync_time';
  static const String kLibraryVersionKey = 'library_version';
  static const String kThemeModeKey = 'theme_mode';
  static const String kAutoDownloadKey = 'auto_download';
  
  // 文件路径
  static const String kSongsDirectory = 'songs';
  static const String kLyricsDirectory = 'lyrics';
  static const String kCacheDirectory = 'cache';
  
  // 分页加载
  static const int kPageSize = 20;
  
  // 超时设置（毫秒）
  static const int kConnectionTimeout = 30000; // 30秒
  static const int kReceiveTimeout = 30000;    // 30秒
  
  // 播放器设置
  static const String kDefaultVolume = 'default_volume';
  static const String kAutoPlay = 'auto_play';
  static const String kRepeatMode = 'repeat_mode';
  static const String kShuffleMode = 'shuffle_mode';
  
  // UI常量
  static const double kDefaultPadding = 16.0;
  static const double kDefaultMargin = 16.0;
  static const double kDefaultRadius = 12.0;
  static const double kDefaultIconSize = 24.0;
  static const double kSmallIconSize = 18.0;
  static const double kLargeIconSize = 36.0;
  
  // 动画时长
  static const Duration kShortAnimationDuration = Duration(milliseconds: 200);
  static const Duration kDefaultAnimationDuration = Duration(milliseconds: 300);
  static const Duration kLongAnimationDuration = Duration(milliseconds: 500);
  
  // 分类标签
  static const List<String> kMusicCategories = [
    '全部',
    '流行',
    '摇滚',
    '民谣',
    '电子',
    '嘻哈',
    '古风',
    '影视',
    '儿童',
    '舞曲',
  ];
  
  // 拼音字母表（用于索引）
  static const List<String> kPinyinLetters = [
    'A', 'B', 'C', 'D', 'E', 'F', 'G', 
    'H', 'I', 'J', 'K', 'L', 'M', 'N', 
    'O', 'P', 'Q', 'R', 'S', 'T', 
    'U', 'V', 'W', 'X', 'Y', 'Z', '#'
  ];
  
  // 错误消息
  static const String kErrorGeneric = '发生错误，请稍后重试';
  static const String kErrorNoInternet = '无法连接到网络，请检查网络设置';
  static const String kErrorTimeout = '连接超时，请稍后重试';
  static const String kErrorNoSongs = '没有找到歌曲';
  static const String kErrorDownload = '下载失败，请重试';
  static const String kErrorPlayback = '播放失败，请尝试重新下载歌曲';
  
  // 提示消息
  static const String kSuccessDownload = '下载完成';
  static const String kSuccessSync = '同步完成';
  static const String kInfoDownloading = '正在下载...';
  static const String kInfoSyncing = '正在同步...';

  // 主题设置
  static const String kThemeMode = 'theme_mode';
  static const String kAccentColor = 'accent_color';

  // 缓存设置
  static const int kMaxCacheSize = 100 * 1024 * 1024; // 100MB
  static const Duration kCacheExpiration = Duration(days: 7);
}
