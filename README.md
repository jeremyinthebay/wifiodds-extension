# WiFi Odds for Flights

A free Chrome overlay for airline-direct search.

Live Chrome Web Store build is **3.0.2**, published 11 Aug 2026. Do not describe
a later store version as live. The public product URL is https://wifiodds.com/ .
That is the homepage `extension/manifest.json` `homepage_url` uses. It is not the
retired `smithfamai.com/unitedstarlink` page.

The overlay scores United, Alaska, and Navan search results. Google Flights is
labels only: it never reorders. Best WiFi names a winner only when at least two
flights have usable data, the leader is ahead by eight points or more, and
tracker confidence is medium or high. If those checks fail, it refuses.

united.com and Navan work at install. alaskaair.com and Google Flights stay
behind an optional permission you grant yourself.

## Two numbers

Keep them separate:

- **Next-gen odds** are the chance of a Starlink or Amazon Leo aircraft. Live
  3.0.2 prints this per flight when the booking page supplies a United or Alaska
  flight number.
- **Streaming score** is a 0-100 rating of WiFi quality across an airline's
  published fleet today. The overlay labels it STREAMING. It is airline-wide.
  It is not per-flight next-gen odds.

An unpublished next-gen count is unknown, not zero. This overlay does not claim
Starlink on a given tail until a tracker confirmation says so.

## Live Store facts

- Name: WiFi Odds for Flights
- Item: [Chrome Web Store](https://chromewebstore.google.com/detail/ojpladpffbibebedfbcgbhckajbnijec)
- Summary matches the live manifest: `Per-flight odds your plane has next-gen WiFi, as you search. Auto-sorts single-airline results by odds. Unofficial.`
- Privacy: https://wifiodds.com/privacy
- Odds data: public APIs of unitedstarlinktracker.com and alaskastarlinktracker.com

`STORE.md` is this repo's record of those facts. It is not a rewrite of the
Chrome Web Store listing. Paste-ready listing copy stays in `store-assets/` and
is not the live listing.

## Install (unpacked)

chrome://extensions → enable Developer mode → Load unpacked → select the
`extension/` folder. Then open a supported search page. This is for local
source. It is not the live Store build.

## What's in this repository

| Path | What it is |
|---|---|
| `extension/` | Chrome overlay source. Manifest version in this tree can be newer than live Store 3.0.2. |
| `STORE.md` | Record of live Store 3.0.2. Not listing copy. |
| `CHANGELOG.md` | Source/package release history. Store publication is a separate, owner-verified event. |
| `store-assets/` | Owner upload packets. Do not treat them as the live listing. |
| `test/` | Browser gates and mutation controls. |

Leftover encyclopedia files (`index.html`, `data.json`, `UPDATER.md`) are not
the live product. Do not present the retired smithfamai.com/unitedstarlink page
as live.

## Browser testing

Routine browser tests must not open a visible Chrome window. `node test/phase2-e2e.mjs` uses
Playwright's full Chromium channel in native headless mode because its default headless shell does
not register this MV3 extension's service worker. Keep `headless: true` and `channel: "chromium"`
together; a missing service worker is a hard gate failure, never a reason to fall back to headed.

`node test/first-run-coverage-e2e.mjs` uses a separate fresh browser profile to prove a real install
opens the coverage page and both optional-host buttons call `permissions.request`. Its three named
mutations are included in `node test/mutation-matrix.mjs`.

`node test/readme-live-store.test.js` checks `README.md` and `STORE.md` against live Store 3.0.2
facts. Watching the current files pass does not prove the guard can fail.

`test/store-screenshots.mjs` is not a routine test: it is the explicit headed exception that captures
real-site Chrome Web Store artwork. Do not run that artifact generator as part of automated testing.

## Release history and tags

[`CHANGELOG.md`](CHANGELOG.md) is the extension repository's release history. Keep current work under
`[Unreleased]`; the first dated release entry must always equal `extension/manifest.json`'s version.
`node build-release-history-verify.mjs` enforces that binding, the date and ordering rules, and the
backfill through 2.0.0. `sh test/release-history-gate.sh` proves the gate fails in each named
direction. The read-only store verifier runs the binding automatically before checking artifacts.

A Git tag and changelog release record source identity; neither claims the Chrome Web Store has
published that source. Live Store stays 3.0.2 until Jeremy uploads a later reviewed package.
Before Jeremy uploads, the matching changelog entry says `Chrome Web Store: not uploaded`.
Store upload and Submit remain Jeremy's manual actions.

Cut a release in this order:

1. Update the manifest and move the packaged source notes from `[Unreleased]` into the matching
   dated changelog entry. The date is the immutable source/package release date; state Chrome Web
   Store publication separately and truthfully.
2. Build and commit the upload ZIP, file manifest, submission copy and store bundle, then run every
   release gate against that exact commit.
3. Create an annotated `vX.Y.Z` tag on that release commit and push that tag by its explicit name.
   Never move or force-update a published tag.

## Shared driver lock

This repository shares the relay's one-driver-at-a-time lock. Install the enforcement once per clone:

    sh install-driver-lock-hooks.sh

Both `pre-commit` and `pre-push` then read `wifiodds-relay/exchange/.driver-lock`. An active lock held
by a different `WIFIODDS_DRIVER_ID` blocks the write. A missing, malformed, expired or dead-pid lock
logs and allows, matching the relay's fail-open stale-lock semantics so an unattended refresh cannot
be wedged by a bad lock file. Run `sh test/driver-lock-hooks-gate.sh` for healthy and failing controls.

## License

MIT. Tracker data remains with unitedstarlinktracker.com and alaskastarlinktracker.com.
Probabilities are historical estimates, not guarantees. Verify your tail about 48 hours
before departure. Unofficial. Not affiliated with or endorsed by any airline, satellite
operator, or data provider.
