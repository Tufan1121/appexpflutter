import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class Colores {
  // 🎨 Paleta Moderna 2024-2025
  static const colorSeed = Color(0xff6366F1);
  static const Color primaryColor = Color(0xff6366F1); // Indigo moderno
  static const Color secondaryColor = Color(0xffEC4899); // Pink suave
  static const Color accentColor = Color(0xff8B5CF6); // Púrpura
  
  // Backgrounds
  static const scaffoldBackgroundColor = Color(0xFFFAFAFA);
  static const surfaceColor = Color(0xFFFFFFFF);
  static const cardColor = Color(0xFFFFFFFF);
  
  // Semantic colors
  static const successColor = Color(0xff10B981);
  static const warningColor = Color(0xffF59E0B);
  static const errorColor = Color(0xffEF4444);
  
  // Neutral colors
  static const textPrimary = Color(0xff0F172A);
  static const textSecondary = Color(0xff64748B);
  static const textTertiary = Color(0xff94A3B8);
  static const dividerColor = Color(0xffE2E8F0);
  
  // Gradients
  static const gradientStart = Color(0xff6366F1);
  static const gradientEnd = Color(0xff8B5CF6);
}

class AppTheme {
  ThemeData getTheme() => ThemeData(
      ///* General
      useMaterial3: true,
      colorSchemeSeed: Colores.colorSeed,
      brightness: Brightness.light,

      ///* Color Scheme
      colorScheme: const ColorScheme.light(
        primary: Colores.primaryColor,
        secondary: Colores.secondaryColor,
        tertiary: Colores.accentColor,
        surface: Colores.surfaceColor,
        error: Colores.errorColor,
      ),

      ///* Texts - Sistema tipográfico escalable
      textTheme: TextTheme(
        // Display (Headlines grandes)
        displayLarge: GoogleFonts.montserratAlternates().copyWith(
          fontSize: 57,
          fontWeight: FontWeight.w700,
          height: 1.12,
          letterSpacing: -0.25,
        ),
        displayMedium: GoogleFonts.montserratAlternates().copyWith(
          fontSize: 45,
          fontWeight: FontWeight.w700,
          height: 1.16,
        ),
        displaySmall: GoogleFonts.montserratAlternates().copyWith(
          fontSize: 36,
          fontWeight: FontWeight.w600,
          height: 1.22,
        ),
        
        // Headlines (Títulos)
        headlineLarge: GoogleFonts.montserratAlternates().copyWith(
          fontSize: 32,
          fontWeight: FontWeight.w600,
          height: 1.25,
        ),
        headlineMedium: GoogleFonts.montserratAlternates().copyWith(
          fontSize: 28,
          fontWeight: FontWeight.w600,
          height: 1.29,
        ),
        headlineSmall: GoogleFonts.montserratAlternates().copyWith(
          fontSize: 24,
          fontWeight: FontWeight.w600,
          height: 1.33,
        ),
        
        // Titles
        titleLarge: GoogleFonts.montserratAlternates().copyWith(
          fontSize: 22,
          fontWeight: FontWeight.w600,
          height: 1.27,
        ),
        titleMedium: GoogleFonts.montserratAlternates().copyWith(
          fontSize: 16,
          fontWeight: FontWeight.w600,
          height: 1.5,
          letterSpacing: 0.15,
        ),
        titleSmall: GoogleFonts.montserratAlternates().copyWith(
          fontSize: 14,
          fontWeight: FontWeight.w600,
          height: 1.43,
          letterSpacing: 0.1,
        ),
        
        // Body
        bodyLarge: GoogleFonts.montserrat().copyWith(
          fontSize: 16,
          fontWeight: FontWeight.w400,
          height: 1.5,
          letterSpacing: 0.5,
        ),
        bodyMedium: GoogleFonts.montserrat().copyWith(
          fontSize: 14,
          fontWeight: FontWeight.w400,
          height: 1.43,
          letterSpacing: 0.25,
        ),
        bodySmall: GoogleFonts.montserrat().copyWith(
          fontSize: 12,
          fontWeight: FontWeight.w400,
          height: 1.33,
          letterSpacing: 0.4,
        ),
        
        // Labels
        labelLarge: GoogleFonts.montserrat().copyWith(
          fontSize: 14,
          fontWeight: FontWeight.w500,
          height: 1.43,
          letterSpacing: 0.1,
        ),
        labelMedium: GoogleFonts.montserrat().copyWith(
          fontSize: 12,
          fontWeight: FontWeight.w500,
          height: 1.33,
          letterSpacing: 0.5,
        ),
        labelSmall: GoogleFonts.montserrat().copyWith(
          fontSize: 11,
          fontWeight: FontWeight.w500,
          height: 1.45,
          letterSpacing: 0.5,
        ),
      ),

      ///* Scaffold Background
      scaffoldBackgroundColor: Colores.scaffoldBackgroundColor,

      ///* Card Theme - Estilo moderno con glassmorphism
      cardTheme: CardThemeData(
        color: Colores.cardColor,
        elevation: 0,
        shadowColor: Colors.black.withOpacity(0.05),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
          side: BorderSide(
            color: Colores.dividerColor.withOpacity(0.5),
            width: 1,
          ),
        ),
        margin: const EdgeInsets.all(8),
      ),

