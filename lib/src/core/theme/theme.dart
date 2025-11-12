
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class AppTheme {
  static const Color _primarySeedColor = Colors.pink;

  static final ThemeData lightTheme = ThemeData(
    useMaterial3: true,
    colorScheme: ColorScheme.fromSeed(
      seedColor: _primarySeedColor,
      brightness: Brightness.light,
    ),
    textTheme: _textTheme,
    appBarTheme: _appBarTheme(ColorScheme.fromSeed(seedColor: _primarySeedColor, brightness: Brightness.light)),
    elevatedButtonTheme: _elevatedButtonTheme(ColorScheme.fromSeed(seedColor: _primarySeedColor, brightness: Brightness.light)),
    cardTheme: _cardTheme,
  );

  static final ThemeData darkTheme = ThemeData(
    useMaterial3: true,
    colorScheme: ColorScheme.fromSeed(
      seedColor: _primarySeedColor,
      brightness: Brightness.dark,
    ),
    textTheme: _textTheme,
    appBarTheme: _appBarTheme(ColorScheme.fromSeed(seedColor: _primarySeedColor, brightness: Brightness.dark)),
    elevatedButtonTheme: _elevatedButtonTheme(ColorScheme.fromSeed(seedColor: _primarySeedColor, brightness: Brightness.dark)),
    cardTheme: _cardTheme,
  );

  static final TextTheme _textTheme = TextTheme(
    displayLarge: GoogleFonts.montserrat(fontSize: 57, fontWeight: FontWeight.bold),
    displayMedium: GoogleFonts.montserrat(fontSize: 45, fontWeight: FontWeight.bold),
    displaySmall: GoogleFonts.montserrat(fontSize: 36, fontWeight: FontWeight.bold),
    headlineLarge: GoogleFonts.montserrat(fontSize: 32, fontWeight: FontWeight.bold),
    headlineMedium: GoogleFonts.montserrat(fontSize: 28, fontWeight: FontWeight.bold),
    headlineSmall: GoogleFonts.montserrat(fontSize: 24, fontWeight: FontWeight.w500),
    titleLarge: GoogleFonts.montserrat(fontSize: 22, fontWeight: FontWeight.w500),
    titleMedium: GoogleFonts.lato(fontSize: 16, fontWeight: FontWeight.w500, letterSpacing: 0.15),
    titleSmall: GoogleFonts.lato(fontSize: 14, fontWeight: FontWeight.w500, letterSpacing: 0.1),
    bodyLarge: GoogleFonts.lato(fontSize: 16, fontWeight: FontWeight.normal, letterSpacing: 0.5),
    bodyMedium: GoogleFonts.lato(fontSize: 14, fontWeight: FontWeight.normal, letterSpacing: 0.25),
    labelLarge: GoogleFonts.lato(fontSize: 14, fontWeight: FontWeight.w500, letterSpacing: 1.25),
    bodySmall: GoogleFonts.lato(fontSize: 12, fontWeight: FontWeight.normal, letterSpacing: 0.4),
    labelSmall: GoogleFonts.lato(fontSize: 10, fontWeight: FontWeight.normal, letterSpacing: 1.5),
  );

  static AppBarTheme _appBarTheme(ColorScheme colorScheme) => AppBarTheme(
        backgroundColor: colorScheme.surface, 
        foregroundColor: colorScheme.onSurface, 
        elevation: 0,
        titleTextStyle: _textTheme.headlineSmall?.copyWith(color: colorScheme.onSurface, fontWeight: FontWeight.bold), 
      );

  static ElevatedButtonThemeData _elevatedButtonTheme(ColorScheme colorScheme) =>
      ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          foregroundColor: colorScheme.onPrimary,
          backgroundColor: colorScheme.primary,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
          textStyle: _textTheme.labelLarge,
        ),
      );

  static final CardThemeData _cardTheme = CardThemeData(
    elevation: 5,
    shadowColor: Colors.black.withOpacity(0.1),
    shape: RoundedRectangleBorder(
      borderRadius: BorderRadius.circular(12.0),
    ),
    margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
  );
}
