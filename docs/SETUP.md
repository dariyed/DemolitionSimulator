# SETUP — Set up everything (do this once)

This guide takes Dariy's machine from zero to a working, Git-backed Roblox project that Claude
Code can build in and that Dariy can play-test in Studio. Work top to bottom. Reuses the exact
same toolchain validated on [HalfSwordGame](https://github.com/dariyed/HalfSwordGame).

Roblox Studio runs on **Windows** and **macOS** only. Steps note `[Win]` / `[Mac]` where they
differ.

---

## 0. Accounts & base software

- [ ] A **GitHub account** (Dariy already has one — `DemolitionSimulator` lives there).
- [ ] A **Roblox account** + **Roblox Studio** installed and updated to the latest version (the
      built-in MCP server we rely on needs a recent Studio).
- [ ] **Node.js LTS** (gives us `npx`, used by some tooling). https://nodejs.org
- [ ] **VS Code** (recommended editor). https://code.visualstudio.com
- [ ] **Claude Code** installed and signed in.

---

## 1. Git + GitHub

**Install Git**
- `[Win]` Install Git for Windows: https://git-scm.com/download/win
- `[Mac]` `xcode-select --install` (includes git), or `brew install git`.

Verify: `git --version`.

**Identify yourself**
```bash
git config --global user.name  "Dariy ..."
git config --global user.email "dariy@example.com"
```

**Install GitHub CLI** (lets Claude Code manage issues/PRs cleanly):
- `[Win]` `winget install --id GitHub.cli`
- `[Mac]` `brew install gh`

**Authenticate** (this is the "connect Claude Code to GitHub" step):
```bash
gh auth login        # choose GitHub.com → HTTPS → authenticate in browser
gh auth status       # confirm you're logged in
```

```bash
git clone https://github.com/dariyed/DemolitionSimulator.git
cd DemolitionSimulator
```

---

## 2. Toolchain manager: Rokit

Rokit installs and version-pins all the Roblox tools (Rojo, StyLua, Selene, Lune, Wally) so
everyone gets identical versions. `rokit.toml` in this repo already pins them:

```toml
[tools]
rojo = "rojo-rbx/rojo@7.6.1"
wally = "UpliftGames/wally@0.3.2"
StyLua = "JohnnyMorganz/StyLua@2.5.2"
selene = "Kampfkarren/selene@0.31.0"
lune = "lune-org/lune@0.10.4"
```

- `[Mac]`:
  ```bash
  curl -fsSL https://raw.githubusercontent.com/rojo-rbx/rokit/main/scripts/install.sh | bash
  ```
- `[Win]`: download and run the installer from
  https://github.com/rojo-rbx/rokit/releases (latest release).

Restart the terminal, then, inside the repo:
```bash
rokit --version
rokit install
```

> Claude Code: the exact owner/repo handles and latest versions can drift. If `rokit install`
> fails, look up the tool's current GitHub release, use the correct handle, and update the
> pin in `rokit.toml`. Commit the change and tell Dariy why.

---

## 3. Rojo: sync code into Studio (this is "how to run code in Roblox")

Rojo maps files on disk to objects inside Studio. You edit `.luau` files; Studio updates live.
This is what lets us use Git + Claude Code and still test in the real engine.

The project skeleton (`default.project.json`, `src/{client,server,shared}`) is already in this
repo — see `CLAUDE.md` §6 for the mapping and layout.

**Install the Studio plugin:** in VS Code install the **"Rojo - Roblox Studio Sync"** extension
(`evaera.vscode-rojo`); it installs both the CLI helper and the Studio plugin. (Alternatively
get the plugin from the Roblox Creator Store / Rojo GitHub.)

**Connect:**
```bash
rojo serve        # starts the sync server
```
Then in Roblox Studio open the place, find the **Rojo** toolbar button, and click **Connect**.
Save a `.luau` file → watch it appear in Studio within milliseconds.

**Build a place file when needed:**
```bash
rojo build -o game.rbxlx
```

**The daily loop for Dariy:** edit in VS Code (or let Claude Code edit) → save → switch to
Studio → press **Play** → test → report.

---

## 4. Connect Claude Code to Roblox Studio (built-in MCP server)

Modern Roblox Studio ships an **MCP server** that lets Claude Code act *inside* Studio: read
the data model, insert/modify instances, run Luau, and automate play-tests. This is how you
(Claude Code) smoke-test before handing builds to Dariy — critical here because collapse
behavior really needs to be watched in-engine, not just reasoned about.

1. In Studio: **File → Studio Settings → Beta Features → enable "MCP Server"** (also exposed
   under **Assistant → MCP Servers → Enable Studio as MCP server**). It listens on
   `localhost:3004`.
2. Register it with Claude Code:
   ```bash
   claude mcp add roblox-studio --transport http http://localhost:3004/mcp
   ```
3. Keep Studio open with a place loaded — MCP operates on the **currently open place**, and
   changes happen live so Dariy can watch.

> Notes: the Studio built-in server is the recommended path. Use the MCP server for
> *inspection, running code, and automated play-tests* — but the **filesystem (via Rojo + Git)
> stays the source of truth**. Don't let MCP edits drift away from the committed source.

---

## 5. Packages: Wally

```bash
wally install
```

`wally.toml` is already set up (`dariy/demolition-simulator-roblox`). Add dependencies with
`wally add` as needed (e.g. a test framework for in-engine specs) and re-run `wally install`.

---

## 6. Testing — two tiers (the "green before manual testing" gate)

We split tests so the gate is fast and reliable:

**Tier 1 — headless logic tests (the primary gate, runs in CI).**
Pure functions in `src/shared/` — most importantly everything in `src/shared/Structural/`
(load path graph, dependency resolution, failure propagation), plus fracture math and any other
pure logic — are tested with **Lune** so they run in seconds with no engine.

```bash
lune run test          # exits non-zero on any failure → blocks the PR
```
`lune/test.luau` discovers `*.spec.luau` under `tests/` and `src/shared/` and runs them.
**These must be green before Dariy play-tests.**

**Tier 2 — in-engine specs (engine-dependent behavior).**
Things that touch Instances/physics (constraints actually breaking, parts actually falling,
network ownership) get `*.spec.luau` files run **inside Studio** via Jest-Lua/TestEZ. Claude
Code triggers these through the Studio MCP server and reports results before handoff. Treat
anything Tier 2 can't fully verify — especially "does the collapse *look* structurally
believable" — as a **manual-test checklist item** for Dariy.

> Rule of thumb: if a function can be written to take inputs (a building's part/role/connection
> graph) and return outputs (which parts fail, in what order) without touching `Workspace`, put
> it in `shared/` and Tier-1 test it. The thin Instance layer on top is what Dariy and Tier-2
> cover.

---

## 7. Lint & format

`stylua.toml` and `selene.toml` configure formatting and linting. Run:
```bash
stylua .            # auto-format
selene src tests    # static analysis
```

---

## 8. Continuous Integration

`.github/workflows/ci.yml` runs, on every PR: installs Rokit tools, then runs
`stylua --check .`, `selene src tests`, and `lune run test`. A red CI blocks merge — this is
the automated enforcement of rule #3 in `CLAUDE.md`.

---

## 9. First session — kickoff prompt for Claude Code

Paste this to Claude Code once the tools above are installed:

```
You are the building partner on Demolition Simulator. Read CLAUDE.md and docs/ROADMAP.md in
full before doing anything.

Then, for our first session:
1. Audit the current repo and tell me what already exists.
2. Confirm the toolchain is installed (rokit install, rojo --version, lune --version) and
   `lune run test` passes on the seeded Version spec.
3. Start Epic 1, Issue #1 (baseline Roblox setup): branch, implement, get CI green, open a PR
   that closes it, then walk me through how to verify it in Studio.

Explain every line of code, step by step, as you go — that's a hard requirement on this
project, not optional. Keep changes small. Follow every rule in CLAUDE.md.
```
