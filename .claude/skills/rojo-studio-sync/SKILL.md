---
name: rojo-studio-sync
description: How to sync Luau code from the filesystem into Roblox Studio with Rojo, build .rbxlx place files, and fix a Rojo connection that won't link. Use when setting up the project, running the game, "Studio isn't updating", "Rojo won't connect", default.project.json mapping, or building a place file.
---

# Rojo ⇄ Studio sync

Rojo maps files on disk → objects inside Studio's DataModel. You edit `.luau`, Studio updates
live. **The filesystem (via Git) is the source of truth** — never let Studio edits drift away
from committed source.

## The mapping (`default.project.json`)

Per CLAUDE.md, the project mapping is:

```
src/client  → StarterPlayer/StarterPlayerScripts   (LocalScripts: input, camera, tool UI)
src/server  → ServerScriptService                  (Scripts: authoritative destruction/damage)
src/shared  → ReplicatedStorage/Shared             (ModuleScripts: pure logic — most tests here)
```

The Workspace also ships a baseline `Baseplate`, `Lighting`, and `SoundService` config so a
fresh clone opens to a usable test map immediately (Epic 1, Issue #1).

## Daily loop

```bash
rojo serve                 # start the sync server (leave it running)
# → in Studio: open a baseplate, click the Rojo toolbar button → Connect
# edit .luau → save → it appears in Studio in milliseconds → press Play → test
```

```bash
rojo build -o game.rbxlx   # build a standalone place file when you need one
```

## Connection won't link — checklist

1. Is `rojo serve` actually running in this repo? (one server, one port — default `34872`).
2. Studio Rojo **plugin** installed and on a recent version? (VS Code `evaera.vscode-rojo`
   installs both CLI helper and the Studio plugin, or get it from the Creator Store).
3. Plugin pointed at the same host/port the server prints.
4. `default.project.json` valid JSON? `rojo build -o /tmp/test.rbxlx` fails loudly if not.
5. Rojo CLI and plugin **major versions must match** — if they disagree, the plugin refuses
   to connect. `rojo --version`; update the pin in `rokit.toml` if needed.

## Verify before claiming it works

Don't say "syncing works" until: `rojo build` produced a place file AND a saved `.luau`
change actually appeared in Studio. That round-trip is the Issue #1 acceptance check.

See also: `green-gate-tests`, `studio-mcp-playtest`.
