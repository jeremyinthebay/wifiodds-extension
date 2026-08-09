#!/bin/sh
# build-store-zip.sh — build the Chrome Web Store package from the EXACT committed
# tree, never the working tree. git archive reads committed blobs, so uncommitted
# edits (e.g. work-in-progress icons) can never leak into a release.
#
# The release gate binds Claude's receipt to the ZIP hash. Build the same bytes
# from the same commit by sorting file names and setting each timestamp from the
# source commit. The per-file manifest also proves content identity.
set -e
VER=$(node -e "console.log(require('./extension/manifest.json').version)")
SHA=$(git rev-parse --short HEAD)
OUT="dist/wifiodds-v${VER}.zip"
MAN="dist/wifiodds-v${VER}.files.sha256"
mkdir -p dist
rm -f "$OUT" "$MAN"
ROOT=$(pwd)
TMP=$(mktemp -d)
LIST=$(mktemp)
trap 'rm -rf "$TMP"; rm -f "$LIST"' EXIT
git archive --format=tar HEAD:extension | tar -xf - -C "$TMP"
STAMP=$(TZ=UTC date -r "$(git show -s --format=%ct HEAD)" +%Y%m%d%H%M.%S)
find "$TMP" -exec touch -t "$STAMP" {} +
(cd "$TMP" && find . -type f > "$LIST")
LC_ALL=C sort -o "$LIST" "$LIST"
(cd "$TMP" && zip -q -X "$ROOT/$OUT" -@ < "$LIST")
echo "built $OUT from commit $SHA"

# unpack and verify
UNPACK=$(mktemp -d)
unzip -q "$OUT" -d "$UNPACK"
PKGVER=$(node -e "console.log(require('$UNPACK/manifest.json').version)")
[ "$PKGVER" = "$VER" ] || { echo "FAIL: manifest version $PKGVER != $VER"; exit 1; }
node --check "$UNPACK/bg.js"
node --check "$UNPACK/content.js"
node --check "$UNPACK/popup.js"
node --check "$UNPACK/coverage.js"
[ -f "$UNPACK/manifest.json" ] || { echo "FAIL: manifest.json not at zip root"; exit 1; }
# Chrome Web Store rejects a manifest description over 132 chars — guard it so a
# too-long description can never ship again (it blocked the first v2.2 upload).
DLEN=$(node -e "process.stdout.write(String(require('$UNPACK/manifest.json').description.length))")
[ "$DLEN" -le 132 ] || { echo "FAIL: manifest description is $DLEN chars (Chrome limit 132)"; exit 1; }
if find "$UNPACK" -name '.DS_Store' | grep -q .; then echo "FAIL: .DS_Store in package"; exit 1; fi

# per-file content manifest, committed alongside the zip
( cd "$UNPACK" && find . -type f | sort | while read -r f; do
    printf '%s  %s\n' "$(shasum -a 256 "$f" | cut -d' ' -f1)" "${f#./}"
  done ) > "$MAN"

# cross-check: the manifest must equal git's own blob content for HEAD:extension
FAIL=0
while read -r hash path; do
  gitblob=$(git cat-file blob "HEAD:extension/$path" | shasum -a 256 | cut -d' ' -f1)
  if [ "$hash" != "$gitblob" ]; then echo "FAIL: $path differs from committed blob"; FAIL=1; fi
done < "$MAN"
[ "$FAIL" = 0 ] || exit 1

echo "package OK · v$VER · content identity verified against HEAD:extension"
echo "  zip     $(shasum -a 256 "$OUT" | cut -d' ' -f1)  (deterministic for the committed tree)"
echo "  files   $MAN  ($(wc -l < "$MAN" | tr -d ' ') files, each == committed blob)"
rm -rf "$UNPACK"
