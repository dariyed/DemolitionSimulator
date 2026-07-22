---
name: green-gate-tests
description: The automated green gate — write Tier-1 headless Luau tests first with Lune, plus stylua + selene, and only hand a green build to Dariy. Use whenever writing tests, "tests are red", designing a pure shared module, CI setup, lint/format, or before asking Dariy to play-test anything.
---

# The green gate (tests-first, never hand Dariy red code)

**Rule 3 of CLAUDE.md, non-negotiable:** write the automated tests first, get them GREEN,
and only *then* hand the build to Dariy for manual play-testing. Never ask him to test red code.

## Two tiers

| Tier | What | Runner | Speed |
| --- | --- | --- | --- |
| **Tier 1** (the gate) | pure logic in `src/shared/` — load path graphs, collapse math, damage propagation, fracture math | **Lune**, hand-rolled runner | seconds, no engine, runs in CI |
| **Tier 2** | things that touch Instances/physics/input — actual parts falling, constraints breaking, explosion VFX | Jest-Lua/TestEZ via **Studio MCP** | needs Studio |

> **Design rule that makes this work:** if a function can take inputs (a structure's part
> graph, a damage event) and return outputs (which elements should now be unsupported, which
> parts should un-anchor) without touching `Workspace`, put it in `shared/` and Tier-1 test it.
> This project lives or dies on the **structural math being correct and testable** — the load
> path graph, failure propagation rules, and fracture thresholds should all be pure functions
> you can unit test with a fake building, before any part ever falls in Studio.

## Run the gate

```bash
lune run test          # discovers *.spec.luau, exits non-zero on any failure → blocks the PR
stylua --check .       # formatting gate (CI)
selene src tests       # lint gate (CI)
```

`lune/test.luau` discovers `*.spec.luau` under `tests/` and `src/shared/`.

## Writing a Tier-1 spec

1. Read the issue's **acceptance criteria** and **automated-test list** in `docs/ROADMAP.md`.
2. Write one `*.spec.luau` per behavior, each asserting one criterion. **Run it red first** —
   a test that can't fail proves nothing.
3. Implement the pure module until green.
4. `stylua .` then `selene src tests` until clean.
5. `lune run test` fully green → *now* you may hand to Dariy.

## When Dariy reports a bug (manual test)

His comment becomes: a fix **and**, wherever possible, a **new Tier-1 regression test** that
would have caught it. A "the collapse looked weird" bug that can't be unit-tested precisely
still becomes a documented tuning knob + a Tier-2/manual checklist item.

## Verify before claiming green

"Tests pass" means you **ran `lune run test` and saw it exit 0** in this session — not "should
pass". Paste the summary line when you hand off.

See also: `studio-mcp-playtest`, `github-issue-flow`, `structural-integrity-system`.
