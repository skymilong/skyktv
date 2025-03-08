/// 枚举类型定义
/// 
/// 定义应用中使用的各种枚举类型

/// 下载状态
enum DownloadStatus {
  /// 未下载
  notDownloaded,
  
  /// 等待下载
  pending,
  
  /// 正在下载
  downloading,
  
  /// 已下载
  downloaded,
  
  /// 下载失败
  failed,
}

/// 播放状态
enum PlaybackStatus {
  none,      // 未开始播放
  loading,   // 加载中
  playing,   // 播放中
  paused,    // 暂停
  stopped,   // 停止
  error,     // 错误
}

/// 播放模式
enum PlayMode {
  /// 顺序播放
  sequence,
  
  /// 单曲循环
  repeat,
  
  /// 列表循环
  repeatAll,
  
  /// 随机播放
  shuffle,
}

/// 歌曲类型
enum SongType {
  /// 本地歌曲
  local,
  
  /// 在线歌曲
  online,
  
  /// 收藏歌曲
  favorite,
}

/// 音频模式
enum AudioMode {
  /// 原唱模式
  original,
  
  /// 伴奏模式（卡拉OK）
  karaoke
}

/// 同步状态
enum SyncStatus {
  /// 未同步
  notSynced,
  
  /// 正在检查更新
  checking,
  
  /// 正在同步
  syncing,
  
  /// 同步完成
  completed,
  
  /// 同步失败
  failed,
  
  /// 已是最新
  upToDate
}

/// 排序方式
enum SortType {
  /// 按名称升序
  nameAsc,
  
  /// 按名称降序
  nameDesc,
  
  /// 按时间升序
  timeAsc,
  
  /// 按时间降序
  timeDesc,
  
  /// 自定义排序
  custom,
}


/// 主题模式
enum AppThemeMode {
  /// 系统默认
  system,
  
  /// 亮色主题
  light,
  
  /// 暗色主题
  dark
}

/// 搜索范围
enum SearchScope {
  /// 所有字段
  all,
  
  /// 仅歌曲名
  title,
  
  /// 仅艺术家
  artist,
  
  /// 仅专辑
  album
}

/// 媒体类型
enum MediaType {
  audio,     // 音频
  video,     // 视频
  karaoke,   // 卡拉OK
}

/// 播放质量
enum PlayQuality {
  auto,      // 自动
  low,       // 低质量 (480p)
  medium,    // 中等质量 (720p)
  high,      // 高质量 (1080p)
}

/// 播放列表类型
enum PlaylistType {
  normal,    // 普通播放列表
  favorite,  // 收藏列表
  history,   // 播放历史
  custom,    // 自定义列表
}

/// 音频通道
enum AudioChannel {
  stereo,    // 立体声
  left,      // 左声道
  right,     // 右声道
  vocal,     // 人声
  music,     // 音乐
}

/// 歌词类型
enum LyricType {
  lrc,       // LRC格式
  krc,       // KRC格式（卡拉OK）
  srt,       // SRT格式（字幕）
  none,      // 无歌词
}

/// 缓存策略
enum CacheStrategy {
  none,          // 不缓存
  memory,        // 内存缓存
  disk,          // 磁盘缓存
  both,          // 内存和磁盘缓存
}

/// 网络类型
enum NetworkType {
  none,          // 无网络
  wifi,          // WiFi
  mobile,        // 移动网络
  ethernet,      // 有线网络
  other,         // 其他
}

/// 屏幕方向
enum ScreenOrientation {
  auto,          // 自动
  portrait,      // 竖屏
  landscape,     // 横屏
  system,        // 跟随系统
}

/// 主题模式
enum ThemeMode {
  light,         // 亮色主题
  dark,          // 暗色主题
  system,        // 跟随系统
}

/// 音频效果
enum AudioEffect {
  none,          // 无效果
  echo,          // 回声
  reverb,        // 混响
  equalizer,     // 均衡器
  pitch,         // 音调
}

/// 视频效果
enum VideoEffect {
  none,          // 无效果
  brightness,    // 亮度
  contrast,      // 对比度
  saturation,    // 饱和度
  blur,          // 模糊
}

/// 建议的枚举定义
enum SortOrder {
  byName,    // 按名称升序
  byNameDesc,   // 按名称降序
  byAddedDate,    // 按日期升序
  byAddedDateDesc,   // 按日期降序
  byPopularity, // 按欢迎度
  byArtist, // 按艺术家
  custom      // 自定义排序
}

enum ViewMode {
  list,       // 列表视图
  grid,       // 网格视图
  card        // 卡片视图
}
