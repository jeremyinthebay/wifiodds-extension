#!/bin/sh
# Candidate-based regression controls for build-store-verify.sh. Release ZIPs
# stopped being committed after 3.0.1, so every control supplies the exact
# candidate bundle + metadata that the verifier now protects.
set -eu

ROOT=$(CDPATH= cd -- "$(dirname "$0")/.." && pwd)
VERSION=$(node -e "console.log(require('$ROOT/extension/manifest.json').version)")
SOURCE_DIR="$ROOT/dist/candidates"
SOURCE_ZIP="$SOURCE_DIR/wifiodds-v${VERSION}-store-bundle.zip"
SOURCE_META="$SOURCE_DIR/wifiodds-v${VERSION}-store-bundle.candidate"
EXPECTED_OK="store-verify OK · candidate identity matches HEAD:extension · bundle embeds it · store copy matches the shipped product (v${VERSION})"
PROVENANCE_FAIL="FAIL: bundled screenshot provenance block differs byte-for-byte from committed literal"
SOURCE_FAIL="FAIL: candidate SOURCE_SHA does not equal HEAD"
TMP_ROOT=$(mktemp -d)
trap 'rm -rf "$TMP_ROOT"' EXIT HUP INT TERM

[ -f "$SOURCE_ZIP" ] && [ -f "$SOURCE_META" ] || {
  echo "CONTROL FAILED: build the candidate before running store provenance controls"
  exit 1
}

fresh_dist() {
  name=$1
  dist="$TMP_ROOT/$name"
  mkdir -p "$dist/candidates"
  cp "$SOURCE_ZIP" "$dist/candidates/"
  cp "$SOURCE_META" "$dist/candidates/"
  printf '%s\n' "$dist"
}

run_verify() {
  dist=$1
  output=$2
  set +e
  (cd "$ROOT" && WIFIODDS_STORE_DIST_DIR="$dist" sh build-store-verify.sh) >"$output" 2>&1
  status=$?
  set -e
  return "$status"
}

clean_dist=$(fresh_dist clean)
clean_out="$TMP_ROOT/clean.out"
run_verify "$clean_dist" "$clean_out" || { cat "$clean_out"; echo "CONTROL FAILED: clean candidate"; exit 1; }
grep -qFx "$EXPECTED_OK" "$clean_out" || { cat "$clean_out"; echo "CONTROL FAILED: missing success identity"; exit 1; }
echo "CONTROL PASS: clean exact candidate"

# Mutate the provenance inside the candidate, then update the metadata hash so
# the verifier must reach the independent committed-provenance comparison.
prov_dist=$(fresh_dist provenance)
prov_zip="$prov_dist/candidates/wifiodds-v${VERSION}-store-bundle.zip"
prov_meta="$prov_dist/candidates/wifiodds-v${VERSION}-store-bundle.candidate"
unpack="$TMP_ROOT/provenance-unpack"
mkdir "$unpack"
unzip -q "$prov_zip" -d "$unpack"
checklist=$(find "$unpack" -name UPLOAD-CHECKLIST.txt -type f | head -1)
sed -i '' '$a\
    These screenshots were captured from the reviewed Store package.' "$checklist"
top=$(find "$unpack" -mindepth 1 -maxdepth 1 -type d | head -1)
rm -f "$prov_zip"
(cd "$unpack" && zip -r -X "$prov_zip" "$(basename "$top")" >/dev/null)
new_hash=$(shasum -a 256 "$prov_zip" | cut -d' ' -f1)
sed -i '' "s/^ZIP_SHA256=.*/ZIP_SHA256=$new_hash/" "$prov_meta"
prov_out="$TMP_ROOT/provenance.out"
if run_verify "$prov_dist" "$prov_out"; then cat "$prov_out"; echo "CONTROL FAILED: provenance mutation passed"; exit 1; fi
grep -qFx "$PROVENANCE_FAIL" "$prov_out" || { cat "$prov_out"; echo "CONTROL FAILED: wrong provenance branch"; exit 1; }
echo "CONTROL PASS: candidate provenance drift fails closed"

# Metadata may not claim that a candidate built from another source is current.
source_dist=$(fresh_dist source)
source_meta="$source_dist/candidates/wifiodds-v${VERSION}-store-bundle.candidate"
sed -i '' 's/^SOURCE_SHA=.*/SOURCE_SHA=0000000000000000000000000000000000000000/' "$source_meta"
source_out="$TMP_ROOT/source.out"
if run_verify "$source_dist" "$source_out"; then cat "$source_out"; echo "CONTROL FAILED: stale source identity passed"; exit 1; fi
grep -qFx "$SOURCE_FAIL" "$source_out" || { cat "$source_out"; echo "CONTROL FAILED: wrong source identity branch"; exit 1; }
echo "CONTROL PASS: stale candidate source fails closed"
