import 'package:flutter/material.dart';

import 'package:momentum24_app/models/event.dart';
import 'package:momentum24_app/services/data_provider_service.dart';
import 'package:momentum24_app/widgets/schedule_item.dart';

class EventDayList extends StatelessWidget {
  final DateTime day;
  final List<Event> allEvents;
  final DataProviderService dataProviderService;
  final Function(List<Event>) onRefresh;

  const EventDayList({
    super.key,
    required this.day,
    required this.allEvents,
    required this.dataProviderService,
    required this.onRefresh,
  });

  @override
  Widget build(BuildContext context) {
    final events = filterEventsForDay(day);
    return RefreshIndicator(
      onRefresh: () {
        return dataProviderService
            .getSchedule(forceNewData: true)
            .then((value) {
          onRefresh(value);
        });
      },
      child: ListView.builder(
        clipBehavior: Clip.antiAlias,
        padding: const EdgeInsets.all(0),
        itemCount: events.length,
        itemBuilder: (context, index) {
          final event = events[index];
          final color = event.category != null
              ? Color(event.category?.color.hex ?? 0xFFFFFF)
              : Theme.of(context).primaryColor;
          final textColor = event.category != null
              ? Color(event.category?.textColor.hex ?? 0xFFFFFF)
              : Theme.of(context).colorScheme.onPrimary;
          return ScheduleItem(
            event: event,
            color: color,
            textColor: textColor,
          );
        },
      ),
    );
  }

  // Filter events in the schedule for a specific day.
  // Adjust the event date for comparison if it's before 3 AM.
  List<Event> filterEventsForDay(DateTime day) {
    return allEvents.where((event) {
      DateTime eventDate = event.start;
      // Adjust the event date for comparison
      if (eventDate.hour < 3) {
        eventDate = eventDate.subtract(const Duration(days: 1));
      }
      eventDate = DateTime(eventDate.year, eventDate.month, eventDate.day);
      return eventDate == day;
    }).toList();
  }
}
