import 'package:avatar_stack/avatar_stack.dart';
import 'package:avatar_stack/positions.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_markdown/flutter_markdown.dart';
import 'package:intl/intl.dart';
import '../pages/information/speakers_screen.dart';
import '../models/event.dart';

class ScheduleItem extends StatelessWidget {
  const ScheduleItem({
    super.key,
    required this.event,
    required this.color,
    required this.nextColor,
  });

  final Event event;
  final Color color;
  final Color nextColor;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        if (event.description != null && event.subevents.isEmpty) {
          _buildBottomModal(context);
        }
      },
      child: Container(
        decoration: BoxDecoration(
          color: nextColor,
        ),
        margin: const EdgeInsets.all(0),
        padding: const EdgeInsets.all(0),
        child: Container(
          decoration: BoxDecoration(
            color: color,
            borderRadius: const BorderRadius.only(
              bottomLeft: Radius.circular(80.0),
            ),
          ),
          padding: EdgeInsets.only(
            left: 16,
            right: 16,
            top: 20.0,
            bottom: event.speakers.isNotEmpty ? 20.0 : 50.0,
          ),
          child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      DateFormat('HH:mm').format(event.start),
                      style: const TextStyle(
                          color: Colors.white,
                          fontSize: 16,
                          fontWeight: FontWeight.bold),
                    ),
                    if (event.location != null)
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          const Icon(
                            Icons.location_on,
                            color: Colors.white,
                          ),
                          const SizedBox(width: 8),
                          Text(
                            event.location!,
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 14,
                            ),
                          ),
                        ],
                      ),
                  ],
                ),
                const SizedBox(
                  height: 2,
                ),
                Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        event.title,
                        style: TextStyle(
                            color: Colors.white,
                            fontSize: event.subevents.isEmpty
                                ? Theme.of(context)
                                    .textTheme
                                    .titleLarge
                                    ?.fontSize
                                : Theme.of(context)
                                        .textTheme
                                        .titleLarge!
                                        .fontSize! *
                                    1.2,
                            fontWeight: FontWeight.bold),
                      ),
                      SizedBox(
                        height: event.subevents.isEmpty ? 40 : 50,
                      ),
                      if (event.description != null && event.subevents.isEmpty)
                        const Icon(
                          Icons.info,
                          color: Colors.white,
                        ),
                    ]),
                if (event.subevents.isNotEmpty)
                  for (var subevent in event.subevents)
                    GestureDetector(
                      onTap: () => _buildSubeventModal(context, subevent),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            subevent.title,
                            style: const TextStyle(
                                color: Colors.white,
                                fontSize: 20,
                                fontWeight: FontWeight.bold),
                          ),
                          const Icon(
                            Icons.info,
                            color: Colors.white,
                          ),
                        ],
                      ),
                    ),
                if (event.speakers.isNotEmpty)
                  _buildSpeakersList(event, context, true),
              ]),
        ),
      ),
    );
  }

  Row _buildSpeakersList(
      Event event, BuildContext context, bool hasLightBackground) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.center,
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Expanded(
          child: SizedBox(
            height: 50,
            child: WidgetStack(
              positions:
                  RestrictedPositions(maxCoverage: 0.4, minCoverage: 0.1),
              buildInfoWidget: (surplus) => BorderedCircleAvatar(
                  border: BorderSide(
                      color: Theme.of(context).colorScheme.onPrimary,
                      width: 1.0),
                  child: FittedBox(
                      fit: BoxFit.contain,
                      child: Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: Text(
                          '+$surplus',
                          style: Theme.of(context).textTheme.titleLarge,
                        ),
                      ))),
              stackedWidgets: event.speakers
                  .map((speaker) => GestureDetector(
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) =>
                                  SpeakersScreen(speaker: speaker.id),
                            ),
                          );
                        },
                        child: BorderedCircleAvatar(
                          backgroundImage: CachedNetworkImageProvider(
                              '${speaker.imageUrl}?w=100&h=150&fit=fillmax&auto=format&q=100'),
                          border: BorderSide(
                              color: Theme.of(context).colorScheme.onPrimary,
                              width: 1.0),
                        ),
                      ))
                  .toList(),
            ),
          ),
        ),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: event.speakers
              .map((speaker) => TextButton(
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) =>
                            SpeakersScreen(speaker: speaker.id),
                      ),
                    );
                  },
                  child: Text(
                    speaker.name,
                    style: TextStyle(
                        color: hasLightBackground
                            ? Theme.of(context).colorScheme.background
                            : Theme.of(context).colorScheme.onBackground),
                  )))
              .toList(),
        ),
      ],
    );
  }

  _buildBottomModal(BuildContext context) {
    return showModalBottomSheet(
        context: context,
        showDragHandle: true,
        builder: (context) {
          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16.0),
                child: Text(
                  event.title,
                  style: const TextStyle(
                      fontSize: 22, fontWeight: FontWeight.bold),
                ),
              ),
              const SizedBox(
                height: 10,
              ),
              Expanded(
                child: Markdown(
                    data: event.description ?? '',
                    styleSheet: MarkdownStyleSheet(
                      p: const TextStyle(
                        fontSize: 16,
                      ),
                    )),
              ),
            ],
          );
        });
  }

  _buildSubeventModal(BuildContext context, Event subevent) {
    return showModalBottomSheet(
        context: context,
        showDragHandle: true,
        builder: (context) {
          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16.0),
                child: Text(
                  subevent.title,
                  style: const TextStyle(
                      fontSize: 22, fontWeight: FontWeight.bold),
                ),
              ),
              const SizedBox(
                height: 10,
              ),
              if (subevent.location != null)
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16.0),
                  child: Row(
                    children: <Widget>[
                      Icon(Icons.location_on,
                          color: Theme.of(context).primaryColor),
                      const SizedBox(
                          width:
                              8.0), // provide some space between the icon and the text
                      Text(
                        subevent.location!,
                        style: TextStyle(
                            fontSize:
                                Theme.of(context).textTheme.bodySmall?.fontSize,
                            fontStyle: FontStyle.italic),
                      ),
                    ],
                  ),
                ),
              const SizedBox(
                height: 10,
              ),
              Expanded(
                child: Markdown(
                    data: subevent.description ?? '',
                    styleSheet: MarkdownStyleSheet(
                      p: const TextStyle(
                        fontSize: 16,
                      ),
                    )),
              ),
              Padding(
                padding: const EdgeInsets.fromLTRB(16.0, 0, 16, 16),
                child: _buildSpeakersList(subevent, context, false),
              ),
            ],
          );
        });
  }
}
