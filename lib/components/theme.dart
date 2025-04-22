// lib/components/theme.dart

import 'package:flutter/material.dart';

const kPrimaryAccent = Color(0xFF8A56AC);

final ThemeData appTheme = ThemeData(
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
    elevation: 0, // ← flat, no shadow
    shadowColor: Colors.transparent,
    centerTitle: true,
    titleTextStyle: TextStyle(
      fontSize: 18,
      fontWeight: FontWeight.w600,
      color: Colors.black,
    ),
    toolbarHeight: 48, // ← standard minimal height
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
