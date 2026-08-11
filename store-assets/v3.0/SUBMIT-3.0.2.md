# Chrome Web Store submission · WiFi Odds for Flights v3.0.2

Chrome Web Store status: **not uploaded**. Jeremy performs the upload and Submit steps manually.

## Dashboard changes for 3.0.2

- **Package:** upload `wifi-odds-extension-3.0.2.zip` from the reviewed handoff bundle.
- **Store listing:** no text change is required. The current description still matches the product.
- **Privacy page:** no change is required. Version 3.0.2 adds no permission, host, stored field, data
  collection, or transmission.
- **Screenshots and promo images:** no change. Reuse the four cleared real-site screenshots and the
  existing promo images in this bundle.

## What's new in 3.0.2

- The WiFi Odds panel closes when Navan leaves flight results, including when seat selection opens,
  so it does not cover the booking controls.
- While flight results are open, the panel can be minimized, reopened, moved left or right, or
  dragged by its header.
- The extension does not save the panel's position.

## What the extension does

WiFi Odds adds next-generation WiFi odds to supported flight-search results and explains when the
evidence is strong enough to name a best choice. It can Guard a selected flight's dated tail
assignment through boarding and alert when the assignment changes.

## Sort behavior

WiFi Odds automatically sorts supported single-carrier results by historical per-flight next-gen
odds by default. Sorting can be turned off in Settings. The visible “Keep site order” control
restores the booking site's order.

On mixed-carrier Navan results, the booking site's order stays in place until the traveler chooses
to prioritize or move scored United flights. Other airlines are unscored (unknown, not worse) and
keep their relative order. Google Flights is never reordered. Sorting does not change fares,
selections, booking controls, or navigation.

## Data that leaves the device

To fetch odds, the service worker sends the following to the relevant community tracker
(`unitedstarlinktracker.com`, or `alaskastarlinktracker.com` for Alaska):

1. origin and destination airport codes for the route being viewed;
2. visible supported flight numbers used for per-flight odds; and
3. for a flight the traveler Guards, its flight number and date on the periodic check schedule.

Local post-flight “worked” / “didn't work” answers remain in `chrome.storage.local` and make no
network request. There is no account, analytics, advertising identifier, or third-party tracking.
The bounded Guard shortlist also remains on the device, never includes fares, times, page markup,
account data, or URLs, and is cleared after departure or when the guarded trip is removed.

## Permissions justification

- `storage` — local odds cache, preferences, guarded trips, their bounded Guard-time alternative
  snapshots, and local outcome history.
- `activeTab`, `scripting` — display the extension on supported booking searches.
- `alarms` — periodic Guard checks and selector refresh.
- `notifications` — dated tail-assignment and post-flight prompts.
- `unitedstarlinktracker.com` host permission — fetch United odds.
- Alaska and Google page access remain optional permissions granted by the traveler at runtime.

On first install, the extension opens its own setup page in a new tab. Opening that page does not
require a new permission. It does not open again on extension or Chrome updates.

## Manifest description

The listing description must quote the manifest exactly:

> Per-flight odds your plane has next-gen WiFi, as you search. Auto-sorts single-airline results by odds. Unofficial.

## Credit

Odds data: @martinamps' community Starlink trackers. The extension is unofficial and is not
affiliated with United, Alaska, Navan, Google, SpaceX, or Amazon.
