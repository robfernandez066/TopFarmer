# TopFarmer v1 Roadmap

This roadmap is written once and is immutable. If delivery reality diverges, the PM records the divergence in `decisions.md`; this file is never rewritten to make history appear aligned.

## Phase 0 — Data and Delivery Guardrails

**Observable goal:** A clean Godot 4.7.1 Compatibility project boots with the v0 balance workbook committed, all seven exported CSVs available for strict runtime loading, platform boundaries documented, and every v1 exclusion enforced as an explicit architectural constraint.

**Requirements:** B5, E3, E4, E6, K4, K5, L1, L2, L3, L4, L5, L6

**Exit evidence:** `balance.xlsx` and its seven CSVs are versioned; the simulator passes; the game fails loudly on missing or malformed balance data; no gameplay number is hardcoded; Android is the v1 packaging target while gameplay code stays portable; no account, cloud, multiplayer, monetization SDK, combat, controllable-avatar, or translated-localization system exists.

**Why this precedes Phase 1:** Data contracts, engine constraints, and scope boundaries must be stable before visual or gameplay systems create dependencies on them. The v0 balance sheet and CSV loading precede every gameplay task.

## Phase 1 — Art, Tone, and Audio Style Lock

**Observable goal:** A committed style guide and locked AI generation recipe produce a small approved reference set with consistent angled top-down perspective, palette, lighting, pivots, shadows, cozy-mysterious tone, and licensed audio sources; no bulk production begins before approval.

**Requirements:** I1, J1, J2, J3, J4, J5

**Exit evidence:** The guide fixes prompt template, negative prompt, palette, resolution, light direction, shadow method, and pivot convention; reference terrain, crop, building, UI, music, and SFX examples pass consistency review; every external audio item has a committed license record.

**Why this precedes Phase 2:** The farm slice needs coherent visual and audio feedback. Locking the generation recipe before bulk assets prevents expensive restyling and guarantees that touch feedback is evaluated in the intended presentation.

## Phase 2 — Playable Farm Interaction Slice

**Observable goal:** On a physical Android device, a player can view most of a portrait farm, pan or zoom when desired, tap plots to plant and harvest, immediately replant the last crop, and receive visible, audible, and tactile-quality feedback for every interaction.

**Requirements:** A1, A2, A3, B1, B2, C1, C2, C3, H3, H4, K1, K2, K6

**Exit evidence:** Crops advance on real UTC time while the app is open; finished plots wait without auto-replanting; plot/building states are legible at default zoom; all buttons and world taps respond; the human has installed Android SDK plus JDK 17 immediately before deployment; a debug build is exercised by touch on a physical device. Device testing repeats at every later phase boundary.

**Why this precedes Phase 3:** Production, persistence, and economy work need a proven direct-touch plot loop and readable farm camera. This phase establishes the smallest real-device interaction baseline before widening the loop.

## Phase 3 — Persistent End-to-End Production Economy

**Observable goal:** A local save survives app and device restarts, reconciles tamper-resistant absolute UTC timers, and supports the complete plant → harvest → produce ingredient → produce final good → sell loop with inventory, level gates, Gold, Starlight, HUD access, and monetization-ready seams but no monetization code.

**Requirements:** A4, A5, B3, B4, D1, D3, D4, E1, E2, E5, H1, H2, K3

**Exit evidence:** Flourmill and Bakery chains run offline; the save contains schema version and entitlements; time gates, capacities, reward rates, and currency behavior are data-driven; common actions take at most two taps; the HUD reserves a banner-safe edge region; a natural post-delivery interstitial seam exists; gameplay remains fully offline.

**Why this precedes Phase 4:** Balance cannot be tuned meaningfully until the entire farming, crafting, and selling loop is playable end to end with persistence and real session timing.

## Phase 4 — Balance and Session-Rhythm Tuning

**Observable goal:** The balance model reflects active, few-hour, and overnight play rhythms; all crop and recipe economics pass automated checks; and the simulator models buildings, orders, and storage caps well enough to support a documented first tuning pass.

**Requirements:** E7, E8, E9

