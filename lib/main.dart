import 'package:fast_cached_network_image/fast_cached_network_image.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get_it/get_it.dart';
import 'package:intl/intl.dart';
import 'package:intl/date_symbol_data_local.dart' as date_symbol_data_local;
import 'package:momentum24_app/services/theme_service.dart';
import 'package:sentry_flutter/sentry_flutter.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:momentum24_app/dependency_container.dart';
import 'package:momentum24_app/pages/home_page.dart';
import 'package:momentum24_app/colors.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  registerDependencies();
  Intl.defaultLocale = 'pl';
  date_symbol_data_local.initializeDateFormatting();

  // make navigation bar transparent
  SystemChrome.setSystemUIOverlayStyle(
    const SystemUiOverlayStyle(
      systemNavigationBarColor: Colors.transparent,
    ),
  );
  // make flutter draw behind navigation bar
  SystemChrome.setEnabledSystemUIMode(SystemUiMode.edgeToEdge);

  const sentryDsn = String.fromEnvironment('SENTRY_DSN');
  if (sentryDsn != "") {
    await SentryFlutter.init(
      (options) {
        options.dsn = sentryDsn;
        options.tracesSampleRate = 1.0;
        options.environment = kDebugMode ? 'debug' : 'production';
      },
    );
  }
  await FastCachedImageConfig.init();
  runApp(const ConferenceApp());
}

class ConferenceApp extends StatelessWidget {
  const ConferenceApp({super.key});

  @override
  Widget build(BuildContext context) {
    final themeService = GetIt.instance.get<ThemeService>();

    return AnimatedBuilder(
        animation: themeService,
        builder: (context, _) {
          return MaterialApp(
            debugShowCheckedModeBanner: false,
            title: const String.fromEnvironment('TITLE'),
            localizationsDelegates: AppLocalizations.localizationsDelegates,
            supportedLocales: AppLocalizations.supportedLocales,
            theme: lightTheme,
            darkTheme: darkTheme,
            themeMode: themeService.themeMode,
            home: const HomePage(),
          );
        });
  }
}
