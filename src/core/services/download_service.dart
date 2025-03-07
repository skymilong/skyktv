import 'dart:io';
import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import '../utils/file_utils.dart';
import '../constants/app_constants.dart';
import '../constants/enum_types.dart';

/// 下载服务
/// 
/// 管理歌曲文件的下载和取消
class DownloadService {
  // 单例实例
  static final DownloadService _instance = DownloadService._internal();
  
  // 工厂构造函数
  factory DownloadService() => _instance;
  
  // 私有构造函数
  DownloadService._internal() {
    _init();
  }
  
  // Dio实例，用于网络请求
  final Dio _dio = Dio();
  
  // 当前下载任务映射表，键为歌曲ID，值为取消令牌
  final Map<String, CancelToken> _downloadTasks = {};
  
  // 下载进度回调映射表
  final Map<String, Function(double)> _progressCallbacks = {};
  
  // 下载状态映射表
  final Map<String, DownloadStatus> _downloadStatus = {};
  
  // 初始化
  void _init() {
    _dio.options.connectTimeout = Duration(milliseconds: AppConstants.kConnectionTimeout);
    _dio.options.receiveTimeout = Duration(milliseconds: AppConstants.kReceiveTimeout);
    _dio.options.sendTimeout = Duration(milliseconds: AppConstants.kConnectionTimeout);
  }
  
  /// 获取歌曲的下载状态
  /// 
  /// [songId] 歌曲ID
  /// 
  /// 返回歌曲的下载状态
  DownloadStatus getDownloadStatus(String songId) {
    return _downloadStatus[songId] ?? DownloadStatus.notDownloaded;
  }
  
  /// 检查歌曲是否已下载
  /// 
  /// [songId] 歌曲ID
  /// [extension] 文件扩展名，默认为mp3
  /// 
  /// 返回歌曲是否已下载
  Future<bool> isSongDownloaded(String songId, {String extension = 'mp3'}) async {
    final filePath = await FileUtils.getSongFilePath(songId, extension: extension);
    return await FileUtils.fileExists(filePath);
  }
  
  /// 下载歌曲
  /// 
  /// [songId] 歌曲ID
  /// [url] 下载URL
  /// [onProgress] 下载进度回调
  /// [onComplete] 下载完成回调
  /// [onError] 下载错误回调
  /// [extension] 文件扩展名，默认为mp3
  /// 
  /// 返回是否成功启动下载
  Future<bool> downloadSong({
    required String songId,
    required String url,
    Function(double)? onProgress,
    Function(String)? onComplete,
    Function(String)? onError,
    String extension = 'mp3',
  }) async {
    // 检查是否已经在下载
    if (_downloadTasks.containsKey(songId)) {
      return false;
    }
    
    try {
      // 更新状态
      _downloadStatus[songId] = DownloadStatus.pending;
      
      // 获取文件路径
      final filePath = await FileUtils.getSongFilePath(songId, extension: extension);
      
      // 创建取消令牌
      final cancelToken = CancelToken();
      _downloadTasks[songId] = cancelToken;
      
      // 保存进度回调
      if (onProgress != null) {
        _progressCallbacks[songId] = onProgress;
      }
      
      // 更新状态
      _downloadStatus[songId] = DownloadStatus.downloading;
      
      // 开始下载
      await _dio.download(
        url,
        filePath,
        onReceiveProgress: (received, total) {
          if (total != -1) {
            final progress = received / total;
            _progressCallbacks[songId]?.call(progress);
          }
        },
        cancelToken: cancelToken,
      );
      
      // 下载完成
      _downloadStatus[songId] = DownloadStatus.downloaded;
      _cleanupDownload(songId);
      onComplete?.call(filePath);
      
      return true;
    } catch (e) {
      debugPrint('Download error for song $songId: $e');
      
      // 如果不是因为取消导致的错误，则更新状态为失败
      if (e is! DioException || e.type != DioExceptionType.cancel) {
        _downloadStatus[songId] = DownloadStatus.failed;
      }
      
      _cleanupDownload(songId);
      onError?.call(e.toString());
      
      return false;
    }
  }
  
