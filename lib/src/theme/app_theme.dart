import 'package:flutter/material.dart';

ThemeData buildAppTheme() {
  const seed = Color(0xFF69D8C2);
  final scheme = ColorScheme.fromSeed(
    seedColor: seed,
    brightness: Brightness.light,
    surface: const Color(0xFFFFFEFB),
  );

  return ThemeData(
    colorScheme: scheme,
    scaffoldBackgroundColor: const Color(0xFFEFFCF8),
    useMaterial3: true,
    textTheme: const TextTheme(
      headlineMedium: TextStyle(fontSize: 30, fontWeight: FontWeight.w900, color: Color(0xFF14363B)),
      titleLarge: TextStyle(fontSize: 24, fontWeight: FontWeight.w900, color: Color(0xFF14363B)),
      titleMedium: TextStyle(fontSize: 19, fontWeight: FontWeight.w800, color: Color(0xFF14363B)),
      bodyLarge: TextStyle(fontSize: 17, fontWeight: FontWeight.w600, color: Color(0xFF214B4F)),
      bodyMedium: TextStyle(fontSize: 15, fontWeight: FontWeight.w600, color: Color(0xFF5A8181)),
    ),
    cardTheme: CardThemeData(
      color: Colors.white.withValues(alpha: 0.9),
      elevation: 0,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
      margin: EdgeInsets.zero,
    ),
    filledButtonTheme: FilledButtonThemeData(
      style: FilledButton.styleFrom(
        backgroundColor: const Color(0xFF8BDCCF),
        foregroundColor: const Color(0xFF14363B),
        textStyle: const TextStyle(fontWeight: FontWeight.w800, fontSize: 16),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
      ),
    ),
    outlinedButtonTheme: OutlinedButtonThemeData(
      style: OutlinedButton.styleFrom(
        foregroundColor: const Color(0xFF14363B),
        side: const BorderSide(color: Color(0xFFCBEAE3)),
        textStyle: const TextStyle(fontWeight: FontWeight.w700, fontSize: 15),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(22)),
      ),
    ),
    chipTheme: ChipThemeData(
      backgroundColor: const Color(0xFFF6FFFC),
      labelStyle: const TextStyle(fontWeight: FontWeight.w700, color: Color(0xFF315A5E)),
      side: BorderSide.none,
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(999)),
    ),
  );
}
