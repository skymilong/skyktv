class Song {
  final String id;
  final String title;
  final String artist;
  final String? coverUrl;
  final String? audioUrl;
  final String? videoUrl;
  final String? lyricsUrl;
  final bool hasVideo;
  final String? quality;

  Song({
    required this.id,
    required this.title,
    required this.artist,
    this.coverUrl,
    this.audioUrl,
    this.videoUrl,
    this.lyricsUrl,
    this.hasVideo = false,
    this.quality,
  });

  factory Song.fromJson(Map<String, dynamic> json) {
    return Song(
      id: json['id'] as String,
      title: json['title'] as String,
      artist: json['artist'] as String,
      coverUrl: json['coverUrl'] as String?,
      audioUrl: json['audioUrl'] as String?,
      videoUrl: json['videoUrl'] as String?,
      lyricsUrl: json['lyricsUrl'] as String?,
      hasVideo: json['hasVideo'] as bool? ?? false,
      quality: json['quality'] as String?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'artist': artist,
      'coverUrl': coverUrl,
      'audioUrl': audioUrl,
      'videoUrl': videoUrl,
      'lyricsUrl': lyricsUrl,
      'hasVideo': hasVideo,
      'quality': quality,
    };
  }
} 