#!/bin/sh
set -eu

RECEIPT_DIR=${WIFIODDS_REVIEW_RECEIPT_DIR:-/Users/jeremysmith/Projects/wifiodds-relay/exchange/from-auditor}
SOURCE_SHA=
RELEASE_TAG=
SITE_SHA=
MODEL_BLOB=
ZIP_SHA256=

while [ "$#" -gt 0 ]; do
  case "$1" in
    --receipt-dir) RECEIPT_DIR=$2; shift 2 ;;
    --source-sha) SOURCE_SHA=$2; shift 2 ;;
    --release-tag) RELEASE_TAG=$2; shift 2 ;;
    --site-sha) SITE_SHA=$2; shift 2 ;;
    --model-blob) MODEL_BLOB=$2; shift 2 ;;
    --zip-sha256) ZIP_SHA256=$2; shift 2 ;;
    *) echo "store receipt: unknown argument $1" >&2; exit 2 ;;
  esac
done

[ "${#SOURCE_SHA}" -eq 40 ] || { echo 'store receipt: SOURCE_SHA must contain 40 characters' >&2; exit 2; }
[ -n "$RELEASE_TAG" ] || { echo 'store receipt: RELEASE_TAG is required' >&2; exit 2; }
[ -n "$SITE_SHA" ] || { echo 'store receipt: SITE_SHA is required' >&2; exit 2; }
[ -n "$MODEL_BLOB" ] || { echo 'store receipt: MODEL_BLOB is required' >&2; exit 2; }
[ "${#ZIP_SHA256}" -eq 64 ] || { echo 'store receipt: ZIP_SHA256 must contain 64 characters' >&2; exit 2; }

for receipt in "$RECEIPT_DIR"/REVIEW-RECEIPT-A-*.md; do
  [ -f "$receipt" ] || continue
  grep -Fqx 'VERDICT: PASS' "$receipt" || continue
  grep -Fqx 'REPOSITORY: united-starlink-companion' "$receipt" || continue
  grep -Fqx "SOURCE_SHA: $SOURCE_SHA" "$receipt" || continue
  grep -Fqx "RELEASE_TAG: $RELEASE_TAG" "$receipt" || continue
  grep -Fqx "SITE_SHA: $SITE_SHA" "$receipt" || continue
  grep -Fqx "MODEL_BLOB: $MODEL_BLOB" "$receipt" || continue
  grep -Fqx "ZIP_SHA256: $ZIP_SHA256" "$receipt" || continue
  echo "store receipt: PASS $(basename "$receipt")"
  exit 0
done

echo 'store receipt: HOLD' >&2
echo "No PASS receipt matches source $SOURCE_SHA, tag $RELEASE_TAG, both model pins, and ZIP $ZIP_SHA256." >&2
echo "Expected under: $RECEIPT_DIR" >&2
exit 1
