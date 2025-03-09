import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:get_it/get_it.dart';
import 'package:momentum24_app/services/theme_service.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

class MomentumAppBar extends StatelessWidget implements PreferredSizeWidget {
  final PreferredSizeWidget? bottom;
  const MomentumAppBar({super.key, this.bottom})
      : preferredSize = bottom == null
            ? const Size.fromHeight(kToolbarHeight)
            : const Size.fromHeight(100);

  @override
  Widget build(BuildContext context) {
    final themeService = GetIt.instance.get<ThemeService>();

    return AnimatedBuilder(
        animation: themeService,
        builder: (context, _) {
          return buildAppBar(context, themeService);
        });
  }

  PreferredSizeWidget buildAppBar(
      BuildContext context, ThemeService themeService) {
    return AppBar(
      title: buildAppBarTitle(context),
      centerTitle: true,
      backgroundColor: Theme.of(context).primaryColor,
      elevation: 0,
      bottom: bottom,
      actions: [
        buildThemeToggleButton(context, themeService),
      ],
    );
  }

  Widget buildAppBarTitle(BuildContext context) {
    return SvgPicture.asset(
      'assets/images/logo.svg',
      fit: BoxFit.contain,
      height: 40,
    );
  }

  Widget buildThemeToggleButton(
      BuildContext context, ThemeService themeService) {
    final localizations = AppLocalizations.of(context);
    final lightThemeText =
        localizations?.switchToLightTheme ?? 'Przełącz na jasny motyw';
    final darkThemeText =
        localizations?.switchToDarkTheme ?? 'Przełącz na ciemny motyw';

    return AnimatedSwitcher(
      duration: const Duration(milliseconds: 300),
      transitionBuilder: (Widget child, Animation<double> animation) {
        return RotationTransition(
          turns: animation,
          child: FadeTransition(
            opacity: animation,
            child: child,
          ),
        );
      },
      child: IconButton(
        key: ValueKey<bool>(themeService.isDarkMode),
        icon: Icon(
          themeService.isDarkMode ? Icons.wb_sunny : Icons.nightlight_round,
          color: Theme.of(context).colorScheme.onPrimary,
        ),
        onPressed: () {
          themeService.toggleTheme();
        },
        tooltip: themeService.isDarkMode ? lightThemeText : darkThemeText,
      ),
    );
  }

  @override
  final Size preferredSize;
}
