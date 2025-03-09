import 'dart:io';
import 'dart:math';
import 'package:path_provider/path_provider.dart';
import 'package:path/path.dart' as path;
import 'package:crypto/crypto.dart' as crypto;
import 'dart:convert';
import '../constants/app_constants.dart';
import '../constants/enum_types.dart';

/// 文件工具类
class FileUtils {
  /// 获取应用文档目录
  static Future<Directory> getAppDirectory() async {
    final appDir = await getApplicationDocumentsDirectory();
    return appDir;
  }

  /// 获取缓存目录
  static Future<Directory> getCacheDirectory() async {
    final cacheDir = await getTemporaryDirectory();
    return cacheDir;
  }

  /// 获取媒体目录
  static Future<Directory> getMediaDirectory(MediaType type) async {
    final appDir = await getAppDirectory();
    final mediaDir = Directory(path.join(appDir.path, type.name));
    if (!await mediaDir.exists()) {
      await mediaDir.create(recursive: true);
    }
    return mediaDir;
  }

  /// 获取歌词目录
  static Future<Directory> getLyricsDirectory() async {
    final appDir = await getAppDirectory();
    final lyricsDir = Directory(path.join(appDir.path, 'lyrics'));
    if (!await lyricsDir.exists()) {
      await lyricsDir.create(recursive: true);
    }
    return lyricsDir;
  }

  /// 获取封面图片目录
  static Future<Directory> getCoverDirectory() async {
    final appDir = await getAppDirectory();
    final coverDir = Directory(path.join(appDir.path, 'covers'));
    if (!await coverDir.exists()) {
      await coverDir.create(recursive: true);
    }
    return coverDir;
  }

  /// 获取媒体文件路径
  static Future<String> getMediaFilePath(String id, MediaType type, {String? extension}) async {
    final mediaDir = await getMediaDirectory(type);
    final ext = extension ?? _getDefaultExtension(type);
    return path.join(mediaDir.path, '$id.$ext');
  }

  /// 获取歌词文件路径
  static Future<String> getLyricFilePath(String id, {LyricType type = LyricType.lrc}) async {
    final lyricsDir = await getLyricsDirectory();
    return path.join(lyricsDir.path, '$id.${type.name}');
  }

  /// 获取封面文件路径
  static Future<String> getCoverFilePath(String id) async {
    final coverDir = await getCoverDirectory();
    return path.join(coverDir.path, '$id.jpg');
  }

  /// 检查文件是否存在
  static Future<bool> exists(String filePath) async {
    return await File(filePath).exists();
  }

  /// 删除文件
  static Future<bool> delete(String filePath) async {
    try {
      final file = File(filePath);
      if (await file.exists()) {
        await file.delete();
        return true;
      }
      return false;
    } catch (e) {
      return false;
    }
  }

  /// 清空目录
  static Future<bool> clearDirectory(String dirPath) async {
    try {
      final dir = Directory(dirPath);
      if (await dir.exists()) {
        await dir.delete(recursive: true);
        await dir.create(recursive: true);
        return true;
      }
      return false;
    } catch (e) {
      return false;
    }
  }

  /// 获取文件大小
  static Future<int> getFileSize(String filePath) async {
    try {
      final file = File(filePath);
      if (await file.exists()) {
        return await file.length();
      }
      return 0;
    } catch (e) {
      return 0;
    }
  }

  /// 获取目录大小
  static Future<int> getDirectorySize(String dirPath) async {
    var totalSize = 0;
    try {
      final dir = Directory(dirPath);
      if (await dir.exists()) {
        await for (final entity in dir.list(recursive: true)) {
          if (entity is File) {
            totalSize += await entity.length();
          }
        }
      }
    } catch (e) {
      // 忽略错误
    }
    return totalSize;
  }

  /// 格式化文件大小
  static String formatFileSize(int bytes) {
    if (bytes <= 0) return '0 B';
    const suffixes = ['B', 'KB', 'MB', 'GB', 'TB'];
    var i = (log(bytes) / log(1024)).floor();
    return '${(bytes / pow(1024, i)).toStringAsFixed(2)} ${suffixes[i]}';
  }

  /// 计算文件的MD5
  static Future<String> calculateMD5(String filePath) async {
    try {
      final file = File(filePath);
      if (await file.exists()) {
        final bytes = await file.readAsBytes();
        final digest = crypto.md5.convert(bytes);
        return digest.toString();
      }
      return '';
    } catch (e) {
      return '';
    }
  }

  /// 获取文件扩展名
  static String getExtension(String filePath) {
    return path.extension(filePath).toLowerCase().replaceAll('.', '');
  }

  /// 获取默认扩展名
  static String _getDefaultExtension(MediaType type) {
    switch (type) {
      case MediaType.audio:
        return 'mp3';
      case MediaType.video:
        return 'mp4';
      case MediaType.karaoke:
        return 'mkv';
    }
  }

  /// 生成缓存键
  static String generateCacheKey(String url) {
    return crypto.md5.convert(utf8.encode(url)).toString();
  }

  /// 检查缓存是否过期
  static bool isCacheExpired(File file, Duration maxAge) {
    return DateTime.now().difference(file.lastModifiedSync()) > maxAge;
  }

  /// 清理过期缓存
  static Future<void> cleanExpiredCache(String dirPath, Duration maxAge) async {
    try {
      final dir = Directory(dirPath);
      if (await dir.exists()) {
        await for (final entity in dir.list(recursive: true)) {
          if (entity is File && isCacheExpired(entity, maxAge)) {
            await entity.delete();
          }
        }
      }
    } catch (e) {
      // 忽略错误
    }
  }
}
