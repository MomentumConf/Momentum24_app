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

TextTheme darkTextTheme = GoogleFonts.latoTextTheme(TextTheme(
  bodyLarge: TextStyle(color: Color(0xFFEEEEEE)),
  bodyMedium: TextStyle(color: Color(0xFFEEEEEE)),
  bodySmall: TextStyle(color: Color(0xFFEEEEEE)),
  titleLarge: TextStyle(color: Color(0xFFEEEEEE)),
  titleMedium: TextStyle(color: Color(0xFFEEEEEE)),
  titleSmall: TextStyle(color: Color(0xFFEEEEEE)),
));

ThemeData darkTheme = ThemeData(
    colorScheme: ColorScheme.fromSeed(
      seedColor: Color($mainColor),
      brightness: Brightness.dark,
    ).copyWith(
      primary: Color($mainColor),
      onPrimary: Color($textOnPrimaryColor),
      secondary: Color($secondaryColor),
      onSecondary: Color($textOnSecondaryColor),
      tertiary: Color($highlightColor),
      onTertiary: Color($textOnHighlightColor),
      surface: Color(0xFF121212),
      onSurface: Color(0xFFEEEEEE),
      background: Color(0xFF121212),
      onBackground: Color(0xFFEEEEEE),
    ),
    useMaterial3: true,
    brightness: Brightness.dark,
    iconTheme: const IconThemeData(
      color: Color(0xFFEEEEEE),
    ),
    primaryColor: Color($mainColor),
    appBarTheme: const AppBarTheme(
      backgroundColor: Color($mainColor),
      foregroundColor: Color($textOnPrimaryColor),
    ),
    textTheme: darkTextTheme,
    cardTheme: const CardTheme(
      color: Color(0xFF1E1E1E),
    ),
    scaffoldBackgroundColor: Color(0xFF191919),
    dialogTheme: const DialogTheme(
      backgroundColor: Color(0xFF1E1E1E),
    ),
    bottomSheetTheme: const BottomSheetThemeData(
      backgroundColor: Color(0xFF1E1E1E),
    ));
