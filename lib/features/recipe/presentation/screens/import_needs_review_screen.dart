import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:go_router/go_router.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

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
    final shouldRefetch = recipe != null && recipe!.ocrRawText == null;
    final ocrFuture = shouldRefetch
        ? FirebaseFirestore.instance.collection('recipes').doc(recipe!.id).get()
        : null;
    final issues = recipe?.issues ?? const <String>[];
    final importDebug = recipe?.importDebug ?? const <String, dynamic>{};
    final debugJson = const JsonEncoder.withIndent('  ').convert(importDebug);
    final stage = importDebug['stage'] as String? ?? '';
    final debugErrors = importDebug['errors'] as List<dynamic>? ?? const <dynamic>[];
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
                    if (recipe != null) ...[
                      Text(
                        'OCR extracted: ${ocrPreview.length} chars',
                        style: theme.textTheme.bodySmall,
                      ),
                      const SizedBox(height: 4),
                      Text(
                        'Steps: ${recipe!.steps.length}, Ingredients: ${recipe!.ingredients.length}, Tools: ${recipe!.tools.length}',
                        style: theme.textTheme.bodySmall,
                      ),
                      if (issues.isNotEmpty) ...[
                        const SizedBox(height: 8),
                        Text(
                          'Issues: ${issues.join(", ")}',
                          style: theme.textTheme.bodySmall,
                        ),
                      ],
                      if (issues.isEmpty) ...[
                        const SizedBox(height: 8),
                        Text(
                          'Import failed - missing diagnostics. Please reimport.',
                          style: theme.textTheme.bodySmall,
                        ),
                        const SizedBox(height: 4),
                        Text(
                          'RecipeId: ${recipe!.id}',
                          style: theme.textTheme.bodySmall,
                        ),
                      ],
                    ],
                    if (recipe != null) ...[
                      const SizedBox(height: 12),
                      ExpansionTile(
                        title: const Text('Debug details'),
                        children: [
                          if (stage.isNotEmpty)
                            Padding(
                              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
                              child: Text('Stage: $stage'),
                            ),
                          if (debugErrors.isNotEmpty)
                            Padding(
                              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
                              child: Text('Errors: ${debugErrors.length}'),
                            ),
                          Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                            child: Text(debugJson, style: theme.textTheme.bodySmall),
                          ),
                        ],
                      ),
                    ],
                    if (recipe != null)
                      shouldRefetch
                          ? FutureBuilder<DocumentSnapshot<Map<String, dynamic>>>(
                              future: ocrFuture,
                              builder: (context, snapshot) {
                                final fetched =
                                    snapshot.data?.data()?['ocrRawText'] as String?;
                                return _buildOcrPreview(
                                  theme,
                                  l10n,
                                  fetched ?? ocrPreview,
                                );
                              },
                            )
                          : _buildOcrPreview(theme, l10n, ocrPreview),
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
                  if (recipe != null)
                    SizedBox(
                      width: double.infinity,
                      child: OutlinedButton(
                        onPressed: () async {
                          final payload = {
                            'recipeId': recipe!.id,
                            'importStatus': recipe!.importStatus,
                            'needsReview': recipe!.needsReview,
                            'issues': issues,
                            'ocrLength': ocrPreview.length,
                            'ingredientsCount': recipe!.ingredients.length,
                            'stepsCount': recipe!.steps.length,
                            'toolsCount': recipe!.tools.length,
                            'importDebug': importDebug,
                          };
                          await Clipboard.setData(
                            ClipboardData(text: jsonEncode(payload)),
                          );
                          if (!context.mounted) return;
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(content: Text('Debug payload copied')),
                          );
                        },
                        child: const Text('Copy debug payload'),
                      ),
                    ),
                  if (recipe != null) const SizedBox(height: 8),
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

  Widget _buildOcrPreview(
    ThemeData theme,
    AppLocalizations l10n,
    String ocrText,
  ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'OCR text extracted: ${ocrText.length} chars',
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
              ocrText.length > 2000 ? '${ocrText.substring(0, 2000)}...' : ocrText,
              style: theme.textTheme.bodySmall,
            ),
          ),
        ),
      ],
    );
  }
}
