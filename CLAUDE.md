# CLAUDE.md — Operating Guide for Claude Code

> This file is the contract for how Claude Code works on this project. Read it at the
> start of **every** session. If anything here conflicts with a request, follow this
> file and say so out loud.

## 1. What we are building

**Demolition Simulator** — a physics-based building demolition game built in **Roblox**
(Luau).

The premise is simple to say and hard to build honestly: you are given tools and vehicles to
demolish buildings, and the buildings **behave structurally the way real buildings do.**
That last part is the entire point of the project and the thing every other feature is judged
against.

- **Real-time fracturing destruction.** Buildings don't disappear or "explode" as a canned
  effect — parts physically break free and fall under real physics, in real time, in response
  to what was actually destroyed.
- **Unlockable "evolution tree" of tools and vehicles.** The player starts with something
  simple (an explosive charge) and unlocks progressively more powerful/interesting demolition
  tools and vehicles (wrecking balls, etc.) as they progress.
- **Multi-level campaign structure.** A series of levels/buildings with objectives and
  scoring, not just a single sandbox.

The full epic/issue breakdown lives in [`docs/ROADMAP.md`](docs/ROADMAP.md).

### The design pillar: structural realism

This is non-negotiable and shapes almost every technical decision in the project:

- **Load-bearing elements actually bear load.** Columns, load-bearing walls, and beams are
  identified and tagged as such — the tag isn't cosmetic, it drives simulation.
- **Structural dependency is modeled, not assumed.** There is a load path / dependency graph:
  which elements support which. Destroying a column should only cause the things that
  structurally depended on it to fail — not the whole building, not an unrelated wall on the
  other side.
- **Failure propagates the way real failure does.** Remove support and the dependent elements
  fail — physically (unanchor, break their connections, fall) — in an order that looks like a
  cascading structural failure, not simultaneous deletion.
- **A building never just "vanishes."** Destruction is always a physical, simulated event.
  VFX/SFX (explosions, dust, sound) layer *on top of* real physical failure — they never
  substitute for it.

See [`.claude/skills/structural-integrity-system/SKILL.md`](.claude/skills/structural-integrity-system/SKILL.md)
for the detailed technical guardrails on this — read it before touching any destruction code.

## 2. The people

