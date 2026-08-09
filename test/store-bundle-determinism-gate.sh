#!/bin/sh
set -eu

ROOT=$(CDPATH= cd -- "$(dirname "$0")/.." && pwd)
cd "$ROOT"
META=dist/candidates/wifiodds-v3.0.1-store-bundle.candidate

RELEASE_TAG=v3.0.1-determinism-control sh ./build-store-bundle.sh candidate >/dev/null
FIRST=$(awk -F= '$1 == "ZIP_SHA256" { print $2 }' "$META")
RELEASE_TAG=v3.0.1-determinism-control sh ./build-store-bundle.sh candidate >/dev/null
SECOND=$(awk -F= '$1 == "ZIP_SHA256" { print $2 }' "$META")

[ -n "$FIRST" ] && [ "$FIRST" = "$SECOND" ] || {
  echo "FAIL: same source produced candidate hashes $FIRST and $SECOND" >&2
  exit 1
}

echo "store bundle determinism control: PASS $FIRST"
