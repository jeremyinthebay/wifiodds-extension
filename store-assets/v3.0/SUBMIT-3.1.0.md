# Chrome Web Store submission · WiFi Odds for Flights v3.1.0

Chrome Web Store status: **not uploaded**. Jeremy uploads the exact reviewed package and submits it
himself. Do not use this document until the release packet names an exact source SHA, site SHA,
model blob, ZIP SHA-256, and Claude Tier A PASS receipt.

## Dashboard fields to replace

### Package

Upload `wifi-odds-extension-3.1.0.zip` from the reviewed handoff bundle only.

### Store listing

- **Name:** `WiFi Odds for Flights`
- **Summary:**

  `Per-flight odds your plane has next-gen WiFi, as you search. Auto-sorts single-airline results by odds. Unofficial.`

- **Category:** Travel
- **Language:** English
- **Description:**

  ```
  WiFi Odds adds next-gen WiFi odds while you compare flights. It labels supported search results
  on united.com, alaskaair.com, Navan, and Google Flights.

  Per-flight next-gen odds show historical evidence for a specific United or Alaska flight when
  a tracker publishes it. Streaming score is a 0–100 rating of an airline's WiFi across its whole
  fleet today. It does not predict the WiFi on a specific flight.

  WiFi Odds automatically sorts supported single-carrier results by historical per-flight next-gen
  odds. You can turn this off in Settings or restore the booking site's order. On mixed-carrier
  Navan results, you can choose to prioritize scored United flights. Other airlines are unscored,
  unknown rather than worse, and keep their relative order. Google Flights is never reordered.

  Guard can watch a selected flight's dated tail assignment through boarding and send a local alert
  if it changes. No account, analytics, advertising identifier, or third-party tracking is used.

  To fetch odds, the service worker sends origin and destination airport codes for the route being
  viewed and visible supported flight numbers to the relevant community tracker. For a flight the
  traveler Guards, it sends that flight number and date on the periodic assignment-check schedule.
  United lookups use unitedstarlinktracker.com and Alaska lookups use alaskastarlinktracker.com.
  Local odds cache, preferences, guarded trips, bounded Guard-time alternatives, and post-flight
  worked/didn't-work answers stay on the device. The bounded Guard-time alternatives clear after
  departure. An unanswered trip expires 30 days after departure. Answered trips and local outcome
  history stay until the traveler removes them. The extension never sends fares, times, page markup,
  account data, or URLs to those trackers.

  Per-flight odds come from the community trackers at unitedstarlinktracker.com and
  alaskastarlinktracker.com. WiFi Odds is unofficial and is not affiliated with United, Alaska,
  Navan, Google, SpaceX, Amazon, or those trackers.
  ```

### What's new

`Streaming score replaces the previous customer score name. Navan flight times now match the valid time shown in the booking result, and screen readers hear the United-only sorting note only on Navan.`

### Screenshots changed

Replace all four 1280×800 images with the files from the reviewed bundle:

1. `store-1-united-1280x800.png`
2. `store-2-googleflights-1280x800.png`
3. `store-3-alaska-1280x800.png`
4. `store-4-navan-1280x800.png`

Each replacement must name the committed source SHA and capture timestamp in its release-packet
provenance. Do not reuse a 3.0.x or provisional image.

## Privacy tab

### Single purpose

`Shows per-flight next-gen WiFi odds and airline-level Streaming scores on supported flight-search results so travelers can compare WiFi evidence before booking.`

### Data usage

Choose **Does not collect or use user data**.

### Privacy policy URL

`https://wifiodds.com/privacy.html`

### Permission justifications

- `storage` stores a local odds cache, preferences, guarded trips, bounded Guard-time alternative
  snapshots, and local outcome history. These stay on the device.
- `activeTab` and `scripting` let the popup read the active supported booking tab and register the
  content script after a user grants an optional host.
- `alarms` performs periodic local Guard checks and selector refresh.
- `notifications` sends local dated tail-assignment and post-flight prompts.
- `unitedstarlinktracker.com` lets the service worker fetch United odds.
- Alaska and Google Flights access remain optional permissions requested only after the traveler
  chooses the matching control.

### Network-data disclosure

The extension sends route airport codes and visible supported flight numbers to the applicable
community tracker for odds lookups. A guarded trip sends its flight number and date only on the
periodic assignment-check schedule. These requests go to `unitedstarlinktracker.com` for United or
`alaskastarlinktracker.com` for Alaska. Device-local data includes the odds cache, preferences,
guarded trips, bounded Guard-time alternatives, and post-flight outcome answers. The extension
keeps those data on the device. Bounded Guard-time alternatives clear after departure. An unanswered
trip expires 30 days after departure, while answered trips and local outcome history remain until
the traveler removes them. It does not send fares, times, page markup, account data, or URLs, and
it uses no account, analytics, advertising identifier, or third-party tracking.

No permission, host, stored field, collection, transmission, retention, or privacy-policy URL
changes in v3.1.0.

## Upload checklist for Jeremy

1. Confirm the release packet's five exact values and Claude PASS receipt.
2. Upload the reviewed ZIP and four named replacement screenshots.
3. Replace the listing, What's new, and privacy fields above.
4. Save the draft, inspect Chrome's generated diff, then select **Submit for review**.
5. Report whether Chrome shows uploaded, submitted, approved, or published.
