import 'dart:io';
import 'package:flutter/foundation.dart';
import '../utils/file_utils.dart';
import 'storage_service.dart';
import '../../features/player/models/lyric.dart';
import 'package:dio/dio.dart';

class LyricsService {
  static final LyricsService _instance = LyricsService._internal();
  factory LyricsService() => _instance;

  final StorageService _storage = StorageService();
  final Dio _dio = Dio();
  final Map<String, Lyrics> _cache = {};

  LyricsService._internal();

  /// 加载歌词
  Future<Lyrics?> loadLyrics(String songId, {String? url}) async {
    try {
      // 1. 首先检查内存缓存
      if (_cache.containsKey(songId)) {
        return _cache[songId];
      }

      // 2. 检查本地文件
      final lyricsPath = await FileUtils.getLyricFilePath(songId);
      if (await FileUtils.exists(lyricsPath)) {
        final content = await File(lyricsPath).readAsString();
        final lyrics = Lyrics.fromLrcContent(content);
        _cache[songId] = lyrics;
        return lyrics;
      }

      // 3. 如果提供了URL，从网络下载
      if (url != null) {
        final response = await _dio.get(url);
        if (response.statusCode == 200) {
          final content = response.data.toString();
          // 保存到本地
          await File(lyricsPath).writeAsString(content);
          // 解析并缓存
          final lyrics = Lyrics.fromLrcContent(content);
          _cache[songId] = lyrics;
          return lyrics;
        }
      }

      return null;
    } catch (e) {
      debugPrint('Error loading lyrics: $e');
      return null;
    }
  }

  /// 清除歌词缓存
  void clearCache() {
    _cache.clear();
  }

  /// 从缓存中移除指定歌词
  void removeFromCache(String songId) {
    _cache.remove(songId);
  }
} 