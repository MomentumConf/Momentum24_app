import 'package:flutter/material.dart';
import 'package:flutter_markdown/flutter_markdown.dart';
import 'package:string_unescape/string_unescape.dart';
import '../../models/song.dart';
import '../../managers/TextScaleManager.dart';

class SingleSongScreen extends StatefulWidget {
  final Song song;

  const SingleSongScreen({super.key, required this.song});

  @override
  SingleSongScreenState createState() => SingleSongScreenState();
}

class SingleSongScreenState extends State<SingleSongScreen> {
  void _zoomIn() {
    textScaleManager.scaleFactor =
        (textScaleManager.scaleFactor + 0.1).clamp(0.8, 3.0);
  }

  void _zoomOut() {
    textScaleManager.scaleFactor =
        (textScaleManager.scaleFactor - 0.1).clamp(0.8, 3.0);
  }

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: textScaleManager,
      builder: (context, _) => Scaffold(
        backgroundColor: Theme.of(context).primaryColorLight,
        body: CustomScrollView(
          slivers: <Widget>[
            SliverAppBar(
              expandedHeight: 120.0,
              pinned: true,
              stretch: true,
              backgroundColor: Theme.of(context).primaryColorLight,
              flexibleSpace: FlexibleSpaceBar(
                title: SizedBox(
                  width: double.infinity,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      Text(
                        widget.song.title,
                        style:
                            Theme.of(context).textTheme.titleMedium?.copyWith(
                                  height: 1.4,
                                ),
                      ),
                      Text(
                        widget.song.originalTitle,
                        style: Theme.of(context).textTheme.titleSmall?.copyWith(
                              height: 1.1,
                              fontSize: 10,
                              color: Theme.of(context)
                                  .textTheme
                                  .bodySmall
                                  ?.color
                                  ?.withOpacity(0.3),
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
                margin: const EdgeInsetsDirectional.symmetric(horizontal: 4.0),
                shape: const RoundedRectangleBorder(
                  borderRadius: BorderRadius.vertical(
                      bottom: Radius.zero, top: Radius.circular(16)),
                ),
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(16.0, 16.0, 16.0, 100),
                  child: MarkdownBody(
                    data: unescape(widget.song.lyrics),
                    styleSheet: MarkdownStyleSheet.fromTheme(Theme.of(context))
                        .copyWith(
                            textScaleFactor: textScaleManager.scaleFactor),
                  ),
                ),
              ),
            ),
          ],
        ),
        floatingActionButton: Row(
          mainAxisAlignment: MainAxisAlignment.end,
          children: <Widget>[
            FloatingActionButton(
              heroTag: 'zoomOut',
              onPressed: _zoomOut,
              child: const Icon(Icons.zoom_out),
            ),
            const SizedBox(width: 10),
            FloatingActionButton(
              heroTag: 'zoomIn',
              onPressed: _zoomIn,
              child: const Icon(Icons.zoom_in),
            ),
          ],
        ),
      ),
    );
  }
}
