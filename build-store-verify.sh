#!/bin/sh
# build-store-verify.sh — FAIL-CLOSED, READ-ONLY candidate identity + copy gate.
#
# WHY THIS EXISTS (Codex round 20 P2). build-store-zip.sh REGENERATES the upload ZIP and file
# manifest from HEAD on every run, so it can only ever prove "the freshly built archive matches
# HEAD" — it can NEVER detect that the archive ALREADY COMMITTED in HEAD is stale. A one-byte
# committed source change with unchanged committed artifacts sails through it at exit 0.
#
# Release archives stopped being committed after 3.0.1. This gate therefore reads the exact
# candidate bundle and metadata produced by build-store-bundle.sh, while resolving product source,
# Store copy, screenshots and provenance from committed HEAD. It writes only to a temporary directory
# and fails closed when the candidate does not match HEAD or its recorded identity.
#
#   sh build-store-verify.sh     # exit 0 = exact candidate + Store copy match committed HEAD
set -eu
cd "$(dirname "$0")"
VER=$(node -e "console.log(require('./extension/manifest.json').version)")
# v3.1.0 continues the active 3.x Store asset set under store-assets/v3.0.
ADIR=${WIFIODDS_STORE_ASSET_DIR:-v3.0}
DIST_DIR=${WIFIODDS_STORE_DIST_DIR:-dist}
case "$DIST_DIR" in
  /*) ;;
  *) DIST_DIR="$(pwd)/$DIST_DIR" ;;
esac
CANDIDATE="$DIST_DIR/candidates/wifiodds-v${VER}-store-bundle.zip"
META="$DIST_DIR/candidates/wifiodds-v${VER}-store-bundle.candidate"
FAIL=0

meta_value() {
  awk -F= -v key="$1" '$1 == key { sub(/^[^=]*=/, ""); print; found=1 } END { if (!found) exit 1 }' "$META"
}

# The manifest is not the release history by itself. Bind it to the first
# released CHANGELOG entry before resolving any version-named artifact paths.
# This is a worktree check here; a committed release runs this same script from
# its committed files, while an in-progress version bump fails before packaging.
node ./build-release-history-verify.mjs

# The exact committed manifest description — the one string every store-copy surface must quote.
DESC=$(git show HEAD:extension/manifest.json | node -e "let s='';process.stdin.on('data',d=>s+=d).on('end',()=>process.stdout.write(JSON.parse(s).description))")

# The one source of truth: sha256 of every committed HEAD:extension blob, "hash  path".
EXPECT=$(git ls-tree -r --name-only HEAD:extension | while read -r f; do
  printf '%s  %s\n' "$(git cat-file blob "HEAD:extension/$f" | shasum -a 256 | cut -d' ' -f1)" "$f"
done | sort -k2)

TMP=$(mktemp -d)
trap 'rm -rf "$TMP"' EXIT HUP INT TERM

# 1. Candidate metadata is the review identity. It must name this exact HEAD and ZIP.
[ -f "$CANDIDATE" ] || { echo "FAIL: candidate bundle missing: $CANDIDATE"; exit 1; }
[ -f "$META" ] || { echo "FAIL: candidate metadata missing: $META"; exit 1; }
SOURCE_SHA=$(meta_value SOURCE_SHA)
RECORDED_ZIP_SHA=$(meta_value ZIP_SHA256)
CURRENT_ZIP_SHA=$(shasum -a 256 "$CANDIDATE" | cut -d' ' -f1)
[ "$SOURCE_SHA" = "$(git rev-parse HEAD)" ] || { echo "FAIL: candidate SOURCE_SHA does not equal HEAD"; FAIL=1; }
[ "$RECORDED_ZIP_SHA" = "$CURRENT_ZIP_SHA" ] || { echo "FAIL: candidate ZIP hash differs from metadata"; FAIL=1; }

# 2. Inspect the candidate itself; never regenerate the artifact under test.
cp "$CANDIDATE" "$TMP/bundle.zip"
mkdir "$TMP/b"
unzip -q "$TMP/bundle.zip" -d "$TMP/b"

# 3. The candidate must embed the exact CONTENT of committed HEAD:extension.
# ZIP container bytes carry timestamps, so the per-file hashes are the identity.
BZIP_COUNT=$(find "$TMP/b" -name "wifi-odds-extension-${VER}.zip" -type f | wc -l | tr -d ' ')
BZIP=$(find "$TMP/b" -name "wifi-odds-extension-${VER}.zip" -type f | head -1)
if [ "$BZIP_COUNT" = 1 ]; then
  mkdir "$TMP/bzip"
  unzip -q "$BZIP" -d "$TMP/bzip"
  BZGOT=$(cd "$TMP/bzip" && find . -type f | sed 's#^\./##' | while read -r f; do
    printf '%s  %s\n' "$(shasum -a 256 "$f" | cut -d' ' -f1)" "$f"
  done | sort -k2)
  if [ "$EXPECT" != "$BZGOT" ]; then
    printf '%s\n' "$EXPECT" > "$TMP/upload.files"
    printf '%s\n' "$BZGOT" > "$TMP/embedded.files"
    FIRST_DIFF=$(awk '
      FNR == NR { expected[$2]=$1; paths[$2]=1; next }
      { actual[$2]=$1; paths[$2]=1 }
      END { for (p in paths) if (expected[p] != actual[p]) print p }
    ' "$TMP/upload.files" "$TMP/embedded.files" | sort | head -1)
    echo "FAIL: candidate bundle package content differs from HEAD:extension"
    echo "  first differing path: $FIRST_DIFF"
    FAIL=1
  fi
else
  echo "FAIL: candidate bundle must contain exactly one wifi-odds-extension-${VER}.zip (found $BZIP_COUNT)"; FAIL=1
fi

# The manifest alongside the embedded package must describe the same content.
BMAN_COUNT=$(find "$TMP/b" -name "wifiodds-v${VER}.files.sha256" -type f | wc -l | tr -d ' ')
BMAN=$(find "$TMP/b" -name "wifiodds-v${VER}.files.sha256" -type f | head -1)
if [ "$BMAN_COUNT" = 1 ]; then
  BMANGOT=$(sort -k2 "$BMAN")
  [ "$EXPECT" = "$BMANGOT" ] || { echo "FAIL: bundle file manifest differs from HEAD:extension"; FAIL=1; }
else
  echo "FAIL: candidate bundle must contain exactly one wifiodds-v${VER}.files.sha256 (found $BMAN_COUNT)"; FAIL=1
fi

# The owner-cleared screenshots must be reused byte-for-byte. The provenance
# copy is not a phrase denylist: the complete block is a committed literal and
# the bundle must carry it byte-for-byte. This makes differently-worded
# overclaims fail closed instead of relying on guesses about future wording.
for shot in store-1-united-1280x800.png store-2-googleflights-1280x800.png store-3-alaska-1280x800.png store-4-navan-1280x800.png; do
  BSHOT=$(find "$TMP/b" -path "*/store-screenshots/$shot" -type f | head -1)
  git show "HEAD:store-assets/${ADIR}/real/$shot" > "$TMP/$shot.head"
  [ -n "$BSHOT" ] && cmp -s "$BSHOT" "$TMP/$shot.head" || { echo "FAIL: bundled screenshot $shot is not the cleared committed asset"; FAIL=1; }
