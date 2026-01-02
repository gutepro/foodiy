#!/usr/bin/env bash
set -euo pipefail

URL="${1:?Usage: ./scripts/audit_recipe_categories.sh <function_url> <token> [key] [title]}"
TOKEN="${2:?Usage: ./scripts/audit_recipe_categories.sh <function_url> <token> [key] [title]}"
KEY="${3:-breakfast}"
TITLE="${4:-Breakfast}"

curl -sS \
  -H "Authorization: Bearer ${TOKEN}" \
  "${URL}?key=${KEY}&title=${TITLE}" | cat

