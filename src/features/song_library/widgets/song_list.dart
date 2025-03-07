import 'package:flutter/material.dart';
import '../../../core/models/song.dart';

class SongList extends StatelessWidget {
  final List<Song> songs;
  final Function(Song)? onSongTap;

  const SongList({
    Key? key,
    required this.songs,
    this.onSongTap,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      itemCount: songs.length,
      itemBuilder: (context, index) {
        final song = songs[index];
        return ListTile(
          leading: song.coverUrl != null
              ? Image.network(
                  song.coverUrl!,
                  width: 50,
                  height: 50,
                  fit: BoxFit.cover,
                  errorBuilder: (context, error, stackTrace) =>
                      const Icon(Icons.music_note),
                )
              : const Icon(Icons.music_note),
          title: Text(song.title),
          subtitle: Text(song.artist),
          onTap: onSongTap != null ? () => onSongTap!(song) : null,
        );
      },
    );
  }
} 