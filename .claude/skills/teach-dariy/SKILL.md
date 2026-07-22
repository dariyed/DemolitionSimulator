---
name: teach-dariy
description: How to work with Dariy on this project — explain every line of code, step by step, in detail, not just a one-line summary. Keep changes small and reviewable, celebrate green tests and good play-tests, and ask clearly for human-only steps. Use at the start of every session, whenever writing or changing code, introducing a new concept, handing off a build, or asking him to do something.
---

# Working with Dariy — detailed, step-by-step, every line explained

Dariy owns the repo and does the manual play-testing. For this project he has explicitly asked
for **detailed, step-by-step explanations with every line of code explained** — this is a
stronger bar than "explain the gist." Treat it as a hard requirement, not a nice-to-have.

## What "every line explained" means in practice

When you write or change code, walk through it the way you'd narrate a code review line by
line:

1. **Before the code:** one or two sentences on *why this piece exists* and what problem it
   solves (e.g. "we need a load path graph so removing one column can tell us which beams and
   walls just lost their support, instead of guessing").
2. **During/after the code:** go through the non-trivial lines or blocks in order and explain
   what each one does and why it's written that way — not just restating syntax
   ("this local variable stores X"), but the reasoning ("we check `role == "Column"` first
   because columns are the only elements that carry vertical load in this model").
3. **Call out anything Roblox-specific** a newcomer wouldn't know cold — constraints, network
   ownership, `RunService` events, attribute usage — with a one-line "what this Roblox concept
   does."
4. **Connect back to the structural model** whenever code touches it: say plainly which part of
   real building physics it's approximating (load path, tributary area, factor of safety) and
   what simplification was made and why.

## Still keep changes small and reviewable

One issue = one feature = one PR. Small diffs he can actually follow line by line. If a change
is getting big, split it and say so — a wall of unexplained code defeats the purpose even if
each line technically gets a comment.

## Celebrate the wins — concretely

Green tests and a believable collapse are real milestones. Name them: "CI is green ✅ — the
load path math is locked in, nothing can quietly break it now."

## Ask clearly for human-only steps

When you need something only a human can do — test in Studio, judge whether a collapse *looks*
structurally right — say so explicitly and tell him exactly what to look for:

> "Tests are green and I smoke-tested in Studio. Please play-test: place a charge on the
> ground-floor column and detonate — does the floor above sag and drop before the walls above
> it fall, or does the whole building just vanish at once? Tell me if it looks like an
> explosion effect instead of a structural failure."

His answer becomes an issue comment → a fix → a regression test.

## When you're unsure, ask one clear question

Don't guess on ambiguity. One specific question beats a wrong build he then has to debug.
Roblox API unsure? Check the docs first (`roblox-api-check`) rather than guessing at him.

## Everything in English

Code, comments, docs, issues, commits — all English.

See also: `github-issue-flow`, `green-gate-tests`, `studio-mcp-playtest`, `structural-integrity-system`.
