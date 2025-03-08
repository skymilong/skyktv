import 'package:flutter/material.dart';
import '../../../data/models/song.dart';
import '../../song_library/widgets/song_list.dart';
import '../widgets/split_view.dart';

class MainScreen extends StatelessWidget {
  const MainScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('KTV点歌系统'),
        actions: [
          IconButton(
            icon: const Icon(Icons.search),
            onPressed: () {
              // TODO: 实现搜索功能
            },
          ),
          IconButton(
            icon: const Icon(Icons.settings),
            onPressed: () {
              // TODO: 实现设置功能
            },
          ),
        ],
      ),
      body: const SplitView(
        left: _LeftPanel(),
        right: _RightPanel(),
      ),
    );
  }
}

class SplitView extends StatelessWidget {
  final Widget left;
  final Widget right;

  const SplitView({
    Key? key,
    required this.left,
    required this.right,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          flex: 2,
          child: left,
        ),
        const VerticalDivider(width: 1),
        Expanded(
          flex: 3,
          child: right,
        ),
      ],
    );
  }
}

class _LeftPanel extends StatelessWidget {
  const _LeftPanel({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    // 临时测试数据
    final testSongs = [
      Song(
        id: '1',
        title: '测试歌曲 1',
        artist: '演唱者 1',
        categories: {"测试1"},
        pinyin: "ceshigequ1",
        pinyinFirst: "CSGQ1",
        album : "未知专辑",
      ),
      Song(
        id: '2',
        title: '测试歌曲2',
        artist: '演唱者2',
        categories: {"测试1"},
        pinyin: "ceshigequ2",
        pinyinFirst: "CSGQ2",
        album : "未知专辑",
      ),
    ];

    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.all(8.0),
          child: TextField(
            decoration: const InputDecoration(
              hintText: '搜索歌曲...',
              prefixIcon: Icon(Icons.search),
              border: OutlineInputBorder(),
            ),
            onChanged: (value) {
              // TODO: 实现搜索功能
            },
          ),
        ),
        Expanded(
          child: SongList(
            songs: testSongs,
            onSongTap: (song) {
              // TODO: 实现歌曲选择功能
            },
          ),
        ),
      ],
    );
  }
}

class _RightPanel extends StatelessWidget {
  const _RightPanel({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Expanded(
          child: Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: const [
                Icon(Icons.music_note, size: 100),
                SizedBox(height: 16),
                Text('暂无播放中的歌曲'),
              ],
            ),
          ),
        ),
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Theme.of(context).colorScheme.surface,
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.1),
                blurRadius: 4,
                offset: const Offset(0, -2),
              ),
            ],
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              IconButton(
                icon: const Icon(Icons.skip_previous),
                onPressed: () {
                  // TODO: 实现上一首功能
                },
              ),
              const SizedBox(width: 16),
              IconButton(
                icon: const Icon(Icons.play_arrow),
                iconSize: 48,
                onPressed: () {
                  // TODO: 实现播放/暂停功能
                },
              ),
              const SizedBox(width: 16),
              IconButton(
                icon: const Icon(Icons.skip_next),
                onPressed: () {
                  // TODO: 实现下一首功能
                },
              ),
            ],
          ),
        ),
      ],
    );
  }
}
