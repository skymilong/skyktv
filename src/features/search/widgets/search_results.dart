import 'package:flutter/material.dart';

class SearchResults extends StatelessWidget {
  final List<Map<String, String>> results;
  final Function(String) onTap;

  const SearchResults({
    Key? key,
    required this.results,
    required this.onTap,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    if (results.isEmpty) {
      return const Center(
        child: Text('没有搜索结果'),
      );
    }

    return ListView.builder(
      itemCount: results.length,
      itemBuilder: (context, index) {
        final result = results[index];
        return ListTile(
          title: Text(result['title']!),
          subtitle: Text(result['artist']!),
          onTap: () => onTap(result['id']!),
        );
      },
    );
  }
}
