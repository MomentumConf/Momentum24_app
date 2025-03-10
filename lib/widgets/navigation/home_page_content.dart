import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:momentum24_app/widgets/navigation/app_navigation_tabs.dart';
import 'package:momentum24_app/widgets/persistent_navbar_style.dart';
import 'package:persistent_bottom_nav_bar_v2/persistent_bottom_nav_bar_v2.dart';
import 'package:web/web.dart' as html;

/// Returns the appropriate bottom padding based on the device type.
double getBottomPaddingBasedOnDevice() {
  if (kIsWeb && html.window.navigator.userAgent.contains('iPhone')) {
    return 20.0;
  }
  return 5.0;
}

class HomePageContent extends StatelessWidget {
  final AppNavigationTabs navigationTabs;
  final void Function(int)? onTabChanged;

  const HomePageContent({
    super.key,
    required this.navigationTabs,
    this.onTabChanged,
  });

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        body: PersistentTabView(
          popAllScreensOnTapOfSelectedTab: true,
          onTabChanged: onTabChanged,
          tabs: navigationTabs.buildTabs(context),
          navBarBuilder: (navBarConfig) => PersistentNavBarStyle(
            navBarConfig: navBarConfig.copyWith(
              navBarHeight: 60 + (getBottomPaddingBasedOnDevice() / 2),
            ),
            navBarDecoration: NavBarDecoration(
              color: Theme.of(context).primaryColor,
              padding: EdgeInsets.fromLTRB(
                2,
                5,
                2,
                getBottomPaddingBasedOnDevice(),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
