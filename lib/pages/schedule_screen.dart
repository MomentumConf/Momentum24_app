import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:get_it/get_it.dart';
import 'package:intl/intl.dart';
import '../models/event.dart';
import '../services/data_provider_service.dart';
import '../widgets/schedule_item.dart';
import '../widgets/active_tab_indicator.dart';

class ScheduleScreen extends StatefulWidget {
  const ScheduleScreen({super.key});

  @override
  ScheduleScreenState createState() => ScheduleScreenState();
}

class ScheduleScreenState extends State<ScheduleScreen>
    with TickerProviderStateMixin {
  TabController? _tabController;
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
        centerTitle: false,
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

  Widget buildAppBarTitle(BuildContext context) {
    return SvgPicture.asset(
      'assets/images/logo.svg',
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
          final color = getColor(index + (_tabController?.index ?? 0), context);
          return ScheduleItem(
            event: event,
            color: color,
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

  Color getColor(int index, BuildContext context) {
    List<Color> colors = [
      const Color(0xFF0066FF),
      const Color(0xFFFF3399),
      const Color(0xFF00CC33),
      const Color(0xFFFFD140),
      const Color(0xFFE51813),
    ];
    int currentIndex = index % colors.length;
    return colors[currentIndex];
  }

  PreferredSizeWidget getTabBar(BuildContext context) {
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

        final scale = 1.0 -
            (uniqueDays.indexOf(day) - _tabController!.animation!.value)
                .abs()
                .clamp(0.0, 1.0);

        return Tab(
          child: AnimatedBuilder(
            animation: _tabController!.animation!,
            builder: (context, child) {
              // final color = ColorTween(
              //   begin: const Color(0xFF00CC33),
              //   end: Theme.of(context).colorScheme.onPrimary,
              // ).lerp(scale)!;
              final color = Theme.of(context).colorScheme.onPrimary;

              return SizedBox(
                width: 50,
                height: 50,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      weekday.toUpperCase(),
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        color: color,
                        fontSize: 12,
                      ),
                    ),
                    Text(
                      dayOfMonth,
                      style: TextStyle(
                        fontSize: 20,
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
