import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'app_colors.dart';

class AppTypography {
  AppTypography._();

  static TextStyle _base({
    required double fontSize,
    required FontWeight fontWeight,
    double? letterSpacing,
    double? height,
    Color? color,
  }) => GoogleFonts.plusJakartaSans(
    fontSize: fontSize,
    fontWeight: fontWeight,
    letterSpacing: letterSpacing,
    height: height,
    color: color ?? AppColors.textHi,
  );

  // Display - large amounts and hero headings
  static TextStyle get displayLg => _base(
    fontSize: 44,
    fontWeight: FontWeight.w700,
    letterSpacing: -0.03 * 44,
    height: 1.05,
  );
  static TextStyle get displayMd => _base(
    fontSize: 38,
    fontWeight: FontWeight.w700,
    letterSpacing: -0.025 * 38,
    height: 1.1,
  );
  static TextStyle get displaySm => _base(
    fontSize: 22,
    fontWeight: FontWeight.w700,
    letterSpacing: -0.02 * 22,
  );

  // Title
  static TextStyle get titleLg => _base(
    fontSize: 18,
    fontWeight: FontWeight.w700,
    letterSpacing: -0.01 * 18,
  );
  static TextStyle get titleMd =>
      _base(fontSize: 16, fontWeight: FontWeight.w600);

  // Body
  static TextStyle get bodyLg =>
      _base(fontSize: 15, fontWeight: FontWeight.w500);
  static TextStyle get bodyMd =>
      _base(fontSize: 14, fontWeight: FontWeight.w500);
  static TextStyle get bodySm =>
      _base(fontSize: 13, fontWeight: FontWeight.w500);

  // Label - small caps section headers
  static TextStyle get labelSm => _base(
    fontSize: 12,
    fontWeight: FontWeight.w700,
    letterSpacing: 0.08 * 12,
    color: AppColors.textMid,
  );
  static TextStyle get labelXs =>
      _base(fontSize: 11, fontWeight: FontWeight.w600);

  // Caption
  static TextStyle get caption => _base(
    fontSize: 12,
    fontWeight: FontWeight.w500,
    color: AppColors.textMid,
  );

  // Mono - monetary amounts (tabular nums)
  static TextStyle get amountLg => _base(
    fontSize: 15,
    fontWeight: FontWeight.w700,
    letterSpacing: -0.01 * 15,
  );
  static TextStyle get amountMd => _base(
    fontSize: 14,
    fontWeight: FontWeight.w700,
    letterSpacing: -0.01 * 14,
  );
}