done
BCHECK=$(find "$TMP/b" -name "UPLOAD-CHECKLIST.txt" -type f | head -1)
if [ -n "$BCHECK" ]; then
  git show "HEAD:store-assets/${ADIR}/UPLOAD-CHECKLIST-PROVENANCE.txt" > "$TMP/provenance.expected"
  awk '
    /^  Screenshot provenance:/ { in_provenance=1 }
    in_provenance && /^  Promo tile:/ { exit }
    in_provenance { print }
  ' "$BCHECK" > "$TMP/provenance.bundled"
  cmp -s "$TMP/provenance.bundled" "$TMP/provenance.expected" || {
    echo "FAIL: bundled screenshot provenance block differs byte-for-byte from committed literal"
    FAIL=1
  }
else
  echo "FAIL: committed bundle has no UPLOAD-CHECKLIST.txt"; FAIL=1
fi

# 3b. the SUBMIT copy INSIDE the committed bundle (what the operator actually uploads) must be the
#     exact committed source AND pass the copy checks itself (round 21 P2). Checking only the repo
#     source is not enough: a bundle whose SUBMIT drifts from source would sail through.
BSUBMIT=$(find "$TMP/b" -name "SUBMIT-${VER}.md" | head -1)
if [ -n "$BSUBMIT" ]; then
  git show "HEAD:store-assets/${ADIR}/SUBMIT-${VER}.md" > "$TMP/submit.head"
  cmp -s "$BSUBMIT" "$TMP/submit.head" || { echo "FAIL: SUBMIT-${VER}.md inside the committed bundle differs byte-for-byte from the committed source"; FAIL=1; }
  BS=$(cat "$BSUBMIT")
  printf '%s' "$BS" | grep -qF "$DESC" || { echo "FAIL: bundled SUBMIT-${VER}.md does not quote the exact manifest description"; FAIL=1; }
  # The rounds-20/21/22 check forbade EVERY default-auto-sort claim, because in
  # v2.2 any such claim was false. In 3.0 single-carrier auto-sort is real, so
  # that check would now block truthful copy — the same class of failure in the
  # opposite direction. It is replaced by 3b-ii, which pins copy to BEHAVIOUR:
  # the mixed-carrier default must still never be advertised as automatic.
  if printf '%s' "$BS" | grep -qiE "sorts mixed-carrier|automatically (sorts|reorders) (all|every|mixed)"; then
    echo "FAIL: bundled SUBMIT-${VER}.md claims automatic sorting on mixed-carrier pages"; FAIL=1
  fi
  printf '%s' "$BS" | grep -qi "prioritize\|move scored" || { echo "FAIL: bundled SUBMIT-${VER}.md does not describe the explicit mixed-carrier action"; FAIL=1; }
  # 3b-ii. SORT DISCLOSURE (Codex round 26, assertion 6). v3.0 sorts single-carrier
  #        pages automatically, so the retired v2.2 sentences are now FALSE and must
  #        never ship; and the copy must carry both the automatic behaviour and the
  #        "unknown, not worse" limitation. Three rounds were spent on copy drifting
  #        from behaviour — this is the assertion that stops a fourth.
  if printf '%s' "$BS" | grep -qiE "no automatic reordering|booking site's own order is preserved until|only when you ask|one-click sort"; then
    echo "FAIL: bundled SUBMIT-${VER}.md still carries a retired no-automatic-reordering claim"; FAIL=1
  fi
  printf '%s' "$BS" | grep -qi "automatically sorts" || { echo "FAIL: bundled SUBMIT-${VER}.md does not disclose automatic sorting"; FAIL=1; }
  printf '%s' "$BS" | grep -qiE "not lower|unknown,? (not|rather than) worse" || { echo "FAIL: bundled SUBMIT-${VER}.md does not state that unscored airlines are unknown, not worse"; FAIL=1; }
  printf '%s' "$BS" | grep -qiE "turn(ed| this)? off in Settings" || { echo "FAIL: bundled SUBMIT-${VER}.md does not say sorting can be turned off"; FAIL=1; }
  # 3c. STALE VERSION COPY (R23 Answer 2): the bundled copy must name the shipped version and must
  #     not present any pre-3.0 public version (2.2.0, or the never-public 2.3 / 2.4 intermediates)
  #     as current. Historical references are not needed in this doc, so any hit is a failure.
  printf '%s' "$BS" | grep -qF "v${VER}" || { echo "FAIL: bundled SUBMIT-${VER}.md never names v${VER}"; FAIL=1; }
  if printf '%s' "$BS" | grep -qE '\b2\.2\.0\b|\bv2\.2\b|\bv2\.3\b|\bv2\.4\b|\b2\.3\.[0-9]\b|\b2\.4\.[0-9]\b'; then
    echo "FAIL: bundled SUBMIT-${VER}.md carries stale pre-3.0 version copy"; FAIL=1
  fi
