// lib/components/theme.dart
import 'package:flutter/material.dart';

const kPrimaryAccent = Color(0xFF8A56AC);

class AppTheme {
  static final lightTheme = ThemeData(
    useMaterial3: false,
    scaffoldBackgroundColor: Colors.white,
    primaryColor: kPrimaryAccent,
    colorScheme: ColorScheme.fromSeed(
      seedColor: kPrimaryAccent,
      brightness: Brightness.light,
    ),
    appBarTheme: const AppBarTheme(
      backgroundColor: Colors.white,
      foregroundColor: Colors.black,
      elevation: 0,
      shadowColor: Colors.transparent,
      centerTitle: true,
      titleTextStyle: TextStyle(
        fontSize: 18,
        fontWeight: FontWeight.w600,
        color: Colors.black,
      ),
      toolbarHeight: 48,
    ),
    iconTheme: const IconThemeData(color: Colors.black),
    bottomNavigationBarTheme: BottomNavigationBarThemeData(
      selectedItemColor: kPrimaryAccent,
      unselectedItemColor: Colors.grey,
      backgroundColor: Colors.white,
      elevation: 10,
    ),
    floatingActionButtonTheme: FloatingActionButtonThemeData(
      backgroundColor: kPrimaryAccent,
      foregroundColor: Colors.white,
    ),
  );

  static final darkTheme = ThemeData(
    useMaterial3: false,
    scaffoldBackgroundColor: const Color(0xFF121212), // Dark grey background
    primaryColor: kPrimaryAccent,
    colorScheme: ColorScheme.fromSeed(
      seedColor: kPrimaryAccent,
      brightness: Brightness.dark,
      background: const Color(0xFF121212),
      surface: const Color(0xFF1E1E1E), // Slightly lighter for cards/lists
    ),
    appBarTheme: const AppBarTheme(
      backgroundColor: Color(0xFF1E1E1E), // Darker app bar
      foregroundColor: Colors.white,
      elevation: 0,
      shadowColor: Colors.transparent,
      centerTitle: true,
      titleTextStyle: TextStyle(
        fontSize: 18,
        fontWeight: FontWeight.w600,
        color: Colors.white,
      ),
      toolbarHeight: 48,
    ),
    iconTheme: const IconThemeData(color: Colors.white),
    bottomNavigationBarTheme: BottomNavigationBarThemeData(
      selectedItemColor: kPrimaryAccent,
      unselectedItemColor: Colors.grey[400],
      backgroundColor: const Color(0xFF1E1E1E),
      elevation: 10,
    ),
    floatingActionButtonTheme: FloatingActionButtonThemeData(
      backgroundColor: kPrimaryAccent,
      foregroundColor: Colors.white,
    ),
  );
}
