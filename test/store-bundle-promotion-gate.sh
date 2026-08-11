#!/bin/sh
set -eu

ROOT=$(CDPATH= cd -- "$(dirname "$0")/.." && pwd)
cd "$ROOT"
TMP=$(mktemp -d)
trap 'rm -rf "$TMP"' EXIT
VER=$(node -e "console.log(require('./extension/manifest.json').version)")
TEST_DIST="$TMP/dist"
META="$TEST_DIST/candidates/wifiodds-v${VER}-store-bundle.candidate"
CANDIDATE="$TEST_DIST/candidates/wifiodds-v${VER}-store-bundle.zip"
OUT="$TEST_DIST/wifiodds-v${VER}-store-bundle.zip"
TAG="v${VER}-promotion-control"

WIFIODDS_STORE_DIST_DIR="$TEST_DIST" RELEASE_TAG="$TAG" sh ./build-store-bundle.sh candidate >/dev/null

set +e
WIFIODDS_STORE_DIST_DIR="$TEST_DIST" WIFIODDS_REVIEW_RECEIPT_DIR="$TMP" sh ./build-store-bundle.sh promote >/dev/null 2>&1
NO_RECEIPT_EXIT=$?
set -e
[ "$NO_RECEIPT_EXIT" -eq 100 ] || {
  echo "FAIL: promotion without a receipt exited $NO_RECEIPT_EXIT, expected 100" >&2
  exit 1
}

SOURCE_SHA=$(awk -F= '$1 == "SOURCE_SHA" { print $2 }' "$META")
SITE_SHA=$(awk -F= '$1 == "SITE_SHA" { print $2 }' "$META")
MODEL_BLOB=$(awk -F= '$1 == "MODEL_BLOB" { print $2 }' "$META")
ZIP_SHA256=$(awk -F= '$1 == "ZIP_SHA256" { print $2 }' "$META")

cat > "$TMP/REVIEW-RECEIPT-A-extension-control.md" <<EOF
VERDICT: PASS
REPOSITORY: united-starlink-companion
SOURCE_SHA: $SOURCE_SHA
RELEASE_TAG: $TAG
SITE_SHA: $SITE_SHA
MODEL_BLOB: $MODEL_BLOB
ZIP_SHA256: $ZIP_SHA256
EOF

WIFIODDS_STORE_DIST_DIR="$TEST_DIST" WIFIODDS_REVIEW_RECEIPT_DIR="$TMP" sh ./build-store-bundle.sh promote >/dev/null
PROMOTED_SHA=$(shasum -a 256 "$OUT" | cut -d' ' -f1)
[ "$PROMOTED_SHA" = "$ZIP_SHA256" ] || {
  echo "FAIL: promoted hash $PROMOTED_SHA differs from reviewed hash $ZIP_SHA256" >&2
  exit 1
}
[ "$(shasum -a 256 "$CANDIDATE" | cut -d' ' -f1)" = "$PROMOTED_SHA" ] || {
  echo 'FAIL: promotion rebuilt or changed the candidate' >&2
  exit 1
}

echo "store bundle promotion controls: PASS (hold, receipt, byte identity) $PROMOTED_SHA"
