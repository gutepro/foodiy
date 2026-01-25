import 'package:flutter/material.dart';

import 'package:foodiy/shared/widgets/foodiy_app_bar.dart';

class ChefScreen extends StatelessWidget {
  const ChefScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: const FoodiyAppBar(title: Text('foodiy - Chef')),
      body: const Center(
        child: Text(
          'This page will highlight favorite chefs and their profiles.',
          style: TextStyle(fontSize: 16),
          textAlign: TextAlign.center,
        ),
      ),
    );
  }
}
