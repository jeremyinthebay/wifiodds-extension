# WiFi Odds non-blocking panel design

Date: 2026-08-10
Owner decision: Jeremy approved the recommended direction in chat.
Route: Terra solo. This is accepted, reversible interaction work.
Risk tier: Tier B, provided no new position or dock state is stored.

## Problem

The injected WiFi Odds panel is fixed above the booking site. On Navan it can remain visible after
the traveler leaves flight results, including during seat selection. It can cover the booking
site's own controls. The existing chevron collapses the panel, but its purpose is easy to miss and
the collapsed header still occupies more space than necessary.

## Approaches considered

1. **Hide when irrelevant, then add clear movement controls. Recommended.** Remove the panel when
   the current page no longer contains supported flight results. Add a visible Minimize button,
   a small reopening tab, pointer dragging, and keyboard-operable Move left and Move right buttons.
   This solves the obstruction without changing extension permissions or stored data.
2. **Make the current panel freely resizable.** This gives the user control but does not stop a
   smaller panel from covering the next booking action. Narrow widths also make the decision cards
   harder to read.
3. **Reserve page space for the panel.** This avoids overlap but requires changing each booking
   site's layout and is likely to break when those sites change their markup.

## Accepted behavior

### Page scope

- Show the panel only while supported flight-result rows are present and connected to the current
  results view.
- Re-check live Navan markup before reusing cached route context.
- Remove the panel when a single-page application moves to seats, checkout, payment, confirmation,
  or any other view without supported result rows.
- Keep the small odds labels already attached to live result rows. Removing the summary panel must
  not change scoring, sorting, coverage, or evidence rules.

### Minimize and reopen

- Replace the ambiguous chevron with a visible **Minimize** button.
- The minimized state becomes a compact **WiFi Odds** tab with an **Open** button.
- Preserve the existing collapsed preference. Do not add a new storage field or change what data
  leaves the browser.

### Move controls

- Let pointer users drag the expanded panel by its header, except when the pointer begins on a
  button or link.
- Keep the panel within the visible viewport during dragging and after a browser resize.
- Add keyboard-operable **Move left** and **Move right** controls. Each docks the panel to the
  corresponding viewport edge.
- Position and dock changes last only for the current page. They are not written to local storage.

### Deferred

- Do not add free-form resizing in this release. Hiding, minimizing, and moving address the booking
  obstruction without creating unreadable panel widths.
- Do not add site permissions, outbound requests, telemetry, or new stored fields.

## Accessibility

- All controls are native buttons with visible text or a visible symbol plus an accurate accessible
  name.
- Minimize, Open, Move left, and Move right work without a mouse and have visible focus rings.
- Dragging is an enhancement, not the only way to move the panel.
- Movement does not trap focus or alter the booking site's tab order.

## Tests

The build starts with failing browser tests for:

1. A Navan results-to-seat transition removes the panel, including a same-path single-page change.
2. Minimize creates the compact tab and Open restores the panel.
3. Move left and Move right dock the panel and keep it inside the viewport.
4. Pointer dragging moves the panel and clamps it to viewport bounds.
5. No new position or dock key is written to `chrome.storage.local`.
6. Existing United, Navan, Alaska, Google Flights, responsive, sorting, and accessibility checks
   remain green.

## Release and review

This work will be committed as an extension source change, not added to the pending Tier A 3.0.1
candidate. After its normal extension gates pass, it receives a Tier B review packet and review-debt
entry. Jeremy remains the only person who uploads or submits a Chrome Web Store package.
