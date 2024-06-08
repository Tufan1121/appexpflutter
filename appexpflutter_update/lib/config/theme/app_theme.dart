import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class Colores {
  static const colorSeed = Color(0xff424CB8);
  static const Color primaryColor = Color(0xff424CB8);
  static const Color secondaryColor = Color(0xffD90080);
  static const scaffoldBackgroundColor = Color(0xFFF8F7F7);
}

class AppTheme {
  ThemeData getTheme() => ThemeData(

      ///* General
      useMaterial3: true,
      colorSchemeSeed: Colores.colorSeed,

      ///* Texts
      textTheme: TextTheme(
          titleLarge: GoogleFonts.montserratAlternates()
              .copyWith(fontSize: 40, fontWeight: FontWeight.bold),
          titleMedium: GoogleFonts.montserratAlternates()
              .copyWith(fontSize: 30, fontWeight: FontWeight.bold),
          titleSmall:
              GoogleFonts.montserratAlternates().copyWith(fontSize: 20)),

      ///* Scaffold Background Color
      scaffoldBackgroundColor: Colores.scaffoldBackgroundColor,

      ///* Buttons
      filledButtonTheme: FilledButtonThemeData(
          style: ButtonStyle(
              textStyle: WidgetStatePropertyAll(
                  GoogleFonts.montserratAlternates()
                      .copyWith(fontWeight: FontWeight.w700)))),

      ///* AppBar
      appBarTheme: AppBarTheme(
        color: Colores.scaffoldBackgroundColor,
        titleTextStyle: GoogleFonts.montserratAlternates().copyWith(
            fontSize: 25, fontWeight: FontWeight.bold, color: Colors.black),
      ));
}
