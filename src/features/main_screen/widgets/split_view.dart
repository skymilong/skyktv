import 'package:flutter/material.dart';

class SplitView extends StatelessWidget {
  final Widget left;
  final Widget right;
  final double ratio;

  const SplitView({
    Key? key,
    required this.left,
    required this.right,
    this.ratio = 0.3,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          flex: (ratio * 100).round(),
          child: left,
        ),
        const VerticalDivider(width: 1),
        Expanded(
          flex: ((1 - ratio) * 100).round(),
          child: right,
        ),
      ],
    );
  }
}
