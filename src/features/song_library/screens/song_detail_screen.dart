import 'package:flutter/material.dart';

class SongDetailScreen extends StatelessWidget {
  final String songId;

  const SongDetailScreen({Key? key, required this.songId}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    // TODO: 根据songId获取歌曲详细信息
    // 这里使用模拟数据
    final songDetails = {
      'title': '示例歌曲',
      'artist': '示例艺术家',
      'album': '示例专辑',
      'releaseDate': '2023-01-01',
      'duration': '3:30',
      'genre': '流行',
    };

    return Scaffold(
      appBar: AppBar(
        title: Text(songDetails['title']!),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('艺术家: ${songDetails['artist']}', style: Theme.of(context).textTheme.headline6),
            const SizedBox(height: 8),
            Text('专辑: ${songDetails['album']}', style: Theme.of(context).textTheme.subtitle1),
            const SizedBox(height: 8),
            Text('发行日期: ${songDetails['releaseDate']}', style: Theme.of(context).textTheme.subtitle1),
            const SizedBox(height: 8),
            Text('时长: ${songDetails['duration']}', style: Theme.of(context).textTheme.subtitle1),
            const SizedBox(height: 8),
            Text('流派: ${songDetails['genre']}', style: Theme.of(context).textTheme.subtitle1),
            const SizedBox(height: 24),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                ElevatedButton.icon(
                  onPressed: () {
                    // TODO: 实现播放功能
                  },
                  icon: const Icon(Icons.play_arrow),
                  label: const Text('播放'),
                ),
                ElevatedButton.icon(
                  onPressed: () {
                    // TODO: 实现添加到播放列表功能
                  },
                  icon: const Icon(Icons.playlist_add),
                  label: const Text('添加到播放列表'),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
