import 'dart:async';

import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';
import '../services/data_provider_service.dart';
import 'package:sentry_flutter/sentry_flutter.dart';
import './schedule_screen.dart';
import './notifications_screen.dart';
import './information_screen.dart';
import './map_screen.dart';
import '../services/api_service.dart';
import '../services/cache_manager.dart';
import '../widgets/bottom_navigation_bar.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  HomePageState createState() => HomePageState();
}

class HomePageState extends State<HomePage> {
  final _defaultDate = DateTime(1970, 1, 1);
  final _updateInterval = const Duration(minutes: 1);

  int unreadNotifications = 0;
  int _currentIndex = 0;
  final List<Widget> _screens = [
    const ScheduleScreen(),
    const NotificationsScreen(),
    const InformationScreen(),
    const MapScreen(),
  ];

  final ApiService _apiService = GetIt.instance.get<ApiService>();
  final CacheManager _cacheManager = GetIt.instance.get<CacheManager>();
  final DataProviderService _dataProviderService =
      GetIt.instance.get<DataProviderService>();
  late Timer _timer;

  Future<int?> getUnreadNotifications() async {
    try {
      var lastReadNotificationDate =
          await _cacheManager.getLastReadNotificationDate();
      if (lastReadNotificationDate == null) {
        lastReadNotificationDate = _defaultDate;
        _cacheManager.saveLastReadNotificationDate(lastReadNotificationDate);
      }
      var unreadNotifications = await _apiService
          .countNotificationsFromDate(lastReadNotificationDate);

      // Reset notifications TTL when a new notification arrives
      if (unreadNotifications > 0) {
        _cacheManager.setLastUpdate(
            CacheManager.notificationsKey, _defaultDate);
      }

      return unreadNotifications;
    } catch (e) {
      Sentry.captureException(e);
      return null;
    }
  }

  @override
  void initState() {
    super.initState();
    _dataProviderService.prefetchAndCacheData();
    getUnreadNotificationsCount();
    startTimer();
  }

  void startTimer() {
    _timer = Timer.periodic(_updateInterval, (timer) {
      getUnreadNotificationsCount();
    });
  }

  void getUnreadNotificationsCount() async {
    try {
      final int? value = await getUnreadNotifications();
      setState(() {
        unreadNotifications = value ?? unreadNotifications;
      });
    } catch (e) {
      Sentry.captureException(e);
    }
  }

  @override
  void dispose() {
    _timer.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        body: _screens[_currentIndex],
        bottomNavigationBar: BottomNavigation(
          onDestinationSelected: (index) {
            setState(() {
              _currentIndex = index;
              if (index == 1) {
                _cacheManager
                    .saveLastReadNotificationDate(DateTime.now().toUtc());
                unreadNotifications = 0;
              }
            });
          },
          selectedIndex: _currentIndex,
          unreadNotifications: unreadNotifications,
        ),
      ),
    );
  }
}