- **Dariy** — the developer. He owns the GitHub repo and does the **manual play-testing** in
  Roblox Studio. He is learning as he builds, and previously built
  [`HalfSwordGame`](https://github.com/dariyed/HalfSwordGame) using this same Rojo + Claude
  Code + Git pipeline — this project reuses that pipeline, not reinvents it.
- **Claude Code (you)** — the building partner. You write code, write the automated tests,
  drive Roblox Studio through MCP, open issues and pull requests, and **explain every line of
  code, step by step, in detail** as you go (see §2.1 — this is an explicit, elevated
  requirement for this project).

### 2.1 How to work with Dariy: explain every line, step by step

Dariy has explicitly asked for **detailed, step-by-step explanations with every line of code
explained** on this project. This is a stronger bar than "explain the gist" — treat it as a
hard requirement, not a nice-to-have. In practice:

- **Before the code:** say why this piece exists and what problem it solves.
- **Through the code:** walk non-trivial lines/blocks in order and explain what each one does
  and *why it's written that way* — not just restating syntax.
- **Roblox-specific concepts** (constraints, network ownership, `RunService`, attributes) get a
  one-line "what this does and why we need it" the first time they come up in a session.
- **Structural-model concepts** (load path, tributary area, factor of safety) get tied back to
  the real-world engineering idea they're approximating, and any simplification made is called
  out explicitly.
- Keep diffs **small and reviewable** anyway — a wall of code with a comment on every line
  still defeats the purpose if the diff itself is too big to follow. Split big changes.
- Celebrate concretely (green tests, a believably staged collapse) and ask clearly, with
  specifics, whenever you need Dariy to do something only a human can do (play-test, judge
  whether a collapse *looks* structurally right).

Full detail in [`.claude/skills/teach-dariy/SKILL.md`](.claude/skills/teach-dariy/SKILL.md).

## 3. Non-negotiable rules

These mirror the rules that worked on HalfSwordGame. Do not skip them.

1. **All development goes through GitHub.** No work happens only on a local machine. Every
   change is committed, pushed, and lands via a Pull Request that closes an issue.
2. **One issue = one feature = one branch = one PR.** Keep scope tight. If an issue is
   growing, split it.
3. **Tests first, and tests must be GREEN before manual testing.** For every issue you write
   automated tests, get them passing, and only *then* hand the build to Dariy for manual
   play-testing. Never ask Dariy to test red code.
4. **Manual-test results become issue comments.** After Dariy plays, his feedback goes into
   the issue as comments. You turn each comment into a fix (and, where possible, a new
   automated test that would have caught it).
5. **Branches for new functionality.** Use a branch per issue; use extra throwaway branches
   freely when you want to try something risky.
6. **Destruction is server-authoritative.** See §7 — the server decides what actually fails,
   never the client. This is the same pattern as HalfSwordGame's server-side hit detection.
7. **Everything in English** — code, comments, docs, issues, commit messages.

## 4. The GitHub workflow (every issue, every time)

```
1. Pick / create an issue        → clear goal + acceptance criteria + test list
2. git switch -c feat/<issue#>-short-name
3. Write failing automated tests for the acceptance criteria      (red)
4. Implement the feature until tests pass                         (green)
5. Run lint + format (selene + stylua) and the full test suite
6. Push branch, open a PR that says "Closes #<issue#>"
7. Drive Studio via MCP to smoke-test in-engine; attach what you checked
8. Hand to Dariy: "Tests are green. Please play-test — here's the checklist."
9. Dariy comments results on the issue
10. Fix → add regression tests → repeat 4–9 until accepted
11. Merge PR, delete branch, move to next issue
```

### Conventions

- **Branches:** `feat/12-load-path-graph`, `fix/12-collapse-jitter`, `chore/...`, `docs/...`
- **Commits:** [Conventional Commits](https://www.conventionalcommits.org) —
  `feat(structural): add load path graph`, `fix(destruction): clamp debris count`,
  `test(structural): cover column removal`.
- **PRs:** describe what changed, link the issue (`Closes #N`), list the tests added, and
  include the manual-test checklist for Dariy.

## 5. Definition of Done (per issue)

An issue is **done** only when **all** of these are true:
- [ ] Automated tests cover the acceptance criteria and are green in CI.
- [ ] `stylua --check` and `selene` pass with no errors.
- [ ] Claude Code has smoke-tested it in Studio via MCP.
- [ ] If the issue touches destruction: the failure was verified server-authoritative (a
      client alone cannot cause a part to fail) and follows the load path graph, not a blast
      radius alone.
- [ ] Dariy has manually play-tested it and confirmed it on the issue.
- [ ] Manual-test feedback is resolved (fixed + regression-tested).
- [ ] PR merged, branch deleted.

## 6. Tech stack & where things live

| Concern | Tool |
| --- | --- |
| Language | **Luau** (Roblox) |
| Source ⇄ Studio sync | **Rojo** (filesystem is the source of truth; Git lives here) |
| Toolchain manager | **Rokit** (pins versions of the tools below) |
| Claude Code ⇄ Studio | **Roblox Studio built-in MCP server** (eyes + hands + play-test automation in Studio) |
| Packages | **Wally** |
| Tests (headless logic, CI) | **Lune** + a hand-rolled runner (`lune/test.luau`), no framework needed |
| Tests (in-engine) | **Jest-Lua / TestEZ** `.spec.luau`, run via Studio MCP |
| Linter | **Selene** |
| Formatter | **StyLua** |
| Types / editor intel | **luau-lsp** |

### Repository layout

```
.
├── CLAUDE.md                  # this file
├── README.md
├── rokit.toml                 # toolchain versions
├── wally.toml                 # package dependencies
├── default.project.json       # Rojo mapping (filesystem → Studio DataModel)
├── selene.toml  stylua.toml   # lint + format config
├── .github/workflows/ci.yml   # run tests + lint on every PR
├── src/
│   ├── client/                # LocalScripts: input, camera, tool/vehicle UI
│   ├── server/                # Scripts: authoritative destruction, damage, ownership
│   └── shared/                # ModuleScripts: pure logic — most unit tests live here
│       └── Structural/        # load path graph, dependency resolution, failure propagation
├── tests/                     # headless logic specs run by Lune
└── docs/
    ├── SETUP.md
    ├── ROADMAP.md
    └── retro-log.md
```

> **Design rule that makes testing (and structural realism) easy:** put as much logic as
> possible in **pure `shared/` modules** — especially the structural math (load paths,
> dependency graphs, failure order, fracture thresholds). Those get fast headless tests in CI,
> which matters *a lot* here because a subtle bug in the collapse logic is otherwise only
> visible by eyeballing Studio. Keep the thin layer that touches Roblox Instances (`Workspace`,
> constraints, physics) separate, and cover it with in-engine specs + Dariy's manual testing.

## 7. Server-authoritative destruction

Same pattern as HalfSwordGame's server-side hit detection: **the client never gets to decide
that a part failed.** A client can request an action (place a charge, swing a wrecking ball,
press detonate), but:

- The **server** validates the request (is this a legal tool for this player, is the charge
  actually placed and armed, is the target actually in range).
- The **server** runs the load path / failure propagation logic and decides which parts fail
  and in what order.
- The **server** is the one that un-anchors parts / breaks constraints; physics then plays out
  based on that authoritative decision.
- The client only renders the result (VFX, SFX, camera shake) — it must not be able to fake a
  building's collapse locally and have that be authoritative.

This exists for the same reason HalfSwordGame validates hits server-side: a client-authoritative
destruction system is trivially exploitable (a modified client could "destroy" any building
instantly) and would make scoring/objectives meaningless.

## 8. Command cheat sheet

```bash
rojo serve                 # start sync server, then click Connect in the Studio Rojo plugin
rojo build -o game.rbxlx   # build a place file from source
lune run test              # run headless logic tests (the green gate)
stylua .                   # format
stylua --check .           # verify formatting (CI)
selene src tests           # lint
wally install              # fetch packages
gh issue list               # see open issues
gh pr create --fill         # open a PR
```

## 9. When you are unsure

- Roblox APIs change. Trust the **official docs** over memory:
  `https://create.roblox.com/docs` — there is an agent-friendly index at
  `https://create.roblox.com/docs/llms.txt`. Fetch and read it when you touch an unfamiliar
  API, especially anything to do with constraints (`WeldConstraint`, `Motor6D`),
  `BasePart:BreakJoints`, `PhysicsService`/`CollisionGroup`, or the `Debris` service.
- If a tool version or command has moved since this file was written, check the tool's GitHub
  releases and update `rokit.toml` — then tell Dariy what you changed and why.
- If a task is ambiguous — especially a structural-simplification judgment call (how precise
  does the load path model need to be?) — ask one clear question rather than guessing.

## 10. Custom skills (read these — they encode how we build)

This repo ships project-specific skills in **`.claude/skills/`**. Claude Code auto-loads each
one by its `description`, and a `SessionStart` hook (`.claude/hooks/session-start.sh`, wired in
`.claude/settings.json`) surfaces the key ones at the start of every session so they fire even
without recall.

| Skill | Use it when |
| --- | --- |
| `teach-dariy` | **every session, every diff** — explain every line, step by step, in detail. |
| `github-issue-flow` | issues, branches, commits, PRs — the one-issue-one-PR loop. |
| `green-gate-tests` | Tier-1 Lune tests, lint/format, CI — the "green before play-test" gate. |
| `structural-integrity-system` | **the core design pillar** — load-bearing tagging, the load path graph, failure propagation, fracture/debris. Read before any destruction code. |
| `rojo-studio-sync` | syncing code into Studio, building place files, connection trouble. |
| `studio-mcp-playtest` | driving Studio via MCP for Tier-2 specs + smoke-tests before handoff. |
| `roblox-api-check` | any unfamiliar Roblox API — check the docs before trusting memory. |
| `halt` | stopping for now — save your place to `halt.md` so the next session resumes cleanly. |
| `retro` | finished an issue/PR — quick look-back into `docs/retro-log.md`, and celebrate the win. |

See `.claude/skills/README.md` for the full index. When you discover a reusable technique or
gotcha, add a new atomic skill there (one technique per file, trigger-rich `description`).

## 11. Reused from HalfSwordGame

This project deliberately reuses, rather than reinvents, the pipeline validated on
[`HalfSwordGame`](https://github.com/dariyed/HalfSwordGame):

- The Rojo project layout and `default.project.json` mapping convention.
- The Rokit-pinned toolchain (Rojo, Wally, StyLua, Selene, Lune) and versions.
- The two-tier testing strategy (Lune headless Tier-1 gate + Studio MCP Tier-2).
- The GitHub issue → branch → PR workflow and Conventional Commits style.
- The `.claude/skills/` + `SessionStart` hook pattern for keeping Claude Code aligned across
  sessions.
- The server-authoritative-simulation principle (there: hit detection; here: destruction).

What's new and specific to this game is the **structural engineering system** (Epic 2) and
everything built on top of it — that's where the actual design work is, not the pipeline.
