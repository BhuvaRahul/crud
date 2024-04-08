import 'package:flutter/material.dart';

class SlidableCardWidget extends StatelessWidget {
  Widget? child;
  Color? color;
  SlidableCardWidget({
    super.key,
    this.child,
    this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 1, vertical: 3),
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(10),
      ),
      child: child,
    );
  }
}
