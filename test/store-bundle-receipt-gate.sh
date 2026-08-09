#!/bin/sh
set -eu

ROOT=$(CDPATH= cd -- "$(dirname "$0")/.." && pwd)
TMP=$(mktemp -d)
trap 'rm -rf "$TMP"' EXIT

SHA=1111111111111111111111111111111111111111
ZIP_SHA=aaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaa
SITE_SHA=2222222222222222222222222222222222222222
MODEL_BLOB=3333333333333333333333333333333333333333
TAG=v9.9.9
RECEIPTS="$TMP/receipts"
mkdir -p "$RECEIPTS"

if "$ROOT/build-store-receipt-check.sh" --receipt-dir "$RECEIPTS" --source-sha "$SHA" --release-tag "$TAG" --site-sha "$SITE_SHA" --model-blob "$MODEL_BLOB" --zip-sha256 "$ZIP_SHA"; then
  echo 'FAIL: promotion passed without a receipt' >&2
  exit 1
fi

cat > "$RECEIPTS/REVIEW-RECEIPT-A-extension-wrong.md" <<EOF
VERDICT: PASS
REPOSITORY: united-starlink-companion
SOURCE_SHA: $SHA
RELEASE_TAG: $TAG
SITE_SHA: $SITE_SHA
MODEL_BLOB: $MODEL_BLOB
ZIP_SHA256: bbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbb
EOF
if "$ROOT/build-store-receipt-check.sh" --receipt-dir "$RECEIPTS" --source-sha "$SHA" --release-tag "$TAG" --site-sha "$SITE_SHA" --model-blob "$MODEL_BLOB" --zip-sha256 "$ZIP_SHA"; then
  echo 'FAIL: promotion accepted another ZIP hash' >&2
  exit 1
fi

cat > "$RECEIPTS/REVIEW-RECEIPT-A-extension-exact.md" <<EOF
VERDICT: PASS
REPOSITORY: united-starlink-companion
SOURCE_SHA: $SHA
RELEASE_TAG: $TAG
SITE_SHA: $SITE_SHA
MODEL_BLOB: $MODEL_BLOB
ZIP_SHA256: $ZIP_SHA
EOF
if ! "$ROOT/build-store-receipt-check.sh" --receipt-dir "$RECEIPTS" --source-sha "$SHA" --release-tag "$TAG" --site-sha "$SITE_SHA" --model-blob "$MODEL_BLOB" --zip-sha256 "$ZIP_SHA"; then
  echo 'FAIL: promotion rejected the exact PASS receipt' >&2
  exit 1
fi

echo 'store bundle receipt controls: PASS (3/3)'
