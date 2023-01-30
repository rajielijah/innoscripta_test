
import 'package:flutter/material.dart';

class ThemeUtil {
  static final lightColors = ColorScheme.light(
      primary: Colors.blueGrey.shade900,
      onPrimary: Colors.white,
      secondary: Colors.cyan.shade600,
      onSecondary: Colors.white,
      background: Colors.white,
      onBackground: Colors.black87,
      surface: Colors.grey.shade50,
      onSurface: Colors.black87);

  static final darkColors = ColorScheme.dark(
      primary: Colors.grey.shade900,
      onPrimary: Colors.white,
      secondary: Colors.cyan.shade600,
      onSecondary: Colors.white,
      background: Colors.grey.shade800,
      onBackground: Colors.white,
      surface: Colors.grey.shade900,
      onSurface: Colors.white);

  static final blackColors = ColorScheme.dark(
      primary: Colors.black,
      onPrimary: Colors.white,
      secondary: Colors.cyan.shade600,
      onSecondary: Colors.white,
      background: Colors.black,
      onBackground: Colors.white,
      surface: Colors.black,
      onSurface: Colors.white);

  static final lightTheme = ThemeData(
      brightness: Brightness.light,
      primarySwatch: Colors.blueGrey,
      primaryColor: Colors.blueGrey.shade900,
      primaryColorBrightness: Brightness.dark,
      accentColor: Colors.cyan.shade600,
      accentColorBrightness: Brightness.dark,
      colorScheme: lightColors,
      fontFamily: 'PublicSans',
      //scaffoldBackgroundColor: Colors.grey.shade100,
      scaffoldBackgroundColor: Colors.white,
      appBarTheme: AppBarTheme(backgroundColor: Colors.blueGrey.shade400),
      bottomSheetTheme: BottomSheetThemeData(
        backgroundColor: Colors.blueGrey.shade50,
      ),
      textButtonTheme: TextButtonThemeData(
          style: TextButton.styleFrom(backgroundColor: lightColors.onSurface)),
      textSelectionTheme:
          TextSelectionThemeData(cursorColor: lightColors.secondary),
      expansionTileTheme: ExpansionTileThemeData(
        iconColor: lightColors.onBackground,
        collapsedIconColor: lightColors.onBackground,
      ),
      inputDecorationTheme: InputDecorationTheme(
          focusedBorder: UnderlineInputBorder(
              borderSide: BorderSide(color: lightColors.onPrimary))));

  static final darkTheme = ThemeData(
      brightness: Brightness.dark,
      primarySwatch: Colors.grey,
      primaryColor: Colors.grey.shade900,
      primaryColorBrightness: Brightness.dark,
      accentColor: Colors.cyan.shade600,
      accentColorBrightness: Brightness.dark,
      colorScheme: darkColors,
      fontFamily: 'PublicSans',
      scaffoldBackgroundColor: Colors.grey.shade800,
      appBarTheme: AppBarTheme(backgroundColor: Colors.grey.shade800),
      bottomSheetTheme: const BottomSheetThemeData(
        backgroundColor: Color(0xFF303030),
      ),
      textButtonTheme: TextButtonThemeData(
          style: TextButton.styleFrom(backgroundColor: darkColors.onSurface)),
      textSelectionTheme:
          TextSelectionThemeData(cursorColor: darkColors.secondary),
      expansionTileTheme: ExpansionTileThemeData(
        iconColor: darkColors.onBackground,
        collapsedIconColor: darkColors.onBackground,
      ),
      inputDecorationTheme: InputDecorationTheme(
          labelStyle: TextStyle(color: darkColors.onPrimary),
          focusedBorder: UnderlineInputBorder(
              borderSide: BorderSide(color: darkColors.onPrimary))));

  static final blackTheme = ThemeData(
      brightness: Brightness.dark,
      primarySwatch: Colors.grey,
      primaryColor: Colors.black,
      primaryColorBrightness: Brightness.dark,
      accentColor: Colors.cyan.shade600,
      accentColorBrightness: Brightness.dark,
      colorScheme: blackColors,
      fontFamily: 'PublicSans',
      scaffoldBackgroundColor: Colors.black,
      appBarTheme: AppBarTheme(backgroundColor: Colors.grey.shade800),
      bottomSheetTheme: const BottomSheetThemeData(
        backgroundColor: Colors.black,
      ),
      textButtonTheme: TextButtonThemeData(
          style: TextButton.styleFrom(backgroundColor: blackColors.onSurface)),
      textSelectionTheme:
          TextSelectionThemeData(cursorColor: blackColors.secondary),
      expansionTileTheme: ExpansionTileThemeData(
        iconColor: blackColors.onBackground,
        collapsedIconColor: blackColors.onBackground,
      ),
      inputDecorationTheme: InputDecorationTheme(
          labelStyle: TextStyle(color: blackColors.onPrimary),
          focusedBorder: UnderlineInputBorder(
              borderSide: BorderSide(color: blackColors.onPrimary))));
}
