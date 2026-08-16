# WiFi Odds booking-row visual pass

- Status: design only
- Owner: Sol
- Requested by: Jeremy Smith, 16 August 2026
- Owner lock: 16 August 2026 ~3:59pm MT (Starlink Confirmed chip)
Mock: [`docs/mockups/overlay-row-visual-pass.html`](../mockups/overlay-row-visual-pass.html)

## Decision

Replace the stacked badge pair with one compact capsule on the booking row.
It inherits the host row's type and rhythm. Ownership is the filled WiFi Odds
plate, not a paper card with a decorative rail.

This pass specifies presentation only. It does not add or change tail-assignment
lookup, data requests, sorting, host detection, permissions, Store copy, package
versions, or release state. The assigned-tail examples in the mock are static
fictional states.

## Source of truth

Colors were read on 16 August 2026 from:

- the live [`wifiodds.com`](https://wifiodds.com/) homepage;
- [`SmithFamAI/wifiodds/assets/site.css`](https://github.com/SmithFamAI/wifiodds/blob/15c8e3471cbc713a00771d631a7fbc07ea0e2151/assets/site.css)
  at site commit `15c8e3471cbc713a00771d631a7fbc07ea0e2151`
  (CSS blob `9db7b5165b6bc89401a8a5c8f891ff2972b7bd10`).

Chip fills match the site mock `.odds` / `.odds.alt` plates, not the extension
`content.css` ramp and not Starlink black.

### Tokens used

| Role | Fill | Ink |
|---|---:|---:|
| next-gen / Starlink plate | `#29d8ff` | `#041318` |
| streaming plate | `#926cff` | `#ffffff` |
| basic / legacy, light host | `#f4eee2` (line `#e3daca`) | `#29241c` |
| basic / legacy, dark host | `#0d0d0f` | `#a6a6ad` |

Host-row chrome (not the chip plate):

| Role | Light host | Dark host |
|---|---:|---:|
| page ground | `#fbf8f2` | `#050505` |
| host ink | `#29241c` | `#ffffff` |

Color jobs:

- the filled cyan or violet plate is the chip. Not paper `#fbf8f2` / `#121216`.
  Not Starlink black.
- `#29d8ff` with `#041318` is the default Starlink Confirmed plate and the
  no-tail next-gen odds plate (site `.odds`).
- `#926cff` with white is the allowed streaming plate (site `.odds.alt`).
- basic/legacy uses the panel pair above, never cyan or violet, never a
  Starlink mark.
- no Bootstrap/status green as chrome. No overlay greens
  (`#33cf80`, `#b6d04f`, `#efb84d`, `#ef8168`).

## Component anatomy

The readout is one `inline-flex` capsule:

1. optional Starlink SVG mark (State B only);
2. the state-specific copy.

It has no shadow, glow, icon cloud, satellite emoji, floating badge, or 2px
identity rail on paper. The plate *is* the fill.

### State A — no tail assigned

One compact odds chip is enough. Visible example:

> **68% next-gen**

Hierarchy:

1. The next-gen odds figure answers the per-flight question.
2. Streaming score is not equal-weight and does not get a second pill.
3. No product wordmark is required on the chip.

The plate is cyan `#29d8ff` with ink `#041318`. Numerals are tabular. Unknown
is written as `— next-gen`, not `0%`. A failed request is written as
`Unavailable`, not styled as a low score.

### State B — assigned tail is Starlink

Visible example:

> [Starlink mark] **Starlink Confirmed**

Copy is exactly `Starlink Confirmed`. Plus the Starlink SVG mark. Not
`Next-gen WiFi · Starlink · ✓ tail assigned`. Not `Next-gen`. Not a percent.
Not a tracked count.

The mark is a public-domain simple-geometry dish silhouette, `fill="currentColor"`,
so it renders in the chip ink. It sits in the capsule, not as a black badge
glued on.

Default plate: cyan `#29d8ff` with ink `#041318`. The other allowed plate is
violet `#926cff` with white. Never a third plate. Never Starlink black.

### State C — assigned tail is any other type

Visible examples:

- **Streaming**
- **Basic**

One chip with the type word only. No Starlink mark. No percent. No tracked
count. Streaming uses the violet plate. Basic/legacy uses the panel pair.

## Starlink SVG mark

Simple geometry, free to use (satellite-dish silhouette). Not a trademarked
wordmark, not Starlink black artwork.

- `viewBox="0 0 16 16"`, drawn at 13px.
- `fill="currentColor"`; no hardcoded black, cyan, or white on the paths.
- `aria-hidden="true"`; the accessible name is the chip copy
  `Starlink Confirmed`.
- Only on State B. Never on State A or State C.

## Geometry and type

- One row, always: `display:inline-flex`, `flex-wrap:nowrap`,
  `white-space:nowrap`.
- Height: 30px on United and Alaska; 28px on Navan; 26px on Google Flights.
- Radius: 8px on airline-direct rows; 7px on Navan; 6px on Google Flights.
  Compact data capsule, not a 999px pill.
- Inline padding: 8px 10px; 5px gap between mark and copy.
- Primary copy: 12–13px, 750–800 weight; host font-size.
- Font: `inherit`. Do not ship an airline face or force Inter, SF Mono, or a
  generic extension stack into the host row.
- Line height: exactly one line; vertically center against the host's metadata
  baseline.
- No shadow and no vertical margin that can increase result-row height.

At constrained widths, keep `Starlink Confirmed` (or the type word, or the
odds figure) first. The SVG may drop only if the accessible name remains
`Starlink Confirmed`. The component never wraps, ellipsizes `Starlink` into
an ambiguous fragment, or pushes a fare or booking action. If the host anchor
cannot preserve the minimum compact width, fail closed at that anchor rather
than reflowing the booking row.

## Per-host fit

The content and chip fills stay the same. Host adapters change only inherited
type, height, radius, gap, and insertion point. If the host is dark, keep the
same cyan / violet fills (they already contrast). Never United blue. Never
Alaska green.

| Host | Fit |
|---|---|
| United | Sit on the flight metadata baseline after the flight identity, at the same 30px control height as nearby compact actions. Use the row's computed font and 8px inline gap. Do not add a second metadata line or change the row's measured height. |
| Alaska | Sit in the existing flight-detail rail, not between time and fare. Keep Alaska's roomier 10px inline gap and 30px height, while inheriting its type. Use no Alaska blue or airline-shaped icon. |
| Navan | Treat the readout as dense corporate metadata: 28px high, 7px radius, 6px gap. Keep it beside the supported flight identity. It must not imply that unknown carriers are worse. |
| Google Flights | Use the compact 26px/6px version beside the carrier-detail line. Never create another row, overlap the price/action column, or move Google's virtualized results. |

Use the integration's explicit host identity to select an adapter. Do not infer
styling or support by scanning airline-name keyword lists.

## Contrast

Measured against the locked plates:

- Starlink / next-gen ink `#041318` on cyan `#29d8ff`: `11.12:1` (AA).
- Streaming white on violet `#926cff`: site `.odds.alt` pairing; allowed by
  the lock. Do not put cyan text on white United paper.
- Basic light ink `#29241c` on `#f4eee2`: `13.33:1`.
- Basic dark muted `#a6a6ad` on `#0d0d0f`: `8.02:1`.

Never cyan text on white host paper. Meaning never depends on color: Starlink
is named `Starlink Confirmed`; other assigned types are named in words; odds
include the `next-gen` label.

## Forbidden

- no tail-assignment lookup or other data implementation in this pass;
- no stacked metric rows;
- no two loud filled pills;
- no second ConnectScore pill;
- no paper `#fbf8f2` / `#121216` as the chip plate;
- no Starlink black as the chip fill;
- no `Next-gen WiFi · Starlink · ✓ tail assigned`;
- no `Next-gen` copy, or a percent, on a Starlink-assigned tail;
- no Starlink mark on Streaming / Basic / any non-Starlink assigned type;
- no percentage headline after a tail is assigned;
- no Next-Gen/Streaming display toggle;
- no airline keyword lists;
- no airline brand colors, logos, or copied component shapes;
- no Bootstrap/status green as generic chrome;
- no new palette, glow, shadow, glass blur, emoji, or decorative satellite;
- no wrap, row-height growth, fare shift, action overlap, or host reorder caused
  by this component;
- no Store version, manifest version, release, or listing change.

## Acceptance checks for a later implementation

1. One component is present per supported row and its bounding box is one line.
2. Host row height, fare position, and booking action position are unchanged
   before versus after injection.
3. State A is one compact odds chip (example `68% next-gen`), not two pills.
4. State B copy is exactly `Starlink Confirmed` plus the currentColor SVG mark.
   The plate is cyan `#29d8ff` / ink `#041318`, or violet `#926cff` / white.
5. State C is the type word only, with no Starlink mark and no percent.
6. Chip fill is never paper `#fbf8f2` / `#121216` and never Starlink black.
7. The mock or implementation contains no metric-mode toggle and no host or
   airline keyword-sniffing fallback.
