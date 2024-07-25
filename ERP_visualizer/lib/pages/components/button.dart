import 'package:erp_visualizer/constants.dart';
import 'package:flutter/material.dart';

class CommonButton{
  //button style for the primary button
  static ElevatedButton primaryButton({
    required String text,
    required Function() onPressed,
    Color? textColor,
    Color? backgroundColor,
  }) {
    // Set default colors if none are provided
    textColor ??= AppColors.secondaryColor;
    backgroundColor ??= AppColors.primaryColor;

    return ElevatedButton(
      onPressed: onPressed,
      child: Text(
        text,
        style: TextStyle(
          fontSize: 16,
          color: textColor,
          fontWeight: FontWeight.bold
        ),
      ),
      style: ElevatedButton.styleFrom(
        backgroundColor: backgroundColor, // Background color
        elevation: 5, // Elevation (shadow)
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(10.0), // Button border radius
        ),
        padding: EdgeInsets.all(8.0), // Padding around the button
        minimumSize: Size(120, 40),
      ),
    );
  }

  //text button style for the secondary button
  static TextButton textButton(String text, Function() onPressed) {
    return TextButton(
      onPressed: onPressed,
      child: Text(
        text,
        style: TextStyle(
          fontSize: 15,
          color: Colors.blue[500],
        ),
      ),
    );
  }

  //accept button style
  static ElevatedButton acceptButton(String text, Function() onPressed) {
    return ElevatedButton(
      onPressed: onPressed,
      child: Text(
        text,
        style: TextStyle(
          fontSize: 15,
          color: Colors.white,
        ),
      ),
      style: ElevatedButton.styleFrom(
        backgroundColor: Colors.green[500],
        padding: EdgeInsets.symmetric(horizontal: 20, vertical: 5),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(10),
        ),
        minimumSize: Size(120, 40),
      ),
    );
  }

  //reject button style
  static ElevatedButton rejectButton(String text, Function() onPressed) {
    return ElevatedButton(
      onPressed: onPressed,
      child: Text(
        text,
        style: TextStyle(
          fontSize: 15,
          color: Colors.white,
        ),
      ),
      style: ElevatedButton.styleFrom(
        backgroundColor: Colors.red[200],
        padding: EdgeInsets.symmetric(horizontal: 20, vertical: 5),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(10),
        ),
        minimumSize: Size(120, 40),
      ),
    );
  }
}