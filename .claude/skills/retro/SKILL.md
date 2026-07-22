---
name: retro
description: A quick look-back after finishing a piece of work — what went well, what was hard, and one thing learned — then celebrate the win. Use after merging a PR, closing an issue, or wrapping a good session. Appends to docs/retro-log.md.
---

# /retro — look back, learn, celebrate

After finishing something real (an issue closed, a PR merged, a collapse that finally *looks*
structurally believable), take two minutes to capture what you learned. This is how the project
gets smarter over time instead of relearning the same lessons.

## Do this

1. Append an entry to **`docs/retro-log.md`** using the template below (create the file if it's missing).
2. If something you learned is reusable, say: *"this could be a new skill"* and offer to add one to
   `.claude/skills/`.
3. **Celebrate the win out loud** with Dariy — name what he accomplished. Green tests and a
   building that collapses the *right* way are real milestones; don't be flat about them.

## Template (append to docs/retro-log.md)

```markdown
## <date> — Issue #<n>: <short title>

- ✅ **Went well:** <what worked — a clean test, a good design choice, a bug caught early>
- ⚠️ **Was hard / would do differently:** <what slowed us down, what we'd change>
- 💡 **Learned:** <one concrete thing — a Roblox API quirk, a structural-math insight, a workflow tweak>
- 🎉 **Win:** <the thing Dariy can be proud of>
```

## Keep it short and honest

4–6 lines. Real wins *and* real stumbles — a retro that only lists wins teaches nothing. If a
collapse looked wrong and we fixed the load path graph, that's a great retro entry (and
probably a regression test too).

## Why it matters

Noticing *how* the structural simulation got more accurate is half the fun and all of the
learning. Future-you (and future-Claude) read this log and skip the mistakes.

See also: `halt`, `green-gate-tests`, `teach-dariy`.
