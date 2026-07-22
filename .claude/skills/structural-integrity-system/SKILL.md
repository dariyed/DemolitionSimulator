---
name: structural-integrity-system
description: The core design pillar of this game — buildings must behave structurally like real buildings. Use whenever designing or touching load-bearing tagging, the load path / structural dependency graph, failure propagation, fracture/debris systems, or anything that removes/destroys a building part. Guards against "destruction" that is really just deletion or random explosions.
---

# Structural realism is the whole point of this game

Demolition Simulator is not "blow things up and delete parts." The design pillar, straight from
CLAUDE.md, is: **buildings behave structurally the way real buildings do.** Every destruction
feature must be checked against this before it's considered done.

## The three things that must always be true

1. **Load-bearing elements actually bear load.** Columns, load-bearing walls, and beams are
   tagged with a structural role (e.g. an attribute like `StructuralRole = "Column"`), and that
   tag is not cosmetic — the load path graph (Epic 2) treats them as the things other elements
   depend on for support.
2. **Removing support causes failure that follows the dependency graph, not a random effect.**
   When a column is destroyed, only the elements whose load path actually ran through that
   column should become unsupported. A wall on the far side of the building with an independent
   load path should not fall just because *something* exploded nearby.
3. **Destruction never "vanishes" a building.** Parts fail physically — unanchor, break their
   `WeldConstraint`/`Motor6D`, and fall under real physics — rather than being `Destroy()`'d
   outright the instant they're "damaged." `Destroy()` (or making debris disappear) is for
   cleanup *after* a piece has finished falling and settling, not as the failure mechanism
   itself.

## The mental model to design against

Think in terms of real structural engineering, simplified enough to be tractable in Luau:

- **Load path:** the route through which a part's weight (and the weight of what it supports)
  ultimately reaches the ground, via the elements below it.
- **Tributary area / dependency:** which elements rely on which — a floor beam depends on the
  columns/walls at its ends; a wall segment above depends on what's below it.
- **Failure propagation:** when an element is removed/destroyed, recompute which remaining
  elements have lost their path to the ground. Those become unsupported and should fail in an
  order that makes physical sense (usually top-down / cascading from the point of failure, not
  everything at once).
- **Factor of safety (simplify, don't skip):** it's fine to use a simple threshold (e.g. "an
  element can support N times its own load before failing") rather than real structural
  calculations — but the simplification should still be a real, testable number, not a hidden
  hack. Document any such constant in the shared config module it lives in.

## Where this lives in code (per the CLAUDE.md repo layout)

- `src/shared/Structural/` — pure modules: the load path graph, dependency resolution, failure
  propagation rules. These take a description of the building (parts + roles + connections) and
  return which parts should fail, in what order. **Tier-1 tested with Lune** — this is the
  highest-value place for tests in the whole project, because a subtle bug here means buildings
  collapse "wrong" in a way that's hard to spot just by looking at Studio once.
- `src/server/` — the thin layer that actually reads the graph's output and un-anchors/breaks
  constraints on real Instances, validated server-side (see the server-authoritative note in
  CLAUDE.md — a client can request a detonation, but the server decides what actually fails).
- `src/client/` — visual/audio feedback only; never decides what fails.

## Before calling a destruction feature done, check

- [ ] Does a part only fail because the graph says it lost support — not because it was near an
      explosion radius with no dependency check?
- [ ] Is there a Tier-1 test with a small fake building (a few columns/walls/beams) proving the
      graph produces the *correct* set of failing parts for a given removed element?
- [ ] Does the failure look staged/cascading in Studio (via `studio-mcp-playtest`), not
      simultaneous?
- [ ] Is any "explosion" VFX layered on *top of* real physical failure, not used to hide the
      absence of it?

See also: `green-gate-tests`, `studio-mcp-playtest`, `roblox-api-check`.
