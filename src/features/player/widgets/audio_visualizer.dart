import 'package:flutter/material.dart';
import 'dart:math' as math;

class AudioVisualizer extends StatefulWidget {
  final bool isPlaying;
  final int barCount;
  final double minHeight;
  final double maxHeight;
  final Duration animationDuration;

  const AudioVisualizer({
    Key? key,
    this.isPlaying = false,
    this.barCount = 27,
    this.minHeight = 10,
    this.maxHeight = 100,
    this.animationDuration = const Duration(milliseconds: 200),
  }) : super(key: key);

  @override
  State<AudioVisualizer> createState() => _AudioVisualizerState();
}

class _AudioVisualizerState extends State<AudioVisualizer> with SingleTickerProviderStateMixin {
  late final AnimationController _controller;
  late final List<double> _heights;
  final _random = math.Random();

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 500),
    )..repeat();
    _heights = List.generate(widget.barCount, (_) => _generateHeight());
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  double _generateHeight() {
    return widget.minHeight + _random.nextDouble() * (widget.maxHeight - widget.minHeight);
  }

  void _updateHeights() {
    if (widget.isPlaying) {
      setState(() {
        for (var i = 0; i < _heights.length; i++) {
          if (_random.nextDouble() < 0.1) {
            _heights[i] = _generateHeight();
          }
        }
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _controller,
      builder: (context, child) {
        _updateHeights();
        return Container(
          width: double.infinity,
          height: widget.maxHeight,
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: List.generate(
              widget.barCount,
              (index) => AnimatedContainer(
                duration: widget.animationDuration,
                width: 4,
                height: widget.isPlaying ? _heights[index] : widget.minHeight,
                decoration: BoxDecoration(
                  color: Theme.of(context).primaryColor.withOpacity(0.8),
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}
