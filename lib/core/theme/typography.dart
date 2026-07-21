import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'colors.dart';

/// Centralized premium typography for the dark and gold theme
class AppTypography {
  AppTypography._();

  // Premium big titles
  static TextStyle displayBold({
    double fontSize = 32.0,
    Color color = AppColors.white,
  }) {
    return GoogleFonts.outfit(
      fontSize: fontSize,
      fontWeight: FontWeight.w900,
      color: color,
      letterSpacing: -0.5,
    );
  }

  // Heading titles (menu catalog, cart, maps)
  static TextStyle headingBold({
    double fontSize = 24.0,
    Color color = AppColors.gold,
  }) {
    return GoogleFonts.outfit(
      fontSize: fontSize,
      fontWeight: FontWeight.bold,
      color: color,
      letterSpacing: 0.2,
    );
  }

  // Subtitles and action items
  static TextStyle subtitleMedium({
    double fontSize = 18.0,
    Color color = AppColors.white,
  }) {
    return GoogleFonts.outfit(
      fontSize: fontSize,
      fontWeight: FontWeight.w600,
      color: color,
    );
  }

  // Standard body text descriptions
  static TextStyle bodyText({
    double fontSize = 14.0,
    Color color = AppColors.grey,
    double height = 1.3,
  }) {
    return GoogleFonts.outfit(
      fontSize: fontSize,
      fontWeight: FontWeight.normal,
      color: color,
      height: height,
    );
  }

  // Tiny label tags, parameters
  static TextStyle caption({
    double fontSize = 12.0,
    Color color = AppColors.grey,
    FontWeight fontWeight = FontWeight.normal,
  }) {
    return GoogleFonts.outfit(
      fontSize: fontSize,
      fontWeight: fontWeight,
      color: color,
    );
  }

  // Gold highlight labels
  static TextStyle goldLabel({
    double fontSize = 14.0,
    FontWeight fontWeight = FontWeight.bold,
  }) {
    return GoogleFonts.outfit(
      fontSize: fontSize,
      fontWeight: fontWeight,
      color: AppColors.gold,
      letterSpacing: 0.5,
    );
  }

  // Compatibility headers for previously generated modules
  static TextStyle modakHeader({
    double fontSize = 32.0,
    Color color = AppColors.gold,
    double strokeWidth = 0.0,
    Color strokeColor = Colors.transparent,
  }) {
    return displayBold(fontSize: fontSize, color: color);
  }

  static TextStyle mouseHeader({
    double fontSize = 24.0,
    Color color = AppColors.white,
    FontWeight fontWeight = FontWeight.bold,
    double letterSpacing = 0.5,
  }) {
    return subtitleMedium(fontSize: fontSize, color: color);
  }

  static TextStyle outfitBody({
    double fontSize = 14.0,
    Color color = AppColors.grey,
    FontWeight fontWeight = FontWeight.normal,
    double height = 1.2,
  }) {
    return bodyText(fontSize: fontSize, color: color, height: height);
  }

  static TextStyle outfitMedium({
    double fontSize = 16.0,
    Color color = AppColors.white,
    FontWeight fontWeight = FontWeight.w600,
  }) {
    return subtitleMedium(fontSize: fontSize, color: color);
  }
}
