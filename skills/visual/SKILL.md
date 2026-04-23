---
name: visual
description: >
  Skill graph visualizer — scans all SKILL.md files in skills/, builds a directed
  relationship graph from explicit `relationships` frontmatter (falling back to
  content inference), and generates both a Mermaid markdown summary and an
  interactive HTML graph at docs/skill-graph.html.
  Trigger: /visual
---

# Visual — Skill Graph Visualizer

Maps every skill in the project into a directed graph: what each skill consumes,
what it produces, and how skills chain into workflows. Generates two outputs —
a Mermaid markdown file for documentation and an interactive browser graph for
exploration.

**Announce at start:** "Mapping skill graph..."

## When to Use

Run `/visual` when you want to:
- Understand how all skills fit together at a glance
- Onboard contributors to the skill ecosystem
- Audit the graph after adding or modifying a skill

## Workflow

### Step 1: Scan all skills

```bash
find skills/ -name "SKILL.md" 2>/dev/null | sort
```

Read each SKILL.md file in full.

---

### Step 2: Extract metadata from each skill

For each skill file, extract:

| Field | Source |
|-------|--------|
| `id` | Directory name (e.g. `skills/walkthrough/` → `walkthrough`) |
| `label` | `name` frontmatter, prefixed with its emoji from README if known |
| `description` | `description` frontmatter — first sentence only |
| `triggers` | Content: `/command` patterns found in the text |
| `inputs` | Content: files/sources the skill reads (e.g. `git diff`, `docs/plans/`) |
| `outputs` | Content: files the skill writes (e.g. `specs/<feature>/review.md`) |
| `relationships` | `relationships` frontmatter array — see schema below |

**Relationships frontmatter schema** (explicit, preferred):
```yaml
relationships:
  - target: <skill-id>         # directory name of another skill
    type: <relationship-type>  # one of the types below
    label: <short phrase>      # shown on the graph edge (≤ 5 words)
```

**Relationship types:**

| Type | Meaning | Arrow style |
|------|---------|-------------|
| `leads-to` | Recommended next step after this skill | solid `-->` |
| `alternative` | Different approach to the same job | dashed `-.->` |
| `complements` | Different purpose, works well alongside | solid `-->` |
| `feeds-from` | This skill consumes target's output | solid `-->` |
| `analyzes` | This skill reads and processes target's files | solid `-->` |

---

### Step 3: Infer relationships (fallback only)

For any skill with **no** `relationships` frontmatter, infer from content:

1. **Named trigger references**: Content mentions another skill's `/command` or directory name → `leads-to` edge toward the referenced skill.
2. **Shared I/O**: Two skills read/write the same file path → `complements` edge between them.
3. **Workflow language**: Content contains "after running X", "before using Y", "works well with Z" → create directed edge matching the phrasing.
4. **Knowledge-sink pattern**: A skill that only writes to a knowledge store with no other skill's output as input → other skills that mention preserving learnings `leads-to` it.

Mark all inferred edges: `"inferred": true` in the graph model. These render as dashed lines in both outputs.

---

### Step 4: Build internal graph model

Produce this JSON structure internally (not written to disk):

```json
{
  "skills": [
    {
      "id": "walkthrough",
      "label": "🚶 walkthrough",
      "description": "One sentence.",
      "triggers": ["/walkthrough"],
      "inputs": ["git diff"],
      "outputs": []
    }
  ],
  "edges": [
    {
      "source": "walkthrough",
      "target": "compound",
      "type": "leads-to",
      "label": "save session learnings",
      "inferred": false
    }
  ]
}
```

---

### Step 5: Write docs/SKILL_GRAPH.md

Create `docs/` if it doesn't exist. Write `docs/SKILL_GRAPH.md` with four sections:

**Section 1 — Overview graph**

```markdown
## Skill Overview

\`\`\`mermaid
flowchart LR
    classDef skill fill:#1a1a2e,stroke:#4a90d9,color:#e0e0ff
    classDef terminal fill:#0d2618,stroke:#4a9d6f,color:#a0ffa0

    skill-a["emoji name\n/trigger"]:::skill
    skill-b["emoji name\n/trigger"]:::skill
    ...

    skill-a -->|"label"| skill-b
    skill-c -.->|"label"| skill-d
\`\`\`
```

