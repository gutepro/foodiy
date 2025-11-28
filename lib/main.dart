import 'package:flutter/material.dart';

void main() {
  runApp(const FoodiyApp());
}

class FoodiyApp extends StatelessWidget {
  const FoodiyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'foodiy',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepOrange),
        useMaterial3: true,
      ),
      home: const FoodiyHomePage(),
    );
  }
}

class FoodiyHomePage extends StatelessWidget {
  const FoodiyHomePage({super.key});

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      body: Center(
        child: Text(
          'FOODIY WORKS',
          style: TextStyle(fontSize: 32),
        ),
      ),
    );
  }
}
