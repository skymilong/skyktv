import 'package:flutter/material.dart';

class SongListItem extends StatelessWidget {
  final String songId;
  final String title;
  final String artist;
  final VoidCallback onTap;

  const SongListItem({
    Key? key,
    required this.songId,
    required this.title,
    required this.artist,
    required this.onTap,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return ListTile(
      title: Text(title),
      subtitle: Text(artist),
      trailing: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          IconButton(
            icon: const Icon(Icons.play_arrow),
            onPressed: () {
              // TODO: 实现播放功能
            },
          ),
          IconButton(
            icon: const Icon(Icons.add),
            onPressed: () {
              // TODO: 实现添加到播放列表功能
            },
          ),
        ],
      ),
      onTap: onTap,
    );
  }
}
