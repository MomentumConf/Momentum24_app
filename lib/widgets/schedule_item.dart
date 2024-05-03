import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_markdown/flutter_markdown.dart';
import 'package:intl/intl.dart';
import 'package:momentum24_app/widgets/pill_button.dart';
import '../pages/information/speakers_screen.dart';
import '../models/event.dart';

class ScheduleItem extends StatelessWidget {
  const ScheduleItem({
    super.key,
    required this.event,
    required this.color,
    required this.textColor,
  });

  final Event event;
  final Color color;
  final Color textColor;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        if (event.description != null && event.subevents.isEmpty) {
          _buildBottomModal(context);
        }
      },
      child: Container(
        margin: const EdgeInsets.symmetric(vertical: 10.0, horizontal: 10),
        padding: const EdgeInsets.all(0),
        child: IntrinsicHeight(
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            mainAxisAlignment: MainAxisAlignment.start,
            children: [
              Container(
                decoration: BoxDecoration(
                    color: Theme.of(context).colorScheme.onPrimary,
                    borderRadius: const BorderRadius.only(
                        topLeft: Radius.circular(20),
                        bottomLeft: Radius.circular(20))),
                padding: const EdgeInsets.only(top: 35),
                width: 100,
                child: Text(
                  DateFormat('HH:mm').format(event.start),
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                      color: Colors.white,
                      fontSize: 22,
                      fontWeight: FontWeight.bold),
                ),
              ),
              Expanded(
                child: Container(
                  decoration: BoxDecoration(
                      color: color,
                      borderRadius: const BorderRadius.only(
                          topRight: Radius.circular(20),
                          bottomRight: Radius.circular(20))),
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 14,
                  ),
                  child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: <Widget>[
                        Row(children: [
                          Flexible(
                            child: Text(
                              event.title,
                              style: TextStyle(
                                  color: textColor,
                                  fontSize: 22,
                                  height: 1.3,
                                  fontWeight: FontWeight.bold),
                            ),
                          ),
                        ]),
                        if (event.location != null) ...[
                          Text(
                            "// ${event.location!}",
                            style: TextStyle(
                                color: textColor, fontSize: 12, height: 0.7),
                          ),
                          const SizedBox(height: 5)
                        ],
                        if (event.subevents.isNotEmpty)
                          ..._buildSubeventsList(event.subevents, context),
                        if (event.speakers.isNotEmpty)
                          _buildSpeakersList(event, context, true),
                        if (event.description != null &&
                            event.subevents.isEmpty) ...[
                          const SizedBox(height: 10),
                          Icon(
                            Icons.info_outline,
                            color: textColor,
                          ),
                        ]
                      ]),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSpeakersList(
      Event event, BuildContext context, bool hasLightBackground) {
    return Column(
      children: [
        for (var speaker in event.speakers)
          PillButton(
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => SpeakersScreen(speaker: speaker.id),
                ),
              );
            },
            child: Row(children: [
              CircleAvatar(
                backgroundImage:
                    CachedNetworkImageProvider("${speaker.imageUrl}?w=50&h=50"),
                radius: 12.5,
              ),
              const SizedBox(
                width: 5,
              ),
              Text(
                speaker.name,
                maxLines: 1,
                style:
                    TextStyle(color: Theme.of(context).colorScheme.onPrimary),
              )
            ]),
          )
      ],
    );
  }

  List<Widget> _buildSubeventsList(
      List<Event> subevents, BuildContext context) {
    return subevents
        .map((subevent) => PillButton(
            child: Row(
              children: [
                Icon(
                  Icons.info_outline,
                  color: textColor,
                ),
                const SizedBox(width: 5),
                Flexible(
                  child: Text(
                    subevent.title,
                    textAlign: TextAlign.start,
                    style: TextStyle(
                        color: textColor,
                        fontSize: 12,
                        height: 1.1,
                        fontWeight: FontWeight.bold),
                  ),
                ),
              ],
            ),
            onTap: () => _buildSubeventModal(context, subevent)))
        .toList();
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
