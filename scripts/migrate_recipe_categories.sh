#!/usr/bin/env bash
set -euo pipefail

URL="${1:?Usage: ./scripts/migrate_recipe_categories.sh <function_url> <token> [dryRun=true|false]}"
TOKEN="${2:?Usage: ./scripts/migrate_recipe_categories.sh <function_url> <token> [dryRun=true|false]}"
DRY_RUN="${3:-false}"

curl -sS \
  -H "Authorization: Bearer ${TOKEN}" \
  "${URL}?dryRun=${DRY_RUN}&pageSize=400&examples=10" | cat

