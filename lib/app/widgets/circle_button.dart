import 'package:flutter/material.dart';

class CircleButton extends StatelessWidget {
  final IconData icon;
  final double iconSize, minWidth, minHeight;
  final VoidCallback onPressed;
  final Color iconColor;
  final Color? backgroundColor;

  const CircleButton({
    Key? key,
    required this.icon,
    required this.iconSize,
    required this.onPressed,
    this.minWidth = 32.0,
    this.minHeight = 32.0,
    this.iconColor = Colors.black,
    this.backgroundColor,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      height: minHeight,
      width: minWidth,
      margin: const EdgeInsets.all(6.0),
      decoration: BoxDecoration(
        color: backgroundColor ?? Colors.grey[200],
        shape: BoxShape.circle,
      ),
      child: IconButton(
        padding: EdgeInsets.zero,
        icon: Icon(icon),
        iconSize: iconSize,
        color: iconColor,
        constraints: BoxConstraints(
          minWidth: minWidth,
          minHeight: minHeight,
        ),
        onPressed: onPressed,
      ),
    );
  }
}
