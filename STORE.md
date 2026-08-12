# Chrome Web Store release materials

The current release package is WiFi Odds for Flights v3.1.0. Jeremy alone uploads and submits the
reviewed package. Use [SUBMIT-3.1.0.md](store-assets/v3.0/SUBMIT-3.1.0.md) as the field-by-field
dashboard source of truth.

## Current status

- Source: pre-candidate only. It has no reviewed Store ZIP.
- Site model: waiting for Claude PASS on site candidate
  `8d8c7ef491bdb49a1912fbd4e494cbf759931f41` before the extension can pin it.
- Screenshots: four replacement captures must come from the committed, pinned candidate. The
  provisional capture pipeline writes outside release assets and cannot supply an upload image.
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
