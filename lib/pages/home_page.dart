import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:get_it/get_it.dart';
import 'package:persistent_bottom_nav_bar_v2/persistent_bottom_nav_bar_v2.dart';
import 'package:sentry_flutter/sentry_flutter.dart';

import '../colors.dart';
import '../services/api_service.dart';
import '../services/cache_manager.dart';
import '../services/data_provider_service.dart';
import '../widgets/persistent_navbar_style.dart';
import './information_screen.dart';
import './map_screen.dart';
import './notifications_screen.dart';
import './schedule_screen.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  HomePageState createState() => HomePageState();
}

class HomePageState extends State<HomePage> {
  final _defaultDate = DateTime(1970, 1, 1);
  final _updateInterval = const Duration(minutes: 1);

  int unreadNotifications = 0;
  final List<Widget> _screens = [
    const SafeArea(child: ScheduleScreen()),
    const SafeArea(child: NotificationsScreen()),
    const SafeArea(child: InformationScreen()),
    const SafeArea(child: MapScreen()),
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
      maintainBottomViewPadding: true,
      child: Scaffold(
        body: PersistentTabView(
          popAllScreensOnTapOfSelectedTab: true,
          onTabChanged: (value) {
            if (value == 1) {
              setState(() {
                _cacheManager
                    .saveLastReadNotificationDate(DateTime.now().toUtc());
                unreadNotifications = 0;
              });
            }
          },
          tabs: [
            PersistentTabConfig(
                screen: _screens[0],
                item: ItemConfig(
                  icon: const Icon(
                    Icons.schedule,
                    color: highlightColor,
                  ),
                  inactiveIcon: const Icon(Icons.schedule_outlined),
                  title: AppLocalizations.of(context)!.schedule,
                  activeForegroundColor: highlightColor,
                  inactiveForegroundColor: textColor,
                )),
            PersistentTabConfig(
              screen: _screens[1],
              item: ItemConfig(
                  icon: const Icon(
                    Icons.notifications,
                    color: highlightColor,
                  ),
                  title: AppLocalizations.of(context)!.notifications,
                  inactiveIcon: Badge(
                      isLabelVisible: unreadNotifications > 0,
                      label: Text(
                        unreadNotifications.toString(),
                        style: const TextStyle(color: Colors.white),
                      ),
                      child: const Icon(Icons.notifications_outlined)),
                  activeForegroundColor: highlightColor,
                  inactiveForegroundColor: textColor),
            ),
            PersistentTabConfig(
                screen: _screens[2],
                item: ItemConfig(
                    icon: const Icon(
                      Icons.info,
                      color: highlightColor,
                    ),
                    inactiveIcon: const Icon(Icons.info_outline),
                    title: AppLocalizations.of(context)!.information,
                    activeForegroundColor: highlightColor,
                    inactiveForegroundColor: textColor)),
            PersistentTabConfig(
                screen: _screens[3],
                item: ItemConfig(
                    icon: const Icon(
                      Icons.map,
                      color: highlightColor,
                    ),
                    inactiveIcon: const Icon(Icons.map_outlined),
                    title: AppLocalizations.of(context)!.map,
                    activeForegroundColor: highlightColor,
                    inactiveForegroundColor: textColor))
          ],
          navBarBuilder: (navBarConfig) => PersistentNavBarStyle(
            navBarConfig: navBarConfig.copyWith(
              navBarHeight: 60,
            ),
            navBarDecoration: NavBarDecoration(
              color: Theme.of(context).primaryColor,
            ),
          ),
        ),
      ),
    );
  }
}
