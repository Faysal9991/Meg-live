import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

/// The original purple diamond artwork used by Max Live.
class DiamondIcon extends StatelessWidget {
  const DiamondIcon({super.key, this.size = 24});

  final double size;

  @override
  Widget build(BuildContext context) => SvgPicture.asset(
    'assets/others/diamond.svg',
    width: size,
    height: size,
    fit: BoxFit.contain,
    excludeFromSemantics: true,
  );
}
