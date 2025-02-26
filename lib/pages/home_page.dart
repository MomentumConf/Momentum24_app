import 'dart:async';
import 'dart:convert';
import 'package:web/helpers.dart' as html;

import 'package:async/async.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:get_it/get_it.dart';
import 'package:momentum24_app/pages/information/speakers_screen.dart';
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

final List<String> enabledScreens =
    List<String>.from(jsonDecode('%ENABLED_MODULES%'));

double getBottomPaddingBasedOnDevice() {
  if (kIsWeb && html.window.navigator.userAgent.contains('iPhone')) {
    return 20.0;
  }
  return 5.0;
}

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
          child = Scaffold(
            body: Container(
              color: Theme.of(context).primaryColor,
              child: const Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [CircularProgressIndicator(color: highlightColor)],
                ),
              ),
            ),
          );
        } else {
          child = buildHomePage(context);
        }

        return AnimatedSwitcher(
            duration: const Duration(seconds: 1), child: child);
      },
    );
  }

  Widget buildHomePage(BuildContext context) {
    return SafeArea(
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
            // Schedule
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
            // Notifications
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
            if (enabledScreens.contains('info'))
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
            if (enabledScreens.contains('speakers'))
              PersistentTabConfig(
                  screen: const SafeArea(child: SpeakersScreen()),
                  item: ItemConfig(
                      icon: const Icon(
                        Icons.people_alt,
                        color: highlightColor,
                      ),
                      inactiveIcon: const Icon(Icons.people_alt_outlined),
                      title: AppLocalizations.of(context)!.speakers,
                      activeForegroundColor: highlightColor,
                      inactiveForegroundColor: textColor)),
            if (enabledScreens.contains('map'))
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
              navBarHeight: 60 + (getBottomPaddingBasedOnDevice() / 2),
            ),
            navBarDecoration: NavBarDecoration(
                color: Theme.of(context).primaryColor,
                padding: EdgeInsets.fromLTRB(
                    2, 5, 2, getBottomPaddingBasedOnDevice())),
          ),
        ),
      ),
    );
  }
}
