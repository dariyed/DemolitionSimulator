---
name: github-issue-flow
description: The mandatory GitHub workflow — one issue = one branch = one PR, tests green before play-test, manual feedback becomes issue comments then regression tests. Use at the start/end of any feature, opening issues, branching, committing, opening a PR, or "how do we close this out".
---

# The GitHub workflow (every issue, every time)

All development goes through GitHub. Nothing lands only on a local machine. This is rule 1 of
CLAUDE.md.

```
1. Pick/create an issue        → clear goal + acceptance criteria + test list
2. git switch -c feat/<issue#>-short-name
3. Write FAILING automated tests for the acceptance criteria      (red)   ← green-gate-tests
4. Implement until tests pass                                     (green)
5. stylua --check . && selene src tests && lune run test
6. Push branch, open a PR with "Closes #<issue#>"
7. Smoke-test in Studio via MCP; attach what you checked          ← studio-mcp-playtest
8. Hand to Dariy: "Tests are green. Please play-test — here's the checklist."
9. Dariy comments results on the issue
10. Fix → add regression test → repeat 4–9 until accepted
11. Merge PR, delete branch, next issue
```

## Conventions

- **Branches:** `feat/12-load-path-graph`, `fix/12-collapse-jitter`, `chore/...`, `docs/...`
- **Commits:** Conventional Commits — `feat(structural): add load path graph`,
  `fix(destruction): clamp debris count`, `test(structural): cover column removal`.
- **PRs:** what changed, `Closes #N`, the tests added, and **Dariy's manual-test checklist**.

## Epics and issues

The full epic/issue breakdown (Foundation → Structural Engineering → Destruction → Tools &
Vehicles → Campaign & Game Loop → Polish) is specified in `docs/ROADMAP.md` (goal / scope /
automated tests / acceptance criteria / Dariy's manual checklist per issue). Open issues
verbatim — `gh issue create` — in build order within each epic. One issue = one feature = one
PR. If an issue grows, split it.

## Handy

```bash
gh issue list                 # see open issues
gh issue create --title "..." --body-file -    # open an issue
gh pr create --fill           # open a PR
gh pr merge --squash --delete-branch
```

## Keep scope tight

If you're touching files outside the issue's scope, stop — that's a second issue. Throwaway
branches are free; use them to try risky things without polluting the feature branch.

See also: `green-gate-tests`, `studio-mcp-playtest`, `teach-dariy`.