**Exit evidence:** Simulator output includes time-to-level and binding constraints from production, orders, and storage; every crop has positive profit; every recipe has positive opportunity-cost margin; tuning notes explain expected sessions and progression pacing; all exports are regenerated and sanity checks pass.

**Why this precedes Phase 5:** Expansion and achievement rewards depend on credible level pace, resource pressure, and sink rates. Tuning the core economy first keeps later progression content from encoding placeholder assumptions.

## Phase 5 — Expansion and Long-Term Progression

**Observable goal:** Players unlock new land through territory expansion and pursue achievements/long-term goals that award decor, plots, and expansions without breaking the tuned economy.

**Requirements:** D2, D5

**Exit evidence:** At least two data-driven territory unlocks work and persist; achievement progress is visible; representative goals grant each required reward category; device testing confirms the expanded farm remains readable and responsive.

**Why this precedes Phase 6:** Orders and quests need stable long-term reward targets and expansion gates. Establishing those destinations first makes delivery and quest rewards meaningful.

## Phase 6 — Orders, Quests, and Mechanical Mystery

**Observable goal:** Standard and large deliveries, daily/weekly/chain quests, and animated reward chests form a repeatable objective layer, while night-only growth, changed nighttime ambience, an unexplained ambient event, and a previous-owner quest chain express the mystery mechanically.

**Requirements:** F1, F2, F3, F4, F5, I5

**Exit evidence:** Order rewards are formula-derived from requested goods; train or airship deliveries provide larger timed objectives; quest cadences persist correctly; chest opening has an interruptible satisfying sequence; Duskcorn grows only at night; nighttime presentation changes; the first ambient mystery and the long-term land-history chain are playable.

**Why this precedes Phase 7:** Objective systems provide reasons to use the farm and progression economy. Custom layouts, animals, and pets then enrich a loop that already has durable goals instead of acting as disconnected decoration.

## Phase 7 — Farm Customization, Living Content, and v1 Release

**Observable goal:** From the farm view, players can enter a clean grid-snapped edit mode, move or flip buildings/decor, undo, store decorations, save layouts, and enjoy magical crop, livestock, and roaming-pet content in an Android v1 release candidate.

**Requirements:** G1, G2, G3, I2, I3, I4

**Exit evidence:** Edit operations persist and restore safely; undo covers every edit action; decoration storage loses nothing; representative magical crop and livestock analogues are integrated; at least one pet roams without blocking taps; final simulator, offline, save-migration, aspect-ratio, performance, and physical-device phase-boundary checks pass.

**Why this is last:** Customization, animals, pets, and release-scale content multiply assets, save state, and UI paths. They follow the complete core loop, tuning, progression destinations, orders, and quests so they build on stable systems.

## Definition of v1 Complete

TopFarmer v1 is complete when every phase exit condition is demonstrated in a release candidate on a supported physical Android device; all 61 frozen requirements are satisfied; the balance workbook remains the source of every gameplay number and its exported CSVs match; the extended simulator and all automated checks pass; save data survives restart and handles clock-integrity rules; every user-facing string is indirect; touch, readability, offline behavior, and supported aspect ratios pass device QA; asset/audio licenses are committed; and none of the explicitly excluded v1 systems has been introduced. Exporting requires a human-configured local Android preset and signing setup.

## Coverage Checklist

- [x] A — Core Loop: 5 of 5 assigned exactly once
- [x] B — Time Model: 5 of 5 assigned exactly once
- [x] C — Camera and Readability: 3 of 3 assigned exactly once
- [x] D — Progression: 5 of 5 assigned exactly once
- [x] E — Economy and Balance: 9 of 9 assigned exactly once
- [x] F — Orders and Quests: 5 of 5 assigned exactly once
- [x] G — Farm Customization: 3 of 3 assigned exactly once
- [x] H — UI and HUD: 4 of 4 assigned exactly once
- [x] I — Content and Theme: 5 of 5 assigned exactly once
- [x] J — Art and Audio: 5 of 5 assigned exactly once
- [x] K — Platform: 6 of 6 assigned exactly once
- [x] L — Explicitly Out of Scope: 6 of 6 assigned exactly once
- [x] Total: 61 unique requirement IDs assigned to one and only one phase
