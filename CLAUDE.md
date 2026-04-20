# cursor-skills

A library of AI skills for Cursor IDE and Claude Code. Each skill is a `SKILL.md` file that instructs the agent how to perform a specific task with structured, repeatable output.

---

## Repository layout

```
skills/          One directory per skill. Each contains SKILL.md and optional references/.
eval/            Evaluation harness. One scenario per skill under eval/scenarios/.
docs/            Persistent markdown outputs (SKILL_GRAPH.md, solutions/).
.docs/           Persistent HTML outputs (skill-dashboard.html, index.html).
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

## Skills

| Skill | Trigger | Reads | Writes |
|-------|---------|-------|--------|
| `exploring` | `/exploring` | codebase (grep scout) | `specs/YYYY-MM-DD/<feature>/context.md` |
| `walkthrough` | `/walkthrough` | git diff | — (conversational) |
| `review-diff` | `/review-diff` | git diff | `.review/review.md` |
| `incremental-implementation` | natural language | `docs/plans/` | `progress.md`, implementation files |
| `preflight` | `/preflight` | codebase, docs | research brief (chat) |
| `create-wiki` | `/create-wiki` | codebase | `.docs/index.html` |
| `compound` | `/compound` | session transcript, git diff | `docs/solutions/**/*.md` |
| `visual` | `/visual` | `skills/**/SKILL.md` | `docs/SKILL_GRAPH.md`, `.docs/skill-dashboard.html`, `.docs/skill-graph.html` |

### Workflow relationships

```
exploring ───────────────────────────────────────────> brainstorming (specs/context.md)
preflight ──────────────────────────────────────────> compound
walkthrough ─────────────────────────────────────┐
review-diff ─────────────────────────────────────+──> compound ──> docs/solutions/
incremental-implementation ──────────────────────┘
create-wiki ─────────────────────────────────────────> compound

walkthrough <──[alternative]──> review-diff
compound    <──[complements]──> create-wiki
```

Entry points (no incoming leads-to): `exploring`, `preflight`, `walkthrough`, `review-diff`, `create-wiki`, `incremental-implementation`, `visual`  
Terminal node (knowledge sink): `compound`

---

## Output directories

| Path | Created by | Purpose |
|------|------------|---------|
| `specs/YYYY-MM-DD/<feature>/context.md` | `exploring` | Locked decisions and feature boundary before design |
| `.review/review.md` | `review-diff` | Markdown diff review with architecture diagrams |
| `progress.md` | `incremental-implementation` | Live implementation progress log |
| `.docs/index.html` | `create-wiki` | Single-page project wiki |
| `.docs/skill-dashboard.html` | `visual` | Three-tab skill dashboard |
| `.docs/skill-graph.html` | `visual` | Standalone Cytoscape graph |
| `docs/SKILL_GRAPH.md` | `visual` | Mermaid overview + workflow chains + skill index |
| `docs/solutions/` | `compound` | Persistent bug fixes, patterns, decisions |

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

## Adding a new skill

1. Create `skills/<name>/SKILL.md` with the required frontmatter fields.
2. Add `relationships` entries in this skill and in any related skills pointing back.
3. Add `references/` materials if the skill requires template files.
4. Create `eval/scenarios/<name>/` with `setup.sh`, `validate.sh`, and `checklist.md`.
5. Update the skills table in `README.md`.

The `/visual` skill will automatically pick up the new skill and its relationships on next run.

---

## Skill graph

Relationship map: `docs/SKILL_GRAPH.md`  
Interactive dashboard: `.docs/skill-dashboard.html`  
Regenerate: run `/visual` in any project that has the skill installed.
