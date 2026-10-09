import 'package:flutter/material.dart';

const journalTeal = Color(0xFF23685F);
const navyText = Color(0xFF1B3040);
const canvasColor = Color(0xFFF8F5EF);
const mutedSurface = Color(0xFFEBF0EB);
const borderColor = Color(0xFFD9DDD6);

ThemeData medicalTheme() => ThemeData(
  useMaterial3: true,
  colorScheme: ColorScheme.fromSeed(
    seedColor: journalTeal,
    primary: journalTeal,
    onSurface: navyText,
    surface: const Color(0xFFFFFDF8),
  ),
  scaffoldBackgroundColor: canvasColor,
  appBarTheme: const AppBarTheme(
    backgroundColor: canvasColor,
    foregroundColor: navyText,
    surfaceTintColor: Colors.transparent,
    centerTitle: false,
    titleTextStyle: TextStyle(
      color: navyText,
      fontSize: 18,
      fontWeight: FontWeight.w600,
    ),
  ),
  textTheme: const TextTheme(
    headlineMedium: TextStyle(
      fontSize: 25,
      fontWeight: FontWeight.w700,
      color: navyText,
    ),
    titleLarge: TextStyle(
      fontSize: 21,
      fontWeight: FontWeight.w700,
      color: navyText,
    ),
    titleMedium: TextStyle(
      fontSize: 16,
      fontWeight: FontWeight.w600,
      color: navyText,
    ),
    bodyLarge: TextStyle(fontSize: 16, height: 1.4, color: navyText),
    bodyMedium: TextStyle(fontSize: 14, height: 1.4, color: navyText),
    bodySmall: TextStyle(fontSize: 12, height: 1.4, color: Color(0xFF53616A)),
  ),
  dividerTheme: const DividerThemeData(
    color: borderColor,
    thickness: 1,
    space: 1,
  ),
  cardTheme: CardThemeData(
    color: const Color(0xFFFFFDF8),
    elevation: 0,
    margin: EdgeInsets.zero,
    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
  ),
  inputDecorationTheme: InputDecorationTheme(
    filled: true,
    fillColor: const Color(0xFFFFFDF8),
    contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
    border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
    enabledBorder: OutlineInputBorder(
      borderRadius: BorderRadius.circular(8),
      borderSide: const BorderSide(color: borderColor),
    ),
    focusedBorder: OutlineInputBorder(
      borderRadius: BorderRadius.circular(8),
      borderSide: const BorderSide(color: journalTeal, width: 2),
    ),
  ),
  filledButtonTheme: FilledButtonThemeData(
    style: FilledButton.styleFrom(
      minimumSize: const Size(48, 48),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
      textStyle: const TextStyle(fontSize: 15, fontWeight: FontWeight.w600),
    ),
  ),
  outlinedButtonTheme: OutlinedButtonThemeData(
    style: OutlinedButton.styleFrom(
      minimumSize: const Size(48, 48),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
      side: const BorderSide(color: borderColor),
    ),
  ),
  iconButtonTheme: IconButtonThemeData(
    style: IconButton.styleFrom(minimumSize: const Size(48, 48)),
  ),
  navigationBarTheme: const NavigationBarThemeData(
    backgroundColor: Color(0xFFFFFDF8),
    surfaceTintColor: Colors.transparent,
    indicatorColor: mutedSurface,
    labelBehavior: NavigationDestinationLabelBehavior.alwaysShow,
  ),
);
