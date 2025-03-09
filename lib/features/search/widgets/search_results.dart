import 'package:flutter/material.dart';
import '../../../data/models/song.dart';

class SearchResults extends StatelessWidget {
  final List<Song> results;
  final Function(String) onTap;
  final bool isLoading;

  const SearchResults({
    Key? key,
    required this.results,
    required this.onTap,
    this.isLoading = false,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    if (isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    if (results.isEmpty) {
      return const Center(
        child: Text('没有找到相关歌曲'),
      );
    }

    return ListView.builder(
      itemCount: results.length,
      itemBuilder: (context, index) {
        final song = results[index];
        return ListTile(
          leading: song.coverUrl != null
              ? Image.network(
                  song.coverUrl!,
                  width: 50,
                  height: 50,
                  fit: BoxFit.cover,
                  errorBuilder: (_, __, ___) => const Icon(Icons.music_note),
                )
              : const Icon(Icons.music_note),
          title: Text(song.title),
          subtitle: Text(song.artist),
          trailing: IconButton(
            icon: const Icon(Icons.more_vert),
            onPressed: () {
              _showSongOptions(context, song);
            },
          ),
          onTap: () => onTap(song.id),
        );
      },
    );
  }

  void _showSongOptions(BuildContext context, Song song) {
    showModalBottomSheet(
      context: context,
      builder: (context) => Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          ListTile(
            leading: const Icon(Icons.play_arrow),
            title: const Text('立即播放'),
            onTap: () {
              Navigator.pop(context);
              // TODO: 实现播放功能
            },
          ),
          ListTile(
            leading: const Icon(Icons.playlist_add),
            title: const Text('添加到播放列表'),
            onTap: () {
              Navigator.pop(context);
              // TODO: 实现添加到播放列表功能
            },
          ),
          ListTile(
            leading: const Icon(Icons.info),
            title: const Text('查看详情'),
            onTap: () {
              Navigator.pop(context);
              onTap(song.id);
            },
          ),
        ],
      ),
    );
  }
}