Rules:
- `leads-to` and `complements` edges: solid `-->`
- `alternative` and inferred edges: dashed `-.->` 
- Node label format: `"emoji name\n/trigger"` (use `\n` for line break)
- Skills with no outbound `leads-to` edges get `:::terminal` class
- Mermaid node IDs must be valid identifiers — replace hyphens with underscores in IDs, keep label as-is

**Section 2 — Workflow chains**

Find all entry-point skills (skills with no incoming `leads-to` edges). For each, trace the full `leads-to` path and write a named workflow:

```markdown
## Workflows

### Code Review Workflow
\`\`\`mermaid
flowchart LR
    walkthrough -->|"save learnings"| compound
\`\`\`

### Implementation Workflow
...
\`\`\`
```

If two paths share the same terminal node, they may be shown in one diagram.

**Section 3 — Data flow**

Show input sources, skills, and output artifacts. Only include skills that have explicit inputs or outputs in their metadata:

```markdown
## Data Flow

\`\`\`mermaid
flowchart LR
    classDef artifact fill:#1a1a1a,stroke:#888,color:#ccc
    classDef ext fill:#2a1a0a,stroke:#d9904a,color:#ffd0a0

    git_diff[/"git diff"/]:::ext
    review_md[/"specs/<feature>/review.md"/]:::artifact

    git_diff --> review_diff
    review_diff --> review_md
\`\`\`
```

**Section 4 — Skill index**

A table: Skill | Trigger | Description | Reads | Writes

---

### Step 6: Generate interactive HTML outputs

Serialize the graph model from Step 4 to a single-line minified JSON string.
Use this JSON string for both outputs below (same data, different templates).

**6a — Skill dashboard** (primary output)

Open `skills/visual/references/dashboard-template.html`.
Replace `/* GRAPH_DATA_JSON */` with the JSON string.
Write to `docs/skill-dashboard.html`.

The dashboard has three tabs:
- **Skills** — card grid with every skill's trigger, description, reads/writes, outgoing relationships
- **Graph** — interactive Cytoscape graph (lazy-initialized on first tab open)
- **Workflows** — auto-derived workflow chains, alternatives, and complements

**6b — Standalone graph** (secondary output)

Open `skills/visual/references/graph-template.html`.
Replace `/* GRAPH_DATA_JSON */` with the same JSON string.
Write to `docs/skill-graph.html`.

If either template file is not found, skip that output and note it in the report.

---

### Step 7: Discoverability check

Search CLAUDE.md for `SKILL_GRAPH`. If not found, propose:

> The skill graph at `docs/SKILL_GRAPH.md` is not yet referenced in CLAUDE.md.  
> Add this block so future agents discover it automatically?
>
> ```markdown
> ## Skill Graph
> Skill relationships and workflows: `docs/SKILL_GRAPH.md`
> Dashboard (skills + graph + workflows): `docs/skill-dashboard.html`
> Standalone graph: `docs/skill-graph.html`
> Wiki: `docs/wiki.html`
> ```
>
> Add to CLAUDE.md? (yes/no)

**Do not auto-write.** Wait for approval before modifying CLAUDE.md.

---

### Step 8: Print completion report

```
★ Skill graph mapped
  Skills:        N
  Relationships: M explicit, K inferred
  → docs/SKILL_GRAPH.md              [Mermaid overview + workflows + data flow + index]
  → docs/skill-dashboard.html       [dashboard: skills cards + graph + workflows]
  → docs/skill-graph.html           [standalone interactive graph]
  CLAUDE.md: surfaced ✓ / not yet referenced
```

---

## Key Constraints

- **Never auto-write** to CLAUDE.md — always ask first
- **Explicit over inferred** — `relationships` frontmatter always wins; inferred edges are dashed in both outputs
- **Idempotent** — re-running `/visual` fully overwrites both output files
- **Non-destructive** — never modifies any SKILL.md file; only writes to `docs/`
- **Mermaid node IDs**: replace `-` with `_` to avoid parse errors (e.g. `review_diff` not `review-diff`)
- **Node label length**: keep `\n`-split lines under 20 characters each for readability
