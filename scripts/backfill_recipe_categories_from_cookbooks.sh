#!/usr/bin/env bash
set -euo pipefail

URL="${1:-}"
TOKEN="${2:-}"
DRY_RUN="${3:-true}"
ONLY_IF_MISSING="${4:-true}"

if [[ -z "$URL" || -z "$TOKEN" ]]; then
  echo "Usage: $0 <FUNCTION_URL> <MIGRATION_TOKEN> [dryRun=true|false] [onlyIfMissing=true|false]"
  exit 1
fi

curl -sS \
  -H "Authorization: Bearer ${TOKEN}" \
  "${URL}?dryRun=${DRY_RUN}&onlyIfMissing=${ONLY_IF_MISSING}" | jq .

