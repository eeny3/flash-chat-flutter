import 'package:flutter/material.dart';

class NavigateButton extends StatelessWidget {
  NavigateButton({this.color, this.text, @required this.onPressed});
  final color;
  final text;
  final onPressed;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: 16.0),
      child: Material(
        elevation: 5.0,
        color: color,
        borderRadius: BorderRadius.circular(30.0),
        child: MaterialButton(
          onPressed: onPressed,
          minWidth: 200.0,
          height: 42.0,
          child: Text(
            text,
            style: TextStyle(
              color: Color(0xFF140F0A),
            ),
          ),
        ),
      ),
    );
  }
}
