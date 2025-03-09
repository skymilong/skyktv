/// 歌词行
class LyricLine {
  final Duration timestamp;
  final String text;
  bool isHighlighted;

  LyricLine({
    required this.timestamp,
    required this.text,
    this.isHighlighted = false,
  });

  factory LyricLine.fromLrcLine(String line) {
    try {
      // 解析LRC格式的时间戳 [mm:ss.xx]
      final timeRegExp = RegExp(r'\[(\d{2}):(\d{2})\.(\d{2})\]');
      final match = timeRegExp.firstMatch(line);
      
      if (match != null) {
        final minutes = int.parse(match.group(1)!);
        final seconds = int.parse(match.group(2)!);
        final milliseconds = int.parse(match.group(3)!) * 10;
        
        final timestamp = Duration(
          minutes: minutes,
          seconds: seconds,
          milliseconds: milliseconds,
        );
        
        final text = line.substring(match.end).trim();
        
        return LyricLine(
          timestamp: timestamp,
          text: text,
        );
      }
      
      // 如果没有时间戳，返回空行
      return LyricLine(
        timestamp: Duration.zero,
        text: line.trim(),
      );
    } catch (e) {
      return LyricLine(
        timestamp: Duration.zero,
        text: line.trim(),
      );
    }
  }
}

/// 歌词管理器
class Lyrics {
  final List<LyricLine> lines;
  int currentIndex;

  Lyrics({
    required this.lines,
    this.currentIndex = -1,
  });

  factory Lyrics.fromLrcContent(String content) {
    final lines = content
        .split('\n')
        .where((line) => line.trim().isNotEmpty)
        .map((line) => LyricLine.fromLrcLine(line))
        .where((line) => line.text.isNotEmpty)
        .toList();

    // 按时间戳排序
    lines.sort((a, b) => a.timestamp.compareTo(b.timestamp));

    return Lyrics(lines: lines);
  }

  /// 更新当前歌词
  void updateCurrentLine(Duration position) {
    // 重置所有行的高亮状态
    for (var line in lines) {
      line.isHighlighted = false;
    }

    // 找到当前时间对应的歌词行
    for (int i = 0; i < lines.length; i++) {
      if (i == lines.length - 1 || 
          (position >= lines[i].timestamp && 
           position < lines[i + 1].timestamp)) {
        currentIndex = i;
        lines[i].isHighlighted = true;
        break;
      }
    }
  }

  /// 获取当前歌词行
  LyricLine? getCurrentLine() {
    if (currentIndex >= 0 && currentIndex < lines.length) {
      return lines[currentIndex];
    }
    return null;
  }

  /// 获取前后几行歌词
  List<LyricLine> getVisibleLines(int before, int after) {
    if (lines.isEmpty) return [];
    
    final start = (currentIndex - before).clamp(0, lines.length);
    final end = (currentIndex + after + 1).clamp(0, lines.length);
    
    return lines.sublist(start, end);
  }
} 