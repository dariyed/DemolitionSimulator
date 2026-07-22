# ROADMAP

## Vision

A physics-based building demolition game in Roblox where the thing that makes it worth
building — instead of just deleting parts on a timer — is that **buildings behave structurally
the way real buildings do.** Load-bearing columns and walls bear load, a load path /
dependency graph tracks what supports what, and destroying support causes a cascading failure
that follows that graph, not a random explosion radius. Tools and vehicles unlock over a
campaign of levels with objectives and scoring.

We ship in small, test-gated steps (same discipline as
[HalfSwordGame](https://github.com/dariyed/HalfSwordGame)): every issue gets automated tests
green before Dariy manually play-tests it.

## Milestones (epics)

| Milestone | Epic | Goal |
| --- | --- | --- |
| v0.1 — Foundation | **Epic 1** | A working Rojo-synced test map with a basic multi-part building and a first (even crude) destruction trigger. Proves the pipeline end to end. |
| v0.2 — Structural Engineering System | **Epic 2** | Buildings carry real structural metadata: load-bearing elements are identified and a load path / dependency graph models what supports what, with correct failure propagation. |
| v0.3 — Destruction System | **Epic 3** | Real-time fracturing, performance-safe debris physics, and structural damage propagation wired into Epic 2's graph — this is where destruction actually looks and feels right. |
| v0.4 — Tools & Vehicles | **Epic 4** | The player has tools (explosive charges) and vehicles (wrecking ball) to cause that destruction, plus an evolution tree that unlocks more of them. |
| v0.5 — Campaign & Game Loop | **Epic 5** | A multi-level campaign with objectives, scoring, and level select/progression. |
| v0.6 — Polish | **Epic 6** | VFX/SFX, UI, and performance optimization/cleanup pass across everything above. |

Epics build on each other in order — Epic 3 (destruction) depends on Epic 2's structural
graph existing first; Epic 4 (tools) depends on Epic 3 having something real to trigger; Epic
5 (campaign) depends on Epic 4's tools existing to build objectives around; Epic 6 polishes
all of the above. Within an epic, build issues in the listed order.

Every issue below follows the rules in [`../CLAUDE.md`](../CLAUDE.md): write the automated
tests first and get them **green**, then hand to Dariy for the manual checklist, then turn his
comments into fixes + regression tests. Explain every line of code, step by step, as you build
(`teach-dariy`).

---

# EPIC 1 — Foundation

**Outcome:** a player can spawn into a test map that contains a real (if simple) multi-part
building, and triggering "destruction" on it does *something* observable and server-driven —
proving the whole pipeline (Rojo ⇄ Studio ⇄ Git ⇄ CI) works before any structural engineering
logic exists.

**Build order:** #1 → #2 → #3.

---

## Issue #1 — Baseline Roblox setup (avatar type, test map)

**Goal:** a clean, buildable, Git-backed project where a player spawns into a simple open test
map with a sensible avatar, proving the pipeline works before any game logic exists.

**Scope**
- Confirm `default.project.json`, `rokit.toml`, `wally.toml`, `selene.toml`, `stylua.toml`,
  and `.github/workflows/ci.yml` (already seeded in this repo) are correct and installable.
- `src/shared/Version.luau` + `tests/Version.spec.luau` as the trivial Tier-1 spec proving
  `lune run test` and CI go green.
- Choose and set the avatar type (`StarterPlayer` properties — e.g. R15, walk speed) suited to
  a third-person demolition game.
- A test map: a baseplate/ground plane and open space to place a building on (Epic 1 Issue #2)
  and later trigger destruction in (Issue #3).

**Automated tests (green gate)**
- `Version.spec.luau` passes under `lune run test`.
- CI is green on the PR (`stylua --check`, `selene`, `lune run test`).

**Acceptance criteria**
- `rojo build -o game.rbxlx` succeeds.
- `rojo serve` + Studio Rojo plugin connects and syncs a saved file.
- Player spawns on the test map with a working, sensibly-configured avatar.

**Dariy's manual checklist**
- [ ] Open the built place / connect Rojo in Studio — it loads with no errors.
- [ ] Press Play — you spawn on the test map and can walk around.
- [ ] Confirm the green check on the PR.

---

## Issue #2 — Basic building structure (multi-part, welded)

**Goal:** a simple multi-part building exists in the test map, assembled the way a real
Roblox structure is (parts joined with `WeldConstraint`/similar), ready to eventually be
tagged with structural roles (Epic 2).

**Scope**
- A small building model (e.g. a few floors, some walls, a few columns) built from multiple
  `Part`/`WedgePart` instances, connected with `WeldConstraint` (not `Weld` — confirm the
  current recommended constraint via `roblox-api-check`).
- `shared/Structural/BuildingSpec.luau` — a **pure** data description of the building (parts,
  approximate positions/sizes) that later issues can consume, rather than only living as a
  hand-placed Studio model. Keep this deliberately simple for now — its job is to exist and be
  buildable, not to model load yet (that's Epic 2).
- A way to (re)build/place this test building in the test map (a server script or a Studio
  plugin/anchor point) so it's reproducible, not a one-off manual placement.

**Automated tests (green gate, Tier 1)**
- `BuildingSpec` returns a well-formed list of parts (no duplicate names/ids, all required
  fields present) for the seeded test building.

**Acceptance criteria**
- The building appears in the test map on play, assembled from multiple welded parts (not one
  single block).
- The building is structurally connected as a Studio model — nudging/breaking one weld
  visibly affects only the directly connected part, confirming the joints are real.

**Dariy's manual checklist**
- [ ] The building looks like a building (multiple distinct parts), not one solid block.
- [ ] Play-test: the building sits still and doesn't jitter or fall apart on its own.

---

## Issue #3 — First destruction trigger test

**Goal:** prove the end-to-end pipeline for "player triggers destruction, server responds" —
deliberately crude (e.g. clicking a part or a test remote removes/un-anchors one part), with
no structural modeling yet. This is the walking skeleton Epic 2 and 3 will replace with real
logic.

**Scope**
- A minimal server-authoritative trigger: a `RemoteEvent` a client can fire, validated
  server-side, that causes exactly one designated test part to fail (unanchor + break its
  weld) and fall.
- No load path graph yet — this issue exists to prove the client → server → physics round
  trip works, and that the **server**, not the client, is the one deciding the part fails (see
  `CLAUDE.md` §7, server-authoritative destruction).

**Automated tests (green gate, Tier 1)**
- A pure validation function (e.g. "is this request well-formed / is this part a legal
  target") used by the server handler is tested directly.

**Acceptance criteria**
- Triggering destruction from the client causes the target part to visibly unanchor and fall
  under physics on all clients (replicated), not just locally.
- A modified/fake client request for an illegal target is rejected server-side (spot-checked
  via Studio MCP, not just assumed).

**Dariy's manual checklist**
- [ ] Trigger the test destruction — the part visibly falls and lands, physically.
- [ ] Confirm it replicates: if playtested with a second client/observer, both see the same
      result.

---

# EPIC 2 — Structural Engineering System

**Outcome:** the building is no longer just geometry — it carries real structural metadata.
Load-bearing columns/walls/beams are identified, a load path / dependency graph models what
supports what, and removing a support element causes *only* the correct dependent elements to
become unsupported. This epic has no visual destruction yet (that's Epic 3) — it's about
getting the **model** right and proven with tests, per `structural-integrity-system`.

**Build order:** #4 → #5 → #6.

---

## Issue #4 — Load-bearing element identification (columns, walls, beams)

**Goal:** every part in a building is classified with a structural role, and that
classification is queryable by other systems.

**Scope**
- `shared/Structural/StructuralRole.luau` — **pure**: an enum/type for roles (`Column`,
  `LoadBearingWall`, `Beam`, `NonStructural`, …) plus validation helpers.
- Tag Instances with the role, e.g. via `Instance:SetAttribute("StructuralRole", ...)`
  (confirm the current recommended attribute API via `roblox-api-check`).
- Extend `shared/Structural/BuildingSpec.luau` (from Issue #2) so each part in the spec
  declares its role, and add a helper to read roles back off real Instances at runtime.

**Automated tests (green gate, Tier 1)**
- Role validation rejects unknown/malformed role strings.
- Given a `BuildingSpec`, a query function correctly lists all `Column`/`LoadBearingWall`
  elements.

**Acceptance criteria**
- Every part in the Epic 1 test building has a correct, inspectable structural role.
- A Studio MCP inspection confirms the attribute is actually present on the real Instances,
  not just in the data model.

**Dariy's manual checklist**
- [ ] Ask Claude to point out (or highlight) which parts of the test building are columns vs.
      walls vs. non-structural — does it match what you'd expect looking at the building?

---

## Issue #5 — Load path / structural dependency graph

**Goal:** a graph exists that models, for this building, which elements support which — the
foundation everything in Epic 3 (real destruction) is built on.

**Scope**
- `shared/Structural/LoadPathGraph.luau` — **pure**: build a dependency graph from a
  `BuildingSpec` (roles + approximate positions/connections) — each element points to what it
  depends on for support, ultimately tracing to the ground.
- Keep the model deliberately simple and documented (e.g. "an element depends on the
  load-bearing element(s) directly below/adjacent to it within some tolerance") rather than a
  full physical simulation — see `structural-integrity-system` on simplifying honestly.
- A query: "if element X is removed, which elements immediately lose their direct support?"
  (not yet full cascading propagation — that's Issue #6).

**Automated tests (green gate, Tier 1)**
- For a small hand-built test building (a few columns, a beam, a wall), the graph correctly
  identifies each element's direct support dependency.
- Removing a column that supports a beam correctly flags that beam as directly unsupported;
  removing an unrelated column does **not** flag it.

**Acceptance criteria**
- The graph is inspectable/debuggable (e.g. a debug print or Studio MCP query showing the
  dependency edges) for the Epic 1 test building.
- Matches the mental model in `structural-integrity-system`: load path, not blast radius.

**Dariy's manual checklist**
- [ ] Ask Claude to show you the dependency graph for the test building in plain language
      ("the roof beam depends on these two columns") and sanity-check it against what you see.

---

## Issue #6 — Realistic failure propagation (removing support causes correct collapse)

**Goal:** removing a support element causes the *correct set* of dependent elements to fail,
in a sensible cascading order — the core promise of this game, proven with tests before any
polish exists.

**Scope**
- `shared/Structural/FailurePropagation.luau` — **pure**: given a `LoadPathGraph` and a
  removed element, recursively resolve which elements are now unsupported (an element that
  depended only on the removed one; then anything that depended only on those; and so on),
  and produce an ordered failure sequence (top-down / cascading, not all-at-once).
- Wire this into the Issue #3 destruction trigger: removing a column now runs the real
  propagation logic instead of the placeholder single-part removal.
- Server-side: apply the failure sequence with a small stagger (even a fixed delay per
  "layer" is fine for now — tuning the *feel* of timing is Epic 3) so it's visibly cascading.

**Automated tests (green gate, Tier 1)**
- Removing a column that solely supports a beam and a wall segment above it: propagation
  includes exactly those elements, not the whole building.
- A building with two independent load paths (e.g. two separate columns each holding up their
  own beam): removing one column's support never marks the other path's elements as failed.
- A multi-level dependency (column → beam → wall above) correctly cascades through all levels,
  not just the first.

**Acceptance criteria**
- In Studio, removing a test column causes only the structurally dependent parts to
  unanchor/fall, visibly staged rather than simultaneous.
- An unrelated, structurally independent part of the building remains standing.

**Dariy's manual checklist**
- [ ] Remove a column from the test building — does only the part of the building that
      "should" fall actually fall? Does the rest stay standing?
- [ ] Does it look staged (top bits fail after the bits below them), not everything at once?

---

# EPIC 3 — Destruction System

**Outcome:** destruction is no longer just "parts unanchor and drop" — it looks and performs
like real demolition. Real-time fracturing breaks parts into debris, debris physics is tuned
to stay performant, and structural damage (not just outright removal) propagates through the
Epic 2 graph.

**Build order:** #7 → #8 → #9.

---

## Issue #7 — Real-time fracture system design

**Goal:** a destroyed/failed part can break into multiple smaller debris pieces in real time,
instead of falling as one intact part.

**Scope**
- `shared/Destruction/FractureConfig.luau` — **pure**: per-material/part-size presets for how
  many debris pieces a fracture produces and a rough size distribution.
- `server/FractureService.luau` — given a part that has failed (from Epic 2's propagation),
  generates debris pieces (e.g. pre-authored chunk models, or simple geometric subdivision —
  pick the simpler approach first and document the choice) and applies physics to them.
- Decide and document: fracture happens **once per failed part**, driven by the server, in
  response to the propagation sequence from Issue #6 — not as a separate, independent trigger.

**Automated tests (green gate, Tier 1)**
- `FractureConfig` returns a valid, in-range debris count/size distribution for each preset.

**Acceptance criteria**
- A failed part visibly fractures into multiple pieces rather than falling as a single block.
- Fracture is driven server-side and replicates consistently to observers (Studio MCP check).

**Dariy's manual checklist**
- [ ] Trigger a collapse — do the failing parts break into believable rubble/debris rather
      than falling as whole intact blocks?

---

## Issue #8 — Debris physics tuning (performance-safe)

**Goal:** debris behaves physically (bounces, settles, piles up) without tanking performance,
even for a building-sized collapse.

**Scope**
- A debris part-count budget and cleanup strategy (e.g. Roblox's `Debris` service to
  auto-remove/anchor settled debris after a timeout) — confirm current API via
  `roblox-api-check`.
- `shared/Destruction/DebrisConfig.luau` — **pure**: tunable constants (max concurrent debris
  parts, settle timeout, physics simplification thresholds) documented so Dariy can tweak feel
  vs. performance.
- Collision group setup so debris doesn't expensively collide with itself at every tiny
  contact (`PhysicsService`/`CollisionGroup` — confirm via `roblox-api-check`).

**Automated tests (green gate, Tier 1)**
- `DebrisConfig` values are validated as in sane ranges (e.g. max debris count > 0, settle
  timeout positive).

**Acceptance criteria**
- A full test-building collapse stays within an agreed frame-time/part-count budget (measured
  and reported by Claude Code via Studio MCP, not just assumed).
- Debris settles and is cleaned up after the configured timeout without visibly popping/
  teleporting.

**Dariy's manual checklist**
- [ ] Trigger a full building collapse — does it stay smooth/playable, or does it chug?
- [ ] Does debris eventually clean up instead of piling up forever?

---

## Issue #9 — Structural integrity / damage propagation (tied into Epic 2's load system)

**Goal:** elements can be **damaged**, not just instantly destroyed — accumulating damage
(e.g. from a wrecking ball hit that doesn't fully sever a column) feeds into the Epic 2 load
path graph, and an element that's lost enough integrity fails even without being explicitly
"removed."

**Scope**
- Extend `shared/Structural/` with an integrity/damage model: each structural element has a
  simple integrity value; damage events reduce it; an element whose integrity drops below its
  documented threshold is treated as "removed" by `FailurePropagation` (Issue #6).
- Server-side damage application: a tool/vehicle hit (Epic 4) applies a damage amount to a
  targeted element via this system — never removes a part directly.

**Automated tests (green gate, Tier 1)**
- Repeated partial damage below the failure threshold does not trigger failure; crossing the
  threshold does.
- Damage propagation correctly re-triggers `FailurePropagation` once an element crosses its
  threshold, producing the same correct dependent-failure set as Issue #6.

**Acceptance criteria**
- A column can be hit multiple times, visibly accumulating damage (even just a debug read-out
  is fine for now — VFX is Epic 6), before it actually fails on the hit that crosses the
  threshold.
- Confirms server-authoritative: damage values live and are decided server-side.

**Dariy's manual checklist**
- [ ] Hit a column repeatedly with the test trigger — does it take a few hits to actually
      bring it down, rather than one hit always being instant destruction?

---

# EPIC 4 — Tools & Vehicles

**Outcome:** the player has an actual way to cause the destruction built in Epics 2–3: a first
tool (explosive charge), a full equip/place/detonate flow, a vehicle-based demolition option
(wrecking ball), and an evolution tree that unlocks more of both over time.

**Build order:** #10 → #11 → #12 → #13.

---

## Issue #10 — First basic tool (explosive charge)

**Goal:** a single, simple tool exists: an explosive charge the player can place in the world.

**Scope**
- `shared/Tools/ExplosiveChargeConfig.luau` — **pure**: charge stats (damage amount fed into
  Issue #9's integrity system, blast radius for *targeting* — not for bypassing the structural
  graph, arm delay).
- A `Tool`/equip-able instance for the charge, and a placement interaction (raycast from the
  player to a valid structural element).

**Automated tests (green gate, Tier 1)**
- `ExplosiveChargeConfig` returns valid, in-range stats.
- A pure "is this a legal placement target" check (e.g. must hit a tagged structural element
  within range) is tested directly.

**Acceptance criteria**
- The player can equip the charge tool and see a placement preview on structural elements.
- Illegal placements (out of range, non-structural target) are rejected server-side.

**Dariy's manual checklist**
- [ ] Equip the charge — can you see where it would be placed before committing?

---

## Issue #11 — Tool equip/place/detonate flow

**Goal:** the full loop — equip, place, arm, detonate — works end to end and feeds into
Epic 3's damage/fracture system, server-authoritative throughout.

**Scope**
- `server/ToolService.luau` — validates equip/place requests, tracks placed-but-not-detonated
  charges, and on detonate applies damage (Issue #9) to the targeted element(s).
- `client/ToolController.luau` — input handling (equip, aim/place, confirm, detonate) and
  passing requests to the server; renders placement state locally but never decides outcome.

**Automated tests (green gate, Tier 1)**
- The place → arm → detonate state machine only allows valid transitions (e.g. can't detonate
  a charge that was never armed).

**Acceptance criteria**
- End to end: equip → place on a column → detonate → Epic 2/3 propagation and fracture happen,
  server-driven.
- A client cannot detonate a charge it didn't legally place (spot-checked via Studio MCP).

**Dariy's manual checklist**
- [ ] Place a charge on a column and detonate it — does the building fail the way Epic 2/3
      taught it to (correct dependents, staged, fractured into debris)?

---

## Issue #12 — Vehicle-based demolition (wrecking ball, etc.)

**Goal:** a second, distinct demolition method — a drivable/controllable wrecking ball (or
similar vehicle) that damages structural elements on impact.

**Scope**
- A vehicle rig (seat + physics-driven ball/arm) the player can enter and control.
- Impact detection feeds into Issue #9's damage system (impact force/mass → damage amount),
  not direct part removal.
- `shared/Vehicles/WreckingBallConfig.luau` — **pure**: mass/swing-force/damage-per-impact
  tuning.

**Automated tests (green gate, Tier 1)**
- `WreckingBallConfig` returns valid, in-range stats.
- A pure "impact → damage amount" mapping is tested for a few representative impact
  speeds/masses.

**Acceptance criteria**
- The player can enter and control the vehicle; swinging it into a structural element damages
  it via the same Epic 2/3 systems as the explosive charge (no separate, parallel destruction
  path).

**Dariy's manual checklist**
- [ ] Drive/control the wrecking ball into the building — does it feel physically heavy, and
      does the damage it causes propagate correctly?

---

## Issue #13 — Evolution tree / unlock system

**Goal:** tools and vehicles are gated behind an unlock progression instead of all being
available from the start.

**Scope**
- `shared/Progression/EvolutionTree.luau` — **pure**: a data structure describing unlockable
  tools/vehicles, their prerequisites, and unlock costs/criteria.
- `server/ProgressionService.luau` — tracks a player's unlocked set (persisted — confirm
  `DataStoreService` usage via `roblox-api-check`) and validates equip requests against it.
- A minimal UI hook to view/unlock nodes (full UI polish is Epic 6).

**Automated tests (green gate, Tier 1)**
- `EvolutionTree` prerequisite checks correctly gate a locked node and allow an unlocked one.
- Unlock cost/criteria validation rejects an under-qualified unlock attempt.

**Acceptance criteria**
- A new player starts with only the base explosive charge; unlocking the wrecking ball (or
  next tool) requires meeting the tree's stated criteria and is enforced server-side.

**Dariy's manual checklist**
- [ ] Confirm you can't equip a tool/vehicle you haven't unlocked yet, and that unlocking it
      through the intended path actually grants it.

---

# EPIC 5 — Campaign & Game Loop

**Outcome:** the destruction and tools built above are wrapped in an actual game: a multi-level
campaign, objectives and scoring per level, and a way to select/progress between levels.

**Build order:** #14 → #15 → #16.

---

## Issue #14 — Level structure (multi-level campaign)

**Goal:** more than one demolition level exists, loadable independently, each with its own
building(s).

**Scope**
- `shared/Campaign/LevelDefinition.luau` — **pure**: a data description of a level (which
  building spec(s) to place, starting tools available, par score/objectives reference for
  Issue #15).
- `server/LevelService.luau` — loads a given level's buildings into the test map / a
  level-specific area, replacing Epic 1's single hardcoded test building with a
  data-driven level.
- At least 2–3 concrete `LevelDefinition`s to prove the structure generalizes beyond one
  hand-built test building.

**Automated tests (green gate, Tier 1)**
- Each seeded `LevelDefinition` validates (references a real building spec, well-formed
  fields).

**Acceptance criteria**
- Loading different levels produces visibly different buildings/layouts in the same running
  game.

**Dariy's manual checklist**
- [ ] Load two different levels — are they actually different buildings, not the same one
      renamed?

---

## Issue #15 — Objective tracking and scoring

**Goal:** each level has explicit objectives (e.g. "bring down the building using under N
charges," "achieve full collapse," "don't damage the neighboring structure") and a score is
computed from performance against them.

**Scope**
- `shared/Campaign/Objectives.luau` — **pure**: objective definitions and a scoring function
  that takes an in-level event log (charges used, structural elements failed, time taken) and
  returns a score/result.
- `server/ScoreService.luau` — records the event log during a level and computes/reports the
  final score via `Objectives`.

**Automated tests (green gate, Tier 1)**
- Given a few representative event logs, `Objectives` produces the expected score/pass-fail
  result.

**Acceptance criteria**
- Completing a level shows objective results and a score, correctly reflecting Structural/
  Destruction system events from Epics 2–3 (not a fake/estimated count).

**Dariy's manual checklist**
- [ ] Complete a level a couple of different ways (efficient vs. wasteful) — does the score
      actually reflect the difference?

---

## Issue #16 — Level select/progression

**Goal:** the player can choose which unlocked level to play next and see their progress
across the campaign.

**Scope**
- `shared/Campaign/ProgressionState.luau` — **pure**: which levels are unlocked/completed given
  a player's history, and what unlocks next.
- A level-select flow (menu or in-world) wired to `LevelService` (Issue #14) and persisted
  progress (reuses the persistence approach from Issue #13).

**Automated tests (green gate, Tier 1)**
- `ProgressionState` correctly computes the unlocked/next-level set for a few representative
  completion histories.

**Acceptance criteria**
- Completing a level unlocks the next one per the intended campaign order; players can
  replay already-unlocked levels.

**Dariy's manual checklist**
- [ ] Complete a level — does the next one become available? Can you go back and replay an
      earlier one?

---

# EPIC 6 — Polish

**Outcome:** everything above looks, sounds, and performs like a finished game rather than a
tech demo. This epic is deliberately last and mostly tuning — don't start it before Epics 1–5
have working, testable behavior to polish.

**Build order:** #17 → #18 → #19.

---

## Issue #17 — VFX/SFX for explosions and collapse

**Goal:** explosions, dust, debris impacts, and structural failure get visual and audio
feedback — layered **on top of** the real physical failure from Epics 2–3, never replacing it
(see `structural-integrity-system`).

**Scope**
- Particle effects for detonation, dust clouds during collapse, debris impact sounds.
- Hook these into the existing server-driven failure/fracture events (Issues #6–#7) as
  client-side rendering only — they must not be able to trigger or fake a failure themselves.

**Automated tests (green gate, Tier 1)**
- N/A for pure VFX/SFX assets; if any pure timing/selection logic is added (e.g. picking which
  sound to play based on debris size), test that logic directly.

**Acceptance criteria**
- Detonation and collapse are accompanied by appropriate VFX/SFX, timed to the actual
  server-driven events rather than a separately-guessed animation.

**Dariy's manual checklist**
- [ ] Does a detonation/collapse *feel* satisfying — does the audio/visual timing match what's
      actually happening structurally?

---

## Issue #18 — UI (HUD, tool selector, score screen)

**Goal:** the player has a clear UI for the tool/vehicle selector, in-level HUD, and the
end-of-level score screen (Issue #15's data, presented properly).

**Scope**
- HUD: current tool, charge count/cooldown, basic level/objective status.
- Tool/vehicle selector reflecting the Issue #13 evolution tree unlock state.
- Score screen presenting Issue #15's objective results.

**Automated tests (green gate, Tier 1)**
- Any pure UI-state-selection logic (e.g. "which tools are shown as locked vs. available")
  is tested directly against `EvolutionTree`/`ProgressionState`.

**Acceptance criteria**
- A player can see, without guessing, what tool they have, what's unlocked, and how they did
  on a level.

**Dariy's manual checklist**
- [ ] Can you tell at a glance what tool you're holding, what's locked, and your last score?

---

## Issue #19 — Performance optimization / debris cleanup

**Goal:** a final pass to make sure a full campaign session (multiple collapses across
multiple levels) stays performant over time, not just for a single collapse (Issue #8 covered
that in isolation).

**Scope**
- Audit and tighten debris/part cleanup across level transitions (nothing from a previous
  level's collapse should linger).
- Profile a full level playthrough (via Studio MCP) and address any regressions found across
  Epics 2–5 now that they're all running together.

**Automated tests (green gate)**
- No regressions: the full Tier-1 suite stays green.
- Add regression tests for any bug found during this pass.

**Acceptance criteria (= project v1 done)**
- A full campaign playthrough (multiple levels, multiple collapses) stays within the agreed
  performance budget with no lingering debris/part leaks between levels.

**Dariy's manual checklist**
- [ ] Play through several levels back to back — does performance stay solid, or does it
      degrade the longer you play?

---

## How a planning session works (for future epics)

When Epic 6 is merged, hold a short planning session for whatever comes next (more levels,
multiplayer, new tools). Pick the next epic, write its outcome in one sentence, break it into
issues using the same template (goal / scope / automated tests / acceptance criteria / Dariy's
manual checklist), and confirm scope before building. Keep issues small enough that one PR
closes one issue.
