import 'package:flutter/material.dart';

// Application-wide colors
class AppColors {
  static const Color primaryColor = Color(0xFF041690);
  static const Color secondaryColor = Colors.black;
  // static const Color green = Color(0xFF009900);
  static const Color green = Colors.green;
}

// Application-wide text styles
class AppText {

  static Text headline1({
    required String text,
    double fontSize = 32.0,
    FontWeight fontWeight = FontWeight.bold,
    Color color = AppColors.secondaryColor,
  }) {
    return Text(
      text,
      style: TextStyle(
        fontSize: fontSize,
        fontWeight: fontWeight,
        color: color,
      ),
    );
  }

  static Text headline2({
    required String text,
    double fontSize = 15.0,
    FontWeight fontWeight = FontWeight.bold,
    Color color = AppColors.secondaryColor,
  }) {
    return Text(
      text,
      style: TextStyle(
        fontSize: fontSize,
        fontWeight: fontWeight,
        color: color,
      ),
    );
  }

  static Text bodyText({
    required String text,
    double fontSize = 14.0,
    Color color = AppColors.secondaryColor,
    int maxLines = 2,
  }) {
    return Text(
      text,
      maxLines: maxLines,
      overflow: TextOverflow.ellipsis,
      style: TextStyle(
        fontSize: fontSize,
        color: color,
      ),
    );
  }

  static TextStyle button({
    double fontSize = 18.0,
    FontWeight fontWeight = FontWeight.bold,
    Color color = AppColors.secondaryColor,
  }) {
    return TextStyle(
      fontSize: fontSize,  // Using ScreenUtil for responsiveness
      fontWeight: fontWeight,
      color: color,
    );
  }

}