---
name: pr-writing
description: Use when writing or updating a pull request description for any repo in this workspace. Produces an English PR text with two clear sections — Background and What this changes — never file lists or implementation detail.
---

# Pull Request description

A pull request description in this workspace is read by future-you and any
other human looking at the git history. Keep it useful for both.

## Language

English. Always.

## Structure

Exactly two sections, nothing else:

### Background
Why is this change being made? Which problem does it solve? Start from the
ticket's `Background` section.

### What this changes
A high-level description of the outcome — what is now possible, fixed, or
improved. Reader-friendly, not a changelog.

## Never include

- File lists or changed-file counts (the diff already shows that)
- Test details or test plans
- Internal code logic or implementation detail
- Class, function, or variable names
- Code snippets
- Any reference to Claude, AI tooling, or how the work was produced

## Example

**Bad** (technical, leaks implementation):

> Adds `scoreForTip()` to `betting-api/src/service/mod.rs` and wires it into
> the `/rating` handler. 4 files changed, 6 new unit tests.

**Good** (focused, useful):

> ## Background
> The ranking endpoint counted exact-score tips and goal-difference tips the
> same way, which made the leaderboard collapse to a tie whenever two users
> got similar predictions.
>
> ## What this changes
> Exact scores now count differently from correct-difference scores, so the
> leaderboard differentiates users who predicted the score precisely from
> those who only got the trend right.

## Before you finish

- Re-read the description: anything technical still in there?
- No class/function names, no file paths, no AI references.
