import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';
import 'package:intl/intl.dart';
import '../models/event.dart';
import '../services/data_provider_service.dart';
import '../widgets/schedule_item.dart';
import '../widgets/active_tab_indicator.dart';
import '../services/cache_manager.dart';

class ScheduleScreen extends StatefulWidget {
  const ScheduleScreen({super.key});

  @override
  ScheduleScreenState createState() => ScheduleScreenState();
}

class ScheduleScreenState extends State<ScheduleScreen>
    with TickerProviderStateMixin {
  TabController? _tabController;
  final CacheManager _cacheManager = GetIt.instance.get<CacheManager>();
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
      appBar: AppBar(
        title: buildAppBarTitle(context),
        backgroundColor: Theme.of(context).primaryColor,
        elevation: 0,
        bottom: isLoading || uniqueDays.isEmpty ? null : getTabBar(context),
      ),
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : TabBarView(
              controller: _tabController,
              children:
                  uniqueDays.map((day) => getEventDay(day, context)).toList(),
            ),
    );
  }

  Text buildAppBarTitle(BuildContext context) {
    return Text(
      'Momentum Konf  2024',
      style: TextStyle(
        color: Theme.of(context).colorScheme.onPrimary,
        fontSize: 20,
        fontWeight: FontWeight.bold,
        fontFeatures: const [FontFeature.enable('smcp')],
      ),
    );
  }

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
          final colors =
              getColors(index + (_tabController?.index ?? 0), context);
          return ScheduleItem(
            event: event,
            color: colors[0],
            nextColor:
                (events.length > index + 1) ? colors[1] : Colors.transparent,
          );
        },
      ),
    );
  }

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

  List<Color> getColors(int index, BuildContext context) {
    final theme = Theme.of(context);
    List<Color> colors = [
      theme.primaryColorLight,
      theme.colorScheme.secondary,
      theme.colorScheme.tertiary,
      theme.primaryColorDark
    ];
    int currentIndex = index % colors.length;
    int nextIndex = (index + 1) % colors.length;
    return [colors[currentIndex], colors[nextIndex]];
  }

  TabBar getTabBar(BuildContext context) {
    return TabBar(
      controller: _tabController,
      indicator: ActiveTabIndicator(color: Colors.white, radius: 10),
      indicatorSize: TabBarIndicatorSize.label,
      indicatorPadding: const EdgeInsets.all(0),
      dividerHeight: 0,
      tabs: uniqueDays.map((day) {
        return Tab(
          child: AnimatedBuilder(
            animation: _tabController!.animation!,
            builder: (BuildContext context, Widget? child) {
              final double scale =
                  (_tabController!.animation!.value - uniqueDays.indexOf(day))
                      .abs()
                      .clamp(0.0, 1.0);
              final Color color = ColorTween(
                begin: Theme.of(context).primaryColor,
                end: Colors.white70,
              ).lerp(scale)!;
              return Transform.scale(
                scale: 1.0 + (0.3 * (1.0 - scale)),
                child: SizedBox(
                  width: 65,
                  height: 65,
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: <Widget>[
                      Text(
                        DateFormat('EEE')
                            .format(day)
                            .replaceAll(RegExp(r'\.$'), ''), // Weekday name
                        textAlign: TextAlign.center,
                        style: TextStyle(
                            color: color, fontSize: 12), // Adjusted font size
                      ),
                      Text(
                        DateFormat('d').format(day), // Day number
                        style: TextStyle(
                            fontSize: 20,
                            color: color,
                            fontWeight: FontWeight.bold),
                      ),
                    ],
                  ),
                ),
              );
            },
          ),
        );
      }).toList(),
    );
  }
}
