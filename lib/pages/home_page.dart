import 'dart:async';
import 'dart:convert';

import 'package:async/async.dart';
import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';
import 'package:sentry_flutter/sentry_flutter.dart';

import '../services/api_service.dart';
import '../services/cache_manager.dart';
import '../services/data_provider_service.dart';
import '../widgets/loading_screen.dart';
import '../widgets/navigation/app_navigation_tabs.dart';
import '../widgets/navigation/home_page_content.dart';

final List<String> enabledScreens =
    const String.fromEnvironment('ENABLED_MODULES', defaultValue: 'info;map')
        .split(';');

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  HomePageState createState() => HomePageState();
}

class HomePageState extends State<HomePage> {
  final _defaultDate = DateTime(1970, 1, 1);
  final _updateInterval = const Duration(minutes: 1);

  int unreadNotifications = 0;

  final ApiService _apiService = GetIt.instance.get<ApiService>();
  final CacheManager _cacheManager = GetIt.instance.get<CacheManager>();
  final DataProviderService _dataProviderService =
      GetIt.instance.get<DataProviderService>();
  late Timer _timer;
  final AsyncMemoizer _memorizer = AsyncMemoizer();

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
    return FutureBuilder(
      future:
          _memorizer.runOnce(() => _dataProviderService.prefetchAndCacheData()),
      builder: (context, snapshot) {
        Widget child;
        if (snapshot.connectionState != ConnectionState.done) {
          child = const LoadingScreen();
        } else {
          child = buildHomePage(context);
        }

        return AnimatedSwitcher(
            duration: const Duration(seconds: 1), child: child);
      },
    );
  }

  Widget buildHomePage(BuildContext context) {
    return HomePageContent(
      navigationTabs: AppNavigationTabs(
        enabledScreens: enabledScreens,
        unreadNotifications: unreadNotifications,
      ),
      onTabChanged: (value) {
        if (value == 1) {
          setState(() {
            _cacheManager.saveLastReadNotificationDate(DateTime.now().toUtc());
            unreadNotifications = 0;
          });
        }
      },
    );
  }
}
