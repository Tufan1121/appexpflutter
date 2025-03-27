import 'package:flutter/material.dart';

class ScreenUtils {
  // final size = MediaQuery.of(context).size;

  static double percentWidth(BuildContext context, double valor) {
    final size = MediaQuery.of(context).size;
    return ((size.width / 100) * valor);
  }

  static double percentHeight(BuildContext context, double valor) {
    final size = MediaQuery.of(context).size;
    return ((size.height / 100) * valor);
  }

  static double horizontalPadding(context, double value) {
    return MediaQuery.of(context).size.width / value;
  }

  static double verticalPadding(context, double value) {
    return MediaQuery.of(context).size.height / value;
  }

  static bool getDeviceSize(
      BuildContext context, int desiredSize, bool isLower) {
    final size = MediaQuery.of(context).size;
    final screenSizes = [ 
      882.7272338867188,
      900,
      1000,
      1150,
      1800
    ];

    if (isLower) {
      if (size.width < screenSizes[desiredSize]) {
        return true;
      }
    } else {
      if (size.width > screenSizes[desiredSize]) {
        return true;
      }
    }

    return false;
  }
}
