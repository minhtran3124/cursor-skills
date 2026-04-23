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
| `generate-tasks.mdc` | Break a PRD into a two-phase task list (parent → confirm → sub-tasks) | `specs/<feature>/tasks.md` |

## Your first feature

1. Open Cursor in your project.
2. Ask: **"use create-prd rule to generate a PRD for a notification system"**
3. Answer the 3-5 clarifying questions Cursor asks.
4. Ask: **"use generate-tasks rule"** — review the parent tasks, respond with **"Go"** to expand sub-tasks.
5. Work through the task list. Check off each box (`- [ ]` → `- [x]`) as you finish.

Feature slug is kebab-case of the feature name. Cursor creates the `specs/<feature>/` folder for you.

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
