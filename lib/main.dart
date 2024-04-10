import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:intl/date_symbol_data_local.dart' as date_symbol_data_local;
import 'package:momentum24_app/dependency_container.dart';
import './pages/home_page.dart';
import 'package:sentry_flutter/sentry_flutter.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

Future<void> main() async {
  registerDependencies();
  Intl.defaultLocale = 'pl';
  date_symbol_data_local.initializeDateFormatting();

  // final sentryDsn = Platform.environment['SENTRY_DSN'];
  const sentryDsn = String.fromEnvironment('SENTRY_DSN');
  if (sentryDsn != "") {
    await SentryFlutter.init(
      (options) {
        options.dsn = sentryDsn;
        options.tracesSampleRate = 1.0;
        options.environment = kDebugMode ? 'debug' : 'production';
      },
      appRunner: () => runApp(const ConferenceApp()),
    );
  } else {
    runApp(const ConferenceApp());
  }
}

class ConferenceApp extends StatelessWidget {
  const ConferenceApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Konferencja Momentum',
      localizationsDelegates: AppLocalizations.localizationsDelegates,
      supportedLocales: AppLocalizations.supportedLocales,

      theme: ThemeData(
        colorSchemeSeed: Colors.deepPurple,
        useMaterial3: true,
        brightness: Brightness.light,
      ),
      // darkTheme: ThemeData.dark(useMaterial3: true).copyWith(
      //   primaryColorDark: Colors.purple[900],
      //   textTheme: ThemeData.dark().textTheme.apply(
      //         bodyColor: Colors.white,
      //         displayColor: Colors.white,
      //       ),
      // ),
      home: const HomePage(),
    );
  }
}
