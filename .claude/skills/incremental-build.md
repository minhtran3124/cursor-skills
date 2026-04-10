---
name: incremental-build
description: Break a plan into small chunks and implement them one at a time with progress tracking. Use when implementing any plan, spec, or design doc step by step.
---

# Incremental Build

Implement a plan by breaking it into small, verifiable chunks. Work through each one sequentially, logging progress after every chunk.

## Step 1: Read the Plan

Read the full plan before doing anything. Identify:
- Major components, modules, or layers to build
- Dependencies between them (what must exist before what)
- Natural seams — places where something visibly works after a chunk is done

## Step 2: Propose Chunk Breakdown

Before writing code, propose how to slice the work:

```
Proposed chunks:

[1] Storage layer — JSON file read/write, data model
[2] Core logic — main business operations
[3] API routes — endpoint handlers, validation
[4] Tests — unit and integration tests

Chunk 3 depends on 1 and 2. Chunk 4 depends on all.
```

Wait for confirmation before starting.

## Step 3: Initialize progress.md

Create `progress.md` in the project root:

```markdown
# Implementation Progress

## Plan Overview
[1-3 sentence summary]

## Chunks
- [ ] [1] Chunk name — brief description
- [ ] [2] Chunk name — brief description
...

---
```

## Step 4: Implement Each Chunk

For each chunk, follow this sequence:

**4a. Brief** — In 2-4 sentences: what you're about to build, which files you'll create or modify, what this chunk connects to.

**4b. Implement** — Write the code. Stay focused on what the chunk describes. Don't clean up adjacent code or add features not in the plan.

**4c. Log to progress.md** — After implementing, append:

```markdown
---

## Chunk [N]: [Name]

**Status:** ✅ Complete
**Files changed:** `path/to/file.py` (created), `path/to/other.py` (modified)

### What changed
[2-4 sentences: what was built, what problem it solves, how it connects to other chunks]
```

## Step 5: Wrap Up

After all chunks are done, finalize progress.md:

```markdown
---

## Final System Overview

### Summary
[3-5 bullets: what was built, how pieces connect, what to do next]
```

## Chunking Rules

A good chunk:
- Covers a single layer or abstraction
- Produces something observable after it's done
- Touches 1-4 files

Too big if:
- Needs "and also" more than twice
- Creates more than 5 files at once

Too small if:
- It's a single type definition
- Produces nothing observable on its own

## Handling Surprises

If you discover something unexpected — a missing dependency, a design conflict — pause and surface it. Explain what you found and why it matters before continuing.
