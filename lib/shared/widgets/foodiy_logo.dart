import 'package:flutter/material.dart';
import 'package:foodiy/core/brand/brand_assets.dart';

/// Centralized logo widget for the Foodiy brand.
class FoodiyLogo extends StatelessWidget {
  const FoodiyLogo({super.key, this.height, this.width});

  final double? height;
  final double? width;

  @override
  Widget build(BuildContext context) {
    final image = Image.asset(
      BrandAssets.foodiyLogo,
      fit: BoxFit.contain,
    );
    if (height == null && width == null) {
      return image;
    }
    return SizedBox(
      height: height,
      width: width,
      child: image,
    );
  }
}
