---
name: code-review
description: Review code changes and generate a structured review document with architecture diagrams and actionable feedback. Use when reviewing PRs, diffs, or any code changes.
---

# Code Review

Review code changes like a senior engineer. Produce a structured review document with architecture diagrams at `.review/review.md`.

## Step 1: Gather Changes

- Run `git diff HEAD` and `git diff --stat HEAD` to see what changed
- If changes are committed, use `git log --oneline -10` and `git diff <base>..HEAD`
- Read the changed files and their surrounding architecture (imports, callers, class hierarchy)
- Read `progress.md` if it exists — understand what was built and why

## Step 2: Generate .review/review.md

Create `.review/` directory if needed. Generate `.review/review.md` with three sections:

### Section 1: System Architecture (C4 Container Level)

A Mermaid flowchart showing system architecture with changed components highlighted:

- Use `flowchart TD` (top-down)
- Show request flow from user through frontend to backend
- Highlight changed components: `fill:#0d3320,stroke:#238636,stroke-width:3px,color:#aff0b5`
- Highlight new components with green circle prefix: `fill:#0d3320,stroke:#238636,stroke-width:3px,color:#aff0b5`
- Highlight data sources: `fill:#0d2044,stroke:#388bfd,stroke-width:2px,color:#79c0ff`
- Include a legend

Always add dark theme init:
```
%%{init: {'theme': 'dark', 'flowchart': {'useMaxWidth': true}} }%%
```

### Section 2: Component Detail Flowchart

Mermaid flowchart of internal logic flow:

- Show decision tree / branching logic
- New paths: dark green with green circle prefix
- Removed paths: dark red dashed with red circle prefix `fill:#3d0f14,stroke:#da3633,stroke-width:2px,stroke-dasharray:5 5,color:#ffa198`
- Unchanged paths: dark grey `fill:#1c1c1c,stroke:#555,color:#aaa`
- Add description table below

### Section 3: Code Walkthrough

For each logical chunk of changes:
- A narrative paragraph explaining what the code does and why
- An inline diff block using ` ```diff ` syntax

## Diagram Rules

- Keep node labels SHORT (under 25 characters)
- Use description table below diagrams for details
- No `\n` in labels — single-line text only
- Use `·` or `‹›` as separators if needed

## Step 3: Evaluate Quality

After generating the review document, evaluate the code:

**Correctness**
- Does the code do what the plan says?
- Are edge cases handled?
- Are there obvious bugs?

**Design**
- Is the code organized logically?
- Are abstractions appropriate (not over-engineered, not under-designed)?
- Does it integrate well with existing code?

**Tests**
- Are there tests for new functionality?
- Do tests cover meaningful scenarios (not just happy path)?

**Security**
- No hardcoded secrets or credentials
- Input validation at boundaries
- No injection vulnerabilities

## Step 4: Produce Feedback

Categorize each finding:
- **MUST FIX** — blocks approval, must be addressed
- **SUGGESTION** — improvement, won't block approval

Format feedback with file paths, line numbers, and what to fix:

```
Review feedback for [chunk/feature]:

1. [MUST FIX] src/routes/tasks.py:25 — missing input validation on
   the priority field. Negative values will pass through.

2. [SUGGESTION] tests/test_tasks.py — add a test for combining
   search + filter parameters.
```

## Review Principles

- Be specific: reference file paths, line numbers, function names
- Be actionable: say what to fix, not just what's wrong
- Be proportional: don't block on style nits during a feature build
- Acknowledge good work: if something is well-designed, say so
