#!/usr/bin/env bash
#
# Runs every module's tests, the app-level tests included — the counterpart of
# the original's TestPlan.xctestplan.
#
set -euo pipefail

cd "$(dirname "$0")/.."

echo "==> analyze"
flutter analyze

for package in packages/network_service packages/movies_data; do
  echo "==> $package (dart)"
  (cd "$package" && dart test "$@")
done

for package in packages/movies packages/search; do
  echo "==> $package"
  (cd "$package" && flutter test "$@")
done

echo "==> app"
flutter test "$@"
