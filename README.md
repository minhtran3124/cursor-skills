# Cursor Skills

Minimal AI workflow rules for [Cursor IDE](https://cursor.com). Drop them into your project and Cursor will guide you from idea → PRD → task list → implementation.

## Install

Copy the rules into your project:

```bash
mkdir -p your-project/.cursor/rules
cp rules/*.mdc your-project/.cursor/rules/
```

`behavior.mdc` loads automatically on every turn. The other rules activate when you reference them.

## Workflow

```
create-prd  ───▶  generate-tasks  ───▶  implement
  │                   │                     │
  ▼                   ▼                     ▼
specs/<feature>/   specs/<feature>/      specs/<feature>/
   prd.md             tasks.md             progress.md
```

Every feature gets its own folder under `specs/`. Each rule reads the prior file in that folder, so artifacts chain automatically.

## Rules

| Rule | Purpose | Writes |
|------|---------|--------|
| `behavior.mdc` | Always-on coding guidelines (simplicity, surgical changes, goal-driven execution) | — |
| `create-prd.mdc` | Generate a PRD from a feature idea via 3-5 clarifying questions | `specs/<feature>/prd.md` |
| `generate-tasks.mdc` | Break a PRD into a two-phase task list; seeds a progress checkpoint | `specs/<feature>/tasks.md`, `specs/<feature>/progress.md` |
| `pause.mdc` | Save a resumable checkpoint when stopping mid-feature | updates `specs/<feature>/progress.md` |
| `resume.mdc` | Read the checkpoint and continue where you left off | — (read-only) |

## Your first feature

1. Open Cursor in your project.
2. Ask: **`@create-prd generate a PRD for a notification system`**
3. Answer the 3-5 clarifying questions.
4. Ask: **`@generate-tasks`** — review the parent tasks, respond with **`Go`** to expand sub-tasks.
5. Work through the task list, checking off each box (`- [ ]` → `- [x]`) as you finish.

> **Tip:** you can also just describe what you want in plain language (`"generate a PRD for a notification system"`). Cursor matches your intent to the rule's `description` automatically — `@`-mention is the reliable fallback when auto-routing misses.

Feature slug is kebab-case of the feature name. Cursor creates the `specs/<feature>/` folder for you.

## Pause and resume

Closing Cursor mid-task? Ask **`@pause`** — Cursor asks what you were about to do, updates `specs/<feature>/progress.md`, and offers to commit WIP. When you come back, **`@resume`** (or just "where was I") reads the checkpoint and points you at the next action. Position is also auto-updated as you complete chunks during implementation, so even an unexpected crash leaves a usable checkpoint.

## Optional: Claude Code skills

For users who also work in Claude Code (or Codex, Jules, other agents), the `skills/` folder contains conversational entry points — most notably `/exploring`, a Socratic requirements-capture that writes `specs/<feature>/context.md`. When present, `create-prd` reads it and skips questions already answered.

See [CLAUDE.md](CLAUDE.md) for the full skill list and relationship graph.

## Repo layout

```
rules/    Cursor rules (.mdc) — primary product
skills/   Optional Claude Code / cross-tool skills
eval/     Evaluation harness for skills
```

---

Have an idea for a new rule or skill? Contributions welcome.
