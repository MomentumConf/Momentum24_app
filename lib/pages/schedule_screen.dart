import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';

import 'package:momentum24_app/models/event.dart' show Event;
import 'package:momentum24_app/services/data_provider_service.dart';
import 'package:momentum24_app/widgets/active_tab_indicator.dart';
import 'package:momentum24_app/widgets/momentum_appbar.dart';
import 'package:momentum24_app/widgets/schedule/day_tab.dart';
import 'package:momentum24_app/widgets/schedule/event_day_list.dart';

class ScheduleScreen extends StatefulWidget {
  const ScheduleScreen({super.key});

  @override
  ScheduleScreenState createState() => ScheduleScreenState();
}

class ScheduleScreenState extends State<ScheduleScreen>
    with TickerProviderStateMixin {
  late TabController _tabController;
  final DataProviderService _dataProviderService =
      GetIt.instance.get<DataProviderService>();
  List<Event> schedule = [];
  bool isLoading = true;
  List<DateTime> uniqueDays = [];

  @override
  void initState() {
    super.initState();
    loadSchedule();
    _tabController = TabController(length: 0, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  Future<void> loadSchedule() async {
    final apiData = await _dataProviderService.getSchedule();
    setState(() {
      updateTabController(apiData);
      schedule = apiData;
      isLoading = false;
    });
  }

  void updateTabController(List<Event> apiData) {
    final uniqueDaysMap = _getUniqueDays(apiData);
    final initialIndex = _getInitialIndex(uniqueDaysMap);
    _tabController.dispose();
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
              children: uniqueDays
                  .map((day) => EventDayList(
                        day: day,
                        allEvents: schedule,
                        dataProviderService: _dataProviderService,
                        onRefresh: (value) {
                          setState(() {
                            updateTabController(value);
                            schedule = value;
                          });
                        },
                      ))
                  .toList(),
            ),
    );
  }

  PreferredSizeWidget getTabBar(BuildContext context) {
    return TabBar(
      controller: _tabController,
      indicator: ActiveTabIndicator(
          color: Theme.of(context).colorScheme.tertiary, radius: 10),
      indicatorSize: TabBarIndicatorSize.label,
      indicatorPadding: const EdgeInsets.all(0),
      dividerHeight: 0,
      tabs: uniqueDays.map((day) {
        return Tab(
          child: AnimatedBuilder(
            animation: _tabController.animation!,
            builder: (context, child) {
              return DayTab(
                day: day,
                daysCount: uniqueDays.length,
              );
            },
          ),
        );
      }).toList(),
    );
  }
}
