---
name: compound
description: >
  Knowledge compounding skill — transforms session learnings into persistent,
  discoverable documentation. Use after any session where a bug was solved,
  a non-obvious pattern was discovered, or an architectural decision was made.
  Trigger: /compound
relationships:
  - target: create-wiki
    type: complements
    label: "docs/solutions/ enriches wiki"
---

# Compound — Knowledge Compounding

Transforms session learnings into `docs/solutions/` — persistent documentation
that future agents and developers can discover and reuse.

**Announce at start:** "Compounding knowledge from this session..."

## When to Use

Run `/compound` after any session where:
- A bug was solved with a non-trivial root cause
- A non-obvious pattern or API behavior was discovered
- An architectural decision was made with considered alternatives

Do NOT run after every session. Only compound when something is genuinely worth
preserving for future sessions.

## Workflow

### Step 1: Gather context

```bash
git diff HEAD~1..HEAD
```

Read the output alongside the current session transcript. This is your primary
input for all analysis steps below.

---

### Step 2: Context Analysis

Classify the session by asking yourself:

- **bug** track: Was there a runtime error, test failure, or unexpected behavior that was diagnosed and fixed?
- **knowledge** track: Was a non-obvious pattern, API behavior, or "how-to" discovered?
- **decision** track: Was an architectural choice made where multiple options were considered?

Produce internally:
- `problem_types`: applicable track(s) — bug, knowledge, decision
- `module`: primary module touched (e.g. `kb/embedding`, `streaming`, `auth`)
- `tags`: 3-6 kebab-case tags (e.g. `voyage, rate-limit, chunking`)
- `category`: freeform slug for `docs/solutions/` subfolder (e.g. `kb`, `streaming`)
- `slug`: 2-5 word kebab-case filename (e.g. `voyage-rate-limit-chunking`)

---

### Step 3: Solution & Pattern Extraction

For the **bug track** — extract (leave `[none]` if not applicable):
- **Problem**: what symptom/error was observed
- **Root Cause**: why it happened
- **Fix**: what resolved it (step-by-step if multi-step)
- **Code Example**: minimal illustrative snippet
- **Prevention**: how to avoid in future

For the **knowledge track** — extract (leave `[none]` if not applicable):
- **Pattern**: name and description of the insight
- **How to Use**: concrete usage instructions
- **Code Example**: illustrative snippet
- **Gotchas**: non-obvious pitfalls

---

### Step 4: Decision Extraction

For the **decision track** — extract (leave `[none]` if no architectural decision was made):

A decision qualifies if: a deliberate choice was made between ≥2 alternatives with a clear rationale.

- **Context**: what problem prompted the decision
- **Options Considered**: list each option with brief trade-off
- **Decision & Rationale**: what was chosen and why (be specific)
- **Consequences**: what this enables or constrains going forward

If multiple decisions were made, extract each separately.

---

### Step 5: Related Docs Check

```bash
find docs/solutions/ -name "*.md" 2>/dev/null
```

For each file found, read its YAML frontmatter (`module`, `tags`). Compare
against this session's `module` and `tags`. Assess overlap:

- **High**: same module AND ≥2 matching tags → same problem described again
- **Moderate**: same category OR ≥1 matching tag → related, different angle
- **Low/none**: no match → independent topic

---

### Step 6: Determine tracks to emit

**Track emission rule** — emit a track only if ALL its required sections are non-empty and not `[none]`:

| Track | Required sections |
|---|---|
| **bug** | Problem, Root Cause, Fix |
| **knowledge** | Pattern, How to Use |
| **decision** | Context, Options Considered, Decision & Rationale |

Skip any track where a required section is `[none]` or empty.

---

### Step 7: Determine output paths

For each track to emit:

1. **Base path**: `docs/solutions/[category]/[slug].md`
2. **Collision handling**:
   - File exists AND overlap is **High** → update existing file
   - File exists AND overlap is **Moderate/Low** → use `[slug]-2.md` (then `-3`, etc.)
   - File does not exist → use `[slug].md`

---

### Step 8: Write output files

Create the category directory if needed. Write one file per emitted track.

**Bug track:**
```markdown
---
problem_type: bug
module: [module]
tags: [tags]
---
## Problem
[content]

## Root Cause
[content]

## Fix
[content]

## Code Example
[content — omit section if [none]]

## Prevention
[content — omit section if [none]]

## Related
[paths from Related Docs Check — omit section if empty]
```

**Knowledge track:**
```markdown
---
problem_type: knowledge
module: [module]
tags: [tags]
---
## Pattern
[content]

## How to Use
[content]

## Code Example
[content — omit section if [none]]

## Gotchas
[content — omit section if [none]]

## Related
[paths from Related Docs Check — omit section if empty]
```

**Decision track:**
```markdown
---
problem_type: decision
module: [module]
tags: [tags]
---
## Context
[content]

## Options Considered
[content]

## Decision & Rationale
[content]

## Consequences
[content — omit section if [none]]

## Related
[paths from Related Docs Check — omit section if empty]
```

If multiple decisions were extracted, write a separate file per decision:
`[slug]-decision-1.md`, `[slug]-decision-2.md`, etc.

---

### Step 9: Discoverability check

Search for `docs/solutions` in `CLAUDE.md` and `.cursor/rules/`. If NOT found,
propose this exact addition:

> The knowledge base at `docs/solutions/` is not yet referenced in CLAUDE.md.
> Add this section so future agents discover it automatically?
>
> ```markdown
> ## Knowledge Base
> Solved problems, patterns, and architectural decisions: `docs/solutions/`
> ```
>
> Add to CLAUDE.md? (yes/no)

**Do not auto-write.** Wait for developer approval.

---

### Step 10: Print completion report

```
★ Compounded
  → docs/solutions/[category]/[slug].md         [bug]
  → docs/solutions/[category]/[slug].md         [decision]
  CLAUDE.md surfaces docs/solutions/ ✓
```

If nothing to compound:
```
★ Nothing to compound — no complete bug fix, pattern, or decision found in this session.
```

---

## Key Constraints

- **Never auto-write** to CLAUDE.md — always propose and ask
- **Never run automatically** — only on explicit `/compound` trigger
- Track emission is **conservative** — skip tracks with any empty required section
- One doc per track per session (except multiple decisions)
