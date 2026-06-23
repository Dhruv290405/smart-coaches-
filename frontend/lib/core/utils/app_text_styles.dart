import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import 'color_constants.dart';

class AppTextStyles {

  static TextStyle header1 = GoogleFonts.poppins(
    fontSize: 16,
    fontWeight: FontWeight.w600,
    color: ColorConstants.textPrimary,
  );
  
  static TextStyle header2 = GoogleFonts.poppins(
    fontSize: 16,
    fontWeight: FontWeight.w600,
    color: ColorConstants.textPrimary,
  );
  
  static TextStyle header3 = GoogleFonts.poppins(
    fontSize: 14,
    fontWeight: FontWeight.w600,
    color: ColorConstants.textPrimary,
  );
  
  // Body Text
  static TextStyle bodyLarge = GoogleFonts.poppins(
    fontSize: 14,
    fontWeight: FontWeight.w400,
    color: ColorConstants.textPrimary,
  );
  
  static TextStyle bodyMedium = GoogleFonts.poppins(
    fontSize: 13,
    fontWeight: FontWeight.w400,
    color: ColorConstants.textSecondary,
  );
  
  static TextStyle bodySmall = GoogleFonts.poppins(
    fontSize: 10,
    fontWeight: FontWeight.w400,
    color: ColorConstants.textTertiary,
  );
  
  // Button Text
  static TextStyle button = GoogleFonts.poppins(
    fontSize: 14,
    fontWeight: FontWeight.w500,
    color: ColorConstants.white,
  );
  
  static TextStyle buttonSmall = GoogleFonts.poppins(
    fontSize: 12,
    fontWeight: FontWeight.w500,
    color: ColorConstants.white,
  );
  
  // Status Badge Text
  static TextStyle badge = GoogleFonts.poppins(
    fontSize: 12,
    fontWeight: FontWeight.w500,
    color: ColorConstants.white,
  );
  
  static TextStyle label = GoogleFonts.poppins(
    fontSize: 14,
    fontWeight: FontWeight.w500,
    color: ColorConstants.textSecondary,
  );
  
  // Percentage Text
  static TextStyle percentage = GoogleFonts.poppins(
    fontSize: 13,
    fontWeight: FontWeight.w600,
    color: ColorConstants.textPrimary,
  );
  
  // Timestamp
  static TextStyle timestamp = GoogleFonts.poppins(
    fontSize: 10,
    fontWeight: FontWeight.w400,
    color: ColorConstants.textTertiary,
  );
  
  // Coach Number
  static TextStyle coachNumber = GoogleFonts.poppins(
    fontSize: 14,
    fontWeight: FontWeight.w600,
    color: ColorConstants.primary,
  );
}