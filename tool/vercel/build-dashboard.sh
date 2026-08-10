#!/usr/bin/env bash
set -euo pipefail

REPO_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/../.." && pwd)"
cd "$REPO_ROOT"

export CI=true
export FLUTTER_SUPPRESS_ANALYTICS=true

FLUTTER_VERSION="$(node -p "require('./tool/tool_versions.json').flutter")"

use_pinned_flutter() {
  local version_line
  version_line="$(flutter --version 2>/dev/null | head -n 1 || true)"
  [[ "$version_line" == *"Flutter ${FLUTTER_VERSION}"* ]]
}

if command -v flutter >/dev/null 2>&1 && use_pinned_flutter; then
  echo "Using preinstalled Flutter ${FLUTTER_VERSION}."
else
  SDK_PARENT="${HOME}/.cache/stone-set/flutter-${FLUTTER_VERSION}"
  FLUTTER_BIN="${SDK_PARENT}/flutter/bin/flutter"

  if [[ ! -x "$FLUTTER_BIN" ]]; then
    echo "Installing Flutter ${FLUTTER_VERSION} for the Vercel dashboard build..."
    rm -rf "$SDK_PARENT"
    mkdir -p "$SDK_PARENT"

    ARCHIVE="${TMPDIR:-/tmp}/flutter_linux_${FLUTTER_VERSION}-stable.tar.xz"
    curl --fail --location --retry 3 --retry-delay 2 \
      "https://storage.googleapis.com/flutter_infra_release/releases/stable/linux/flutter_linux_${FLUTTER_VERSION}-stable.tar.xz" \
      --output "$ARCHIVE"
    tar -xf "$ARCHIVE" -C "$SDK_PARENT"
    rm -f "$ARCHIVE"
  fi

  # Vercel's build cache can restore the Flutter SDK with an owner that differs
  # from the current build user. Flutter runs Git commands against its SDK repo,
  # so trust only this exact pinned SDK checkout before invoking Flutter.
  git config --global --add safe.directory "${SDK_PARENT}/flutter"

  export PATH="${SDK_PARENT}/flutter/bin:${PATH}"
fi

flutter --version
flutter config --enable-web >/dev/null
flutter precache --web

dart pub get --enforce-lockfile
dart run bin/stone_set.dart stage-rank-assets

pushd apps/dashboard >/dev/null
flutter build web \
  --release \
  --dart-define-from-file=../../config/dart_defines.release.json
popd >/dev/null

test -f apps/dashboard/build/web/index.html

echo "Stone Set dashboard build complete: apps/dashboard/build/web"
