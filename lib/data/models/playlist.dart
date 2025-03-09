import 'package:equatable/equatable.dart';
import '../../core/constants/enum_types.dart';
import 'song.dart';

/// 播放列表模型类
/// 
/// 表示用户创建的歌曲播放列表
class Playlist extends Equatable {
  /// 唯一标识符
  String id;
  
  /// 播放列表名称
  String name;
  
  /// 播放列表描述
  String description;
  
  /// 创建日期
  DateTime createdAt;
  
  /// 最后修改日期
  DateTime updatedAt;
  
  /// 播放列表中的歌曲ID列表
  List<String> songIds;
  
  /// 播放列表封面图片URL
  String? coverUrl;
  
  /// 是否为系统默认播放列表
  bool isSystem;

  /// 构造函数
  Playlist({
    required this.id,
    required this.name,
    this.description = '',
    required this.createdAt,
    required this.updatedAt,
    this.songIds = const [],
    this.coverUrl,
    this.isSystem = false,
  });

  /// 从JSON构造
  factory Playlist.fromJson(Map<String, dynamic> json) {
    return Playlist(
      id: json['id'] as String,
      name: json['name'] as String,
      description: json['description'] as String? ?? '',
      createdAt: DateTime.parse(json['createdAt'] as String),
      updatedAt: DateTime.parse(json['updatedAt'] as String),
      songIds: (json['songIds'] as List?)?.map((e) => e as String).toList() ?? [],
      coverUrl: json['coverUrl'] as String?,
      isSystem: json['isSystem'] as bool? ?? false,
    );
  }

  /// 转换为JSON
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'description': description,
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt.toIso8601String(),
      'songIds': songIds,
      'coverUrl': coverUrl,
      'isSystem': isSystem,
    };
  }

  /// 创建一个新的Playlist实例，但更新部分属性
  Playlist copyWith({
    String? id,
    String? name,
    String? description,
    DateTime? createdAt,
    DateTime? updatedAt,
    List<String>? songIds,
    String? coverUrl,
    bool? isSystem,
  }) {
    return Playlist(
      id: id ?? this.id,
      name: name ?? this.name,
      description: description ?? this.description,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      songIds: songIds ?? this.songIds,
      coverUrl: coverUrl ?? this.coverUrl,
      isSystem: isSystem ?? this.isSystem,
    );
  }

  /// 添加歌曲到播放列表
  Playlist addSong(String songId) {
    if (songIds.contains(songId)) {
      return this;
    }
    
    final newSongIds = List<String>.from(songIds)..add(songId);
    return copyWith(
      songIds: newSongIds,
      updatedAt: DateTime.now(),
    );
  }

  /// 从播放列表中移除歌曲
  Playlist removeSong(String songId, MediaType type) {
    if (!songIds.contains(songId)) {
      return this;
    }
    
    final newSongIds = List<String>.from(songIds)..remove(songId);
    return copyWith(
      songIds: newSongIds,
      updatedAt: DateTime.now(),
    );
  }

  /// 清空播放列表
  Playlist clearSongs() {
    return copyWith(
      songIds: [],
      updatedAt: DateTime.now(),
    );
  }

  /// 获取播放列表中的歌曲数量
  int get songCount => songIds.length;

  /// 检查播放列表是否为空
  bool get isEmpty => songIds.isEmpty;

  /// 检查播放列表是否包含指定歌曲
  bool containsSong(String songId) => songIds.contains(songId);

  /// 实现Equatable所需的属性列表
  @override
  List<Object?> get props => [
    id, name, description, createdAt, updatedAt, songIds, coverUrl, isSystem
  ];

  /// 创建一个空的播放列表
  factory Playlist.empty() {
    final now = DateTime.now();
    return Playlist(
      id: 'temp_${now.millisecondsSinceEpoch}',
      name: '新建播放列表',
      createdAt: now,
      updatedAt: now,
    );
  }

  /// 创建一个系统默认的"我喜欢"播放列表
  factory Playlist.favorites() {
    final now = DateTime.now();
    return Playlist(
      id: 'system_favorites',
      name: '我的收藏',
      description: '我收藏的歌曲',
      createdAt: now,
      updatedAt: now,
      isSystem: true,
    );
  }

  /// 创建一个系统默认的"最近播放"播放列表
  factory Playlist.recentlyPlayed() {
    final now = DateTime.now();
    return Playlist(
      id: 'system_recently_played',
      name: '最近播放',
      description: '最近播放的歌曲',
      createdAt: now,
      updatedAt: now,
      isSystem: true,
    );
  }
}
