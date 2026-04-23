# cursor-skills

AI workflow rules for [Cursor IDE](https://cursor.com) — primary product — plus optional skills for Claude Code, Codex, and other compatible agents. Rules are `.mdc` files Cursor loads natively; skills are `SKILL.md` files that serve as conversational on-ramps and specialized tools. Together they chain through per-feature artifacts in `specs/<feature>/`.

---

## Repository layout

```
rules/           Cursor IDE rules (.mdc). Primary product.
skills/          Optional Claude Code / cross-tool skills. One directory per skill.
eval/            Evaluation harness. One scenario per skill under eval/scenarios/.
docs/            Generated outputs: wiki.html, skill-dashboard.html, skill-graph.html,
                 SKILL_GRAPH.md, solutions/. All gitignored.
specs/           Feature folders. One directory per feature with context.md, prd.md,
                 tasks.md, progress.md, review.md. Gitignored.
```

---

## Skill schema

Every `SKILL.md` opens with YAML frontmatter:

```yaml
---
name: <kebab-case id>
description: >
  When to trigger this skill and what it does.
  The AI uses this to decide whether to activate the skill.
allowed-tools: Bash(git *), Read, Glob, Grep, Write, Edit
relationships:
  - target: <other-skill-id>
    type: leads-to | alternative | complements | feeds-from | analyzes
    label: "short phrase shown on graph edge"
---
```

**Required fields:** `name`, `description`  
**Optional but expected:** `allowed-tools`, `relationships`

### Relationship types

| Type | Meaning |
|------|---------|
| `leads-to` | Recommended next step after this skill |
| `alternative` | Different approach to the same job |
| `complements` | Different purpose, works well alongside |
| `feeds-from` | This skill consumes output of the target |
| `analyzes` | This skill reads and processes target's files |

---

## Primary product: Cursor rules

The repository targets **Cursor IDE users first**. Rules in `rules/*.mdc` are the primary product — Cursor loads them natively and they chain through feature artifacts in `specs/<feature>/`.

| Rule | Trigger | Reads | Writes |
|------|---------|-------|--------|
| `behavior.mdc` | always-on (`alwaysApply: true`) | — | — (governs coding behavior) |
| `create-prd.mdc` | `@create-prd` or agent-routed | `specs/<feature>/context.md` (optional) | `specs/<feature>/prd.md` |
| `generate-tasks.mdc` | `@generate-tasks` or agent-routed | `specs/<feature>/prd.md` or `context.md` | `specs/<feature>/tasks.md`, seeds `specs/<feature>/progress.md` |
| `pause.mdc` | `@pause`, "stop here", "save my place" | `specs/<feature>/tasks.md`, `progress.md` | updates Position block in `specs/<feature>/progress.md` |
| `resume.mdc` | `@resume`, "where was I", "continue" | `specs/<feature>/progress.md` | — (read-only) |

## Optional: Claude Code skills

Skills in `skills/*/SKILL.md` are optional conversational on-ramps. They work in Claude Code, Codex, and any compatible agent — and their outputs feed the rules track.

| Skill | Trigger | Reads | Writes |
|-------|---------|-------|--------|
| `introduce` | `/introduce` | `README.md`, `CLAUDE.md` | `docs/INTRODUCE.md`, `docs/workflow.gif` |
| `exploring` | `/exploring` | codebase (grep scout) | `specs/<feature>/context.md` |
| `walkthrough` | `/walkthrough` | git diff | — (conversational) |
| `review-diff` | `/review-diff` | git diff | `specs/<feature>/review.md` |
| `incremental-implementation` | natural language | plan file, `specs/<feature>/` | `specs/<feature>/progress.md`, code |
| `preflight` | `/preflight` | codebase, docs | research brief (chat) |
| `create-wiki` | `/create-wiki` | codebase | `docs/wiki.html` |
| `compound` | `/compound` | session transcript, git diff | `docs/solutions/**/*.md` |
| `visual` | `/visual` | `skills/**/SKILL.md` | `docs/SKILL_GRAPH.md`, `docs/skill-dashboard.html`, `docs/skill-graph.html` |

### Workflow

```
(optional on-ramp)                   PRIMARY (Cursor-native)                (implementation + review)
─────────────────                    ──────────────────────                 ─────────────────────────
exploring  ─────────▶  create-prd  ─────▶  generate-tasks  ─────▶  incremental-implementation
context.md             prd.md               tasks.md                 progress.md
                                                                     review-diff → review.md

cross-cutting (any phase):
  @pause  ──▶ writes Position block to specs/<feature>/progress.md
  @resume ──▶ reads Position block, routes back into the workflow

all files for one feature live in: specs/<feature>/

project-level outputs (not feature-scoped):
  docs/solutions/**         ← compound (knowledge base)
  docs/wiki.html            ← create-wiki
  docs/skill-dashboard.html ← visual
  docs/skill-graph.html     ← visual
  docs/SKILL_GRAPH.md       ← visual
  docs/INTRODUCE.md         ← introduce (onboarding tour)
```

Entry points: `introduce`, `exploring`, `preflight`, `walkthrough`, `create-wiki`, `visual`, `create-prd` (Cursor)  
Re-entry point (after a break): `resume`  
Terminal node (knowledge sink): `compound`

---

## Output directories

**One rule: every feature is a folder under `specs/`. Everything feature-scoped lives inside it.**

| Path | Created by | Purpose |
|------|------------|---------|
| `specs/<feature>/context.md` | `exploring` | Locked decisions and feature boundary before design |
| `specs/<feature>/prd.md` | `create-prd` | Product requirements document |
| `specs/<feature>/tasks.md` | `generate-tasks` | Two-phase implementation task list |
| `specs/<feature>/progress.md` | `incremental-implementation` | Live implementation progress log |
| `specs/<feature>/review.md` | `review-diff` | Markdown diff review with architecture diagrams |
| `docs/INTRODUCE.md` | `introduce` | New-developer onboarding tour with embedded workflow GIF |
| `docs/workflow.gif` | `introduce` | Animated loop of the rule chain (copied from skill's `references/`) |
| `docs/wiki.html` | `create-wiki` | Single-page project wiki |
| `docs/skill-dashboard.html` | `visual` | Three-tab skill dashboard |
| `docs/skill-graph.html` | `visual` | Standalone Cytoscape graph |
| `docs/SKILL_GRAPH.md` | `visual` | Mermaid overview + workflow chains + skill index |
| `docs/solutions/` | `compound` | Persistent bug fixes, patterns, decisions |

Feature slug: kebab-case derived from the feature name (e.g. "Add notifications" → `notifications`).

---

## Eval harness

```
eval/
├── run-eval.sh              Entry point: bash eval/run-eval.sh <skill> [validate]
├── fixture-app/             Shared test codebase (Flask task API) used by all scenarios
└── scenarios/
    └── <skill>/
        ├── setup.sh         Prepares eval/sandbox/ for the scenario
        ├── validate.sh      Automated structural checks on skill output
        └── checklist.md     Manual quality review criteria
```

**Coverage:** `walkthrough`, `review-diff`, `create-wiki`, `incremental-implementation`  
**Missing scenarios:** `compound`, `preflight`, `visual`

Running a scenario:
```bash
bash eval/run-eval.sh review-diff          # set up sandbox
# open eval/sandbox/ in Cursor, run /review-diff
bash eval/run-eval.sh review-diff validate # check output
```

---

## Adding a new rule (primary)

1. Create `rules/<name>.mdc` with `description` and `alwaysApply` frontmatter.
2. Write a strong `description` — Cursor's Agent Requested routing matches on it, so list likely user phrases when relevant.
3. If the rule writes a new artifact, put it under `specs/<feature>/` (feature-scoped) or `docs/` (project-scoped) — do not invent new root-level directories.
4. If the rule updates `progress.md`, it must also update the Position block — not just append to Chunks/Log.
5. Update the rules table in this file and in `README.md`.

## Adding a new skill (optional)

1. Create `skills/<name>/SKILL.md` with the required frontmatter fields.
2. Add `relationships` entries in this skill and in any related skills pointing back.
3. Add `references/` materials if the skill requires template files.
4. Create `eval/scenarios/<name>/` with `setup.sh`, `validate.sh`, and `checklist.md`.
5. Update the skills table in this file and in `README.md`.

The `/visual` skill will automatically pick up the new skill and its relationships on next run.

---

## Skill graph

Relationship map: `docs/SKILL_GRAPH.md`  
Interactive dashboard: `docs/skill-dashboard.html`  
Standalone graph: `docs/skill-graph.html`  
Regenerate: run `/visual` in any project that has the skill installed.
