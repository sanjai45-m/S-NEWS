import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class TabsWidget extends StatelessWidget {
  const TabsWidget({
    super.key,
    required this.text,
    required this.color,
    required this.fontSize,
    required this.function,
    required this.textColor,
  });

  final String text;
  final Color color;
  final double fontSize;
  final Function function;
  final Color textColor;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        function();
      },
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(15),
          color: color,
        ),
        child: Padding(
          padding: const EdgeInsets.all(8.0),
          child: Text(
            text,
            style:GoogleFonts.italiana(textStyle: TextStyle(
              fontSize: fontSize,
              fontWeight: FontWeight.w600,
              color: textColor,
            ),)
          ),
        ),
      ),
    );
  }
}
