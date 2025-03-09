import 'package:flutter/material.dart';
import 'package:flutter_markdown/flutter_markdown.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../widgets/snapping_handler.dart';

class SpeakerDetailSheet extends StatelessWidget {
  final String content;
  final ScrollController scrollController;
  final bool hasContent;

  const SpeakerDetailSheet({
    super.key,
    required this.content,
    required this.scrollController,
    this.hasContent = true,
  });

  @override
  Widget build(BuildContext context) {
    final textStyleWhiteColor = TextStyle(
      color: Theme.of(context).colorScheme.onSecondary,
    );

    return Container(
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.secondary,
        borderRadius: const BorderRadius.only(
          topLeft: Radius.circular(20),
          topRight: Radius.circular(20),
        ),
      ),
      child: hasContent
          ? ListView(
              controller: scrollController,
              children: <Widget>[
                const Center(child: SnappingHandler()),
                Padding(
                  padding: const EdgeInsets.fromLTRB(8, 36, 8, 8),
                  child: MarkdownBody(
                    onTapLink: (text, href, title) {
                      if (href != null) {
                        launchUrl(Uri.parse(href));
                      }
                    },
                    styleSheet: MarkdownStyleSheet.fromTheme(Theme.of(context))
                        .copyWith(
                      p: textStyleWhiteColor,
                      h2: textStyleWhiteColor,
                      strong: textStyleWhiteColor,
                      a: textStyleWhiteColor.copyWith(
                        decoration: TextDecoration.underline,
                        decorationColor: textStyleWhiteColor.color,
                      ),
                    ),
                    data: content,
                  ),
                )
              ],
            )
          : null,
    );
  }
}
