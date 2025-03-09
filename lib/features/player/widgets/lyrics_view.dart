import 'package:flutter/material.dart';
import '../models/lyric.dart';

class LyricsView extends StatelessWidget {
  final Lyrics lyrics;
  final double fontSize;
  final Color highlightColor;
  final Color normalColor;
  final int visibleLinesBeforeCurrent;
  final int visibleLinesAfterCurrent;

  const LyricsView({
    Key? key,
    required this.lyrics,
    this.fontSize = 18,
    this.highlightColor = Colors.blue,
    this.normalColor = Colors.grey,
    this.visibleLinesBeforeCurrent = 5,
    this.visibleLinesAfterCurrent = 5,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final visibleLines = lyrics.getVisibleLines(
      visibleLinesBeforeCurrent,
      visibleLinesAfterCurrent,
    );

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            for (var line in visibleLines)
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 8),
                child: AnimatedDefaultTextStyle(
                  duration: const Duration(milliseconds: 300),
                  style: TextStyle(
                    fontSize: line.isHighlighted ? fontSize * 1.2 : fontSize,
                    color: line.isHighlighted ? highlightColor : normalColor,
                    fontWeight: line.isHighlighted ? FontWeight.bold : FontWeight.normal,
                  ),
                  child: Text(
                    line.text,
                    textAlign: TextAlign.center,
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
} 