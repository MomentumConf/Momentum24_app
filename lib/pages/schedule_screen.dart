import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';
import 'package:intl/intl.dart';

import '../models/event.dart' show Event;
import '../services/data_provider_service.dart';
import '../widgets/active_tab_indicator.dart';
import '../widgets/momentum_appbar.dart';
import '../widgets/schedule_item.dart';

class ScheduleScreen extends StatefulWidget {
  const ScheduleScreen({super.key});

  @override
  ScheduleScreenState createState() => ScheduleScreenState();
}

class ScheduleScreenState extends State<ScheduleScreen>
    with TickerProviderStateMixin {
  late TabController _tabController;
  DataProviderService _dataProviderService =
      GetIt.instance.get<DataProviderService>();
  List<Event> schedule = [];
  bool isLoading = true;
  List<DateTime> uniqueDays = [];

  @override
  void initState() {
    super.initState();
    initializeServices();
    loadSchedule();
    _tabController = TabController(length: 0, vsync: this);
  }

  void initializeServices() {
    _dataProviderService = _dataProviderService.setNotifier((value) {
      setState(() => schedule = value);
      updateTabController(value);
    });
  }

  @override
  void dispose() {
    _tabController?.dispose();
    super.dispose();
  }

  Future<void> loadSchedule() async {
    final apiData = await _dataProviderService.getSchedule();
    updateTabController(apiData);
    setState(() {
      schedule = apiData;
      isLoading = false;
    });
  }

  void updateTabController(List<Event> apiData) {
    final uniqueDaysMap = _getUniqueDays(apiData);
    final initialIndex = _getInitialIndex(uniqueDaysMap);
    _tabController?.dispose();
    _tabController = TabController(
      length: uniqueDaysMap.length,
      initialIndex: initialIndex,
      vsync: this,
    );
    uniqueDays = uniqueDaysMap;
  }

  int _getInitialIndex(List<DateTime> uniqueDaysMap) {
    DateTime today = DateTime.now();
    return uniqueDaysMap
        .indexWhere(
          (day) =>
              day.year == today.year &&
              day.month == today.month &&
              day.day == today.day,
        )
        .clamp(0, uniqueDaysMap.length - 1);
  }

  List<DateTime> _getUniqueDays(List<Event> schedule) {
    var uniqueDates = schedule.map((event) {
      DateTime eventDate = event.start;
      // Move event to the previous day if it's before 3 AM
      if (eventDate.hour < 3) {
        eventDate = eventDate.subtract(const Duration(days: 1));
      }
      return DateTime(eventDate.year, eventDate.month, eventDate.day);
    }).toSet();
    return uniqueDates.toList()..sort((a, b) => a.compareTo(b));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: MomentumAppBar(
          bottom: isLoading || uniqueDays.isEmpty ? null : getTabBar(context)),
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : TabBarView(
              controller: _tabController,
              children:
                  uniqueDays.map((day) => getEventDay(day, context)).toList(),
            ),
    );
  }

  // A function that filters events for a given day, and returns a RefreshIndicator
  // containing a ListView of ScheduleItem widgets based on the filtered events.
  Widget getEventDay(DateTime day, BuildContext context) {
    final events = filterEventsForDay(day);
    return RefreshIndicator(
      onRefresh: () {
        return _dataProviderService
            .getSchedule(forceNewData: true)
            .then((value) {
          updateTabController(value);
          setState(() {
            schedule = value;
          });
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
    return schedule.where((event) {
      DateTime eventDate = event.start;
      // Adjust the event date for comparison
      if (eventDate.hour < 3) {
        eventDate = eventDate.subtract(const Duration(days: 1));
      }
      eventDate = DateTime(eventDate.year, eventDate.month, eventDate.day);
      return eventDate == day;
    }).toList();
  }

  PreferredSizeWidget getTabBar(BuildContext context) {
    final deviceWidth = MediaQuery.of(context).size.width;
    return TabBar(
      controller: _tabController,
      indicator: ActiveTabIndicator(color: const Color(0xFFFFD143), radius: 10),
      indicatorSize: TabBarIndicatorSize.label,
      indicatorPadding: const EdgeInsets.all(0),
      dividerHeight: 0,
      tabs: uniqueDays.map((day) {
        final weekday =
            DateFormat('EEE').format(day).replaceAll(RegExp(r'\.$'), '');
        final dayOfMonth = DateFormat('d').format(day);

        return Tab(
          child: AnimatedBuilder(
            animation: _tabController.animation!,
            builder: (context, child) {
              final color = Theme.of(context).colorScheme.onPrimary;

              return SizedBox(
                width: deviceWidth / uniqueDays.length,
                height: 50,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      ((deviceWidth > 365 || weekday.length == 2)
                              ? weekday
                              : weekday[0] + weekday[2])
                          .toUpperCase(),
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        color: color,
                        fontSize: 12,
                      ),
                    ),
                    Text(
                      dayOfMonth,
                      style: TextStyle(
                        fontSize: 16,
                        color: color,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              );
            },
          ),
        );
      }).toList(),
    );
  }
}
