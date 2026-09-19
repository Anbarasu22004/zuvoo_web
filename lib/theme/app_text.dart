import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

/// Inter Tight for tight cinematic display type, Inter for body.
class AppText {
  static TextStyle display(double size, Color color) => GoogleFonts.interTight(
        fontSize: size,
        fontWeight: FontWeight.w500,
        height: 1.0,
        letterSpacing: -size * 0.05,
        color: color,
      );

  static TextStyle heading(double size, Color color, {FontWeight weight = FontWeight.w500}) =>
      GoogleFonts.interTight(
        fontSize: size,
        fontWeight: weight,
        height: 1.15,
        letterSpacing: -size * 0.025,
        color: color,
      );

  static TextStyle body(double size, Color color, {FontWeight weight = FontWeight.w400, double height = 1.6}) =>
      GoogleFonts.inter(fontSize: size, fontWeight: weight, height: height, color: color);

  static TextStyle label(Color color, {double size = 14}) =>
      GoogleFonts.inter(fontSize: size, fontWeight: FontWeight.w600, height: 1.2, color: color);

  /// Uppercase nav / button type.
  static TextStyle caps(Color color, {double size = 15}) =>
      GoogleFonts.inter(fontSize: size, fontWeight: FontWeight.w500, letterSpacing: size * 0.04, height: 1.2, color: color);

  static TextStyle eyebrow(Color color) =>
      GoogleFonts.inter(fontSize: 13, fontWeight: FontWeight.w500, letterSpacing: 1.6, height: 1.2, color: color);

  static TextStyle script(double size, Color color) =>
      GoogleFonts.caveat(fontSize: size, fontWeight: FontWeight.w500, height: 1.0, color: color);
}
