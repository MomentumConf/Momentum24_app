import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart' show GoogleFonts;

TextTheme textTheme = GoogleFonts.latoTextTheme(TextTheme(
  bodyLarge: TextStyle(color: Color($textColor)),
  bodyMedium: TextStyle(color: Color($textColor)),
  bodySmall: TextStyle(color: Color($textColor)),
  titleLarge: TextStyle(color: Color($textColor)),
  titleMedium: TextStyle(color: Color($textColor)),
  titleSmall: TextStyle(color: Color($textColor)),
));

ThemeData lightTheme = ThemeData(
    colorScheme: ColorScheme.fromSeed(seedColor: Color($mainColor)).copyWith(
      primary: Color($mainColor),
      onPrimary: Color($textOnPrimaryColor),
      secondary: Color($secondaryColor),
      onSecondary: Color($textOnSecondaryColor),
      tertiary: Color($highlightColor),
      onTertiary: Color($textOnHighlightColor),
      surface: Colors.white,
      onSurface: Color($textColor),
      background: Colors.white,
      onBackground: Color($textColor),
    ),
    useMaterial3: true,
    brightness: Brightness.light,
    iconTheme: const IconThemeData(
      color: Color($textColor),
    ),
    primaryColor: Color($mainColor),
    appBarTheme: const AppBarTheme(
      backgroundColor: Color($mainColor),
      foregroundColor: Color($textOnPrimaryColor),
    ),
    textTheme: textTheme,
    cardTheme: const CardTheme(
      color: Colors.white,
    ),
    dialogTheme: const DialogTheme(
      backgroundColor: Colors.white,
    ),
    bottomSheetTheme: const BottomSheetThemeData(
      backgroundColor: Colors.white,
    ));
