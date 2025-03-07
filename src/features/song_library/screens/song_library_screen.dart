import 'package:flutter/material.dart';
import '../widgets/category_tabs.dart';
import '../widgets/song_list_item.dart';

class SongLibraryScreen extends StatefulWidget {
  const SongLibraryScreen({Key? key}) : super(key: key);

  @override
  _SongLibraryScreenState createState() => _SongLibraryScreenState();
}

class _SongLibraryScreenState extends State<SongLibraryScreen> {
  String _selectedCategory = '全部';

  // 模拟歌曲数据
  final List<Map<String, String>> _songs = [
    {'id': '1', 'title': '歌曲1', 'artist': '歌手1'},
    {'id': '2', 'title': '歌曲2', 'artist': '歌手2'},
    {'id': '3', 'title': '歌曲3', 'artist': '歌手3'},
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('歌曲库'),
        actions: [
          IconButton(
            icon: const Icon(Icons.search),
            onPressed: () {
              // TODO: 实现搜索功能
            },
          ),
        ],
      ),
      body: Column(
        children: [
          CategoryTabs(
            categories: const ['全部', '华语', '欧美', '日韩'],
            selectedCategory: _selectedCategory,
            onCategorySelected: (category) {
              setState(() {
                _selectedCategory = category;
              });
              // TODO: 根据选择的分类筛选歌曲
            },
          ),
          Expanded(
            child: ListView.builder(
              itemCount: _songs.length,
              itemBuilder: (context, index) {
                final song = _songs[index];
                return SongListItem(
                  songId: song['id']!,
                  title: song['title']!,
                  artist: song['artist']!,
                  onTap: () {
                    // TODO: 导航到歌曲详情页面
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
