import 'package:flutter/material.dart';
import 'package:momentum24_app/models/song.dart';
import 'package:momentum24_app/managers/TextScaleManager.dart';
import 'package:momentum24_app/widgets/information/song_header.dart';
import 'package:momentum24_app/widgets/information/song_content.dart';

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
                  SongHeader(
                    song: song,
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
                  ),
                  SongContent(
                    lyrics: song.lyrics,
                    textScaleFactor: textScaleManager.scaleFactor,
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
