// PHASE 1 - UI & navigation (layout, theme, widgets)
import 'package:flutter/material.dart';

class AppColors {
  static const primary = Color(0xFF5B3DF5);
  static const primary2 = Color(0xFF8A6BFF);
  static const deep = Color(0xFF1A1050);
  static const ok = Color(0xFF22B573);
  static const warn = Color(0xFFF59E0B);
  static const bad = Color(0xFFEF4444);
  static const hero = LinearGradient(
      begin: Alignment.topLeft, end: Alignment.bottomRight, colors: [deep, Color(0xFF4B2FD8)]);
  static const btn = LinearGradient(colors: [primary, primary2]);
}

ThemeData buildTheme(Brightness b) {
  final dark = b == Brightness.dark;
  return ThemeData(
    useMaterial3: true,
    colorScheme: ColorScheme.fromSeed(seedColor: AppColors.primary, brightness: b),
    scaffoldBackgroundColor: dark ? const Color(0xFF0B0724) : const Color(0xFFF1EEFF),
    appBarTheme: const AppBarTheme(
        backgroundColor: Colors.transparent, elevation: 0, scrolledUnderElevation: 0, centerTitle: true),
  );
}
