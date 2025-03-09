/// API端点常量
/// 
/// 定义应用中使用的所有API端点
class ApiEndpoints {
  // 私有构造函数，防止实例化
  ApiEndpoints._();
  
  // 基础URL
  // 注意：在实际应用中，应该根据环境（开发、测试、生产）来设置不同的基础URL
  static const String baseUrl = 'https://api.ktvapp.example.com';
  
  // 静态资源URL
  static const String staticBaseUrl = 'https://static.ktvapp.example.com';
  
  // 曲库API
  static const String libraryInfo = '$baseUrl/api/song-library-info.json';
  static const String fullLibrary = '$baseUrl/api/song-library-full.json';
  static const String incrementalUpdates = '$baseUrl/api/song-library-updates';
  
  // 获取特定更新的URL
  static String getUpdateUrl(String updateId) {
    return '$incrementalUpdates/$updateId.json';
  }
  
  // 歌曲资源
  static const String songsBaseUrl = '$staticBaseUrl/songs';
  
  // 获取歌曲文件URL
  static String getSongFileUrl(String songId) {
    return '$songsBaseUrl/$songId.mp3';
  }
  
  // 获取歌曲MV URL
  static String getSongVideoUrl(String songId) {
    return '$songsBaseUrl/$songId.mp4';
  }
  
  // 获取歌词URL
  static String getLyricsUrl(String songId) {
    return '$songsBaseUrl/lyrics/$songId.lrc';
  }
  
  // 获取歌曲封面URL
  static String getCoverUrl(String songId) {
    return '$songsBaseUrl/covers/$songId.jpg';
  }
  
  // 用于测试的本地静态文件URL（用于开发环境）
  static const String localLibraryInfo = 'assets/data/song-library-info.json';
  static const String localFullLibrary = 'assets/data/song-library-full.json';
  
  // 是否使用本地测试数据（在开发环境中设置为true）
  static const bool useLocalData = false;
  
  // 获取实际使用的库信息URL（根据环境选择本地或远程）
  static String get effectiveLibraryInfoUrl {
    return useLocalData ? localLibraryInfo : libraryInfo;
  }
  
  // 获取实际使用的完整库URL（根据环境选择本地或远程）
  static String get effectiveFullLibraryUrl {
    return useLocalData ? localFullLibrary : fullLibrary;
  }
}
