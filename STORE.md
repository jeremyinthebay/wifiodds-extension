# Chrome Web Store release materials

The current release package is WiFi Odds for Flights v3.1.0. Jeremy alone uploads and submits the
reviewed package. Use [SUBMIT-3.1.0.md](store-assets/v3.0/SUBMIT-3.1.0.md) as the field-by-field
dashboard source of truth.

## Current status

- Source: final candidate preparation. It has no reviewed Store ZIP yet.
- Site model: pinned to Claude-reviewed, live site commit
  `cae8be119b83abff12f57877c1cf344b03b8b6b8` and model blob
  `8b04acd3a7c88f7dea86d5367a5de1ffc125222e`.
- Screenshots: four 1280×800 replacement captures were generated from committed source `4a7d6f0`
  after the full browser gate passed. The release bundle carries their exact provenance block.
- Privacy and permissions: unchanged from the published 3.0.2 listing. The v3.1.0 package adds no
  host, permission, stored field, collection, transmission, or retention behavior.

## Operator boundary

1. Wait for the exact extension candidate, ZIP hash, and Claude Tier A PASS receipt.
2. Upload only the reviewed ZIP and the four images named in the submission package.
3. Paste the replacement listing and privacy fields from the submission package.
4. Save the draft, inspect Chrome's change summary, and submit it yourself.
5. Report upload, submission, approval, and publication as separate states.

The Chrome Web Store summary must continue to match `extension/manifest.json` exactly. The longer
Store description belongs in the submission package.