  /// 下载歌词
  /// 
  /// [songId] 歌曲ID
  /// [url] 下载URL
  /// 
  /// 返回是否成功下载
  Future<bool> downloadLyrics(String songId, String url) async {
    try {
      final filePath = await FileUtils.getLyricsFilePath(songId);
      
      final response = await _dio.get(
        url,
        options: Options(responseType: ResponseType.plain),
      );
      
      if (response.statusCode == 200) {
        final file = File(filePath);
        await file.writeAsString(response.data);
        return true;
      }
      
      return false;
    } catch (e) {
      debugPrint('Error downloading lyrics for song $songId: $e');
      return false;
    }
  }
  
  /// 取消下载
  /// 
  /// [songId] 歌曲ID
  /// 
  /// 返回是否成功取消
  bool cancelDownload(String songId) {
    if (_downloadTasks.containsKey(songId)) {
      _downloadTasks[songId]?.cancel('User cancelled download');
      _downloadStatus[songId] = DownloadStatus.notDownloaded;
      _cleanupDownload(songId);
      return true;
    }
    return false;
  }
  
  /// 清理下载任务
  /// 
  /// [songId] 歌曲ID
  void _cleanupDownload(String songId) {
    _downloadTasks.remove(songId);
    _progressCallbacks.remove(songId);
  }
  
  /// 删除已下载的歌曲
  /// 
  /// [songId] 歌曲ID
  /// [extension] 文件扩展名，默认为mp3
  /// 
  /// 返回是否成功删除
  Future<bool> deleteSong(String songId, {String extension = 'mp3'}) async {
    try {
      // 取消正在进行的下载
      cancelDownload(songId);
      
      // 删除歌曲文件
      final filePath = await FileUtils.getSongFilePath(songId, extension: extension);
      final deleted = await FileUtils.deleteFile(filePath);
      
      // 删除歌词文件
      final lyricsPath = await FileUtils.getLyricsFilePath(songId);
      await FileUtils.deleteFile(lyricsPath);
      
      // 更新状态
      if (deleted) {
        _downloadStatus[songId] = DownloadStatus.notDownloaded;
      }
      
      return deleted;
    } catch (e) {
      debugPrint('Error deleting song $songId: $e');
      return false;
    }
  }
  
  /// 清空所有下载
  /// 
  /// 返回是否成功清空
  Future<bool> clearAllDownloads() async {
    try {
      // 取消所有正在进行的下载
      for (final songId in _downloadTasks.keys.toList()) {
        cancelDownload(songId);
      }
      
      // 清空歌曲目录
      final songsDir = await FileUtils.getSongsDirectory();
      final cleared = await FileUtils.clearDirectory(songsDir.path);
      
      // 清空歌词目录
      final lyricsDir = await FileUtils.getLyricsDirectory();
      await FileUtils.clearDirectory(lyricsDir.path);
      
      // 清空状态
      _downloadStatus.clear();
      
      return cleared;
    } catch (e) {
      debugPrint('Error clearing all downloads: $e');
      return false;
    }
  }
  
  /// 获取下载目录大小
  /// 
  /// 返回下载目录大小（字节）
  Future<int> getDownloadSize() async {
    try {
      final songsDir = await FileUtils.getSongsDirectory();
      final lyricsDir = await FileUtils.getLyricsDirectory();
      
      final songsSize = await FileUtils.getDirectorySize(songsDir.path);
      final lyricsSize = await FileUtils.getDirectorySize(lyricsDir.path);
      
      return songsSize + lyricsSize;
    } catch (e) {
      debugPrint('Error getting download size: $e');
      return 0;
    }
  }
  
  /// 获取格式化的下载大小
  /// 
  /// 返回格式化的下载大小字符串
  Future<String> getFormattedDownloadSize() async {
    final size = await getDownloadSize();
    return FileUtils.formatFileSize(size);
  }
}
