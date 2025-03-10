import 'package:flutter/material.dart';
import 'package:momentum24_app/models/song.dart';

class SongHeader extends StatelessWidget {
  final Song song;
  final List<Widget> actions;

  const SongHeader({
    super.key,
    required this.song,
    required this.actions,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return SliverAppBar(
      expandedHeight: 120.0,
      pinned: true,
      stretch: true,
      backgroundColor: theme.colorScheme.secondary,
      foregroundColor: theme.colorScheme.onSecondary,
      actions: actions,
      flexibleSpace: FlexibleSpaceBar(
        title: SizedBox(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              Text(
                song.title,
                style: theme.textTheme.titleMedium?.copyWith(
                  color: theme.colorScheme.onSecondary,
                  height: 1.4,
                ),
              ),
              Text(
                song.originalTitle,
                style: theme.textTheme.titleSmall?.copyWith(
                  color: theme.colorScheme.onSecondary.withAlpha(77),
                  height: 1.1,
                  fontSize: 10,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
