import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import 'package:foodiy/features/recipe/domain/recipe_step.dart';
import 'package:foodiy/features/recipe/presentation/screens/recipe_player_screen.dart';
import 'package:foodiy/router/app_routes.dart';

class RecipeDetailsArgs {
  final String title;
  final String imageUrl;
  final String time;
  final String difficulty;
  final String originalLanguageCode;

  const RecipeDetailsArgs({
    required this.title,
    required this.imageUrl,
    required this.time,
    required this.difficulty,
    this.originalLanguageCode = 'he',
  });
}

class RecipeDetailsScreen extends StatelessWidget {
  const RecipeDetailsScreen({super.key, required this.args});

  final RecipeDetailsArgs args;

  TextDirection _directionFromLanguage(String code) {
    const rtlLanguages = ['he', 'ar', 'fa', 'ur'];
    if (rtlLanguages.contains(code.toLowerCase())) {
      return TextDirection.rtl;
    }
    return TextDirection.ltr;
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final ingredients = [
      '200 g pasta',
      '300 g ground beef',
      '1 onion, chopped',
      '2 cloves garlic',
      'Tomato sauce',
      'Salt, pepper, olive oil',
    ];
    final steps = [
      'Boil pasta in salted water until al dente.',
      'Saute onion and garlic, then brown the beef.',
      'Add tomato sauce and simmer.',
      'Combine pasta with sauce and season to taste.',
      'Plate and garnish with fresh herbs or cheese.',
    ];

    return Directionality(
      textDirection: _directionFromLanguage(args.originalLanguageCode),
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Recipe'),
          leading: IconButton(
            icon: const Icon(Icons.arrow_back),
            onPressed: () {
              if (context.canPop()) {
                context.pop();
              } else {
                Navigator.of(context).maybePop();
              }
            },
          ),
        ),
        body: SingleChildScrollView(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              ClipRRect(
                borderRadius: BorderRadius.circular(16),
                child: Image.network(
                  args.imageUrl,
                  height: 220,
                  width: double.infinity,
                  fit: BoxFit.cover,
                  errorBuilder: (context, error, stackTrace) {
                    return Container(
                      height: 220,
                      width: double.infinity,
                      color: Colors.black12,
                      alignment: Alignment.center,
                      child: const Icon(Icons.image_not_supported),
                    );
                  },
                ),
              ),
              const SizedBox(height: 16),
              Text(
                args.title,
                style: theme.textTheme.headlineSmall,
              ),
              const SizedBox(height: 8),
              Row(
                children: [
                  const Icon(Icons.schedule, size: 18),
                  const SizedBox(width: 6),
                  Text(args.time),
                  const SizedBox(width: 16),
                  const Icon(Icons.local_fire_department_outlined, size: 18),
                  const SizedBox(width: 6),
                  Text(args.difficulty),
                ],
              ),
              const SizedBox(height: 16),
              const Text(
                'A comforting family style dish, perfect for weeknights.',
              ),
              const SizedBox(height: 24),
              Text(
                'Ingredients',
                style: theme.textTheme.titleMedium,
              ),
              const SizedBox(height: 8),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: ingredients
                    .map(
                      (item) => Padding(
                        padding: const EdgeInsets.symmetric(vertical: 4),
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text('- '),
                            Expanded(child: Text(item)),
                          ],
                        ),
                      ),
                    )
                    .toList(),
              ),
              const SizedBox(height: 24),
              Text(
                'Preparation',
                style: theme.textTheme.titleMedium,
              ),
              const SizedBox(height: 8),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: List.generate(
                  steps.length,
                  (index) => Padding(
                    padding: const EdgeInsets.symmetric(vertical: 6),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('${index + 1}. '),
                        Expanded(child: Text(steps[index])),
                      ],
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 24),
              ElevatedButton.icon(
                onPressed: () {
                  final steps = [
                    const RecipeStep(
                      text: 'Boil water in a large pot.',
                      durationSeconds: null,
                    ),
                    const RecipeStep(
                      text: 'Add the pasta and cook for 8 minutes.',
                      durationSeconds: 8 * 60,
                    ),
                    const RecipeStep(
                      text: 'Heat olive oil in a pan.',
                      durationSeconds: null,
                    ),
                    const RecipeStep(
                      text: 'Add onion and garlic, cook for 3 minutes.',
                      durationSeconds: 3 * 60,
                    ),
                    const RecipeStep(
                      text: 'Add tomato sauce and simmer.',
                      durationSeconds: 5 * 60,
                    ),
                    const RecipeStep(
                      text: 'Combine pasta with sauce and serve.',
                      durationSeconds: null,
                    ),
                  ];

                  final playerArgs = RecipePlayerArgs(
                    title: args.title,
                    imageUrl: args.imageUrl,
                    steps: steps,
                    languageCode: args.originalLanguageCode,
                  );
                  context.push(AppRoutes.recipePlayer, extra: playerArgs);
                },
                icon: const Icon(Icons.play_arrow),
                label: const Text('Start cooking'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
