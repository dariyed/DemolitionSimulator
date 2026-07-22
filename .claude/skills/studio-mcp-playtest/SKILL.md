---
name: studio-mcp-playtest
description: Drive Roblox Studio through its built-in MCP server to inspect the data model, run Luau, run Tier-2 in-engine specs, and smoke-test before handing a build to Dariy. Use when running in-engine specs, "smoke-test in Studio", checking instances/constraints/network ownership/collapse behavior actually got created, or connecting Claude to Studio.
---

# Studio MCP — your eyes and hands inside the engine

Modern Studio ships an **MCP server** that lets you act *inside the open place*: read the
DataModel, insert/modify instances, run Luau, and automate play-tests. This is how you
smoke-test Tier-2 behavior — especially physical collapse, which can only really be judged by
watching parts actually fall — **before** handing a build to Dariy.

## One-time connect

1. In Studio: **File → Studio Settings → Beta Features → enable "MCP Server"** (also under
   **Assistant → MCP Servers → Enable Studio as MCP server**). It listens on `localhost:3004`.
2. Register with Claude Code: `claude mcp add roblox-studio --transport http http://localhost:3004/mcp`
3. Keep Studio open with the place loaded — MCP operates on the **currently open place**, and
   changes happen live so Dariy can watch.

## What to use it for

- **Inspect:** confirm the things your code is supposed to create actually exist — e.g. after
  tagging a column as load-bearing, does it carry the expected `StructuralRole` attribute and
  is it registered in the load path graph? After detonation, did the server actually
  un-anchor/break the constraints on the dependent parts (not just delete them)?
- **Run Luau:** execute a snippet to check a value or reproduce a bug without a full play-test.
- **Tier-2 specs:** run `*.spec.luau` (Jest-Lua/TestEZ) that need real Instances/physics, and
  report pass/fail before handoff.

## The boundary that keeps the project sane

The **filesystem (Rojo + Git) stays the source of truth.** Use MCP to *inspect, run, and
test* — but don't author game code by mutating the live DataModel and leaving it there. Any
change worth keeping goes back into a `.luau` file, committed. An older standalone
`studio-rust-mcp-server` exists as reference; the **built-in** server is the recommended path.

## Before handoff to Dariy

Report exactly what you smoke-tested in-engine and what you saw (ideally describe the collapse
behavior you observed, not just "it ran"), then give him the manual checklist from the issue.
Never hand off "should work in Studio" — open it and check.

See also: `green-gate-tests`, `rojo-studio-sync`, `structural-integrity-system`.
