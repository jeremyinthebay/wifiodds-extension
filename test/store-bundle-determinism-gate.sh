#!/bin/sh
set -eu

ROOT=$(CDPATH= cd -- "$(dirname "$0")/.." && pwd)
cd "$ROOT"
TMP=$(mktemp -d)
trap 'rm -rf "$TMP"' EXIT
VER=$(node -e "console.log(require('./extension/manifest.json').version)")
TEST_DIST="$TMP/dist"
META="$TEST_DIST/candidates/wifiodds-v${VER}-store-bundle.candidate"

WIFIODDS_STORE_DIST_DIR="$TEST_DIST" RELEASE_TAG="v${VER}-determinism-control" sh ./build-store-bundle.sh candidate >/dev/null
FIRST=$(awk -F= '$1 == "ZIP_SHA256" { print $2 }' "$META")
WIFIODDS_STORE_DIST_DIR="$TEST_DIST" RELEASE_TAG="v${VER}-determinism-control" sh ./build-store-bundle.sh candidate >/dev/null
SECOND=$(awk -F= '$1 == "ZIP_SHA256" { print $2 }' "$META")

[ -n "$FIRST" ] && [ "$FIRST" = "$SECOND" ] || {
  echo "FAIL: same source produced candidate hashes $FIRST and $SECOND" >&2
  exit 1
}

echo "store bundle determinism control: PASS $FIRST"
