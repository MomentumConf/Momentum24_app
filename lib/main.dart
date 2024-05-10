import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
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

  WidgetsFlutterBinding.ensureInitialized();
  // make navigation bar transparent
  SystemChrome.setSystemUIOverlayStyle(
    const SystemUiOverlayStyle(
      systemNavigationBarColor: Colors.transparent,
    ),
  );
  // make flutter draw behind navigation bar
  SystemChrome.setEnabledSystemUIMode(SystemUiMode.edgeToEdge);

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

const colorBlack = Color.fromRGBO(25, 25, 24, 1);
const primaryColor = Color(0xFFE94190);
const secondary = Color(0xFF3463AC);
const selectedColor = Color(0xFFFFD143);

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
        colorScheme: ColorScheme.fromSeed(seedColor: primaryColor).copyWith(
          primary: primaryColor,
          onPrimary: const Color.fromRGBO(25, 25, 24, 1),
          secondary: secondary,
          onSecondary: Colors.white,
        ),
        useMaterial3: true,
        brightness: Brightness.light,
      ).copyWith(
          primaryColor: primaryColor,
          appBarTheme: const AppBarTheme(
            backgroundColor: primaryColor,
            foregroundColor: colorBlack,
          )),
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
