#!/usr/bin/env bash
set -euo pipefail

if ! git rev-parse HEAD^ >/dev/null 2>&1; then
  echo "No parent commit available; run the first Vercel build."
  exit 1
fi

if git diff --quiet HEAD^ HEAD -- \
  apps/dashboard \
  packages \
  assets \
  bin \
  lib \
  config/dart_defines.release.json \
  tool/vercel \
  tool/tool_versions.json \
  pubspec.yaml \
  pubspec.lock \
  vercel.json; then
  echo "No dashboard/shared build inputs changed; skip this Vercel deployment."
  exit 0
fi

echo "Dashboard/shared build inputs changed; continue this Vercel deployment."
exit 1
