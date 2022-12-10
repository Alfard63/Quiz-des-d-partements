import 'package:flutter/material.dart';

class AnswerButton extends StatelessWidget {
  final String text, value;
  final Color color, textColor;
  final void Function()? onPressed;

  const AnswerButton({
    Key? key,
    required this.text,
    required this.value,
    required this.color,
    required this.textColor,
    required this.onPressed,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return TextButton(
      onPressed: onPressed,
      style: TextButton.styleFrom(
        backgroundColor: Colors.white,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(10),
          side: BorderSide(
            color: color,
            width: 3,
          ),
        ),
      ),
      child: Text(
        text,
        style: TextStyle(color: textColor, fontWeight: FontWeight.bold),
      ),
    );
  }
}
