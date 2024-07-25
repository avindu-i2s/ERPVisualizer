import 'package:flutter/material.dart';

class CommonButton extends StatelessWidget {
  CommonButton(this.buttonText, this.navigation, color, textColor);
  final String buttonText;
  final VoidCallback navigation;
  Color textColor = Colors.black;
  Color color = Colors.blueAccent;
  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 35,
      width: 80,
      child: RawMaterialButton(
        shape:
        RoundedRectangleBorder(borderRadius: BorderRadius.circular(22.5)),
        elevation: 0,
        highlightElevation: 0,
        highlightColor: Color.fromARGB(255, 253, 171, 77),
        onPressed: navigation,
        fillColor: color,
        child: Row(
          children: [
            Expanded(
              child: Text(buttonText,
                  textAlign: TextAlign.center,
                  style: TextStyle(
                      color: textColor,
                      fontSize: 14,
                      fontWeight: FontWeight.w500)),
            ),
          ],
        ),
      ),
    );
  }
}