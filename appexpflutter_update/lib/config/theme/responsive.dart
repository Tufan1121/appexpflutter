import 'package:flutter/material.dart';
import 'dart:math' as math;

class Responsive {
  late double _with, _height;
  late double _diagonal;

  double get width => _with;
  double get height => _height;
  double get diagonal => _diagonal;

  static Responsive of(BuildContext context) => Responsive(context);

  Responsive(BuildContext context) {
    final size = MediaQuery.of(context).size;
    _with = size.width;
    _height = size.height;
    _diagonal = math.sqrt(math.pow(_with, 2) + math.pow(_height, 2));
  }

  double wp(double percent) => _with * percent / 100;
  double hp(double percent) => _height * percent / 100;
  double dp(double percent) => _diagonal * percent / 100;
}
