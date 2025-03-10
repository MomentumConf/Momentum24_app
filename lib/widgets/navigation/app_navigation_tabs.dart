import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:momentum24_app/pages/information/speakers_screen.dart';
import 'package:momentum24_app/pages/information_screen.dart';
import 'package:momentum24_app/pages/map_screen.dart';
import 'package:momentum24_app/pages/notifications_screen.dart';
import 'package:momentum24_app/pages/schedule_screen.dart';
import 'package:persistent_bottom_nav_bar_v2/persistent_bottom_nav_bar_v2.dart';

/// A utility class that provides navigation tab configurations for the app.
class AppNavigationTabs {
  final List<String> enabledScreens;
  final int unreadNotifications;

  const AppNavigationTabs({
    required this.enabledScreens,
    required this.unreadNotifications,
  });

  Map<String, Widget> getScreens() {
    final Map<String, Widget> screens = {
      'schedule': const SafeArea(child: ScheduleScreen()),
      'notifications': const SafeArea(child: NotificationsScreen()),
    };

    if (enabledScreens.contains('info')) {
      screens['info'] = const SafeArea(child: InformationScreen());
    }

    if (enabledScreens.contains('map')) {
      screens['map'] = const SafeArea(child: MapScreen());
    }

    if (enabledScreens.contains('speakers')) {
      screens['speakers'] = const SafeArea(child: SpeakersScreen());
    }

    return screens;
  }

  List<PersistentTabConfig> buildTabs(BuildContext context) {
    final Map<String, Widget> availableScreens = getScreens();
    final List<PersistentTabConfig> tabs = [
      _buildScheduleTab(context, availableScreens['schedule']!),
      _buildNotificationsTab(context, availableScreens['notifications']!),
    ];

    if (availableScreens.containsKey('info')) {
      tabs.add(_buildInfoTab(context, availableScreens['info']!));
    }

    if (availableScreens.containsKey('speakers')) {
      tabs.add(_buildSpeakersTab(context, availableScreens['speakers']!));
    }

    if (availableScreens.containsKey('map')) {
      tabs.add(_buildMapTab(context, availableScreens['map']!));
    }

    return tabs;
  }

  PersistentTabConfig _buildScheduleTab(BuildContext context, Widget screen) {
    return PersistentTabConfig(
      screen: screen,
      item: ItemConfig(
        icon: Icon(
          Icons.schedule,
          color: Theme.of(context).colorScheme.tertiary,
        ),
        inactiveIcon: const Icon(Icons.schedule_outlined),
        title: AppLocalizations.of(context)!.schedule,
        activeForegroundColor: Theme.of(context).colorScheme.tertiary,
        inactiveForegroundColor: Theme.of(context).colorScheme.onPrimary,
      ),
    );
  }

  PersistentTabConfig _buildNotificationsTab(
      BuildContext context, Widget screen) {
    return PersistentTabConfig(
      screen: screen,
      item: ItemConfig(
        icon: Icon(
          Icons.notifications,
          color: Theme.of(context).colorScheme.tertiary,
        ),
        title: AppLocalizations.of(context)!.notifications,
        inactiveIcon: Badge(
          backgroundColor: Theme.of(context).colorScheme.tertiary,
          isLabelVisible: unreadNotifications > 0,
          label: Text(
            unreadNotifications.toString(),
            style: TextStyle(
              color: Theme.of(context).colorScheme.onTertiary,
            ),
          ),
          child: const Icon(Icons.notifications_outlined),
        ),
        activeForegroundColor: Theme.of(context).colorScheme.tertiary,
        inactiveForegroundColor: Theme.of(context).colorScheme.onPrimary,
      ),
    );
  }

  PersistentTabConfig _buildInfoTab(BuildContext context, Widget screen) {
    return PersistentTabConfig(
      screen: screen,
      item: ItemConfig(
        icon: Icon(
          Icons.info,
          color: Theme.of(context).colorScheme.tertiary,
        ),
        inactiveIcon: const Icon(Icons.info_outline),
        title: AppLocalizations.of(context)!.information,
        activeForegroundColor: Theme.of(context).colorScheme.tertiary,
        inactiveForegroundColor: Theme.of(context).colorScheme.onPrimary,
      ),
    );
  }

  PersistentTabConfig _buildSpeakersTab(BuildContext context, Widget screen) {
    return PersistentTabConfig(
      screen: screen,
      item: ItemConfig(
        icon: Icon(
          Icons.people_alt,
          color: Theme.of(context).colorScheme.tertiary,
        ),
        inactiveIcon: const Icon(Icons.people_alt_outlined),
        title: AppLocalizations.of(context)!.speakers,
        activeForegroundColor: Theme.of(context).colorScheme.tertiary,
        inactiveForegroundColor: Theme.of(context).colorScheme.onPrimary,
      ),
    );
  }

  PersistentTabConfig _buildMapTab(BuildContext context, Widget screen) {
    return PersistentTabConfig(
      screen: screen,
      item: ItemConfig(
        icon: Icon(
          Icons.map,
          color: Theme.of(context).colorScheme.tertiary,
        ),
        inactiveIcon: const Icon(Icons.map_outlined),
        title: AppLocalizations.of(context)!.map,
        activeForegroundColor: Theme.of(context).colorScheme.tertiary,
        inactiveForegroundColor: Theme.of(context).colorScheme.onPrimary,
      ),
    );
  }
}
