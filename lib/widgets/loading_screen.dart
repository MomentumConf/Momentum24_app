import 'package:flutter/material.dart';

/// A reusable loading screen widget that displays a centered circular progress indicator.
class LoadingScreen extends StatelessWidget {
  final Color? backgroundColor;

  const LoadingScreen({
    super.key,
    this.backgroundColor,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        color: backgroundColor ?? Theme.of(context).primaryColor,
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              CircularProgressIndicator(
                color: Theme.of(context).colorScheme.primary,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
