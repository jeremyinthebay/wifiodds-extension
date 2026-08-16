# WiFi Odds booking-row visual pass

- Status: design only
- Owner: Sol
- Requested by: Jeremy Smith, 16 August 2026
Mock: [`docs/mockups/overlay-row-visual-pass.html`](../mockups/overlay-row-visual-pass.html)

## Decision

Replace the stacked badge pair with one quiet, horizontal readout. It borrows the
host row's type and rhythm, while a two-pixel WiFi Odds accent rail and the
WiFi Odds color tokens keep ownership clear. It is a small piece of data, not a
miniature extension popup.

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

The live homepage uses the dark set. The shared stylesheet supplies the paired
light set used on light surfaces. The mock uses those exact values rather than
deriving lookalikes.

### Tokens used

| Role | Light host | Dark host |
|---|---:|---:|
| ground | `#fbf8f2` | `#050505` |
| readout surface | `#fbf8f2` | `#121216` |
| ink | `#29241c` | `#ffffff` |
| soft ink | `#443d32` | `#d3d3d8` |
| muted ink | `#6e6557` | `#a6a6ad` |
| outer hairline | `#e3daca` | `#65656d` |
| inner hairline | `#ece5d6` | `#29292f` |
| accent / sky | `#2d5a7d` | `#29d8ff` |
| accent companion | `#5b4a99` | `#926cff` |
| high / good number | `#1e7a46` | `#54f09b` |
| middle / mixed number | `#975e00` | `#ffd45a` |
| low / long-shot number | `#a84b2f` | `#ff698d` |
| zero / unknown number | `#716a62` | `#87878f` |

Color has the same jobs it has on WiFi Odds:

- the sky pair owns the two-pixel identity rail and no data;
- score-band colors own numeric odds/scores and no chrome;
- WiFi type and provider are categories, so they stay in ink;
- muted ink carries supporting copy;
- unknown is gray, never a false zero in green, amber, or clay.

There is no Bootstrap green fill. A high value is green text, not a green
lozenge.

## Component anatomy

The readout is one `inline-flex` row with four possible parts:

1. a two-pixel sky-to-violet identity rail;
2. the quiet product label `WiFi Odds`;
3. the state-specific headline;
4. optional supporting facts separated by hairline dividers.

It has no shadow, glow, icon cloud, satellite emoji, or floating badge. The
surface is a low-contrast piece of WiFi Odds paper on a light row and a
WiFi Odds card on a dark row.

### State A — no tail assigned

Visible example:

> **WiFi Odds** · **68%** next-gen · **44** streaming

Hierarchy:

1. `68% next-gen` is primary because it answers the per-flight question.
2. `44 streaming` is supporting fleet context.
3. `WiFi Odds` is a quiet source label, not a headline.

Both measures remain explicitly labelled, but neither gets its own filled pill.
Numerals are tabular. Only the numerals take their score-band colors. The labels
stay soft ink.

Unknown is written as `— next-gen`, not `0%`. A failed request is written as
`Unavailable`, not styled as a low score.

### State B — tail assigned

Visible examples:

- **Next-gen WiFi** · Starlink · ✓ tail assigned
- **Streaming WiFi** · 2Ku · ✓ tail assigned
- **Basic WiFi** · Panasonic · ✓ tail assigned

The WiFi type is the headline. Percentages disappear from the row because the
assigned aircraft is now the more specific fact. The provider is secondary and
the assignment confirmation is tertiary. The headline remains ink rather than
borrowing a score color: `next-gen`, `streaming`, and `basic` are categories,
not percentages.

The check uses the exact `good` token as a confirmation fact. It does not turn
the whole component green.

## Geometry and type

- One row, always: `display:inline-flex`, `flex-wrap:nowrap`,
  `white-space:nowrap`.
- Height: 30px on United and Alaska; 28px on Navan; 26px on Google Flights.
- Radius: 8px on airline-direct rows; 7px on Navan; 6px on Google Flights.
  This is a compact data plate, not a 999px pill.
- Inline padding: 8px after the rail; 6px gaps; 8px between major groups.
- Rail: 2px wide, full component height.
- Primary figure/type: 12.5–13px, 700–750 weight.
- Supporting copy: 11.5–12px, 600 weight.
- Product label: 10.5–11px, 750 weight; no forced all-caps tracking.
- Font: `inherit`. Do not ship an airline face or force Inter, SF Mono, or a
  generic extension stack into the host row.