      ///* Buttons - Diseño contemporáneo
      filledButtonTheme: FilledButtonThemeData(
        style: ButtonStyle(
          backgroundColor: WidgetStateProperty.resolveWith((states) {
            if (states.contains(WidgetState.disabled)) {
              return Colores.textTertiary;
            }
            return Colores.primaryColor;
          }),
          foregroundColor: const WidgetStatePropertyAll(Colors.white),
          elevation: WidgetStateProperty.resolveWith((states) {
            if (states.contains(WidgetState.pressed)) return 0;
            if (states.contains(WidgetState.hovered)) return 2;
            return 1;
          }),
          padding: const WidgetStatePropertyAll(
            EdgeInsets.symmetric(horizontal: 24, vertical: 16),
          ),
          shape: WidgetStatePropertyAll(
            RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
          ),
          textStyle: WidgetStatePropertyAll(
            GoogleFonts.montserrat(
              fontWeight: FontWeight.w600,
              fontSize: 16,
              letterSpacing: 0.5,
            ),
          ),
        ),
      ),

      outlinedButtonTheme: OutlinedButtonThemeData(
        style: ButtonStyle(
          foregroundColor: const WidgetStatePropertyAll(Colores.primaryColor),
          side: WidgetStateProperty.resolveWith((states) {
            if (states.contains(WidgetState.hovered)) {
              return const BorderSide(color: Colores.primaryColor, width: 2);
            }
            return const BorderSide(color: Colores.primaryColor, width: 1.5);
          }),
          padding: const WidgetStatePropertyAll(
            EdgeInsets.symmetric(horizontal: 24, vertical: 16),
          ),
          shape: WidgetStatePropertyAll(
            RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
          ),
        ),
      ),

      textButtonTheme: TextButtonThemeData(
        style: ButtonStyle(
          foregroundColor: const WidgetStatePropertyAll(Colores.primaryColor),
          padding: const WidgetStatePropertyAll(
            EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          ),
          textStyle: WidgetStatePropertyAll(
            GoogleFonts.montserrat(
              fontWeight: FontWeight.w600,
              fontSize: 14,
            ),
          ),
        ),
      ),

      ///* AppBar - Estilo moderno y limpio
      appBarTheme: AppBarTheme(
        centerTitle: false,
        elevation: 0,
        scrolledUnderElevation: 1,
        backgroundColor: Colores.surfaceColor,
        surfaceTintColor: Colors.transparent,
        shadowColor: Colors.black.withOpacity(0.05),
        foregroundColor: Colores.textPrimary,
        titleTextStyle: GoogleFonts.montserratAlternates().copyWith(
          fontSize: 20,
          fontWeight: FontWeight.w700,
          color: Colores.textPrimary,
          letterSpacing: 0.15,
        ),
        iconTheme: const IconThemeData(
          color: Colores.textPrimary,
          size: 24,
        ),
      ),

      ///* Input Decoration - Forms modernos
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: Colores.surfaceColor,
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: Colores.dividerColor, width: 1.5),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: Colores.dividerColor, width: 1.5),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: Colores.primaryColor, width: 2),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: Colores.errorColor, width: 1.5),
        ),
        focusedErrorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: Colores.errorColor, width: 2),
        ),
        labelStyle: GoogleFonts.montserrat(
          fontSize: 14,
          fontWeight: FontWeight.w500,
          color: Colores.textSecondary,
        ),
        hintStyle: GoogleFonts.montserrat(
          fontSize: 14,
          color: Colores.textTertiary,
        ),
      ),

      ///* Divider
      dividerTheme: const DividerThemeData(
        color: Colores.dividerColor,
        thickness: 1,
        space: 16,
      ),

      ///* Icon Theme
      iconTheme: const IconThemeData(
        color: Colores.textSecondary,
        size: 24,
      ),
  );
}
