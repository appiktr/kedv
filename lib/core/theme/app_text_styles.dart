import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:kedv/core/theme/app_colors.dart';

/// Uygulama metin stilleri
class AppTextStyles {
  AppTextStyles._();

  /// Başlık stili - 28px Bold
  static TextStyle get heading => GoogleFonts.plusJakartaSans(
        fontSize: 28,
        fontWeight: FontWeight.w700,
        height: 35 / 28,
        color: AppColors.textPrimary,
      );

  /// Alt başlık stili - 16px Regular
  static TextStyle get subtitle => GoogleFonts.plusJakartaSans(
        fontSize: 16,
        fontWeight: FontWeight.w400,
        height: 24 / 16,
        color: AppColors.textPrimary,
      );

  /// Body stili - 16px Regular
  static TextStyle get body => GoogleFonts.plusJakartaSans(
        fontSize: 16,
        fontWeight: FontWeight.w400,
        height: 24 / 16,
        color: AppColors.textPrimary,
      );

  /// Input hint stili - 16px Regular
  static TextStyle get inputHint => GoogleFonts.plusJakartaSans(
        fontSize: 16,
        fontWeight: FontWeight.w400,
        height: 24 / 16,
        color: AppColors.hint,
      );

  /// Input text stili - 16px Regular
  static TextStyle get inputText => GoogleFonts.plusJakartaSans(
        fontSize: 16,
        fontWeight: FontWeight.w400,
        height: 24 / 16,
        color: AppColors.textPrimary,
      );

  /// Button stili - 16px Bold
  static TextStyle get button => GoogleFonts.plusJakartaSans(
        fontSize: 16,
        fontWeight: FontWeight.w700,
        height: 24 / 16,
        color: AppColors.background,
      );

  /// Link stili - 14px Regular
  static TextStyle get link => GoogleFonts.plusJakartaSans(
        fontSize: 14,
        fontWeight: FontWeight.w400,
        height: 21 / 14,
        color: AppColors.secondary,
      );

  /// Caption stili - 14px Regular
  static TextStyle get caption => GoogleFonts.plusJakartaSans(
        fontSize: 14,
        fontWeight: FontWeight.w400,
        height: 21 / 14,
        color: AppColors.textSecondary,
      );

  /// Label stili - 16px Medium
  static TextStyle get label => GoogleFonts.plusJakartaSans(
        fontSize: 16,
        fontWeight: FontWeight.w500,
        height: 24 / 16,
        color: AppColors.textPrimary,
      );

  /// AppBar title stili - 18px Bold
  static TextStyle get appBarTitle => GoogleFonts.plusJakartaSans(
        fontSize: 18,
        fontWeight: FontWeight.w700,
        height: 23 / 18,
        color: AppColors.textPrimary,
      );

  /// Page title stili - 22px Bold
  static TextStyle get pageTitle => GoogleFonts.plusJakartaSans(
        fontSize: 22,
        fontWeight: FontWeight.w700,
        height: 28 / 22,
        color: AppColors.textPrimary,
      );
}