- Line height: exactly one line; vertically center against the host's metadata
  baseline.
- No shadow and no vertical margin that can increase result-row height.

At constrained widths, keep the state headline and its label first. The product
wordmark may collapse to the accent rail, and `tail assigned` may collapse to a
checked icon with the full accessible name. The component never wraps,
ellipsizes `next-gen`/`streaming` into an ambiguous fragment, or pushes a fare
or booking action. If the host anchor cannot preserve the minimum compact width,
fail closed at that anchor rather than reflowing the booking row.

## Per-host fit

The content and colors stay the same. Host adapters change only inherited type,
height, radius, gap, and insertion point.

| Host | Fit |
|---|---|
| United | Sit on the flight metadata baseline after the flight identity, at the same 30px control height as nearby compact actions. Use the row's computed font and 8px inline gap. Do not add a second metadata line or change the row's measured height. |
| Alaska | Sit in the existing flight-detail rail, not between time and fare. Keep Alaska's roomier 10px inline gap and 30px height, while inheriting its type. Use no Alaska blue or airline-shaped icon. |
| Navan | Treat the readout as dense corporate metadata: 28px high, 7px radius, 6px gap. Keep it beside the supported flight identity. It must not imply that unknown carriers are worse. |
| Google Flights | Use the compact 26px/6px version beside the carrier-detail line. Never create another row, overlap the price/action column, or move Google's virtualized results. |

Use the integration's explicit host identity to select an adapter. Do not infer
styling or support by scanning airline-name keyword lists.

## Dark-host adaptation

Keep the WiFi Odds palette; do not invert into a host brand.

- Surface: `#121216`, optionally at 94–96% opacity when it sits over textured
  chrome.
- Outer boundary: `#65656d`, the site's accessible dark boundary token.
- Inner dividers: `#29292f`.
- Ink: `#ffffff`; supporting copy: `#d3d3d8` or `#a6a6ad`.
- Accent rail: `#29d8ff` to `#926cff`.
- Numeric bands: `#54f09b`, `#ffd45a`, `#ff698d`, `#87878f`.

No translucent light text directly on an unknown host background. The dark
surface remains behind the text so contrast does not depend on the airline's
header color.

## Contrast

Measured against the exact mock surfaces:

- light ink / paper: `14.53:1`;
- light muted / paper: `5.41:1`;
- light sky / paper: `6.90:1`;
- light good / paper: `5.04:1`;
- light mixed / paper: `5.06:1`;
- light long / paper: `5.34:1`;
- light zero / paper: `5.03:1`;
- dark ink / card: `18.69:1`;
- dark muted / card: `7.72:1`;
- dark sky / card: `11.00:1`;
- dark good / card: `12.74:1`;
- dark mixed / card: `13.18:1`;
- dark long / card: `6.81:1`;
- dark zero / card: `5.24:1`.

Every text pairing clears WCAG AA for normal text. Meaning never depends on
color: every number has a text label, and every assigned state names its WiFi
type.

## Forbidden

- no tail-assignment lookup or other data implementation in this pass;
- no stacked metric rows;
- no two loud filled pills;
- no bare or unlabeled percentages;
- no percentage headline after a tail is assigned;
- no Next-Gen/Streaming display toggle;
- no airline keyword lists;
- no airline brand colors, logos, or copied component shapes;
- no Bootstrap/status green as generic chrome;
- no new palette, gradient-filled score chip, glow, shadow, glass blur, emoji,
  or decorative satellite;
- no wrap, row-height growth, fare shift, action overlap, or host reorder caused
  by this component;
- no Store version, manifest version, release, or listing change.

## Acceptance checks for a later implementation

1. One component is present per supported row and its bounding box is one line.
2. Host row height, fare position, and booking action position are unchanged
   before versus after injection.
3. State A labels both numbers in one typographic strip.
4. State B starts with `Next-gen WiFi`, `Streaming WiFi`, or `Basic WiFi` and
   shows no percentage as the headline.
5. Light and dark computed colors match the token table above.
6. All text/background pairs remain at least `4.5:1`.
7. The mock or implementation contains no metric-mode toggle and no host or
   airline keyword-sniffing fallback.
