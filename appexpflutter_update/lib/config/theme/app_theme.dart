import 'package:flutter/material.dart';

class Colores {
  // Primary brand colors - Modern purple/blue palette
  static const colorSeed = Color(0xff6366F1); // Indigo
  static const Color primaryColor = Color(0xff6366F1); // Indigo 500
  static const Color secondaryColor = Color(0xffEC4899); // Pink 500
  static const Color accentColor = Color(0xff8B5CF6); // Purple 500
  
  // Background colors
  static const scaffoldBackgroundColor = Color(0xFFF8FAFC); // Slate 50
  static const surfaceColor = Color(0xFFFFFFFF);
  static const cardBackground = Color(0xFFFEFEFE);
  
  // Text colors - Better contrast
  static const textPrimary = Color(0xff0F172A); // Slate 900
  static const textSecondary = Color(0xff64748B); // Slate 500
  static const textTertiary = Color(0xff94A3B8); // Slate 400
  static const textOnPrimary = Color(0xFFFFFFFF);
  
  // Status colors - Modern palette
  static const successColor = Color(0xff10B981); // Green 500
  static const errorColor = Color(0xffEF4444); // Red 500
  static const warningColor = Color(0xffF59E0B); // Amber 500
  static const infoColor = Color(0xff3B82F6); // Blue 500
  
  // Gradients - Vibrant and modern
  static const gradientStart = Color(0xff6366F1); // Indigo
  static const gradientMiddle = Color(0xff8B5CF6); // Purple
  static const gradientEnd = Color(0xffEC4899); // Pink
  
  // Glassmorphism colors
  static const glassBackground = Color(0x40FFFFFF); // 25% white
  static const glassBorder = Color(0x30FFFFFF); // 19% white
  static const glassShadow = Color(0x1A000000); // 10% black
  
  // Input field colors
  static const inputBackground = Color(0xFFF1F5F9); // Slate 100
  static const inputBorder = Color(0xFFE2E8F0); // Slate 200
  static const inputFocusBorder = Color(0xff6366F1); // Primary
  static const inputError = Color(0xffFEE2E2); // Red 100
}

