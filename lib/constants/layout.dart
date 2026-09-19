import 'dart:math' as math;

import 'package:flutter/material.dart';

class Breakpoints {
  static const mobile = 720.0;
  static const tablet = 1080.0;
  static const maxContent = 1200.0;
  static const navHeight = 76.0;
}

extension LayoutContext on BuildContext {
  double get vw => MediaQuery.sizeOf(this).width;
  double get vh => MediaQuery.sizeOf(this).height;
  bool get isMobile => vw < Breakpoints.mobile;
  bool get isTablet => vw >= Breakpoints.mobile && vw < Breakpoints.tablet;
  bool get isDesktop => vw >= Breakpoints.tablet;
  bool get reduceMotion => MediaQuery.of(this).disableAnimations;

  T responsive<T>({required T mobile, T? tablet, required T desktop}) =>
      isMobile ? mobile : (isTablet ? (tablet ?? desktop) : desktop);

  double get gutter => responsive(mobile: 20.0, tablet: 32.0, desktop: 48.0);
}

/// Motion maths shared by scenes.
double clamp01(double v) => v.clamp(0.0, 1.0);
double lerpD(double a, double b, double t) => a + (b - a) * t;
double smoothstep(double e0, double e1, double x) {
  final t = clamp01((x - e0) / (e1 - e0));
  return t * t * (3 - 2 * t);
}
double easeOutCubic(double t) => 1 - math.pow(1 - clamp01(t), 3).toDouble();
