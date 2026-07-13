import 'package:chethanafm/utils/theme/app_colors.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

final appTheme = ThemeData(
  useMaterial3: true,
  scaffoldBackgroundColor: AppColors.backgroundColor,
  primaryColor: AppColors.primaryColor,
  colorScheme: ColorScheme.light(
    primary: AppColors.primaryColor,
    secondary: AppColors.secondaryColor,
    surface: AppColors.cardColor,
    error: AppColors.liveIndicator,
  ),
  appBarTheme: AppBarTheme(
    backgroundColor: AppColors.primaryColor,
    foregroundColor: Colors.white,
    elevation: 0,
    centerTitle: true,
    titleTextStyle: GoogleFonts.outfit(
      fontWeight: FontWeight.w600,
      fontSize: 20.0,
      color: Colors.white,
    ),
  ),
  elevatedButtonTheme: ElevatedButtonThemeData(
    style: ElevatedButton.styleFrom(
      backgroundColor: AppColors.primaryColor,
      foregroundColor: Colors.white,
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      textStyle: GoogleFonts.outfit(
        color: Colors.white,
        fontWeight: FontWeight.w600,
        fontSize: 16.0,
      ),
    ),
  ),
  textTheme: GoogleFonts.outfitTextTheme(
    const TextTheme(
      titleLarge: TextStyle(fontSize: 22.0, fontWeight: FontWeight.bold, color: AppColors.textPrimary),
      titleMedium: TextStyle(fontSize: 16.0, fontWeight: FontWeight.w600, color: AppColors.textPrimary),
      titleSmall: TextStyle(fontSize: 14.0, fontWeight: FontWeight.normal, color: AppColors.textSecondary),
      bodyLarge: TextStyle(fontSize: 16.0, fontWeight: FontWeight.normal, color: AppColors.textPrimary),
      bodyMedium: TextStyle(fontSize: 14.0, fontWeight: FontWeight.normal, color: AppColors.textSecondary),
      labelSmall: TextStyle(fontSize: 10.0, fontWeight: FontWeight.w500),
    ),
  ),
);
