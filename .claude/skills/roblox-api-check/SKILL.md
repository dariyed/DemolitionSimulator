---
name: roblox-api-check
description: Before using an unfamiliar or memory-recalled Roblox/Luau API, fetch the official docs instead of trusting memory. Use whenever touching a constraint, service, Enum, method signature, or any Roblox API you're not 100% sure of — especially WeldConstraint, physics constraints (Weld/Hinge/Motor6D), BasePart:BreakJoints, network ownership, PhysicsService, CollisionGroup, Instance:Destroy vs unanchoring.
---

# Check the Roblox API, don't trust memory

Roblox APIs change, and model memory of them goes stale. The recurring failure is writing code
against a half-remembered signature, shipping a red build, and burning a play-test. Verify first.

## Where to look (in order)

1. **Official docs:** https://create.roblox.com/docs
2. **Agent-friendly index:** https://create.roblox.com/docs/llms.txt — fetch and read this when
   you touch an unfamiliar API; it points to the right page fast.
3. The specific reference page for the class/Enum (e.g. `WeldConstraint`, `Motor6D`,
   `BasePart:BreakJoints`, `PhysicsService`, `CollisionGroup`, `Instance:Destroy`).

## When to trigger this

- Any **structural connection** work (this project lives on `WeldConstraint`/`Motor6D` between
  building parts — confirm break behavior, `BreakJoints`, and how welds report their connected
  parts before wiring the load path graph to them).
- Debris physics: `PhysicsService` collision groups, part count budgets, `Debris` service for
  cleanup, `Region3`/spatial queries for destruction radius.
- Network ownership, input capture, any time you're about to write "I think the property is…".

## Also: tool versions drift

If a `rokit add` handle or a tool command has moved since SETUP.md was written, check the
tool's GitHub releases, use the correct owner/repo handle, pin the version in `rokit.toml`,
**and tell Dariy what you changed and why.**

## The rule

Spending 30 seconds fetching `llms.txt` beats shipping a red build. When a detail matters,
read the source of truth — this is `verify-before-claiming` applied to Roblox.

See also: `structural-integrity-system`, `green-gate-tests`.
