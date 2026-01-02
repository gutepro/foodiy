import 'package:flutter/material.dart';
import 'package:foodiy/core/brand/brand_assets.dart';

/// Centralized logo widget for the Foodiy brand.
class FoodiyLogo extends StatelessWidget {
  const FoodiyLogo({super.key});

  @override
  Widget build(BuildContext context) {
    return Image.asset(
      BrandAssets.foodiyLogo,
      fit: BoxFit.contain,
      // TODO: Add responsive scaling once layout breakpoints are defined.
    );
  }
}
