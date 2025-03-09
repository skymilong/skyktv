// lib/data/models/song.dart
import 'package:equatable/equatable.dart';

import '../../core/constants/enum_types.dart';

class Song extends Equatable {
  final String id;
  String title;
  String artist;
  String pinyin;
  String pinyinFirst;
  String album;
  String? coverUrl;
  String? songUrl;
  String? localPath;
  bool isDownloaded;
  bool isFavorite;
  DownloadStatus downloadStatus;
  DateTime addedTime;
  DateTime? favoriteTime;
  int playCount;
  Duration? duration;
  SongType type;
  String? quality;
  Set<String> categories;
  int popularity;

  Song({
    required this.id,
    required this.title,
    required this.artist,
    required this.categories,
    required this.pinyin,
    required this.pinyinFirst,
    required this.album,
    this.coverUrl,
    this.songUrl,
    this.localPath,
    this.isDownloaded = false,
    this.isFavorite = false,
    this.downloadStatus = DownloadStatus.notDownloaded,
    DateTime? addedTime,
    DateTime? favoriteTime,
    this.playCount = 0,
    this.duration,
    this.type = SongType.online,
    this.quality,
    this.popularity = 0,
  }) : addedTime = addedTime ?? DateTime.now();

  /// 创建一个新的Song实例，但更新部分属性
  Song copyWith({
    String? id,
    String? title,
    String? artist,
    String? album,
    String? pinyin,
    String? pinyinFirst,
    String? coverUrl,
    String? songUrl,
    String? localPath,
    bool? isDownloaded,
    bool? isFavorite,
    DownloadStatus? downloadStatus,
    DateTime? addedTime,
    DateTime? favoriteTime,
    int? playCount,
    Duration? duration,
    SongType? type,
    String? quality,
    Set? categories,
    popularity,
  }) {
    return Song(
      id: id ?? this.id,
      title: title ?? this.title,
      artist: artist ?? this.artist,
      album: album ?? this.album,
      pinyin: pinyin ?? this.pinyin,
      pinyinFirst: pinyinFirst ?? this.pinyinFirst,
      coverUrl: coverUrl ?? this.coverUrl,
      songUrl: songUrl ?? this.songUrl,
      localPath: localPath ?? this.localPath,
      isDownloaded: isDownloaded ?? this.isDownloaded,
      isFavorite: isFavorite ?? this.isFavorite,
      downloadStatus: downloadStatus ?? this.downloadStatus,
      addedTime: addedTime ?? this.addedTime,
      favoriteTime: favoriteTime ?? this.favoriteTime,
      playCount: playCount ?? this.playCount,
      duration: duration ?? this.duration,
      type: type ?? this.type,
      quality: quality ?? this.quality,
      categories: this.categories,
      popularity: popularity ?? this.popularity,
    );
  }

  @override
  List<Object?> get props => [
    id, 
    title, 
    artist, 
    album, 
    coverUrl, 
    songUrl,
    localPath,
    isDownloaded,
    isFavorite,
    downloadStatus,
    addedTime,
    favoriteTime,
    playCount,
    duration,
    type,
    quality,
    categories,
    popularity,
  ];

  /// 从JSON创建Song实例
  factory Song.fromJson(Map<String, dynamic> json) {
    return Song(
      id: json['id'] as String,
      title: json['title'] as String,
      artist: json['artist'] as String,
      album: json['album'] as String,
      pinyin: json['pinyin'] as String,
      pinyinFirst: json['pinyinFirst'] as String,
      coverUrl: json['coverUrl'] as String?,
      songUrl: json['songUrl'] as String?,
      localPath: json['localPath'] as String?,
      isDownloaded: json['isDownloaded'] as bool? ?? false,
      isFavorite: json['isFavorite'] as bool? ?? false,
      downloadStatus: DownloadStatus.values[json['downloadStatus'] as int? ?? 0],
      addedTime: json['addedTime'] != null 
          ? DateTime.parse(json['addedTime'] as String)
          : null,
      playCount: json['playCount'] as int? ?? 0,
      duration: json['duration'] != null 
          ? Duration(milliseconds: json['duration'] as int)
          : null,
      type: SongType.values[json['type'] as int? ?? 0],
      quality: json['quality'] as String?,
      categories: (json['categories'] as List<dynamic>?)
          ?.cast<String>()
          .toSet() ?? <String>{} ,
      popularity: json['popularity'] as int? ?? 0,
    );
  }

  /// 转换为JSON
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'artist': artist,
      'album': album,
      'pinyin': pinyin,
      'pinyinFirst': pinyinFirst,
      'coverUrl': coverUrl,
      'songUrl': songUrl,
      'localPath': localPath,
      'isDownloaded': isDownloaded,
      'isFavorite': isFavorite,
      'downloadStatus': downloadStatus.index,
      'addedTime': addedTime.toIso8601String(),
      'favoriteTime': favoriteTime?.toIso8601String(),
      'playCount': playCount,
      'duration': duration?.inMilliseconds,
      'type': type.index,
      'quality': quality,
      'categories': categories.toSet(),
      'popularity': popularity,

    };
  }
}