class AppTheme {
  ThemeData getTheme() => ThemeData(
      ///* General
      useMaterial3: true,
      brightness: Brightness.light,
      
      ///* Color Scheme - Alto contraste
      colorScheme: ColorScheme.light(
        primary: Colores.primaryColor,
        secondary: Colores.secondaryColor,
        tertiary: Colores.accentColor,
        surface: Colores.surfaceColor,
        surfaceContainerHighest: Colores.inputBackground,
        error: Colores.errorColor,
        onPrimary: Colors.white,
        onSecondary: Colors.white,
        onSurface: Colores.textPrimary,
        onError: Colors.white,
      ),

      ///* Texts - Mayor contraste con fuentes del sistema
      textTheme: const TextTheme(
        // Headlines
        headlineLarge: TextStyle(
          fontSize: 40,
          fontWeight: FontWeight.w800,
          color: Colores.textPrimary,
          letterSpacing: -1,
          height: 1.2,
        ),
        headlineMedium: TextStyle(
          fontSize: 32,
          fontWeight: FontWeight.w700,
          color: Colores.textPrimary,
          letterSpacing: -0.5,
          height: 1.2,
        ),
        headlineSmall: TextStyle(
          fontSize: 24,
          fontWeight: FontWeight.w600,
          color: Colores.textPrimary,
          height: 1.3,
        ),
        
        // Titles
        titleLarge: TextStyle(
          fontSize: 22,
          fontWeight: FontWeight.w700,
          color: Colores.textPrimary,
          height: 1.3,
        ),
        titleMedium: TextStyle(
          fontSize: 18,
          fontWeight: FontWeight.w600,
          color: Colores.textPrimary,
          height: 1.4,
        ),
        titleSmall: TextStyle(
          fontSize: 16,
          fontWeight: FontWeight.w600,
          color: Colores.textPrimary,
          height: 1.4,
        ),
        
        // Body
        bodyLarge: TextStyle(
          fontSize: 16,
          fontWeight: FontWeight.w400,
          color: Colores.textPrimary,
          height: 1.5,
        ),
        bodyMedium: TextStyle(
          fontSize: 14,
          fontWeight: FontWeight.w400,
          color: Colores.textSecondary,
          height: 1.5,
        ),
        bodySmall: TextStyle(
          fontSize: 12,
          fontWeight: FontWeight.w400,
          color: Colores.textTertiary,
          height: 1.4,
        ),
        
        // Labels
        labelLarge: TextStyle(
          fontSize: 14,
          fontWeight: FontWeight.w600,
          color: Colores.textPrimary,
          letterSpacing: 0.1,
        ),
        labelMedium: TextStyle(
          fontSize: 12,
          fontWeight: FontWeight.w500,
          color: Colores.textSecondary,
          letterSpacing: 0.5,
        ),
      ),

      ///* Scaffold Background Color
      scaffoldBackgroundColor: Colores.scaffoldBackgroundColor,

      ///* AppBar - Mayor contraste
      appBarTheme: const AppBarTheme(
        backgroundColor: Colors.white,
        foregroundColor: Colores.textPrimary,
        elevation: 0,
        shadowColor: Colors.black12,
        surfaceTintColor: Colors.transparent,
        titleTextStyle: TextStyle(
          fontSize: 20,
          fontWeight: FontWeight.w700,
          color: Colores.textPrimary,
        ),
        iconTheme: IconThemeData(
          color: Colores.textPrimary,
          size: 24,
        ),
      ),

      ///* Card Theme - Mejor definición
      cardTheme: CardThemeData(
        color: Colors.white,
        elevation: 2,
        shadowColor: Colors.black.withOpacity(0.08),
        surfaceTintColor: Colors.transparent,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
        margin: const EdgeInsets.all(8),
      ),

      ///* Input Decoration - Alto contraste
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: Colores.inputBackground,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: Colores.inputBorder, width: 1.5),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: Colores.inputBorder, width: 1.5),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: Colores.inputFocusBorder, width: 2),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: Colores.errorColor, width: 1.5),
        ),
        focusedErrorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: Colores.errorColor, width: 2),
        ),
        labelStyle: const TextStyle(
          fontSize: 14,
          fontWeight: FontWeight.w500,
          color: Colores.textSecondary,
        ),
        hintStyle: const TextStyle(
          fontSize: 14,
          color: Colores.textTertiary,
        ),
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
      ),

      ///* Buttons - Mayor contraste
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: Colores.primaryColor,
          foregroundColor: Colors.white,
          elevation: 2,
          shadowColor: Colores.primaryColor.withOpacity(0.3),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
          textStyle: const TextStyle(
            fontSize: 15,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),

      filledButtonTheme: FilledButtonThemeData(
        style: ButtonStyle(
          backgroundColor: WidgetStateProperty.all(Colores.primaryColor),
          foregroundColor: WidgetStateProperty.all(Colors.white),
          textStyle: const WidgetStatePropertyAll(
            TextStyle(
              fontWeight: FontWeight.w700,
            ),
          ),
        ),
      ),

      ///* Icon Theme
      iconTheme: const IconThemeData(
        color: Colores.textSecondary,
        size: 24,
      ),

      ///* Divider
      dividerTheme: const DividerThemeData(
        color: Colores.inputBorder,
        thickness: 1,
        space: 1,
      ),

      ///* Bottom Navigation Bar
      bottomNavigationBarTheme: const BottomNavigationBarThemeData(
        backgroundColor: Colors.white,
        selectedItemColor: Colores.primaryColor,
        unselectedItemColor: Colores.textTertiary,
        elevation: 8,
        type: BottomNavigationBarType.fixed,
        selectedLabelStyle: TextStyle(
          fontSize: 12,
          fontWeight: FontWeight.w600,
        ),
        unselectedLabelStyle: TextStyle(
          fontSize: 12,
          fontWeight: FontWeight.w500,
        ),
      ),
  );
}
