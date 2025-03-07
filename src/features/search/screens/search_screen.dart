import 'package:flutter/material.dart';
import '../widgets/search_bar.dart';
import '../widgets/search_results.dart';

class SearchScreen extends StatefulWidget {
  const SearchScreen({Key? key}) : super(key: key);

  @override
  _SearchScreenState createState() => _SearchScreenState();
}

class _SearchScreenState extends State<SearchScreen> {
  String _searchQuery = '';
  List<Map<String, String>> _searchResults = [];

  void _onSearch(String query) {
    setState(() {
      _searchQuery = query;
      // TODO: 实现实际的搜索逻辑
      _searchResults = [
        {'id': '1', 'title': '搜索结果1', 'artist': '艺术家1'},
        {'id': '2', 'title': '搜索结果2', 'artist': '艺术家2'},
        {'id': '3', 'title': '搜索结果3', 'artist': '艺术家3'},
      ];
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('搜索'),
      ),
      body: Column(
        children: [
          SearchBar(onSearch: _onSearch),
          Expanded(
            child: SearchResults(
              results: _searchResults,
              onTap: (String songId) {
                // TODO: 实现导航到歌曲详情页面
                print('Tapped song with id: $songId');
              },
            ),
          ),
        ],
      ),
    );
  }
}
