import 'package:flutter/material.dart';

class AppTheme {
  // Primary Colors - Updated for better contrast
  static const Color mossGreen = Color(0xFFFF007F); // Replaced with Lighter Latte for better contrast on dark bg
  static const Color leafGreen = Color(0xFF00F0FF); // Replaced with Warm Wood
  static const Color mintGreen = Color(0xFF8A2BE2); // Replaced with Mocha
  static const Color deepSoil = Color(0xFF0A0A0A);
  static const Color warmSand = Color(0xFF121212); // Replaced with Party Cream
  static const Color mistWhite = Color(0xFFFFFFFF);
  static const Color sunGlow = Color(0xFFFFD700);
  static const Color skyBlue = Color(0xFF00FF00); // Replaced with Foam
  static const Color roseGold = Color(0xFFFF1493); // Replaced with Matcha
  static const Color lavender = Color(0xFF2C2C2C); // Replaced with Light Grey
  static const Color coral = Color(0xFFFF4500);
  static const Color slate = Color(0xFFAAAAAA); // Replaced with Light Slate for contrast
  static const Color charcoal = Color(0xFFFFFFFF); // Replaced with Dark Roast
  static const Color cream = Color(0xFF222222);

  // Gradients for existing widgets compatibility
  static const LinearGradient leafGradient = LinearGradient(
    colors: [leafGreen, mossGreen],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static const LinearGradient sunGradient = LinearGradient(
    colors: [Color(0xAAFFB74D), Color(0x00FFB74D)],
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
  );

  static ThemeData get theme => ThemeData(
        fontFamily: 'SF Pro Display',
        scaffoldBackgroundColor: warmSand,
        colorScheme: ColorScheme.fromSeed(
          seedColor: mossGreen,
          brightness: Brightness.dark,
        ),
        textTheme: const TextTheme(
          displayLarge: TextStyle(
            fontSize: 34,
            fontWeight: FontWeight.w800,
            color: charcoal,
            letterSpacing: -1.0,
            height: 1.2,
          ),
          headlineSmall: TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.w700,
            color: charcoal,
            letterSpacing: -0.5,
          ),
          titleLarge: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.w600,
            color: charcoal,
          ),
          titleMedium: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w600,
            color: charcoal,
          ),
          bodyLarge: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w400,
            color: charcoal,
            height: 1.5,
          ),
          bodyMedium: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w400,
            color: slate,
            height: 1.4,
          ),
          labelSmall: TextStyle(
            fontSize: 11,
            fontWeight: FontWeight.w500,
            color: slate,
            letterSpacing: 0.5,
          ),
        ),
      );

  // Compatibility alias for lightTheme
  static ThemeData get lightTheme => theme;
}