else
  echo "FAIL: committed bundle has no SUBMIT-${VER}.md"; FAIL=1
fi
# 4. the repository SUBMIT SOURCE must also match the shipped product (round 20 P1).
SUBMIT=$(git show "HEAD:store-assets/${ADIR}/SUBMIT-${VER}.md")
printf '%s' "$SUBMIT" | grep -qF "$DESC" || { echo "FAIL: SUBMIT-${VER}.md does not quote the exact committed manifest description"; FAIL=1; }
if printf '%s' "$SUBMIT" | grep -qiE "sorts mixed-carrier|automatically (sorts|reorders) (all|every|mixed)"; then
  echo "FAIL: SUBMIT-${VER}.md claims automatic sorting on mixed-carrier pages"; FAIL=1
fi
if printf '%s' "$SUBMIT" | grep -qiE "no automatic reordering|booking site's own order is preserved until|only when you ask|one-click sort"; then
  echo "FAIL: SUBMIT-${VER}.md still carries a retired no-automatic-reordering claim"; FAIL=1
fi
printf '%s' "$SUBMIT" | grep -qi "automatically sorts" || { echo "FAIL: SUBMIT-${VER}.md does not disclose automatic sorting"; FAIL=1; }
printf '%s' "$SUBMIT" | grep -qiE "not lower|unknown,? (not|rather than) worse" || { echo "FAIL: SUBMIT-${VER}.md does not state that unscored airlines are unknown, not worse"; FAIL=1; }
printf '%s' "$SUBMIT" | grep -qiE "turn(ed| this)? off in Settings" || { echo "FAIL: SUBMIT-${VER}.md does not say sorting can be turned off"; FAIL=1; }
printf '%s' "$SUBMIT" | grep -qi "prioritize\|move scored" || { echo "FAIL: SUBMIT-${VER}.md does not describe the explicit mixed-carrier action"; FAIL=1; }
# 4b. stale version copy in the SOURCE, same rule as 3c.
printf '%s' "$SUBMIT" | grep -qF "v${VER}" || { echo "FAIL: SUBMIT-${VER}.md never names v${VER}"; FAIL=1; }
if printf '%s' "$SUBMIT" | grep -qE '\b2\.2\.0\b|\bv2\.2\b|\bv2\.3\b|\bv2\.4\b|\b2\.3\.[0-9]\b|\b2\.4\.[0-9]\b'; then
  echo "FAIL: SUBMIT-${VER}.md carries stale pre-3.0 version copy"; FAIL=1
fi

[ "$FAIL" = 0 ] && echo "store-verify OK · candidate identity matches HEAD:extension · bundle embeds it · store copy matches the shipped product (v${VER})" || { echo "store-verify FAILED — do not upload"; exit 1; }
