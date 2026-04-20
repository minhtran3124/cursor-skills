# Cursor Skills

A collection of custom AI skills for [Cursor IDE](https://cursor.com) and [Claude Code](https://claude.ai/code). These skills teach the AI agent how to perform specific tasks with consistent, structured output.

> **New to AI skills?** Think of them as instruction files you drop into your project — each skill tells the AI exactly how to do a specific job well.

## Skills

| Skill | Trigger | What it does |
|-------|---------|-------------|
| `walkthrough` | `/walkthrough` | Walks you through git changes file-by-file, like a senior engineer explaining a PR |
| `review-diff` | `/review-diff` | Generates a Markdown review with C4 architecture diagrams and code walkthrough |
| `incremental-implementation` | describe a plan | Builds features step-by-step, verifying each chunk before moving on |
| `preflight` | `/preflight` | Research-first check before building — maps the repo, finds reusable code, recommends the lightest path |
| `create-wiki` | `/create-wiki` | Generates a single-page HTML wiki documenting your entire project |
| `compound` | `/compound` | Transforms session learnings into persistent `docs/solutions/` docs — bugs, patterns, decisions |
| `visual` | `/visual` | Generates a skill dashboard with cards, interactive graph, and workflow chains |

## Quick Start

**Step 1 — Clone this repo**

```bash
git clone <this-repo-url>
```

**Step 2 — Copy skills into your project**

```bash
mkdir -p your-project/.cursor/skills
cp -r skills/walkthrough your-project/.cursor/skills/
```

**Step 3 — Use in Cursor or Claude Code**

```
/walkthrough          → explain git changes on current branch
/review-diff          → generate a visual review of uncommitted changes
/preflight            → research-first check before building a feature
/create-wiki          → generate project documentation
/compound             → save session learnings to docs/solutions/
/visual               → generate skill relationship graph and dashboard
```

For `incremental-implementation`, describe a plan and ask the AI to "implement this step by step".

## How It Works

```
YOUR PROJECT
  .cursor/skills/
  ├── walkthrough/SKILL.md    ← skill instructions
  ├── review-diff/SKILL.md
  └── ...
         |
         v
  Cursor / Claude Code reads SKILL.md on trigger
         |
         v
  AI follows the steps and produces structured output
```

## Example: Using `/walkthrough`

```
You                                    AI
 |                                      |
 |  1. Make changes or switch branch    |
 |                                      |
 |  2. Type: /walkthrough               |
 |  ----------------------------------> |
 |                                      |
 |         3. Lists all changed files   |
 |  <---------------------------------- |
 |                                      |
 |         4. Explains file #1          |
 |            (before / after / why)    |
 |  <---------------------------------- |
 |                                      |
 |  5. "next" or ask a question         |
 |  ----------------------------------> |
 |                                      |
 |         6. Explains file #2 ...      |
 |  <---------------------------------- |
 |                                      |
 |         7. Summary of all changes    |
 |  <---------------------------------- |
```

## The `/visual` Skill — Skill Dashboard

`/visual` maps every skill in your project into a relationship graph and generates browser files you can open directly:

| Output | What it shows |
|--------|--------------|
| `.docs/skill-dashboard.html` | Three-tab dashboard: skill cards, interactive graph, workflow chains |
| `.docs/skill-graph.html` | Standalone interactive graph |
| `docs/SKILL_GRAPH.md` | Mermaid diagrams and skill index table |

**Skills tab** — a card for every skill with its trigger, description, reads/writes, and outgoing relationships. Click any card to open a full detail view: complete description, how-to-use guide, I/O breakdown, and all relationships with direction and context.

**Graph tab** — interactive force-directed graph (Cytoscape.js). Hover a node to dim unconnected skills and reveal edge type labels on its connections. Hover an edge for the full relationship detail. Toggle explicit vs. inferred edges with the filter buttons.

**Workflows tab** — auto-derived workflow chains, alternative pairs, and complements rendered as visual step sequences.

Relationships between skills are declared in each `SKILL.md` frontmatter:

```yaml
relationships:
  - target: compound
    type: leads-to
    label: "save session learnings"
  - target: review-diff
    type: alternative
    label: "formal written review"
```

When no explicit metadata is present, `/visual` infers relationships from skill content and marks them as dashed edges.

## Example: Using `/create-wiki`

1. Open your project in Cursor
2. Open AI chat and type: `/create-wiki`
3. AI explores your codebase automatically
4. Generates `.docs/index.html`
5. Open that file in a browser

## Adding a Skill to All Projects

Copy it to the global Cursor skills directory:

```bash
mkdir -p ~/.cursor/skills
cp -r skills/walkthrough ~/.cursor/skills/
```

## Repository Structure

```
skills/
├── walkthrough/                  # Git change explainer
│   └── SKILL.md
├── review-diff/                  # Visual diff reviewer
│   └── SKILL.md
├── incremental-implementation/   # Step-by-step builder
│   └── SKILL.md
├── preflight/                    # Research-first feature check
│   ├── SKILL.md
│   └── references/
│       ├── research-brief-template.md
│       └── pressure-scenarios.md
├── create-wiki/                  # Project wiki generator
│   ├── SKILL.md
│   └── references/
│       └── template.html
├── compound/                     # Knowledge compounding
│   └── SKILL.md
└── visual/                       # Skill graph visualizer
    ├── SKILL.md
    └── references/
        ├── dashboard-template.html  # Three-tab dashboard
        └── graph-template.html      # Standalone graph

eval/                             # Skill evaluation framework
├── run-eval.sh                   # Entry point
├── fixture-app/                  # Test codebase (Flask task API)
└── scenarios/                    # One per skill (setup + validate + checklist)
```

> Each skill is a `SKILL.md` file — no install, no config, just copy and go.

## Evaluating Skills

```bash
# 1. Set up a test scenario
bash eval/run-eval.sh review-diff

# 2. Open eval/sandbox/ in Cursor and run the skill

# 3. Validate the output
bash eval/run-eval.sh review-diff validate
```

Available scenarios: `review-diff`, `walkthrough`, `create-wiki`, `incremental-implementation`

See [eval/README.md](eval/README.md) for the full guide.

Have an idea for a new skill? Feel free to contribute.
