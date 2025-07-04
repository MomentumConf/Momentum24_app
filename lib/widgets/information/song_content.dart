import 'package:flutter/material.dart';
import 'package:flutter_markdown/flutter_markdown.dart';
import 'package:string_unescape/string_unescape.dart';
import 'package:url_launcher/url_launcher.dart';

class SongContent extends StatelessWidget {
  final String lyrics;
  final double textScaleFactor;

  const SongContent({
    super.key,
    required this.lyrics,
    required this.textScaleFactor,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return SliverFillRemaining(
      fillOverscroll: true,
      hasScrollBody: false,
      child: Card(
        margin: const EdgeInsetsDirectional.symmetric(horizontal: 4.0),
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(
            bottom: Radius.zero,
            top: Radius.circular(16),
          ),
        ),
        child: Padding(
          padding: const EdgeInsets.fromLTRB(16.0, 16.0, 16.0, 100),
          child: MarkdownBody(
            data: unescape(lyrics),
            styleSheet: MarkdownStyleSheet.fromTheme(theme).copyWith(
              textScaler: TextScaler.linear(textScaleFactor),
            ),
            onTapLink: (text, href, title) {
              launchUrl(Uri.parse(href!));
            }
          ),
        ),
      ),
    );
  }
}
