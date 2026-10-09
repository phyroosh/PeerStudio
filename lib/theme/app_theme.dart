import 'package:flutter/material.dart';

class AppTheme {
  static const Color background = Color(0xFF0B0B0F);
  static const Color surface = Color(0xFF16161F);
  static const Color border = Color(0xFF242433);
  static const Color electricCyan = Color(0xFF00F5D4);
  static const Color neonAmethyst = Color(0xFF9B5DE5);

  static ThemeData get darkTheme {
    return ThemeData(
      brightness: Brightness.dark,
      scaffoldBackgroundColor: background,
      colorScheme: const ColorScheme.dark(
        primary: electricCyan,
        secondary: neonAmethyst,
        surface: surface,
      ),
      appBarTheme: const AppBarTheme(
        backgroundColor: Colors.transparent,
        elevation: 0,
        centerTitle: false,
        titleTextStyle: TextStyle(
          fontSize: 24,
          fontWeight: FontWeight.w600,
          letterSpacing: -0.5,
          color: Colors.white,
        ),
      ),
      textTheme: const TextTheme(
        displayLarge: TextStyle(fontSize: 32, fontWeight: FontWeight.bold, letterSpacing: -1),
        displayMedium: TextStyle(fontSize: 28, fontWeight: FontWeight.bold, letterSpacing: -0.5),
        titleLarge: TextStyle(fontSize: 22, fontWeight: FontWeight.w600),
        bodyLarge: TextStyle(fontSize: 16, height: 1.5, color: Colors.white70),
        bodyMedium: TextStyle(fontSize: 14, height: 1.5, color: Colors.white70),
      ),
      useMaterial3: true,
    );
  }
}
