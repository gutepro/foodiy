import 'package:flutter/material.dart';
import 'package:foodiy/shared/widgets/foodiy_logo.dart';
import 'package:foodiy/shared/navigation/go_home.dart';

class FoodiyHomeLogoButton extends StatelessWidget {
  const FoodiyHomeLogoButton({super.key, this.height = 28, this.width = 28});

  final double height;
  final double width;

  @override
  Widget build(BuildContext context) {
    return Tooltip(
      message: 'Home',
      child: InkResponse(
        onTap: () async => goHome(context),
        radius: 28,
        child: FoodiyLogo(height: height, width: width),
      ),
    );
  }
}
