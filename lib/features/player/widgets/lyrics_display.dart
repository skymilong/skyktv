import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../core/services/player_service.dart';
import '../models/lyric.dart';

class LyricsDisplay extends StatefulWidget {
  final String? songId;
  final Duration position;
  final double height;
  final TextStyle? activeStyle;
  final TextStyle? inactiveStyle;

  const LyricsDisplay({
    Key? key,
    this.songId,
    this.position = Duration.zero,
    this.height = 120,
    this.activeStyle,
    this.inactiveStyle,
  }) : super(key: key);

  @override
  State<LyricsDisplay> createState() => _LyricsDisplayState();
}

class _LyricsDisplayState extends State<LyricsDisplay> {
  final ScrollController _scrollController = ScrollController();
  List<LyricLine> _lyrics = [];
  int _currentIndex = 0;

  @override
  void initState() {
    super.initState();
    _loadLyrics();
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  @override
  void didUpdateWidget(LyricsDisplay oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.songId != widget.songId) {
      _loadLyrics();
    }
    if (oldWidget.position != widget.position) {
      _updateCurrentLine();
    }
  }

  Future<void> _loadLyrics() async {
    if (widget.songId == null) {
      setState(() {
        _lyrics = [];
        _currentIndex = 0;
      });
      return;
    }

    try {
      final playerService = context.read<PlayerService>();
      _lyrics = await playerService.loadLyrics(widget.songId!);
      
      // 根据当前播放位置更新当前行
      _updateCurrentLine();
      
    } catch (e) {
      debugPrint('Error loading lyrics: $e');
      setState(() {
        _lyrics = [];
        _currentIndex = 0;
      });
    }
  }

  void _updateCurrentLine() {
    if (_lyrics.isEmpty) return;
    
    final visibleLines = Lyrics(lines: _lyrics).getVisibleLines(1, 1);
    final currentLine = visibleLines.firstWhere(
      (line) => line.isHighlighted,
      orElse: () => visibleLines.first,
    );
    
    final newIndex = _lyrics.indexOf(currentLine);
    if (newIndex != _currentIndex) {
      setState(() {
        _currentIndex = newIndex;
      });
      _scrollToCurrentLine();
    }
  }

  void _scrollToCurrentLine() {
    if (_lyrics.isEmpty || !_scrollController.hasClients) return;

    final itemHeight = widget.height / 3;
    final offset = _currentIndex * itemHeight;
    _scrollController.animateTo(
      offset,
      duration: const Duration(milliseconds: 300),
      curve: Curves.easeInOut,
    );
  }

  @override
  Widget build(BuildContext context) {
    if (_lyrics.isEmpty) {
      return SizedBox(
        height: widget.height,
        child: const Center(
          child: Text(
            '暂无歌词',
            style: TextStyle(
              fontSize: 16,
              color: Colors.grey,
            ),
          ),
        ),
      );
    }

    final defaultActiveStyle = TextStyle(
      fontSize: 16,
      color: Theme.of(context).primaryColor,
      fontWeight: FontWeight.bold,
    );

    final defaultInactiveStyle = TextStyle(
      fontSize: 14,
      color: Theme.of(context).textTheme.bodyMedium?.color?.withOpacity(0.6),
    );

    return SizedBox(
      height: widget.height,
      child: ListView.builder(
        controller: _scrollController,
        itemCount: _lyrics.length,
        itemBuilder: (context, index) {
          final line = _lyrics[index];
          final isActive = index == _currentIndex;

          return Container(
            height: widget.height / 3,
            alignment: Alignment.center,
            child: Text(
              line.text,
              textAlign: TextAlign.center,
              style: isActive
                ? (widget.activeStyle ?? defaultActiveStyle)
                : (widget.inactiveStyle ?? defaultInactiveStyle),
            ),
          );
        },
      ),
    );
  }
}
