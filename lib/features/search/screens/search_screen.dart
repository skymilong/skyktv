import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../core/services/song_service.dart';
import '../../../data/models/song.dart';
import '../widgets/search_bar.dart';
import '../widgets/search_results.dart';

class SearchScreen extends StatefulWidget {
  const SearchScreen({Key? key}) : super(key: key);

  @override
  _SearchScreenState createState() => _SearchScreenState();
}

class _SearchScreenState extends State<SearchScreen> {
  List<Song> _searchResults = [];
  bool _isLoading = false;

  Future<void> _onSearch(String query) async {
    if (query.isEmpty) {
      setState(() {
        _searchResults = [];
        _isLoading = false;
      });
      return;
    }

    setState(() {
      _isLoading = true;
    });

    try {
      final songService = context.read<SongService>();
      final results = await songService.searchSongs(query);
      setState(() {
        _searchResults = results;
        _isLoading = false;
      });
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('搜索失败: $e')),
      );
      setState(() {
        _isLoading = false;
      });
    }
  }

  void _navigateToSongDetail(String songId) {
    Navigator.pushNamed(
      context,
      '/song_detail',
      arguments: songId,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('搜索'),
      ),
      body: Column(
        children: [
          AppSearchBar(onSearch: _onSearch),
          Expanded(
            child: SearchResults(
              results: _searchResults,
              onTap: _navigateToSongDetail,
              isLoading: _isLoading,
            ),
          ),
        ],
      ),
    );
  }
}
