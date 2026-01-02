# Recipe Categories Migration (One-Time)

Target state:
- `/recipes/{id}.categories` is `array<string>` of **category keys** (e.g. `["breakfast"]`)
- `/recipes/{id}.isPublic` is `bool`
- `/recipes/{id}.updatedAt` is a timestamp (server time)

This repo includes a privileged Cloud Function migration runner:
- `functions/index.js` → `migrateRecipeCategories`
- `functions/index.js` → `backfillRecipeCategoriesFromCookbooks` (optional but critical if old recipes never stored categories)

## 1) Configure + deploy

Set a migration token (required):
```bash
firebase functions:config:set migration.token="REPLACE_WITH_RANDOM_TOKEN"
```

Deploy the migration function:
```bash
firebase deploy --only functions:migrateRecipeCategories
```

If you need to backfill categories from existing cookbooks:
```bash
firebase deploy --only functions:backfillRecipeCategoriesFromCookbooks
```

## 2) Dry run (recommended)

Replace the URL with the one printed by `firebase deploy`:
```bash
./scripts/migrate_recipe_categories.sh "https://<REGION>-<PROJECT>.cloudfunctions.net/migrateRecipeCategories" "REPLACE_WITH_RANDOM_TOKEN" true
```

## 3) Run migration

```bash
./scripts/migrate_recipe_categories.sh "https://<REGION>-<PROJECT>.cloudfunctions.net/migrateRecipeCategories" "REPLACE_WITH_RANDOM_TOKEN" false
```

The response includes:
- `scanned`, `updated`, `skipped`
- `examples` (first N before/after patches)

## 4) Backfill from cookbooks (if recipes have no categories at all)

This is required when:
- `/recipes/{id}.categories` is missing/empty for older recipes
- but the recipe appears inside a user-created cookbook that has categories

Dry run:
```bash
./scripts/backfill_recipe_categories_from_cookbooks.sh "https://<REGION>-<PROJECT>.cloudfunctions.net/backfillRecipeCategoriesFromCookbooks" "REPLACE_WITH_RANDOM_TOKEN" true true
```

Run:
```bash
./scripts/backfill_recipe_categories_from_cookbooks.sh "https://<REGION>-<PROJECT>.cloudfunctions.net/backfillRecipeCategoriesFromCookbooks" "REPLACE_WITH_RANDOM_TOKEN" false true
```

Notes:
- Uses `/cookbooks/{cookbookId}.categories` and `/cookbooks/{cookbookId}/entries/*` to update `/recipes/{recipeId}.categories`.
- By default, only updates recipes that currently have no categories (`onlyIfMissing=true`).

## Notes

- Migration reads categories from (in order): `categories`, `category`, `tags`, `categoryKeys`
- Values are normalized by:
  - trim
  - lowercasing + slugifying (spaces/punctuation → `-`)
  - exact title mapping (e.g. `"Breakfast"` → `"breakfast"`)
- If more than 5 categories are present, keys are sorted and first 5 kept (deterministic).
- `isPublic` is only changed if it is a string `"true"`/`"false"`; otherwise it is left as-is.
- `updatedAt` is always set to server timestamp on updates.
