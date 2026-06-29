import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class AppTheme {
  AppTheme._();

  static const Color primaryColor = Color(0xFF0B1C30);
  static const Color secondaryColor = Color(0xFF4648D4);
  static const Color secondaryContainerColor = Color(0xFF6063EE);
  static const Color secondaryFixedColor = Color(0xFFE1E0FF);
  static const Color surfaceColor = Color(0xFFF8F9FF);
  static const Color surfaceContainer = Color(0xFFE5EEFF);
  static const Color surfaceContainerLow = Color(0xFFEFF4FF);
  static const Color surfaceContainerLowest = Color(0xFFFFFFFF);
  static const Color errorColor = Color(0xFFBA1A1A);
  static const Color outlineColor = Color(0xFF76777D);
  static const Color outlineVariantColor = Color(0xFFC6C6CD);
  static const Color onSurfaceColor = Color(0xFF0B1C30);
  static const Color onSurfaceVariantColor = Color(0xFF45464D);
  static const Color onPrimaryContainerColor = Color(0xFF7C839B);
  static const Color primaryContainerDark = Color(0xFF131B2E);

  static ThemeData get lightTheme {
    const colorScheme = ColorScheme.light(
      primary: secondaryColor,
      secondary: secondaryContainerColor,
      surface: surfaceColor,
      error: errorColor,
      onPrimary: Colors.white,
      onSecondary: Colors.white,
      onSurface: onSurfaceColor,
      onError: Colors.white,
    );

    return ThemeData(
      useMaterial3: true,
      colorScheme: colorScheme,
      scaffoldBackgroundColor: surfaceColor,
      textTheme: GoogleFonts.interTextTheme().copyWith(
        displayLarge: GoogleFonts.inter(
          fontSize: 48,
          fontWeight: FontWeight.w700,
          color: primaryColor,
          letterSpacing: -0.02,
        ),
        displayMedium: GoogleFonts.inter(
          fontSize: 32,
          fontWeight: FontWeight.w700,
          color: primaryColor,
          letterSpacing: -0.02,
        ),
        headlineLarge: GoogleFonts.inter(
          fontSize: 32,
          fontWeight: FontWeight.w600,
          color: primaryColor,
          letterSpacing: -0.01,
        ),
        headlineMedium: GoogleFonts.inter(
          fontSize: 24,
          fontWeight: FontWeight.w600,
          color: primaryColor,
        ),
        titleLarge: GoogleFonts.inter(
          fontSize: 20,
          fontWeight: FontWeight.w500,
          color: primaryColor,
        ),
        titleMedium: GoogleFonts.inter(
          fontSize: 16,
          fontWeight: FontWeight.w500,
          color: onSurfaceColor,
        ),
        bodyLarge: GoogleFonts.inter(
          fontSize: 18,
          fontWeight: FontWeight.w400,
          color: onSurfaceColor,
        ),
        bodyMedium: GoogleFonts.inter(
          fontSize: 16,
          fontWeight: FontWeight.w400,
          color: onSurfaceColor,
        ),
        bodySmall: GoogleFonts.inter(
          fontSize: 14,
          fontWeight: FontWeight.w400,
          color: onSurfaceVariantColor,
        ),
        labelLarge: GoogleFonts.inter(
          fontSize: 14,
          fontWeight: FontWeight.w600,
          color: secondaryColor,
        ),
        labelMedium: GoogleFonts.inter(
          fontSize: 12,
          fontWeight: FontWeight.w400,
          color: onSurfaceVariantColor,
        ),
      ),
      appBarTheme: AppBarTheme(
        backgroundColor: Colors.white.withAlpha(204),
        foregroundColor: onSurfaceColor,
        elevation: 0,
        scrolledUnderElevation: 0,
        centerTitle: true,
        titleTextStyle: GoogleFonts.inter(
          fontSize: 18,
          fontWeight: FontWeight.w600,
          color: onSurfaceColor,
        ),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: secondaryColor,
          foregroundColor: Colors.white,
          elevation: 0,
          shadowColor: secondaryColor.withAlpha(51),
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          textStyle: GoogleFonts.inter(
            fontSize: 16,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          foregroundColor: secondaryColor,
          side: const BorderSide(color: outlineVariantColor),
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          textStyle: GoogleFonts.inter(
            fontSize: 16,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: surfaceContainerLow,
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: outlineVariantColor),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: outlineVariantColor),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: secondaryColor, width: 2),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: errorColor),
        ),
        labelStyle: GoogleFonts.inter(
          fontSize: 14,
          color: onSurfaceVariantColor,
        ),
        hintStyle: GoogleFonts.inter(
          fontSize: 14,
          color: onSurfaceVariantColor,
        ),
        prefixIconColor: onSurfaceVariantColor,
        suffixIconColor: onSurfaceVariantColor,
      ),
      cardTheme: CardThemeData(
        elevation: 0,
        color: surfaceContainerLowest,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
          side: const BorderSide(color: outlineVariantColor, width: 0.5),
        ),
      ),
      dividerTheme: const DividerThemeData(
        color: outlineVariantColor,
        thickness: 1,
      ),
      chipTheme: ChipThemeData(
        backgroundColor: secondaryFixedColor,
        labelStyle: GoogleFonts.inter(
          fontSize: 12,
          fontWeight: FontWeight.w600,
          color: secondaryColor,
        ),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(6),
        ),
      ),
      bottomNavigationBarTheme: const BottomNavigationBarThemeData(
        backgroundColor: Colors.white,
        selectedItemColor: secondaryColor,
        unselectedItemColor: onSurfaceVariantColor,
        elevation: 0,
        type: BottomNavigationBarType.fixed,
      ),
    );
  }
}
