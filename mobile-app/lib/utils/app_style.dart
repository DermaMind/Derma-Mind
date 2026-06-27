import 'package:dermamind_app/utils/app_color.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class AppStyle{
  static TextStyle  logoText = GoogleFonts.inter(
    fontSize: 35,
    fontWeight: FontWeight.bold,
    color: AppColor.secondaryColor,
  );
  static TextStyle semi20Linear= GoogleFonts.inter(
      fontSize: 20,
      fontWeight: FontWeight.bold,
      color: AppColor.linearColor

  );
 static TextStyle regular= GoogleFonts.inter(
   fontSize: 16,
   fontWeight: FontWeight.w400,
   color: AppColor.blackColor
 );
  static TextStyle semi40linear= GoogleFonts.inter(
      fontSize: 20,
      fontWeight: FontWeight.bold,
      color: AppColor.blackColor
  );
  static TextStyle nameLinear= GoogleFonts.inter(
      fontSize: 25,
      fontWeight: FontWeight.bold,
      color: AppColor.blackColor
  );
  static TextStyle SkinTestCard= GoogleFonts.cairo(
      fontSize: 22,
      fontWeight: FontWeight.w800,
      color: AppColor.blackColor
  );
  static TextStyle TextServiceCard= GoogleFonts.poppins(
      fontSize: 17,
      fontWeight: FontWeight.bold,
      color: AppColor.blackColor
  );
  static TextStyle popularText= GoogleFonts.inter(
      fontSize: 16,
      fontWeight: FontWeight.bold,
      color: AppColor.black2Color
  );
  static TextStyle seeText= GoogleFonts.inter(
      fontSize: 14,
      fontWeight: FontWeight.bold,
      color: AppColor.iconColorSelect
  );
  static TextStyle productNameText= GoogleFonts.inter(
      fontSize: 14,
      fontWeight: FontWeight.bold,
      color: AppColor.black2Color,
    height: 1.3,
  );
  static TextStyle priceText= GoogleFonts.inter(
    fontSize: 13,
    fontWeight: FontWeight.w600,
    color: AppColor.priceColor,

  );
  static TextStyle productDetailsText= GoogleFonts.inter(
    fontSize: 20,
    fontWeight: FontWeight.w500,
    color: AppColor.black2Color,

  );
  static TextStyle priceDetailsText= GoogleFonts.roboto(
    fontSize: 18,
    fontWeight: FontWeight.w500,
    color: AppColor.blackColor,

  );
  static TextStyle scanText= GoogleFonts.poppins(
    fontSize: 22,
    fontWeight: FontWeight.w400,
    color: AppColor.blackColor,

  );

}