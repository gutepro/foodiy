import 'package:flutter/material.dart';

/// Centralized logo widget for the Foodiy brand.
class FoodiyLogo extends StatelessWidget {
  const FoodiyLogo({super.key});

  @override
  Widget build(BuildContext context) {
    return Image.asset(
      'assets/images/foodiy_logo.png.png',
      fit: BoxFit.contain,
      // TODO: Add responsive scaling once layout breakpoints are defined.
    );
  }
}
