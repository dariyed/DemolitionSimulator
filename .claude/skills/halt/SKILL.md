---
name: halt
description: Pause cleanly and save your place so the next session picks up exactly where you stopped. Use when Dariy is stopping for the day, switching tasks, running low on time, or you're running low on context. Writes halt.md at the repo root.
---

# /halt — save your place and stop

When it's time to stop, don't just leave work dangling — write a short `halt.md` so next session
(yours or Dariy's) starts knowing exactly where things are. The session-start hook automatically
reads `halt.md` and surfaces it, so this is how you hand off to your future self.

## Do this

1. Write **`halt.md`** at the repo root using the template below. Keep it short — 6–10 lines.
2. Tell Dariy in plain language what you saved and what's next.
3. Stop. Don't start new work after writing halt.md.

## Template

```markdown
# HALT — <date>

**Working on:** Issue #<n> — <short title>
**Branch:** <branch name>
**Status:** tests <green / red — which>, PR <none / #n open / merged>

**Where we are:** <1–2 sentences: what's done, what's half-done>

**Next step (start here):** <the single next thing to do>

**Watch out for:** <anything fragile, any open question, anything Dariy still needs to test>
```

## Why it matters

Sessions start fresh with no memory of last time. Two minutes writing `halt.md` saves ten minutes
of "wait, where were we?" — and means Dariy never loses momentum between sessions.

> Tip: if tests are **red**, say so loudly in the Status line. Never leave a halt that hides a red build.

## When you come back

The session-start hook shows the halt. Read it, **verify what it claims is still true** (check the
branch, run the tests), continue from "Next step", then delete `halt.md` once you've resumed.

See also: `github-issue-flow`, `green-gate-tests`, `retro`.
