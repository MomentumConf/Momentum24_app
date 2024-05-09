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
const primaryColor = Color.fromRGBO(233, 65, 144, 1);
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
        ),
        navigationBarTheme: NavigationBarThemeData(
            backgroundColor: primaryColor,
            indicatorColor: colorBlack,
            iconTheme: MaterialStateProperty.resolveWith((state) {
              if (state.contains(MaterialState.selected)) {
                return const IconThemeData(color: selectedColor);
              }
              return const IconThemeData(color: colorBlack);
            }),
            labelTextStyle: MaterialStateProperty.resolveWith((state) {
              Color color = colorBlack;

              if (state.contains(MaterialState.selected)) {
                color = selectedColor;
              }

              return TextStyle(
                color: color,
                fontSize: 13,
              );
            })),
        useMaterial3: true,
        brightness: Brightness.light,
      ).copyWith(
        primaryColor: primaryColor,
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
