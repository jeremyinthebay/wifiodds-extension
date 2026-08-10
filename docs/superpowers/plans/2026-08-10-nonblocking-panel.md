# Non-blocking Extension Panel Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** Keep the WiFi Odds panel from covering later booking steps and give mouse and keyboard users clear ways to minimize or move it.

**Architecture:** Keep the feature inside the existing injected content script and stylesheet. Add a live Navan result-view eligibility check before rendering, plus one panel-interaction initializer that owns minimize, reopen, docking, dragging, and viewport clamping. Reuse the existing `uslCollapsed` preference and add no stored position or dock state.

**Tech Stack:** Chrome Manifest V3 content script, plain JavaScript and CSS, Playwright Chromium browser harness in `test/phase2-e2e.mjs`.

## Global Constraints

- Do not change permissions, hosts, outbound requests, telemetry, scoring, sorting, evidence, or coverage rules.
- Do not add a local-storage field for position or dock state.
- Keep pointer movement inside the visible viewport.
- Every interaction must have a keyboard-operable equivalent with a visible focus ring.
- Do not add free-form resizing.
- Preserve unrelated user-owned files under `test/out/`, `dist/`, and `store-assets/`.

---

### Task 1: Remove the panel outside live Navan flight results

**Files:**
- Modify: `test/phase2-e2e.mjs`
- Modify: `extension/content.js:285-310`
- Modify: `extension/content.js:2308-2348`

**Interfaces:**
- Consumes: existing `getNavanContext()`, `registry`, `navanUnitedCount`, `panelEl`, and `refresh()`.
- Produces: `navanResultsActive(): boolean`, which returns true only when a current Navan route header and at least one supported live result row belong to the active result view.

- [ ] **Step 1: Write the failing browser case**

Add a `navan-panel-leaves-booking-flow` case whose driver loads Navan results, waits for `.usl-panel`, replaces the results view in place with a seat-selection fixture while keeping the same URL, waits beyond the two-second refresh, and asserts:

```js
checks: {
  panelShownOnResults: shown === true,
  panelRemovedOnSeatView: panelAfterSeat === false,
  noInjectedPanelControlsRemain: controlsAfterSeat === 0,
}
```

- [ ] **Step 2: Run the browser harness and verify RED**

Run: `node test/phase2-e2e.mjs`

Expected: only the new case fails because `.usl-panel` remains after the same-path seat transition.

- [ ] **Step 3: Add the live result-view gate**

Implement `navanResultsActive()` using current connected registered rows and a live `SEL.navanRoute` match. Change `getNavanContext()` so its cache is returned only after live route markup is confirmed. In `refresh()`, remove `panelEl`, clear the Navan render signature, and return when the live result gate is false.

- [ ] **Step 4: Run the browser harness and verify GREEN**

Run: `node test/phase2-e2e.mjs`

Expected: the new case and existing Navan loading, no-United, sorting, and failure cases pass.

- [ ] **Step 5: Commit Task 1**

Stage only `extension/content.js` and `test/phase2-e2e.mjs`. Commit with:

```text
extension: remove panel outside flight results

Driver: codex-builder
```

### Task 2: Add visible minimize, docking, and pointer movement

**Files:**
- Modify: `test/phase2-e2e.mjs`
- Modify: `extension/content.js:2027-2110`
- Modify: `extension/content.css:42-103`
- Modify: `extension/content.css:284-334`

**Interfaces:**
- Consumes: the existing `.usl-panel`, `.usl-body`, header, `uslCollapsed`, and render cycle.
- Produces: `setupPanelControls(panel: HTMLElement): void` and `clampPanelToViewport(panel: HTMLElement): void`.

- [ ] **Step 1: Write failing interaction checks**

Extend a stable United browser case to verify these literal outcomes:

```js
{
  visibleMinimizeLabel: minimize.textContent.trim() === "Minimize",
  compactTabAfterMinimize: collapsed.width <= 210 && open.textContent.trim() === "Open",
  keyboardDockLeft: Math.round(left.left) === 12,
  keyboardDockRight: Math.round(innerWidth - right.right) === 12,
  pointerDragMovesPanel: dragged.left !== right.left || dragged.top !== right.top,
  dragStaysInViewport: dragged.left >= 0 && dragged.top >= 0 &&
    dragged.right <= innerWidth && dragged.bottom <= innerHeight,
}
```

Capture `chrome.storage.local` before and after moving and assert that no key matching `/position|dock|panelLeft|panelTop/i` was added.

- [ ] **Step 2: Run the browser harness and verify RED**

Run: `node test/phase2-e2e.mjs`

Expected: the new Minimize/Open, dock, and drag checks fail because the controls and movement do not exist.

- [ ] **Step 3: Implement the controls**

Replace the chevron button with visible `Minimize`, `Move left`, and `Move right` buttons. When collapsed, hide the route, estimate, refresh, docking controls, and body; show a compact `WiFi Odds` label and `Open` button. Remove header-click collapsing so pointer dragging cannot minimize accidentally.

Implement pointer dragging from the header when `event.target.closest("button,a")` is false. Use pointer capture, viewport coordinates, and clamping based on the panel rectangle. Dock buttons set temporary inline left/right positioning. A resize listener reclamps only panels moved during the current page.

- [ ] **Step 4: Run focused and full browser verification**

Run: `node test/phase2-e2e.mjs`

Expected: all panel interaction, responsive geometry, contrast, and existing host cases pass with zero failed checks.

- [ ] **Step 5: Commit Task 2**

Stage only `extension/content.js`, `extension/content.css`, and `test/phase2-e2e.mjs`. Commit with:

```text
extension: keep panel clear of booking controls

Driver: codex-builder
```

### Task 3: Run gates and prepare the Tier B handoff

**Files:**
- Modify: `CHANGELOG.md`
- Create: `/Users/jeremysmith/Projects/wifiodds-relay/exchange/from-builder/REVIEW-REQUEST-B-nonblocking-panel-2026-08-10.md`
- Modify: `/Users/jeremysmith/Projects/wifiodds-relay/exchange/BACKLOG.md`
- Modify after source shipment: `/Users/jeremysmith/Projects/wifiodds-relay/exchange/REVIEW-DEBT.md`

**Interfaces:**
- Consumes: the exact source SHA and fresh gate outputs from Tasks 1 and 2.
- Produces: a named Tier B review packet tied to that SHA. It does not create or promote a Chrome Web Store bundle.

- [ ] **Step 1: Add one plain-English Unreleased changelog bullet**

State that the booking-page panel now leaves later booking steps and can be minimized or moved. Do not claim Chrome Web Store publication.

- [ ] **Step 2: Run the complete extension gates**

Run each command separately and record its bare exit code:

```sh
node test/phase2-e2e.mjs
node test/mutation-matrix.mjs
sh build-store-verify.sh extension
```

Expected: every command exits 0. Do not run `build-store-bundle.sh candidate` because this Tier B source work must not replace the pending Tier A candidate.

- [ ] **Step 3: Inspect the exact diff and commit**

Confirm `git diff --check` is clean and that only the design, plan, content script, stylesheet, browser test, and changelog are in this work. Commit the changelog with the implementation if it is not already included.

- [ ] **Step 4: Update the queue and write the review packet**

Move backlog item 36 to the DONE log with the exact SHA and date. The review packet must name the accepted behavior, Tier B boundary, changed files, fresh commands and exit codes, evidence paths, limits, and least-certain point.

- [ ] **Step 5: Stop before release-package work**

Report the tested source SHA and review links to Jeremy. Do not upload, submit, tag, build a replacement store candidate, or claim the change is in the Chrome Web Store.
