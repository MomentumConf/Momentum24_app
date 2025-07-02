import 'package:flutter/material.dart';
import 'package:flutter_markdown/flutter_markdown.dart';

import 'package:momentum24_app/models/event.dart';
import 'speakers_list.dart';

class EventDetailModal extends StatelessWidget {
  final Event event;
  final bool isSubevent;

  const EventDetailModal({
    super.key,
    required this.event,
    this.isSubevent = false,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16.0),
          child: Text(
            event.title,
            style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
          ),
        ),
        const SizedBox(height: 10),
        if (event.location != null && isSubevent)
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0),
            child: Row(
              children: <Widget>[
                Icon(Icons.location_on,
                    color: Theme.of(context).brightness == Brightness.dark
                        ? Theme.of(context).colorScheme.secondary
                        : Theme.of(context).primaryColor),
                const SizedBox(width: 8.0),
                Text(
                  event.location!,
                  style: TextStyle(
                    fontSize: Theme.of(context).textTheme.bodySmall?.fontSize,
                    fontStyle: FontStyle.italic,
                  ),
                ),
              ],
            ),
          ),
        if (event.location != null && isSubevent) const SizedBox(height: 10),
        Expanded(
          child: Markdown(
            data: event.description ?? '',
            styleSheet: MarkdownStyleSheet(
              p: const TextStyle(fontSize: 16),
            ),
          ),
        ),
        if (event.speakers.isNotEmpty && isSubevent)
          Padding(
            padding: const EdgeInsets.fromLTRB(16.0, 0, 16, 16),
            child: SpeakersList(
              event: event,
              hasLightBackground: false,
            ),
          ),
      ],
    );
  }

  static void show(BuildContext context, Event event,
      {bool isSubevent = false}) {
    showModalBottomSheet(
      context: context,
      showDragHandle: true,
      useRootNavigator: true,
      builder: (context) {
        return EventDetailModal(
          event: event,
          isSubevent: isSubevent,
        );
      },
    );
  }
}
