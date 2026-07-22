# Custom skills — Demolition Simulator (Roblox)

Project-specific skills that support development. Each is a `<name>/SKILL.md` with a
trigger-rich `description` so Claude Code auto-loads it at the relevant moment. They are also
surfaced at session start by `../hooks/session-start.sh` and referenced from `../../CLAUDE.md`.

| Skill | Fires when you're working on… |
| --- | --- |
| [`teach-dariy`](teach-dariy/SKILL.md) | every session, every piece of code — explain every line, step by step, in detail |
| [`github-issue-flow`](github-issue-flow/SKILL.md) | issues, branches, commits, PRs — the one-issue-one-PR loop |
| [`green-gate-tests`](green-gate-tests/SKILL.md) | Tier-1 Lune tests, lint/format, CI — the "green before play-test" gate |
| [`structural-integrity-system`](structural-integrity-system/SKILL.md) | load-bearing tagging, the load path graph, failure propagation, fracture/debris — the core design pillar |
| [`rojo-studio-sync`](rojo-studio-sync/SKILL.md) | syncing code into Studio, building place files, connection trouble |
| [`studio-mcp-playtest`](studio-mcp-playtest/SKILL.md) | driving Studio via MCP for Tier-2 specs + smoke-tests |
| [`roblox-api-check`](roblox-api-check/SKILL.md) | any unfamiliar Roblox API — check docs before trusting memory |
| [`halt`](halt/SKILL.md) | stopping for now — save your place to `halt.md` so next session resumes cleanly |
| [`retro`](retro/SKILL.md) | finished an issue/PR — quick look-back (went well / was hard / learned / win) into `docs/retro-log.md` |

## How they were made

Adapted from the same pipeline used on HalfSwordGame (`github.com/dariyed/HalfSwordGame`), plus
one new skill (`structural-integrity-system`) written specifically for this project's core
design pillar: destruction must follow real structural dependencies, never random deletion. To
add or change a skill, keep it to one technique, give the `description` real trigger phrases,
and link related skills under `See also`.
