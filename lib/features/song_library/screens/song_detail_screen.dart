import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../core/services/player_service.dart';
import '../../../core/services/song_service.dart';
import '../../../data/models/song.dart';

class SongDetailScreen extends StatelessWidget {
  final String songId;

  const SongDetailScreen({Key? key, required this.songId}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('歌曲详情'),
      ),
      body: FutureBuilder<Song?>(
        future: context.read<SongService>().getSongById(songId),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (snapshot.hasError) {
            return Center(child: Text('加载失败: ${snapshot.error}'));
          }

          if (!snapshot.hasData || snapshot.data == null) {
            return const Center(child: Text('未找到歌曲'));
          }

          final song = snapshot.data!;
          return SingleChildScrollView(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                if (song.coverUrl != null)
                  Center(
                    child: Image.network(
                      song.coverUrl!,
                      height: 200,
                      width: 200,
                      fit: BoxFit.cover,
                    ),
                  ),
                const SizedBox(height: 16),
                Text(song.title, style: Theme.of(context).textTheme.headlineSmall),
                const SizedBox(height: 8),
                Text('艺术家: ${song.artist}', style: Theme.of(context).textTheme.titleMedium),
                if (song.album != null) ...[
                  const SizedBox(height: 8),
                  Text('专辑: ${song.album}', style: Theme.of(context).textTheme.titleMedium),
                ],
                const SizedBox(height: 24),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    ElevatedButton.icon(
                      onPressed: () {
                        context.read<PlayerService>().loadSong(songId);
                      },
                      icon: const Icon(Icons.play_arrow),
                      label: const Text('播放'),
                    ),
                    ElevatedButton.icon(
                      onPressed: () {
                        // TODO: 实现添加到播放列表
                      },
                      icon: const Icon(Icons.playlist_add),
                      label: const Text('添加到播放列表'),
                    ),
                  ],
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}
