import 'package:flutter/material.dart';

class SnappingHandler extends StatelessWidget {
  const SnappingHandler({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 32,
      height: 4,
      margin: const EdgeInsets.only(top: 15.0, bottom: 4.0),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.onSurfaceVariant.withOpacity(0.4),
        borderRadius: const BorderRadius.all(Radius.circular(12.0)),
      ),
    );
  }
}
