import 'package:flutter/material.dart';

class PillButton extends StatelessWidget {
  const PillButton({
    super.key,
    required this.child,
    required this.onTap,
  });

  final Widget child;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.symmetric(vertical: 2.5),
        padding: const EdgeInsets.symmetric(vertical: 4.0, horizontal: 5),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(15),
          color: Colors.white.withAlpha(77),
        ),
        child: child,
      ),
    );
  }
}
