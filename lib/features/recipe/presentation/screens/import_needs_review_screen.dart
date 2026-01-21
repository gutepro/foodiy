import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import 'package:foodiy/features/recipe/domain/recipe.dart';
import 'package:foodiy/router/app_routes.dart';
import 'package:foodiy/shared/widgets/foodiy_app_bar.dart';
import 'package:foodiy/l10n/app_localizations.dart';

class ImportNeedsReviewScreen extends StatelessWidget {
  const ImportNeedsReviewScreen({super.key, this.recipe});

  final Recipe? recipe;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final l10n = AppLocalizations.of(context)!;
    debugPrint(
      '[L10N] locale=${Localizations.localeOf(context)} screen=ImportNeedsReview keys=recipeImportNeedsReviewTitle,goHomeButton',
    );
    final ocrPreview = recipe?.ocrRawText ?? '';
    final ocrLength = ocrPreview.length;
    return Scaffold(
      appBar: FoodiyAppBar(
        title: Text(l10n.recipeImportNeedsReviewTitle),
      ),
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      l10n.recipeImportNeedsReviewBody,
                      style: theme.textTheme.titleMedium,
                    ),
                    const SizedBox(height: 12),
                    if (recipe != null)
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'OCR text extracted: $ocrLength chars',
                            style: theme.textTheme.bodySmall,
                          ),
                          const SizedBox(height: 6),
                          Text(l10n.recipeOcrPreviewLabel, style: theme.textTheme.bodyMedium),
                          const SizedBox(height: 6),
                          Container(
                            padding: const EdgeInsets.all(8),
                            decoration: BoxDecoration(
                              color: Colors.grey.shade100,
                              borderRadius: BorderRadius.circular(8),
                            ),
                            height: 160,
                            child: SingleChildScrollView(
                              child: Text(
                                ocrPreview.length > 2000
                                    ? '${ocrPreview.substring(0, 2000)}...'
                                    : ocrPreview,
                                style: theme.textTheme.bodySmall,
                              ),
                            ),
                          ),
                        ],
                      ),
                  ],
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                children: [
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: () {
                        context.go(AppRoutes.home);
                      },
                      child: Text(l10n.goHomeButton),
                    ),
                  ),
                  const SizedBox(height: 8),
                  SizedBox(
                    width: double.infinity,
                    child: OutlinedButton(
                      onPressed: () {
                        context.go(AppRoutes.recipeImportDocument);
                      },
                      child: Text(l10n.tryAgain),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
