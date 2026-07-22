# HANDOFF — start here, Claude

> You are the building partner on **Demolition Simulator**, working with **Dariy** (owns this
> repo, does the manual play-testing). This doc gets you from "fresh clone" to "building
> Epic 1, Issue #1". Read it once, in full.

## 1. What already exists in this repo (seeded for you)

This repo was bootstrapped with the full HalfSwordGame-style pipeline and operating docs, plus
the game-specific plan — but **no game logic yet** (Epic 1 is the first real build).

```
CLAUDE.md                          ← the contract. Read it first, every session.
README.md
rokit.toml  wally.toml  selene.toml  stylua.toml
default.project.json               ← Rojo mapping + baseline test-map Workspace setup
.github/workflows/ci.yml           ← lint + format + test on every PR
src/shared/Version.luau            ← trivial seeded module
tests/Version.spec.luau            ← trivial seeded Tier-1 spec (proves CI goes green)
lune/test.luau                     ← hand-rolled Tier-1 test runner
docs/
  SETUP.md                         ← one-time machine setup (tools, MCP, CI) + kickoff prompt
  ROADMAP.md                       ← full plan: 6 epics, 19 issues, fully specified
  HANDOFF.md                       ← this file
.claude/
  skills/                          ← 9 project skills (auto-loaded by description) — see skills/README.md
  hooks/session-start.sh           ← surfaces the skills + rules at every session start
  settings.json                    ← wires the hook
```

## 2. The rules, in one breath (full version in CLAUDE.md §3)

1. **Everything goes through GitHub** — issue → branch → PR. Nothing lives only on disk.
2. **One issue = one feature = one branch = one PR.**
3. **Tests first, GREEN before Dariy play-tests.** Never hand him red code.
4. Manual-test feedback → issue comments → fixes + regression tests.
5. **Destruction is server-authoritative** — the client never decides a part failed.
6. **Explain every line of code, step by step** — an explicit, elevated requirement for this
   project (see `CLAUDE.md` §2.1 / `teach-dariy` skill).
7. **Everything in English.**

## 3. Your skills (lean on them)

`.claude/skills/` ships 9 skills that fire automatically by topic:

- **`teach-dariy`** — explain every line, step by step, in detail. This is a hard requirement
  on this project, not a nice-to-have.
- **`github-issue-flow`** — the issue→branch→PR loop and commit/PR conventions.
- **`green-gate-tests`** — Tier-1 Lune tests + lint/format; the green gate before any play-test.
- **`structural-integrity-system`** — **the core design pillar.** Read before touching any
  destruction, load-bearing tagging, or collapse code.
- **`rojo-studio-sync`**, **`studio-mcp-playtest`** — get code into Studio and smoke-test it.
- **`roblox-api-check`** — fetch `create.roblox.com/docs` before trusting memory on any API.

Run `cat .claude/skills/README.md` for the full table.

## 4. Prerequisites (confirm before building)

Setup is covered in `docs/SETUP.md`. Before your first build, confirm on this machine:

```bash
git --version
gh auth status          # must be logged in as Dariy — this is how you do GitHub ops
rokit --version         # toolchain manager (installs rojo/wally/stylua/selene/lune)
```

- **`gh auth status` not logged in?** Stop and have Dariy run `gh auth login`.
- **Roblox Studio** installed + updated, with the **MCP server** enabled (SETUP.md §4) — your
  eyes/hands in-engine, essential here because collapse behavior needs to be watched, not just
  reasoned about. Windows/macOS only.
- Missing tools? Follow `docs/SETUP.md` top to bottom.

## 5. First session — do this

1. **Audit the repo** and confirm what's listed in §1 above.
2. **Run the toolchain**: `rokit install`, then `lune run test` — confirm the seeded
   `Version.spec.luau` passes and CI is set up to run the same on every PR.
3. **Open all 19 issues** across the 6 epics, verbatim from `docs/ROADMAP.md`, each with its
   goal, scope, automated-test list, acceptance criteria, and Dariy's manual checklist. Group
   them with milestones matching the 6 epics.
4. **Start Epic 1, Issue #1** (baseline Roblox setup): branch, implement, get CI green, open a
   PR that says `Closes #1`, then walk Dariy through how to verify it.

Explain every line of code, step by step, as you go — this project's explicit, elevated
requirement. Keep changes small. Follow every rule in `CLAUDE.md`.

## 6. The very first thing to say to Dariy

> "I've read CLAUDE.md and the roadmap. Here's what's already in the repo, here's what we'll
> build in Epic 1, and here's how the test-first GitHub loop will work — with every line of
> code explained as we go. First, can you confirm `gh auth status` shows you logged in? Then
> I'll start Issue #1."
