import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../models/event.dart';
import 'schedule/event_detail_modal.dart';
import 'schedule/speakers_list.dart';
import 'schedule/subevents_list.dart';

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

  double getHourTopPadding(Event event) {
    if (event.description != null ||
        event.subevents.isNotEmpty ||
        event.speakers.isNotEmpty) {
      return 35;
    }
    if (event.description == null && event.location == null) {
      return 12;
    }
    return 18;
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        if (event.description != null && event.subevents.isEmpty) {
          EventDetailModal.show(context, event);
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
                    color: Theme.of(context).brightness == Brightness.dark
                        ? Theme.of(context).colorScheme.surface
                        : Theme.of(context).colorScheme.onSurface,
                    borderRadius: const BorderRadius.only(
                        topLeft: Radius.circular(20),
                        bottomLeft: Radius.circular(20))),
                padding: EdgeInsets.only(top: getHourTopPadding(event)),
                width: 100,
                child: Text(
                  DateFormat('HH:mm').format(event.start),
                  textAlign: TextAlign.center,
                  style: TextStyle(
                      color: Theme.of(context).brightness == Brightness.dark
                          ? Theme.of(context).colorScheme.onSurface
                          : Theme.of(context).colorScheme.surface,
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
                          SubeventsList(subevents: event.subevents),
                        if (event.speakers.isNotEmpty)
                          SpeakersList(
                            event: event,
                            hasLightBackground: true,
                          ),
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
}
