#!/bin/sh
# Build one review candidate, then promote those exact bytes after Claude records a PASS receipt.
set -eu

cd "$(dirname "$0")"
ROOT=$(pwd)
MODE=${1:-candidate}
DIST_DIR=${WIFIODDS_STORE_DIST_DIR:-dist}
case "$DIST_DIR" in
  /*) ;;
  *) DIST_DIR="$ROOT/$DIST_DIR" ;;
esac
VER=$(node -e "console.log(require('./extension/manifest.json').version)")
RELEASE_TAG=${RELEASE_TAG:-v${VER}}
ADIR=v$(printf '%s' "$VER" | cut -d. -f1,2)
CANDIDATE_DIR="$DIST_DIR/candidates"
CANDIDATE="$CANDIDATE_DIR/wifiodds-v${VER}-store-bundle.zip"
META="$CANDIDATE_DIR/wifiodds-v${VER}-store-bundle.candidate"
OUT="$DIST_DIR/wifiodds-v${VER}-store-bundle.zip"
RECEIPT_DIR=${WIFIODDS_REVIEW_RECEIPT_DIR:-/Users/jeremysmith/Projects/wifiodds-relay/exchange/from-auditor}

pin_value() {
  awk -F= -v key="$1" '$1 == key { print $2; found=1 } END { if (!found) exit 1 }' release-model.pin
}

meta_value() {
  awk -F= -v key="$1" '$1 == key { sub(/^[^=]*=/, ""); print; found=1 } END { if (!found) exit 1 }' "$META"
}

promote_candidate() {
  [ -f "$CANDIDATE" ] || { echo "FAIL: candidate is missing: $CANDIDATE" >&2; exit 1; }
  [ -f "$META" ] || { echo "FAIL: candidate metadata is missing: $META" >&2; exit 1; }

  SOURCE_SHA=$(meta_value SOURCE_SHA)
  CANDIDATE_TAG=$(meta_value RELEASE_TAG)
  SITE_SHA=$(meta_value SITE_SHA)
  MODEL_BLOB=$(meta_value MODEL_BLOB)
  RECORDED_ZIP_SHA=$(meta_value ZIP_SHA256)
  CURRENT_ZIP_SHA=$(shasum -a 256 "$CANDIDATE" | cut -d' ' -f1)

  [ "$SOURCE_SHA" = "$(git rev-parse HEAD)" ] || { echo 'FAIL: HEAD moved after candidate assembly' >&2; exit 1; }
  [ "$SITE_SHA" = "$(pin_value SITE_SHA)" ] || { echo 'FAIL: SITE_SHA changed after candidate assembly' >&2; exit 1; }
  [ "$MODEL_BLOB" = "$(pin_value MODEL_BLOB)" ] || { echo 'FAIL: MODEL_BLOB changed after candidate assembly' >&2; exit 1; }
  [ "$RECORDED_ZIP_SHA" = "$CURRENT_ZIP_SHA" ] || { echo 'FAIL: candidate ZIP hash changed after assembly' >&2; exit 1; }

  sh ./build-store-receipt-check.sh \
    --receipt-dir "$RECEIPT_DIR" \
    --source-sha "$SOURCE_SHA" \
    --release-tag "$CANDIDATE_TAG" \
    --site-sha "$SITE_SHA" \
    --model-blob "$MODEL_BLOB" \
    --zip-sha256 "$CURRENT_ZIP_SHA" || {
      echo 'STORE BUNDLE HELD: Claude has not cleared these exact candidate bytes.' >&2
      exit 100
    }

  mkdir -p "$DIST_DIR"
  cp "$CANDIDATE" "$OUT"
  [ "$(shasum -a 256 "$OUT" | cut -d' ' -f1)" = "$CURRENT_ZIP_SHA" ] || {
    echo 'FAIL: promoted ZIP differs from reviewed candidate' >&2
    rm -f "$OUT"
    exit 1
  }
  echo "promoted $OUT without rebuilding · sha256 $CURRENT_ZIP_SHA"
}

build_candidate() {
  SOURCE_SHA=$(git rev-parse HEAD)
  SITE_SHA=$(pin_value SITE_SHA)
  MODEL_BLOB=$(pin_value MODEL_BLOB)
  STAGE_ROOT=$(mktemp -d)
  trap 'rm -rf "$STAGE_ROOT"' EXIT
  STAGE="$STAGE_ROOT/wifiodds-v${VER}-store-bundle"

  WIFIODDS_STORE_DIST_DIR="$DIST_DIR" sh ./build-store-zip.sh

  mkdir -p "$STAGE/store-screenshots" "$STAGE/promo-tiles" "$CANDIDATE_DIR"
  cp "$DIST_DIR/wifiodds-v${VER}.zip" "$STAGE/wifi-odds-extension-${VER}.zip"
  cp "$DIST_DIR/wifiodds-v${VER}.files.sha256" "$STAGE/"
  cp "store-assets/${ADIR}/SUBMIT-${VER}.md" "$STAGE/"
  cp "store-assets/${ADIR}/real/store-1-united-1280x800.png" "$STAGE/store-screenshots/"
  cp "store-assets/${ADIR}/real/store-2-googleflights-1280x800.png" "$STAGE/store-screenshots/"
  cp "store-assets/${ADIR}/real/store-3-alaska-1280x800.png" "$STAGE/store-screenshots/"
  cp "store-assets/${ADIR}/real/store-4-navan-1280x800.png" "$STAGE/store-screenshots/"
  cp store-assets/v2.1/promo-marquee-1400x560.png store-assets/v2.1/promo-small-440x280.png store-assets/v2.1/store-icon-128.png "$STAGE/promo-tiles/"

  cat > "$STAGE/UPLOAD-CHECKLIST.txt" <<EOF
WiFi Odds v${VER} Chrome Web Store upload set
  Package: wifi-odds-extension-${VER}.zip
  Screenshots: store-1-united, store-2-googleflights, store-3-alaska, store-4-navan
  Field copy and privacy disclosure: SUBMIT-${VER}.md
Upload only the files in this bundle.
EOF
  cat "store-assets/${ADIR}/UPLOAD-CHECKLIST-PROVENANCE.txt" >> "$STAGE/UPLOAD-CHECKLIST.txt"

  ALLOW="wifi-odds-extension-${VER}.zip
wifiodds-v${VER}.files.sha256
SUBMIT-${VER}.md
UPLOAD-CHECKLIST.txt
store-screenshots/store-1-united-1280x800.png
store-screenshots/store-2-googleflights-1280x800.png
store-screenshots/store-3-alaska-1280x800.png
store-screenshots/store-4-navan-1280x800.png
promo-tiles/promo-marquee-1400x560.png
promo-tiles/promo-small-440x280.png
promo-tiles/store-icon-128.png"
  GOT=$(cd "$STAGE" && find . -type f | sed 's#^\./##' | sort)
  [ "$(printf '%s\n' "$ALLOW" | sort)" = "$GOT" ] || {
    echo 'FAIL: bundle contents do not match the allow-list' >&2
    printf '%s\n' "$GOT" >&2
    exit 1
  }

  for png in "$STAGE"/store-screenshots/*.png; do
    W=$(sips -g pixelWidth "$png" | awk '/pixelWidth/{print $2}')
    H=$(sips -g pixelHeight "$png" | awk '/pixelHeight/{print $2}')
    [ "$W" = 1280 ] && [ "$H" = 800 ] || { echo "FAIL: $(basename "$png") is ${W}x${H}" >&2; exit 1; }
  done

  STAMP=$(TZ=UTC date -r "$(git show -s --format=%ct HEAD)" +%Y%m%d%H%M.%S)
  find "$STAGE" -exec touch -t "$STAMP" {} +
  rm -f "$CANDIDATE"
  (cd "$STAGE_ROOT" && zip -r -X "$CANDIDATE" "$(basename "$STAGE")" >/dev/null)
  ZIP_SHA256=$(shasum -a 256 "$CANDIDATE" | cut -d' ' -f1)
  cat > "$META" <<EOF
SOURCE_SHA=$SOURCE_SHA
RELEASE_TAG=$RELEASE_TAG
SITE_SHA=$SITE_SHA
MODEL_BLOB=$MODEL_BLOB
ZIP_SHA256=$ZIP_SHA256
EOF
  echo "candidate built: $CANDIDATE"
  cat "$META"
  echo "Run 'sh build-store-bundle.sh promote' after Claude records a PASS receipt."
}

case "$MODE" in
  candidate) build_candidate ;;
  promote) promote_candidate ;;
  *) echo 'usage: sh build-store-bundle.sh [candidate|promote]' >&2; exit 2 ;;
esac
