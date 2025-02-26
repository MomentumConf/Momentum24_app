import 'package:flutter/material.dart';
import 'package:flutter_markdown/flutter_markdown.dart';
import 'package:string_unescape/string_unescape.dart';
import '../../models/song.dart';
import '../../managers/TextScaleManager.dart';

class SingleSongScreen extends StatefulWidget {
  final List<Song> songs;
  final int currentIndex;

  const SingleSongScreen(
      {super.key, required this.songs, required this.currentIndex});

  @override
  SingleSongScreenState createState() => SingleSongScreenState();
}

class SingleSongScreenState extends State<SingleSongScreen> {
  late int currentIndex = widget.currentIndex;

  void _zoomIn() {
    textScaleManager.scaleFactor =
        (textScaleManager.scaleFactor + 0.1).clamp(0.8, 3.0);
  }

  void _zoomOut() {
    textScaleManager.scaleFactor =
        (textScaleManager.scaleFactor - 0.1).clamp(0.8, 3.0);
  }

  void goToNextSong() {
    if (currentIndex < widget.songs.length - 1) {
      setState(() {
        currentIndex++;
      });
    }
  }

  void goToPreviousSong() {
    if (currentIndex > 0) {
      setState(() {
        currentIndex--;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    Song song = widget.songs[currentIndex];

    return ListenableBuilder(
        listenable: textScaleManager,
        builder: (context, _) => Scaffold(
              backgroundColor: theme.colorScheme.secondary,
              body: CustomScrollView(
                slivers: <Widget>[
                  SliverAppBar(
                    expandedHeight: 120.0,
                    pinned: true,
                    stretch: true,
                    backgroundColor: theme.colorScheme.secondary,
                    foregroundColor: theme.colorScheme.onSecondary,
                    actions: <Widget>[
                      IconButton(
                        icon: const Icon(Icons.zoom_out),
                        onPressed: _zoomOut,
                      ),
                      IconButton(
                        icon: const Icon(Icons.zoom_in),
                        onPressed: _zoomIn,
                      ),
                    ],
                    flexibleSpace: FlexibleSpaceBar(
                      title: SizedBox(
                        width: double.infinity,
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
                                color:
                                    theme.colorScheme.onSecondary.withAlpha(77),
                                height: 1.1,
                                fontSize: 10,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                  SliverFillRemaining(
                    fillOverscroll: true,
                    hasScrollBody: false,
                    child: Card(
                      margin: const EdgeInsetsDirectional.symmetric(
                          horizontal: 4.0),
                      shape: const RoundedRectangleBorder(
                        borderRadius: BorderRadius.vertical(
                            bottom: Radius.zero, top: Radius.circular(16)),
                      ),
                      child: Padding(
                        padding:
                            const EdgeInsets.fromLTRB(16.0, 16.0, 16.0, 100),
                        child: MarkdownBody(
                          data: unescape(song.lyrics),
                          styleSheet: MarkdownStyleSheet.fromTheme(theme)
                              .copyWith(
                                  textScaler: TextScaler.linear(
                                      textScaleManager.scaleFactor)),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
              floatingActionButton: Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: <Widget>[
                    if (currentIndex > 0)
                      FloatingActionButton(
                        onPressed: goToPreviousSong,
                        child: const Icon(Icons.chevron_left),
                      ),
                    const SizedBox(width: 10),
                    if (currentIndex < widget.songs.length - 1)
                      FloatingActionButton(
                        onPressed: goToNextSong,
                        child: const Icon(Icons.chevron_right),
                      ),
                  ]),
            ));
  }
}
