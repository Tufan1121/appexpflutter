import 'package:flutter/material.dart';

/// Helper class to replace GoogleFonts without dependencies
/// Uses system fonts instead
class GoogleFonts {
  static TextStyle montserrat({
    FontWeight? fontWeight,
    Color? color,
    double? fontSize,
    double? height,
    double? letterSpacing,
  }) {
    return TextStyle(
      fontWeight: fontWeight,
      color: color,
      fontSize: fontSize,
      height: height,
      letterSpacing: letterSpacing,
    );
  }

  static TextStyle montserratAlternates({
    FontWeight? fontWeight,
    Color? color,
    double? fontSize,
    double? height,
    double? letterSpacing,
  }) {
    return TextStyle(
      fontWeight: fontWeight,
      color: color,
      fontSize: fontSize,
      height: height,
      letterSpacing: letterSpacing,
    );
  }
}
