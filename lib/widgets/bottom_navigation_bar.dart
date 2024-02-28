import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

class BottomNavigation extends StatelessWidget {
  final int selectedIndex;
  final Function(int) onDestinationSelected;
  final int unreadNotifications;

  const BottomNavigation({
    super.key,
    required this.selectedIndex,
    required this.onDestinationSelected,
    required this.unreadNotifications,
  });

  @override
  Widget build(BuildContext context) {
    return NavigationBar(
      height: 60,
      selectedIndex: selectedIndex,
      labelBehavior: NavigationDestinationLabelBehavior.alwaysShow,
      onDestinationSelected: onDestinationSelected,
      destinations: [
        NavigationDestination(
          icon: const Icon(Icons.schedule_outlined),
          selectedIcon: const Icon(Icons.schedule),
          label: AppLocalizations.of(context)!.schedule,
        ),
        NavigationDestination(
          icon: Badge(
              isLabelVisible: unreadNotifications > 0,
              label: Text(
                unreadNotifications.toString(),
                style: const TextStyle(color: Colors.white),
              ),
              child: const Icon(Icons.notifications_outlined)),
          selectedIcon: const Icon(Icons.notifications),
          label: AppLocalizations.of(context)!.notifications,
        ),
        NavigationDestination(
          icon: const Icon(Icons.info_outline),
          selectedIcon: const Icon(Icons.info),
          label: AppLocalizations.of(context)!.information,
        ),
        NavigationDestination(
          icon: const Icon(Icons.map_outlined),
          selectedIcon: const Icon(Icons.map),
          label: AppLocalizations.of(context)!.map,
        ),
      ],
    );
  }
}
