# Demolition Simulator

A physics-based building demolition game built in Roblox (Luau), where buildings behave
**structurally** the way real buildings do: load-bearing columns and walls actually bear load,
destroying support causes realistic, cascading collapse, and destruction always respects
structural dependencies instead of just deleting parts.

Built with [Rojo](https://github.com/rojo-rbx/rojo) and developed with Claude Code, reusing the
Rojo + Claude Code + Git pipeline from
[HalfSwordGame](https://github.com/dariyed/HalfSwordGame).

See [`CLAUDE.md`](CLAUDE.md) for the full project brief and development rules, and
[`docs/ROADMAP.md`](docs/ROADMAP.md) for the epic/issue breakdown.

## Getting started

Install the pinned toolchain with [Rokit](https://github.com/rojo-rbx/rokit), then:

```bash
rojo serve
```

Open Roblox Studio, connect via the Rojo plugin, and press Play.

Run the automated test suite:

```bash
lune run test
```

Full setup steps are in [`docs/SETUP.md`](docs/SETUP.md).
