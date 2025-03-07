// lib/data/models/song.dart
class Song {
  final String id;
  final String title;
  final String artist;
  final String album;
  final String pinyin;
  final String pinyinFirst;
  final int duration;
  final String coverUrl;
  final String songUrl;
  final bool hasAccompaniment;
  final DateTime addedDate;
  final Map<String, dynamic> extraInfo;
  bool isDownloaded;
  String? localPath;
  
  Song({
    required this.id,
    required this.title,
    required this.artist,
    required this.album,
    required this.pinyin,
    required this.pinyinFirst,
    required this.duration,
    required this.coverUrl,
    required this.songUrl,
    this.hasAccompaniment = false,
    required this.addedDate,
    this.extraInfo = const {},
    this.isDownloaded = false,
    this.localPath,
  });
  
  factory Song.fromJson(Map<String, dynamic> json) {
    return Song(
      id: json['id'],
      title: json['title'],
      artist: json['artist'],
      album: json['album'],
      pinyin: json['pinyin'],
      pinyinFirst: json['pinyinFirst'],
      duration: json['duration'],
      coverUrl: json['coverUrl'],
      songUrl: json['songUrl'],
      hasAccompaniment: json['hasAccompaniment'] ?? false,
      addedDate: DateTime.parse(json['addedDate']),
      extraInfo: json['extraInfo'] ?? {},
      isDownloaded: json['isDownloaded'] ?? false,
      localPath: json['localPath'],
    );
  }
  
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'artist': artist,
      'album': album,
      'pinyin': pinyin,
      'pinyinFirst': pinyinFirst,
      'duration': duration,
      'coverUrl': coverUrl,
      'songUrl': songUrl,
      'hasAccompaniment': hasAccompaniment,
      'addedDate': addedDate.toIso8601String(),
      'extraInfo': extraInfo,
      'isDownloaded': isDownloaded,
      'localPath': localPath,
    };
  }
}
