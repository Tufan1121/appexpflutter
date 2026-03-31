import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class Colores {
  static const colorSeed = Color(0xff424CB8);
  static const Color primaryColor = Color(0xff424CB8);
  static const Color secondaryColor = Color(0xffD90080);
  static const scaffoldBackgroundColor = Color(0xFFF8F7F7);
}

class AppTheme {
  static ThemeData lightTheme() {
    const primaryColor = Color(0xFF37474F); // Gris azulado oscuro
    const secondaryColor = Color(0xFF546E7A); // Gris azulado medio
    const scaffoldBg = Color(0xFFF5F5F5); // Gris claro
    const surfaceColor = Colors.white;
    const onSurfaceColor = Color(0xFF212121);

    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.light,
      colorScheme: const ColorScheme.light(
        primary: primaryColor,
        secondary: secondaryColor,
        surface: surfaceColor,
        onPrimary: Colors.white,
        onSecondary: Colors.white,
        onSurface: onSurfaceColor,
      ),
      scaffoldBackgroundColor: scaffoldBg,
      textTheme: TextTheme(
        titleLarge: GoogleFonts.montserratAlternates()
            .copyWith(fontSize: 40, fontWeight: FontWeight.bold),
        titleMedium: GoogleFonts.montserratAlternates()
            .copyWith(fontSize: 30, fontWeight: FontWeight.bold),
        titleSmall:
            GoogleFonts.montserratAlternates().copyWith(fontSize: 20),
      ),
      filledButtonTheme: FilledButtonThemeData(
        style: ButtonStyle(
          backgroundColor: WidgetStatePropertyAll(primaryColor),
          textStyle: WidgetStatePropertyAll(
            GoogleFonts.montserratAlternates()
                .copyWith(fontWeight: FontWeight.w700),
          ),
        ),
      ),
      appBarTheme: AppBarTheme(
        backgroundColor: primaryColor,
        foregroundColor: Colors.white,
        elevation: 0,
        titleTextStyle: GoogleFonts.montserratAlternates().copyWith(
          fontSize: 25,
          fontWeight: FontWeight.bold,
          color: Colors.white,
        ),
      ),
      cardTheme: CardThemeData(
        color: surfaceColor,
        elevation: 1,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
      ),
      bottomSheetTheme: const BottomSheetThemeData(
        backgroundColor: surfaceColor,
      ),
      snackBarTheme: SnackBarThemeData(
        backgroundColor: primaryColor,
        contentTextStyle: GoogleFonts.montserrat(color: Colors.white),
      ),
    );
  }

  static ThemeData darkTheme() {
    const primaryColor = Color(0xFF90A4AE); // Gris azulado claro
    const secondaryColor = Color(0xFFB0BEC5); // Gris azulado más claro
    const scaffoldBg = Color(0xFF1A1A2E); // Azul oscuro profundo
    const surfaceColor = Color(0xFF16213E); // Azul oscuro medio
    const onSurfaceColor = Color(0xFFE0E0E0);

    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.dark,
      colorScheme: const ColorScheme.dark(
        primary: primaryColor,
        secondary: secondaryColor,
        surface: surfaceColor,
        onPrimary: Color(0xFF1A1A2E),
        onSecondary: Color(0xFF1A1A2E),
        onSurface: onSurfaceColor,
      ),
      scaffoldBackgroundColor: scaffoldBg,
      textTheme: TextTheme(
        titleLarge: GoogleFonts.montserratAlternates().copyWith(
            fontSize: 40,
            fontWeight: FontWeight.bold,
            color: onSurfaceColor),
        titleMedium: GoogleFonts.montserratAlternates().copyWith(
            fontSize: 30,
            fontWeight: FontWeight.bold,
            color: onSurfaceColor),
        titleSmall: GoogleFonts.montserratAlternates()
            .copyWith(fontSize: 20, color: onSurfaceColor),
      ),
      filledButtonTheme: FilledButtonThemeData(
        style: ButtonStyle(
          backgroundColor: WidgetStatePropertyAll(primaryColor),
          textStyle: WidgetStatePropertyAll(
            GoogleFonts.montserratAlternates()
                .copyWith(fontWeight: FontWeight.w700),
          ),
        ),
      ),
      appBarTheme: AppBarTheme(
        backgroundColor: surfaceColor,
        foregroundColor: onSurfaceColor,
        elevation: 0,
        titleTextStyle: GoogleFonts.montserratAlternates().copyWith(
          fontSize: 25,
          fontWeight: FontWeight.bold,
          color: onSurfaceColor,
        ),
      ),
      cardTheme: CardThemeData(
        color: surfaceColor,
        elevation: 1,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
      ),
      bottomSheetTheme: const BottomSheetThemeData(
        backgroundColor: surfaceColor,
      ),
      snackBarTheme: SnackBarThemeData(
        backgroundColor: surfaceColor,
        contentTextStyle: GoogleFonts.montserrat(color: onSurfaceColor),
      ),
    );
  }

  // Método legacy para compatibilidad
  ThemeData getTheme() => lightTheme();
}
