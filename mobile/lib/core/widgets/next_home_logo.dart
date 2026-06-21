import 'package:flutter/material.dart';

class NextHomeLogo extends StatelessWidget {
  final double size;
  final bool lightTheme;
  final bool showText;

  const NextHomeLogo({
    Key? key,
    this.size = 100,
    this.lightTheme = false,
    this.showText = true,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: size,
      child: Image.asset(
        'assets/images/nexthomelogo.png',
        fit: BoxFit.contain,
      ),
    );
  }
}
